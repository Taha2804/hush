-- Rounds chosen by the host, turn-based voting, locked votes, early-end requests,
-- invitation lookups and room activity tracking. Safe to re-run.
begin;

-- ---------------------------------------------------------------------------
-- Columns
-- ---------------------------------------------------------------------------
alter table public.rooms add column if not exists total_rounds int not null default 3;
alter table public.rooms add column if not exists current_round int not null default 0;
alter table public.rooms add column if not exists match_id uuid;
alter table public.rooms add column if not exists last_activity_at timestamptz not null default now();
do $$ begin
    alter table public.rooms add constraint rooms_total_rounds_range check (total_rounds between 1 and 10);
exception when duplicate_object then null; end $$;
create index if not exists idx_rooms_status_activity on public.rooms(status, last_activity_at);
create index if not exists idx_room_players_player on public.room_players(player_id);
create index if not exists idx_room_players_seen on public.room_players(room_id, last_seen_at);

alter table public.game_sessions add column if not exists match_id uuid;
alter table public.game_sessions add column if not exists match_round int not null default 1;
alter table public.game_sessions add column if not exists vote_mode text not null default 'simultaneous';
alter table public.game_sessions add column if not exists vote_visibility text not null default 'private';
-- Ids of players who have handed in a ballot this vote. Never the targets.
alter table public.game_sessions add column if not exists voters jsonb not null default '[]'::jsonb;
-- Filled when a vote closes: counts always, who-voted-whom only in public mode.
alter table public.game_sessions add column if not exists last_vote_summary jsonb;
do $$ begin
    alter table public.game_sessions add constraint game_sessions_vote_mode check (vote_mode in ('simultaneous', 'sequential'));
    alter table public.game_sessions add constraint game_sessions_vote_visibility check (vote_visibility in ('private', 'public'));
