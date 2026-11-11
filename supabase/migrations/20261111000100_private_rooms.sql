-- Stage 1: private rooms, server-chosen words, reconnection, game-flow fixes.
-- Safe to re-run. Apply after schema.sql.

begin;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Word bank. Lives in a schema the API does not expose, so nobody can read or
-- influence the words. Filled by 20261111000200_word_bank_seed.sql.
-- ---------------------------------------------------------------------------
create table if not exists private.word_bank (
    id bigint generated always as identity primary key,
    category text not null,
    word text not null,
    hints text[] not null default '{}',
    fakes text[] not null default '{}',
    unique (category, word)
);
create index if not exists idx_word_bank_category on private.word_bank(category);

create table if not exists private.session_words (
    session_id uuid primary key references public.game_sessions(id) on delete cascade,
    room_id uuid not null references public.rooms(id) on delete cascade,
    word_id bigint not null references private.word_bank(id)
);
create index if not exists idx_session_words_room on private.session_words(room_id);

-- ---------------------------------------------------------------------------
-- Membership checks used by security rules
-- ---------------------------------------------------------------------------
create or replace function public.is_room_member(p_room_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
    select exists (
        select 1 from public.room_players
        where room_id = p_room_id and player_id = auth.uid()
    );
$$;

create or replace function public.is_session_member(p_session_id uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
    select exists (
        select 1 from public.game_sessions gs
        join public.room_players rp on rp.room_id = gs.room_id
        where gs.id = p_session_id and rp.player_id = auth.uid()
    );
$$;

-- ---------------------------------------------------------------------------
-- Security rules: read if you are a member, write only through functions
-- ---------------------------------------------------------------------------
drop policy if exists "Rooms viewable by everyone" on public.rooms;
drop policy if exists "Authenticated users can create rooms" on public.rooms;
drop policy if exists "Hosts can update their rooms" on public.rooms;
drop policy if exists "Room members can view their room" on public.rooms;
create policy "Room members can view their room" on public.rooms
    for select to authenticated using (public.is_room_member(id));

drop policy if exists "Room players viewable by everyone in room" on public.room_players;
drop policy if exists "Players can join room" on public.room_players;
drop policy if exists "Players can update own status or host can update" on public.room_players;
drop policy if exists "Players can leave or host can remove" on public.room_players;
drop policy if exists "Room members can view players" on public.room_players;
create policy "Room members can view players" on public.room_players
    for select to authenticated using (public.is_room_member(room_id));

drop policy if exists "Game sessions viewable by room participants" on public.game_sessions;
create policy "Game sessions viewable by room participants" on public.game_sessions
    for select to authenticated using (public.is_room_member(game_sessions.room_id));

drop policy if exists "Game players viewable by session participants" on public.game_players;
create policy "Game players viewable by session participants" on public.game_players
    for select to authenticated using (public.is_session_member(game_players.session_id));

drop policy if exists "Clues viewable by session participants" on public.game_clues;
drop policy if exists "Active player can insert clue" on public.game_clues;
create policy "Clues viewable by session participants" on public.game_clues
    for select to authenticated using (public.is_session_member(game_clues.session_id));

drop policy if exists "Voters can cast their own vote" on public.game_votes;

drop policy if exists "Results viewable by session participants" on public.game_results;
create policy "Results viewable by session participants" on public.game_results
    for select to authenticated using (public.is_session_member(game_results.session_id));

-- ---------------------------------------------------------------------------
-- Internal helpers (not callable from the app)
-- ---------------------------------------------------------------------------
create or replace function private.clean_name(p_name text, p_fallback text)
returns text language sql immutable as $$
    select left(coalesce(nullif(regexp_replace(trim(coalesce(p_name, '')), '\s+', ' ', 'g'), ''), p_fallback), 20);
$$;

create or replace function private.transfer_host(p_room_id uuid, p_new_host uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    update public.rooms set host_id = p_new_host, updated_at = now() where id = p_room_id;
    update public.room_players set is_host = (player_id = p_new_host) where room_id = p_room_id;
end;
$$;

-- Marks silent players as disconnected and replaces a host who has gone away.
-- Runs from each client's heartbeat, so no scheduled job is needed.
create or replace function private.sweep_room(p_room_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_host uuid;
    v_host_seen timestamptz;
    v_next uuid;
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
end;
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
        discussion_start_time = now(),
        discussion_end_time = now() + make_interval(secs => v_seconds),
        timer_paused = false,
        timer_remaining_seconds = v_seconds,
        updated_at = now()
    where id = p_session_id;
end;
$$;

-- Moves to the next living player's clue, or on to discussion when all are in.
create or replace function private.advance_clue_turn(p_session_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_len int;
    v_step int;
    v_limit int;
    v_rounds int;
begin
    select * into v_session from public.game_sessions where id = p_session_id for update;
    v_len := jsonb_array_length(v_session.turn_order);
    select least(greatest(coalesce((config->>'clueRounds')::int, 1), 1), 5) into v_rounds
    from public.rooms where id = v_session.room_id;
    v_limit := v_len * v_rounds;
    v_step := v_session.clue_step + 1;

    while v_step < v_limit and not exists (
        select 1 from public.game_players
        where session_id = p_session_id and is_alive
          and player_id = (v_session.turn_order->>(v_step % v_len))::uuid
    ) loop
        v_step := v_step + 1;
    end loop;

    if v_step >= v_limit then
        update public.game_sessions set clue_step = v_step where id = p_session_id;
        perform private.begin_discussion(p_session_id);
    else
        update public.game_sessions set clue_step = v_step, updated_at = now() where id = p_session_id;
    end if;
end;
$$;

create or replace function private.end_game(p_session_id uuid, p_winner text, p_reason text)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_room uuid;
    v_word text;
    v_imposters jsonb;
begin
    select room_id into v_room from public.game_sessions where id = p_session_id;

    select secret_word into v_word from public.private_player_assignments
    where session_id = p_session_id and is_imposter = false limit 1;

    select coalesce(jsonb_agg(player_id), '[]'::jsonb) into v_imposters
    from public.private_player_assignments
    where session_id = p_session_id and is_imposter = true;

    insert into public.game_results (session_id, winner, win_reason, secret_word, imposters)
    values (p_session_id, p_winner, p_reason, coalesce(v_word, 'Unknown'), v_imposters);

    update public.game_sessions
    set phase = 'result', winner = p_winner, win_reason = p_reason, updated_at = now()
    where id = p_session_id;

    -- The room is immediately ready for another game.
    update public.rooms set status = 'waiting', updated_at = now() where id = v_room;
    update public.room_players set is_ready = false where room_id = v_room;
end;
$$;

-- Ends the game if a departure has already decided it. Returns true if ended.
create or replace function private.settle_after_departure(p_session_id uuid)
returns boolean language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_imp int;
    v_crew int;
begin
    select count(*) filter (where ppa.is_imposter), count(*) filter (where not ppa.is_imposter)
    into v_imp, v_crew
    from public.game_players gp
    join public.private_player_assignments ppa
      on ppa.session_id = gp.session_id and ppa.player_id = gp.player_id
    where gp.session_id = p_session_id and gp.is_alive;

    if v_imp = 0 then
        perform private.end_game(p_session_id, 'crew', 'imposterLeft');
        return true;
    elsif v_imp >= v_crew then
        perform private.end_game(p_session_id, 'imposters', 'impostersOutnumber');
        return true;
    end if;
    return false;
end;
$$;

create or replace function private.remove_player(p_room_id uuid, p_player uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_room public.rooms;
    v_session public.game_sessions;
    v_next uuid;
    v_len int;
    v_was_alive boolean;
begin
    select * into v_room from public.rooms where id = p_room_id for update;
    if not found then return; end if;

    delete from public.room_players where room_id = p_room_id and player_id = p_player;
    if not found then return; end if;

    if not exists (select 1 from public.room_players where room_id = p_room_id) then
        delete from public.rooms where id = p_room_id;
        return;
    end if;

    if v_room.status = 'playing' then
        select * into v_session from public.game_sessions
        where room_id = p_room_id and phase <> 'result'
        order by created_at desc limit 1 for update;

        if found then
            update public.game_players set is_alive = false
            where session_id = v_session.id and player_id = p_player and is_alive
            returning true into v_was_alive;

            if coalesce(v_was_alive, false)
               and not private.settle_after_departure(v_session.id)
               and v_session.phase = 'clue' then
                v_len := jsonb_array_length(v_session.turn_order);
                if (v_session.turn_order->>(v_session.clue_step % v_len))::uuid = p_player then
                    perform private.advance_clue_turn(v_session.id);
                end if;
            end if;
        end if;
    end if;

    if v_room.host_id = p_player then
        select player_id into v_next from public.room_players
        where room_id = p_room_id
        order by is_connected desc, joined_at asc limit 1;
        perform private.transfer_host(p_room_id, v_next);
    else
        -- Delete events cannot be filtered per room, so touching the room row
        -- is what tells everyone else to refresh the player list.
        update public.rooms set updated_at = now() where id = p_room_id;
    end if;
end;
$$;

create or replace function private.leave_other_rooms(p_user uuid, p_keep uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_room uuid;
begin
    for v_room in
        select room_id from public.room_players
        where player_id = p_user and room_id is distinct from p_keep
    loop
        perform private.remove_player(v_room, p_user);
    end loop;
end;
$$;

create or replace function private.upsert_profile(p_user uuid, p_name text, p_avatar int)
returns void language sql security definer
set search_path = public, pg_temp as $$
    insert into public.profiles (id, display_name, avatar_index)
    values (p_user, p_name, least(greatest(coalesce(p_avatar, 0), 0), 7))
    on conflict (id) do update
    set display_name = excluded.display_name,
        avatar_index = excluded.avatar_index,
        updated_at = now();
$$;

-- ---------------------------------------------------------------------------
-- App-callable functions
-- ---------------------------------------------------------------------------
drop function if exists public.create_room(text, text, int, jsonb);
create or replace function public.create_room(
    p_display_name text,
    p_avatar int,
    p_config jsonb default null
)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_user uuid := auth.uid();
    v_name text := private.clean_name(p_display_name, 'Host');
    v_room uuid;
    v_code text;
    v_mode text := coalesce(p_config->>'mode', 'hint');
    v_config jsonb;
    v_attempt int := 0;
    c_chars constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
begin
    if v_user is null then raise exception 'Please sign in first.'; end if;

    delete from public.rooms where expires_at < now();
    perform private.leave_other_rooms(v_user, null);
    perform private.upsert_profile(v_user, v_name, p_avatar);

    v_config := jsonb_build_object(
        'mode', case when v_mode in ('classic', 'hint', 'fakeWord') then v_mode else 'hint' end,
        'imposterCount', least(greatest(coalesce((p_config->>'imposterCount')::int, 1), 1), 5),
        'clueRounds', least(greatest(coalesce((p_config->>'clueRounds')::int, 1), 1), 5),
        'discussionSeconds', least(greatest(coalesce((p_config->>'discussionSeconds')::int, 180), 15), 900)
    );

    loop
        v_attempt := v_attempt + 1;
        select string_agg(substr(c_chars, 1 + floor(random() * 32)::int, 1), '')
        into v_code from generate_series(1, 6);
        begin
            insert into public.rooms (code, host_id, status, config)
            values (v_code, v_user, 'waiting', v_config)
            returning id into v_room;
            exit;
        exception when unique_violation then
            if v_attempt >= 10 then raise exception 'Could not create a room. Please try again.'; end if;
        end;
    end loop;

    insert into public.room_players (room_id, player_id, display_name, avatar_index, is_host, is_ready)
    values (v_room, v_user, v_name, least(greatest(coalesce(p_avatar, 0), 0), 7), true, true);

    return jsonb_build_object('room_id', v_room, 'code', v_code, 'player_id', v_user);
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
    where code = upper(trim(p_code)) and expires_at > now()
    for update;
    if not found then raise exception 'Room not found. Check the code and try again.'; end if;

    v_is_member := exists (
        select 1 from public.room_players where room_id = v_room.id and player_id = v_user
    );

    if not v_is_member then
        if v_room.status <> 'waiting' then
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
        'room_id', v_room.id,
        'code', v_room.code,
        'host_id', v_room.host_id,
        'status', v_room.status,
        'player_id', v_user
    );
end;
$$;

create or replace function public.my_active_room()
returns jsonb language sql stable security definer
set search_path = public, pg_temp as $$
    select jsonb_build_object('room_id', r.id, 'code', r.code, 'status', r.status)
    from public.room_players rp
    join public.rooms r on r.id = rp.room_id
    where rp.player_id = auth.uid() and r.expires_at > now()
    order by rp.joined_at desc
    limit 1;
$$;

create or replace function public.room_heartbeat(p_room_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    update public.room_players
    set last_seen_at = now(), is_connected = true
    where room_id = p_room_id and player_id = auth.uid();

    if not found then
        return jsonb_build_object('member', false);
    end if;

    update public.rooms
    set expires_at = now() + interval '4 hours'
    where id = p_room_id and expires_at < now() + interval '2 hours';

    perform private.sweep_room(p_room_id);
    return jsonb_build_object('member', true);
end;
$$;

drop function if exists public.start_online_game(uuid, text, text, text, text, int, int);
create or replace function public.start_online_game(p_room_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_user uuid := auth.uid();
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
    select * into v_room from public.rooms where id = p_room_id for update;
    if not found then raise exception 'Room not found.'; end if;
    if v_room.host_id is distinct from v_user then
        raise exception 'Only the room host can start the game.';
    end if;
    if v_room.status <> 'waiting' then
        raise exception 'A game is already running in this room.';
    end if;

    -- Independent shuffles, so turn order says nothing about who the imposters are.
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

    -- Pick a random category, then a random word this room has not played yet.
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
        discussion_start_time, discussion_end_time, timer_remaining_seconds
    ) values (
        p_room_id, 1, 'reveal', v_category, v_mode, v_order[1], to_jsonb(v_order),
        now(), now() + make_interval(secs => v_seconds), v_seconds
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

    update public.rooms set status = 'playing', updated_at = now() where id = p_room_id;

    return jsonb_build_object(
        'session_id', v_session,
        'player_count', v_count,
        'category', v_category,
        'phase', 'reveal'
    );
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

    if (v_session.phase, p_target_phase) not in (
        ('reveal', 'clue'), ('clue', 'discussion'), ('discussion', 'vote')
    ) then
        -- A double tap, or two hosts racing: the game has already moved on.
        return jsonb_build_object('session_id', p_session_id, 'phase', v_session.phase);
    end if;

    if p_target_phase = 'discussion' then
        perform private.begin_discussion(p_session_id);
    else
        update public.game_sessions
        set phase = p_target_phase, updated_at = now()
        where id = p_session_id;
    end if;

    return jsonb_build_object('session_id', p_session_id, 'phase', p_target_phase);
end;
$$;

create or replace function public.submit_online_clue(p_session_id uuid, p_clue_text text)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_text text := left(trim(coalesce(p_clue_text, '')), 60);
    v_len int;
begin
    if v_text = '' then raise exception 'Please enter a clue.'; end if;

    select * into v_session from public.game_sessions where id = p_session_id for update;
    if not found or v_session.phase <> 'clue' then
        raise exception 'Game is not in the clue phase.';
    end if;

    v_len := jsonb_array_length(v_session.turn_order);
    if (v_session.turn_order->>(v_session.clue_step % v_len))::uuid is distinct from auth.uid() then
        raise exception 'It is not your turn.';
    end if;

    insert into public.game_clues (session_id, player_id, clue_step, round_number, clue_text)
    values (p_session_id, auth.uid(), v_session.clue_step, v_session.round_number, v_text);

    perform private.advance_clue_turn(p_session_id);
    return jsonb_build_object('status', 'clue_submitted');
end;
$$;

-- Host-only escape hatch for when the player whose turn it is has dropped out.
create or replace function public.skip_clue_turn(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_host uuid;
    v_current uuid;
begin
    select * into v_session from public.game_sessions where id = p_session_id for update;
    if not found or v_session.phase <> 'clue' then
        raise exception 'Game is not in the clue phase.';
    end if;

    select host_id into v_host from public.rooms where id = v_session.room_id;
    if v_host is distinct from auth.uid() then
        raise exception 'Only the host can skip a turn.';
    end if;

    perform private.sweep_room(v_session.room_id);

    v_current := (v_session.turn_order->>(v_session.clue_step % jsonb_array_length(v_session.turn_order)))::uuid;
    if exists (
        select 1 from public.room_players
        where room_id = v_session.room_id and player_id = v_current and is_connected
    ) then
        raise exception 'That player is still connected.';
    end if;

    perform private.advance_clue_turn(p_session_id);
    return jsonb_build_object('status', 'skipped');
end;
$$;

create or replace function public.cast_online_vote(p_session_id uuid, p_target_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
begin
    select * into v_session from public.game_sessions where id = p_session_id;
    if not found or v_session.phase <> 'vote' then
        raise exception 'Game is not in the voting phase.';
    end if;
    if p_target_id = auth.uid() then raise exception 'You cannot vote for yourself.'; end if;

    if not exists (
        select 1 from public.game_players
        where session_id = p_session_id and player_id = auth.uid() and is_alive
    ) then
        raise exception 'You are out of this game.';
    end if;
    if not exists (
        select 1 from public.game_players
        where session_id = p_session_id and player_id = p_target_id and is_alive
    ) then
        raise exception 'That player is no longer in the game.';
    end if;

    insert into public.game_votes (session_id, voter_id, target_id, round_number, revote_number)
    values (p_session_id, auth.uid(), p_target_id, v_session.round_number, v_session.revotes)
    on conflict (session_id, voter_id, round_number, revote_number)
    do update set target_id = excluded.target_id, created_at = now();

    return jsonb_build_object('status', 'vote_cast');
end;
$$;

create or replace function public.tally_online_votes(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_host uuid;
    v_top uuid;
    v_top_votes int;
    v_second int;
    v_was_imp boolean;
    v_imp int;
    v_crew int;
    v_winner text;
    v_reason text;
begin
    select * into v_session from public.game_sessions where id = p_session_id for update;
    if not found then raise exception 'Game not found.'; end if;
    if v_session.phase <> 'vote' then
        return jsonb_build_object('phase', v_session.phase);
    end if;

    select host_id into v_host from public.rooms where id = v_session.room_id;
    if v_host is distinct from auth.uid() then
        raise exception 'Only the host can reveal the votes.';
    end if;

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

    if v_second = v_top_votes then
        if v_session.revotes = 0 then
            update public.game_sessions set revotes = 1, updated_at = now() where id = p_session_id;
            return jsonb_build_object('tie', true, 'revote_number', 1);
        end if;
        perform private.end_game(p_session_id, 'imposters', 'tieAfterRevote');
        return jsonb_build_object('phase', 'result', 'winner', 'imposters', 'reason', 'tieAfterRevote');
    end if;

    update public.game_players
    set is_alive = false, is_eliminated = true, eliminated_round = v_session.round_number
    where session_id = p_session_id and player_id = v_top;

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

create or replace function public.leave_room(p_room_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    if auth.uid() is null then return; end if;
    perform private.remove_player(p_room_id, auth.uid());
end;
$$;

alter function public.toggle_ready(uuid, boolean) set search_path = public, pg_temp;
alter function public.get_my_assignment(uuid) set search_path = public, pg_temp;

-- ---------------------------------------------------------------------------
-- Only signed-in users (guests included) may call these.
-- ---------------------------------------------------------------------------
do $$
declare
    f text;
begin
    foreach f in array array[
        'is_room_member(uuid)',
        'is_session_member(uuid)',
        'create_room(text, int, jsonb)',
        'join_room(text, text, int)',
        'my_active_room()',
        'room_heartbeat(uuid)',
        'toggle_ready(uuid, boolean)',
        'start_online_game(uuid)',
        'get_my_assignment(uuid)',
        'advance_game_phase(uuid, text)',
        'submit_online_clue(uuid, text)',
        'skip_clue_turn(uuid)',
        'cast_online_vote(uuid, uuid)',
        'tally_online_votes(uuid)',
        'leave_room(uuid)'
    ] loop
        execute format('revoke execute on function public.%s from public, anon', f);
        execute format('grant execute on function public.%s to authenticated', f);
    end loop;
end;
$$;

notify pgrst, 'reload schema';

commit;