exception when duplicate_object then null; end $$;
create index if not exists idx_game_sessions_room_created on public.game_sessions(room_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Early discussion end requests
-- ---------------------------------------------------------------------------
create table if not exists public.discussion_end_requests (
    id uuid primary key default gen_random_uuid(),
    session_id uuid not null references public.game_sessions(id) on delete cascade,
    room_id uuid not null references public.rooms(id) on delete cascade,
    requester_id uuid references public.profiles(id) on delete set null,
    requester_name text not null,
    status text not null default 'pending' check (status in ('pending', 'approved', 'rejected', 'expired')),
    approvals int not null default 1,
    eligible int not null,
    created_at timestamptz not null default now(),
    expires_at timestamptz not null,
    resolved_at timestamptz
);
create unique index if not exists idx_end_requests_one_pending
    on public.discussion_end_requests(session_id) where status = 'pending';
create index if not exists idx_end_requests_room_created on public.discussion_end_requests(room_id, created_at);
alter table public.discussion_end_requests enable row level security;
drop policy if exists "Room members can see end requests" on public.discussion_end_requests;
create policy "Room members can see end requests" on public.discussion_end_requests
    for select to authenticated using (public.is_room_member(room_id));

create table if not exists public.discussion_end_votes (
    request_id uuid not null references public.discussion_end_requests(id) on delete cascade,
    player_id uuid not null references public.profiles(id) on delete cascade,
    approve boolean not null,
    created_at timestamptz not null default now(),
    primary key (request_id, player_id)
);
alter table public.discussion_end_votes enable row level security;

do $$ begin
    alter publication supabase_realtime add table public.discussion_end_requests;
exception when duplicate_object then null; end $$;

-- ---------------------------------------------------------------------------
-- Room activity (throttled so chat does not rewrite the room row constantly)
-- ---------------------------------------------------------------------------
create or replace function private.touch_room(p_room_id uuid)
returns void language sql security definer
set search_path = public, pg_temp as $$
    update public.rooms set last_activity_at = now()
    where id = p_room_id and last_activity_at < now() - interval '1 minute';
$$;

create or replace function private.on_activity()
returns trigger language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    perform private.touch_room(new.room_id);
    return null;
end;
$$;

drop trigger if exists trg_activity_messages on public.room_messages;
create trigger trg_activity_messages after insert on public.room_messages
    for each row execute function private.on_activity();
drop trigger if exists trg_activity_sessions on public.game_sessions;
create trigger trg_activity_sessions after insert or update on public.game_sessions
    for each row execute function private.on_activity();
drop trigger if exists trg_activity_players on public.room_players;
create trigger trg_activity_players after insert on public.room_players
    for each row execute function private.on_activity();

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
create or replace function private.alive_count(p_session_id uuid)
returns int language sql stable security definer
set search_path = public, pg_temp as $$
    select count(*)::int from public.game_players where session_id = p_session_id and is_alive;
$$;

-- Next living player in turn order who has not voted yet.
create or replace function private.current_voter(p_session_id uuid)
returns uuid language sql stable security definer
set search_path = public, pg_temp as $$
    select t.pid::uuid
    from public.game_sessions gs,
         jsonb_array_elements_text(gs.turn_order) with ordinality as t(pid, ord)
    where gs.id = p_session_id
      and not (gs.voters ? t.pid)
      and exists (
          select 1 from public.game_players gp
          where gp.session_id = gs.id and gp.player_id = t.pid::uuid and gp.is_alive
      )
    order by t.ord
    limit 1;
$$;

create or replace function private.begin_discussion(p_session_id uuid, p_next_round boolean default false)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_seconds int;
begin
    select least(greatest(coalesce((r.config->>'discussionSeconds')::int, 180), 15), 900) into v_seconds
    from public.game_sessions gs join public.rooms r on r.id = gs.room_id
    where gs.id = p_session_id;

    update public.game_sessions
    set phase = 'discussion',
        round_number = round_number + (case when p_next_round then 1 else 0 end),
        revotes = case when p_next_round then 0 else revotes end,
        voters = '[]'::jsonb,
        discussion_start_time = now(),
        discussion_end_time = now() + make_interval(secs => v_seconds),
        timer_paused = false,
        timer_remaining_seconds = v_seconds,
        updated_at = now()
    where id = p_session_id;
end;
$$;

create or replace function private.begin_vote(p_session_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    update public.discussion_end_requests
    set status = 'expired', resolved_at = now()
    where session_id = p_session_id and status = 'pending';

    update public.game_sessions
    set phase = 'vote', voters = '[]'::jsonb, last_vote_summary = null, updated_at = now()
    where id = p_session_id and phase = 'discussion';
end;
$$;

-- Applies time-based rules: expired end requests and finished discussion timers.
create or replace function private.sync_session(p_session_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_phase text;
    v_end timestamptz;
begin
    update public.discussion_end_requests
    set status = 'expired', resolved_at = now()
    where session_id = p_session_id and status = 'pending' and expires_at <= now();

    select phase, discussion_end_time into v_phase, v_end
    from public.game_sessions where id = p_session_id;
    if v_phase = 'discussion' and v_end is not null and v_end <= now() then
        perform private.begin_vote(p_session_id);
    end if;
end;
$$;

create or replace function private.sweep_room(p_room_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_host uuid;
    v_host_seen timestamptz;
    v_next uuid;
    v_session uuid;
begin
    update public.room_players
    set is_connected = false
    where room_id = p_room_id and is_connected and last_seen_at < now() - interval '45 seconds';

    select r.host_id, rp.last_seen_at into v_host, v_host_seen
    from public.rooms r
    left join public.room_players rp on rp.room_id = r.id and rp.player_id = r.host_id
    where r.id = p_room_id;

    if v_host_seen is null or v_host_seen < now() - interval '60 seconds' then
        select player_id into v_next from public.room_players
        where room_id = p_room_id and is_connected and player_id is distinct from v_host
        order by joined_at asc limit 1;
        if v_next is not null then
            perform private.transfer_host(p_room_id, v_next);
        end if;
    end if;

    select id into v_session from public.game_sessions
    where room_id = p_room_id and phase <> 'result'
    order by created_at desc limit 1;
    if v_session is not null then
        perform private.sync_session(v_session);
    end if;
end;
$$;

-- Points: crew winners 1 each, imposter winners 2 each.
create or replace function private.end_game(p_session_id uuid, p_winner text, p_reason text)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_word text;
    v_imposters jsonb;
    v_scores jsonb;
    v_total int;
begin
    select * into v_session from public.game_sessions where id = p_session_id;

    select secret_word into v_word from public.private_player_assignments
    where session_id = p_session_id and is_imposter = false limit 1;

    select coalesce(jsonb_agg(player_id) filter (where is_imposter), '[]'::jsonb),
           coalesce(jsonb_object_agg(player_id,
               case when p_winner = 'crew' and not is_imposter then 1
                    when p_winner = 'imposters' and is_imposter then 2
                    else 0 end), '{}'::jsonb)
    into v_imposters, v_scores
    from public.private_player_assignments where session_id = p_session_id;

    insert into public.game_results (session_id, winner, win_reason, secret_word, imposters, scores)
    values (p_session_id, p_winner, p_reason, coalesce(v_word, 'Unknown'), v_imposters, v_scores);

    update public.game_sessions
    set phase = 'result', winner = p_winner, win_reason = p_reason, updated_at = now()
    where id = p_session_id;

    select total_rounds into v_total from public.rooms where id = v_session.room_id;
    if v_session.match_round >= v_total then
        update public.rooms set status = 'finished', updated_at = now() where id = v_session.room_id;
        update public.room_players set is_ready = false where room_id = v_session.room_id;
    else
        -- Still mid-match: the host starts the next round.
        update public.rooms set updated_at = now() where id = v_session.room_id;
    end if;
end;
$$;

-- Resolves the current ballot. Shared by the host button and the automatic close.
create or replace function private.tally(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_top uuid;
    v_top_votes int;
    v_second int;
    v_was_imp boolean;
    v_imp int;
    v_crew int;
    v_winner text;
    v_reason text;
    v_summary jsonb;
begin
    select * into v_session from public.game_sessions where id = p_session_id;

    select target_id, n into v_top, v_top_votes from (
        select target_id, count(*)::int n from public.game_votes
        where session_id = p_session_id and round_number = v_session.round_number
          and revote_number = v_session.revotes
        group by target_id order by n desc, target_id limit 1
    ) t;
    if v_top is null then raise exception 'Nobody has voted yet.'; end if;

    select n into v_second from (
        select count(*)::int n from public.game_votes
        where session_id = p_session_id and round_number = v_session.round_number
          and revote_number = v_session.revotes
        group by target_id order by n desc offset 1 limit 1
    ) t;

    select jsonb_build_object(
        'counts', coalesce(jsonb_object_agg(target_id, n), '{}'::jsonb)
    ) into v_summary
    from (
        select target_id, count(*)::int n from public.game_votes
        where session_id = p_session_id and round_number = v_session.round_number
          and revote_number = v_session.revotes
        group by target_id
    ) c;

    if v_session.vote_visibility = 'public' then
        v_summary := v_summary || jsonb_build_object('ballots', (
            select coalesce(jsonb_object_agg(voter_id, target_id), '{}'::jsonb) from public.game_votes
            where session_id = p_session_id and round_number = v_session.round_number
              and revote_number = v_session.revotes
        ));
    end if;

    if v_second = v_top_votes then
        if v_session.revotes = 0 then
            update public.game_sessions
            set revotes = 1, voters = '[]'::jsonb,
                last_vote_summary = v_summary || jsonb_build_object('tie', true),
                updated_at = now()
            where id = p_session_id;
            return jsonb_build_object('tie', true, 'revote_number', 1);
        end if;
        update public.game_sessions set last_vote_summary = v_summary || jsonb_build_object('tie', true)
        where id = p_session_id;
        perform private.end_game(p_session_id, 'imposters', 'tieAfterRevote');
        return jsonb_build_object('phase', 'result', 'winner', 'imposters', 'reason', 'tieAfterRevote');
    end if;

    update public.game_players
    set is_alive = false, is_eliminated = true, eliminated_round = v_session.round_number
    where session_id = p_session_id and player_id = v_top;

    update public.game_sessions
    set last_vote_summary = v_summary || jsonb_build_object('eliminated', v_top)
    where id = p_session_id;

    select is_imposter into v_was_imp from public.private_player_assignments
    where session_id = p_session_id and player_id = v_top;

    select count(*) filter (where ppa.is_imposter), count(*) filter (where not ppa.is_imposter)
    into v_imp, v_crew
    from public.game_players gp
    join public.private_player_assignments ppa
      on ppa.session_id = gp.session_id and ppa.player_id = gp.player_id
    where gp.session_id = p_session_id and gp.is_alive;

    if v_imp = 0 then
        v_winner := 'crew'; v_reason := 'allImpostersCaught';
    elsif v_imp >= v_crew then
        v_winner := 'imposters'; v_reason := 'impostersOutnumber';
    elsif not v_was_imp then
        v_winner := 'imposters'; v_reason := 'wrongPlayerVoted';
    end if;

    if v_winner is not null then
        perform private.end_game(p_session_id, v_winner, v_reason);
        return jsonb_build_object('phase', 'result', 'winner', v_winner, 'reason', v_reason, 'eliminated_id', v_top);
    end if;

    perform private.begin_discussion(p_session_id, true);
    return jsonb_build_object('phase', 'discussion', 'eliminated_id', v_top);
end;
$$;

-- Deals one round: roles, a server-chosen word, and a fresh session.
create or replace function private.create_round(p_room_id uuid)
returns uuid language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_room public.rooms;
    v_order uuid[];
    v_imposters uuid[];
    v_count int;
    v_imposter_count int;
    v_mode text;
    v_seconds int;
    v_category text;
    v_word private.word_bank;
    v_hint text;
    v_fake text;
    v_session uuid;
    v_p record;
    v_is_imp boolean;
begin
    select * into v_room from public.rooms where id = p_room_id;

    select array_agg(player_id order by random()) into v_order
    from public.room_players where room_id = p_room_id;
    v_count := coalesce(cardinality(v_order), 0);
    if v_count < 3 then raise exception 'At least 3 players are required to start.'; end if;

    v_imposter_count := least(greatest(coalesce((v_room.config->>'imposterCount')::int, 1), 1), (v_count - 1) / 2);
    select array_agg(id) into v_imposters from (
        select player_id as id from public.room_players
        where room_id = p_room_id order by random() limit v_imposter_count
    ) picked;

    v_mode := coalesce(v_room.config->>'mode', 'hint');
    v_seconds := least(greatest(coalesce((v_room.config->>'discussionSeconds')::int, 180), 15), 900);

    select category into v_category from (select distinct category from private.word_bank) c
    order by random() limit 1;
    if v_category is null then raise exception 'The word list has not been installed yet.'; end if;

    select w.* into v_word from private.word_bank w
    where w.category = v_category
      and not exists (
          select 1 from private.session_words sw
          where sw.room_id = p_room_id and sw.word_id = w.id
      )
    order by random() limit 1;
    if not found then
        select w.* into v_word from private.word_bank w
        where w.category = v_category order by random() limit 1;
    end if;

    if cardinality(v_word.hints) > 0 then
        v_hint := v_word.hints[1 + floor(random() * cardinality(v_word.hints))::int];
    end if;
    if cardinality(v_word.fakes) > 0 then
        v_fake := v_word.fakes[1 + floor(random() * cardinality(v_word.fakes))::int];
    end if;

    insert into public.game_sessions (
        room_id, round_number, phase, category, mode, starter_id, turn_order,
        discussion_start_time, discussion_end_time, timer_remaining_seconds,
        match_id, match_round, vote_mode, vote_visibility
    ) values (
        p_room_id, 1, 'reveal', v_category, v_mode, v_order[1], to_jsonb(v_order),
        now(), now() + make_interval(secs => v_seconds), v_seconds,
        v_room.match_id, v_room.current_round,
        case when v_room.config->>'voteMode' = 'sequential' then 'sequential' else 'simultaneous' end,
        case when v_room.config->>'voteVisibility' = 'public' then 'public' else 'private' end
    ) returning id into v_session;

    insert into private.session_words (session_id, room_id, word_id)
    values (v_session, p_room_id, v_word.id);

    for v_p in select player_id, display_name, avatar_index from public.room_players where room_id = p_room_id loop
        v_is_imp := v_p.player_id = any(v_imposters);

        insert into public.game_players (session_id, player_id, display_name, avatar_index, is_alive)
        values (v_session, v_p.player_id, v_p.display_name, v_p.avatar_index, true);

        insert into public.private_player_assignments (
            session_id, player_id, is_imposter, secret_word, hint, fake_word, teammates
        ) values (
            v_session,
            v_p.player_id,
            v_is_imp,
            case
                when not v_is_imp then v_word.word
                when v_mode = 'fakeWord' and v_fake is not null then v_fake
                else 'IMPOSTER'
            end,
            case when v_is_imp and v_mode = 'hint' then v_hint end,
            case when v_is_imp and v_mode = 'fakeWord' then v_fake end,
            case when v_is_imp then to_jsonb(v_imposters) else '[]'::jsonb end
        );
    end loop;

    update public.rooms set status = 'playing', updated_at = now(), last_activity_at = now() where id = p_room_id;
    return v_session;
end;
$$;

-- ---------------------------------------------------------------------------
-- App-callable functions
-- ---------------------------------------------------------------------------
create or replace function public.update_room_settings(
    p_room_id uuid, p_total_rounds int, p_vote_mode text, p_vote_visibility text
)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    if p_total_rounds not between 1 and 10 then raise exception 'Choose between 1 and 10 rounds.'; end if;
    if p_vote_mode not in ('simultaneous', 'sequential') or p_vote_visibility not in ('private', 'public') then
        raise exception 'Unknown voting option.';
    end if;
    update public.rooms
    set total_rounds = p_total_rounds,
        config = config || jsonb_build_object('voteMode', p_vote_mode, 'voteVisibility', p_vote_visibility),
        updated_at = now()
    where id = p_room_id and host_id = auth.uid() and status in ('waiting', 'finished');
    if not found then raise exception 'Only the host can change settings before the game starts.'; end if;
end;
$$;

-- Starts a new match (round 1).
create or replace function public.start_online_game(p_room_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_room public.rooms;
    v_session uuid;
begin
    select * into v_room from public.rooms where id = p_room_id for update;
    if not found then raise exception 'Room not found.'; end if;
    if v_room.host_id is distinct from auth.uid() then
        raise exception 'Only the room host can start the game.';
    end if;
    if v_room.status not in ('waiting', 'finished') then
        raise exception 'A game is already running in this room.';
    end if;

    update public.rooms set match_id = gen_random_uuid(), current_round = 1 where id = p_room_id;
    v_session := private.create_round(p_room_id);
    return jsonb_build_object('session_id', v_session, 'round', 1);
end;
$$;

create or replace function public.start_next_round(p_room_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_room public.rooms;
    v_phase text;
    v_session uuid;
begin
    select * into v_room from public.rooms where id = p_room_id for update;
    if not found then raise exception 'Room not found.'; end if;
    if v_room.host_id is distinct from auth.uid() then
        raise exception 'Only the host can start the next round.';
    end if;
    if v_room.status <> 'playing' then raise exception 'There is no match in progress.'; end if;
    if v_room.current_round >= v_room.total_rounds then raise exception 'That was the last round.'; end if;

    select phase into v_phase from public.game_sessions
    where room_id = p_room_id order by created_at desc limit 1;
    if v_phase is distinct from 'result' then raise exception 'Finish this round first.'; end if;

    update public.rooms set current_round = current_round + 1 where id = p_room_id;
    v_session := private.create_round(p_room_id);
    return jsonb_build_object('session_id', v_session, 'round', v_room.current_round + 1);
end;
$$;

create or replace function public.advance_game_phase(p_session_id uuid, p_target_phase text)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_host uuid;
begin
    select * into v_session from public.game_sessions where id = p_session_id for update;
    if not found then raise exception 'Game not found.'; end if;

    select host_id into v_host from public.rooms where id = v_session.room_id;
    if v_host is distinct from auth.uid() then
        raise exception 'Only the host can advance the game.';
    end if;

    if v_session.phase = 'discussion' and p_target_phase = 'vote' then
        if v_session.discussion_end_time > now() then
            raise exception 'Discussion ends when the timer runs out or everyone agrees to end it.';
        end if;
        perform private.begin_vote(p_session_id);
        return jsonb_build_object('session_id', p_session_id, 'phase', 'vote');
    end if;

    if (v_session.phase, p_target_phase) not in (('reveal', 'clue'), ('clue', 'discussion')) then
        return jsonb_build_object('session_id', p_session_id, 'phase', v_session.phase);
    end if;

    if p_target_phase = 'discussion' then
        perform private.begin_discussion(p_session_id);
    else
        update public.game_sessions set phase = p_target_phase, updated_at = now() where id = p_session_id;
    end if;
    return jsonb_build_object('session_id', p_session_id, 'phase', p_target_phase);
end;
$$;

-- Lets any member's app apply the timer the moment its countdown ends.
create or replace function public.sync_game(p_session_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    if not public.is_session_member(p_session_id) then raise exception 'Game not found.'; end if;
    perform private.sync_session(p_session_id);
end;
$$;

create or replace function public.cast_online_vote(p_session_id uuid, p_target_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_existing uuid;
    v_me uuid := auth.uid();
begin
    -- Locking the session row serialises votes, so the ballot list stays exact.
    select * into v_session from public.game_sessions where id = p_session_id for update;
    if not found or v_session.phase <> 'vote' then
        raise exception 'Voting is not open.';
    end if;

    select target_id into v_existing from public.game_votes
    where session_id = p_session_id and voter_id = v_me
      and round_number = v_session.round_number and revote_number = v_session.revotes;
    if v_existing is not null then
        -- A retry of the same vote succeeds; a different choice does not.
        if v_existing = p_target_id then return jsonb_build_object('status', 'recorded'); end if;
        raise exception 'Your vote is already locked in.';
    end if;

    if p_target_id = v_me then raise exception 'You cannot vote for yourself.'; end if;
    if not exists (
        select 1 from public.game_players where session_id = p_session_id and player_id = v_me and is_alive
    ) then
        raise exception 'You are out of this game.';
    end if;
    if not exists (
        select 1 from public.game_players where session_id = p_session_id and player_id = p_target_id and is_alive
    ) then
        raise exception 'That player is no longer in the game.';
    end if;
    if v_session.vote_mode = 'sequential' and private.current_voter(p_session_id) is distinct from v_me then
        raise exception 'Please wait for your turn to vote.';
    end if;

    insert into public.game_votes (session_id, voter_id, target_id, round_number, revote_number)
    values (p_session_id, v_me, p_target_id, v_session.round_number, v_session.revotes);

    update public.game_sessions
    set voters = voters || to_jsonb(v_me::text), updated_at = now()
    where id = p_session_id;

    if jsonb_array_length(v_session.voters) + 1 >= private.alive_count(p_session_id) then
        perform private.tally(p_session_id);
    end if;
    return jsonb_build_object('status', 'recorded');
end;
$$;

create or replace function public.tally_online_votes(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_host uuid;
begin
    select * into v_session from public.game_sessions where id = p_session_id for update;
    if not found then raise exception 'Game not found.'; end if;
    if v_session.phase <> 'vote' then return jsonb_build_object('phase', v_session.phase); end if;
    select host_id into v_host from public.rooms where id = v_session.room_id;
    if v_host is distinct from auth.uid() then raise exception 'Only the host can close the vote.'; end if;
    return private.tally(p_session_id);
end;
$$;

-- Host skips a disconnected player's clue or (in turn-based voting) vote.
create or replace function public.skip_turn(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_host uuid;
    v_current uuid;
begin
    select * into v_session from public.game_sessions where id = p_session_id for update;
    if not found then raise exception 'Game not found.'; end if;
    select host_id into v_host from public.rooms where id = v_session.room_id;
    if v_host is distinct from auth.uid() then raise exception 'Only the host can skip a turn.'; end if;

    perform private.sweep_room(v_session.room_id);

    if v_session.phase = 'clue' then
        v_current := (v_session.turn_order->>(v_session.clue_step % jsonb_array_length(v_session.turn_order)))::uuid;
    elsif v_session.phase = 'vote' and v_session.vote_mode = 'sequential' then
        v_current := private.current_voter(p_session_id);
    else
        raise exception 'There is no turn to skip.';
    end if;

    if exists (
        select 1 from public.room_players
        where room_id = v_session.room_id and player_id = v_current and is_connected
    ) then
        raise exception 'That player is still connected.';
    end if;

    if v_session.phase = 'clue' then
        perform private.advance_clue_turn(p_session_id);
    else
        update public.game_sessions set voters = voters || to_jsonb(v_current::text), updated_at = now()
        where id = p_session_id;
        if jsonb_array_length(v_session.voters) + 1 >= private.alive_count(p_session_id) then
            if exists (select 1 from public.game_votes where session_id = p_session_id
                       and round_number = v_session.round_number and revote_number = v_session.revotes) then
                perform private.tally(p_session_id);
            end if;
        end if;
    end if;
    return jsonb_build_object('status', 'skipped');
end;
$$;

create or replace function public.skip_clue_turn(p_session_id uuid)
returns jsonb language sql security definer
set search_path = public, pg_temp as $$
    select public.skip_turn(p_session_id);
$$;

create or replace function public.request_end_discussion(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_name text;
    v_eligible int;
    v_last timestamptz;
    v_id uuid;
begin
    select * into v_session from public.game_sessions where id = p_session_id for update;
    if not found or v_session.phase <> 'discussion' then raise exception 'Discussion is not running.'; end if;

    select display_name into v_name from public.game_players
    where session_id = p_session_id and player_id = auth.uid() and is_alive;
    if v_name is null then raise exception 'Only players still in the game can ask to end discussion.'; end if;

    perform private.sync_session(p_session_id);
    if exists (select 1 from public.discussion_end_requests where session_id = p_session_id and status = 'pending') then
        raise exception 'A request is already waiting for answers.';
    end if;

    select max(created_at) into v_last from public.discussion_end_requests where session_id = p_session_id;
    if v_last > now() - interval '30 seconds' then
        raise exception 'Please wait a moment before asking again.';
    end if;

    v_eligible := private.alive_count(p_session_id);
    insert into public.discussion_end_requests (session_id, room_id, requester_id, requester_name, eligible, expires_at)
    values (p_session_id, v_session.room_id, auth.uid(), v_name, v_eligible, now() + interval '20 seconds')
    returning id into v_id;
    insert into public.discussion_end_votes (request_id, player_id, approve) values (v_id, auth.uid(), true);

    if v_eligible <= 1 then
        update public.discussion_end_requests set status = 'approved', resolved_at = now() where id = v_id;
        perform private.begin_vote(p_session_id);
    end if;
    return jsonb_build_object('request_id', v_id);
end;
$$;

create or replace function public.respond_end_discussion(p_request_id uuid, p_approve boolean)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_req public.discussion_end_requests;
begin
    select * into v_req from public.discussion_end_requests where id = p_request_id for update;
    if not found then raise exception 'Request not found.'; end if;
    if not exists (
        select 1 from public.game_players
        where session_id = v_req.session_id and player_id = auth.uid() and is_alive
    ) then
        raise exception 'Only players still in the game can answer.';
    end if;

    if v_req.status = 'pending' and v_req.expires_at <= now() then
        update public.discussion_end_requests set status = 'expired', resolved_at = now() where id = p_request_id;
        return jsonb_build_object('status', 'expired');
    end if;
    if v_req.status <> 'pending' then return jsonb_build_object('status', v_req.status); end if;

    begin
        insert into public.discussion_end_votes (request_id, player_id, approve) values (p_request_id, auth.uid(), p_approve);
    exception when unique_violation then
        raise exception 'You already answered.';
    end;

    if not p_approve then
        update public.discussion_end_requests set status = 'rejected', resolved_at = now() where id = p_request_id;
        return jsonb_build_object('status', 'rejected');
    end if;

    update public.discussion_end_requests set approvals = approvals + 1 where id = p_request_id
    returning * into v_req;
    if v_req.approvals >= v_req.eligible then
        update public.discussion_end_requests set status = 'approved', resolved_at = now() where id = p_request_id;
        perform private.begin_vote(v_req.session_id);
        return jsonb_build_object('status', 'approved');
    end if;
    return jsonb_build_object('status', 'pending', 'approvals', v_req.approvals, 'eligible', v_req.eligible);
end;
$$;

-- Points per player for the room's current match.
create or replace function public.match_standings(p_room_id uuid)
returns jsonb language sql stable security definer
set search_path = public, pg_temp as $$
    select coalesce(jsonb_agg(jsonb_build_object('player_id', s.pid, 'display_name', s.name, 'points', s.points)
                              order by s.points desc, s.name), '[]'::jsonb)
    from (
        select gp.player_id as pid, max(gp.display_name) as name,
               sum(coalesce((gr.scores->>gp.player_id::text)::int, 0))::int as points
        from public.rooms r
        join public.game_sessions gs on gs.room_id = r.id and gs.match_id = r.match_id
        join public.game_players gp on gp.session_id = gs.id
        left join public.game_results gr on gr.session_id = gs.id
        where r.id = p_room_id and public.is_room_member(p_room_id)
        group by gp.player_id
    ) s;
$$;

-- What an invitation or typed code points to, without joining.
create or replace function public.peek_room(p_code text)
returns jsonb language plpgsql stable security definer
set search_path = public, pg_temp as $$
declare
    v_room public.rooms;
    v_count int;
    v_host text;
    v_member boolean;
begin
    select * into v_room from public.rooms where code = upper(regexp_replace(coalesce(p_code, ''), '[^A-Za-z0-9]', '', 'g'));
    if not found then return jsonb_build_object('status', 'not_found'); end if;
    if v_room.expires_at <= now() then return jsonb_build_object('status', 'expired'); end if;

    select count(*) into v_count from public.room_players where room_id = v_room.id;
    select display_name into v_host from public.room_players where room_id = v_room.id and player_id = v_room.host_id;
    v_member := auth.uid() is not null and exists (
        select 1 from public.room_players where room_id = v_room.id and player_id = auth.uid()
    );

    return jsonb_build_object(
        'status', case
            when v_member then 'member'
            when v_room.status = 'playing' then 'started'
            when v_count >= v_room.max_players then 'full'
            else 'open' end,
        'code', v_room.code,
        'host_name', coalesce(v_host, 'Host'),
        'player_count', v_count,
        'max_players', v_room.max_players
    );
end;
$$;

create or replace function public.join_room(
    p_code text,
    p_display_name text,
    p_avatar int
)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_user uuid := auth.uid();
    v_name text := private.clean_name(p_display_name, 'Player');
    v_room public.rooms;
    v_is_member boolean;
    v_count int;
begin
    if v_user is null then raise exception 'Please sign in first.'; end if;

    select * into v_room from public.rooms
    where code = upper(regexp_replace(coalesce(p_code, ''), '[^A-Za-z0-9]', '', 'g'))
    for update;
    if not found then raise exception 'No room has that code. Check it and try again.'; end if;
    if v_room.expires_at <= now() then raise exception 'This room has expired.'; end if;

    v_is_member := exists (
        select 1 from public.room_players where room_id = v_room.id and player_id = v_user
    );

    if not v_is_member then
        if v_room.status = 'playing' then
            raise exception 'That game has already started.';
        end if;
        select count(*) into v_count from public.room_players where room_id = v_room.id;
        if v_count >= v_room.max_players then
            raise exception 'Room is full (maximum % players).', v_room.max_players;
        end if;
    end if;

    perform private.leave_other_rooms(v_user, v_room.id);
    perform private.upsert_profile(v_user, v_name, p_avatar);

    insert into public.room_players (room_id, player_id, display_name, avatar_index, is_host, is_ready, is_connected)
    values (v_room.id, v_user, v_name, least(greatest(coalesce(p_avatar, 0), 0), 7), false, false, true)
    on conflict (room_id, player_id) do update
    set display_name = excluded.display_name,
        avatar_index = excluded.avatar_index,
        is_connected = true,
        last_seen_at = now();

    return jsonb_build_object(
        'room_id', v_room.id, 'code', v_room.code, 'host_id', v_room.host_id,
        'status', v_room.status, 'player_id', v_user
    );
end;
$$;

create or replace function public.room_heartbeat(p_room_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    update public.room_players
    set last_seen_at = now(), is_connected = true
    where room_id = p_room_id and player_id = auth.uid();
    if not found then return jsonb_build_object('member', false); end if;

    -- Somebody is here, so the room is not expiring.
    update public.rooms set expires_at = now() + interval '2 hours'
    where id = p_room_id and expires_at < now() + interval '90 minutes';

    perform private.sweep_room(p_room_id);
    return jsonb_build_object('member', true);
end;
$$;

do $$
declare
    f text;
begin
    foreach f in array array[
        'update_room_settings(uuid, int, text, text)', 'start_online_game(uuid)', 'start_next_round(uuid)',
        'advance_game_phase(uuid, text)', 'sync_game(uuid)', 'cast_online_vote(uuid, uuid)',
        'tally_online_votes(uuid)', 'skip_turn(uuid)', 'skip_clue_turn(uuid)',
        'request_end_discussion(uuid)', 'respond_end_discussion(uuid, boolean)',
        'match_standings(uuid)', 'join_room(text, text, int)', 'room_heartbeat(uuid)'
    ] loop
        execute format('revoke execute on function public.%s from public, anon', f);
        execute format('grant execute on function public.%s to authenticated', f);
    end loop;
end;
$$;
-- Invitations are checked before the player has signed in.
revoke execute on function public.peek_room(text) from public;
grant execute on function public.peek_room(text) to anon, authenticated;

notify pgrst, 'reload schema';
commit;
