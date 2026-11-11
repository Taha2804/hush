-- Word-view acknowledgements, a per-turn clue timer, and host-started clue
-- rounds and discussions. Safe to re-run.
begin;

alter table public.private_player_assignments add column if not exists viewed_at timestamptz;
-- Who has confirmed seeing their word. Ids only, never words.
alter table public.game_sessions add column if not exists viewers jsonb not null default '[]'::jsonb;
alter table public.game_sessions add column if not exists clue_turn_deadline timestamptz;
alter table public.game_sessions add column if not exists clues_complete boolean not null default false;

create or replace function private.clue_seconds(p_session_id uuid)
returns int language sql stable security definer
set search_path = public, pg_temp as $$
    select least(greatest(coalesce((r.config->>'clueSeconds')::int, 60), 20), 180)
    from public.game_sessions gs join public.rooms r on r.id = gs.room_id
    where gs.id = p_session_id;
$$;

-- Moves to the next living player's clue. When every turn is used up the
-- round is marked complete and waits for the host to start the discussion.
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
        update public.game_sessions
        set clue_step = v_limit, clues_complete = true, clue_turn_deadline = null, updated_at = now()
        where id = p_session_id;
    else
        update public.game_sessions
        set clue_step = v_step,
            clue_turn_deadline = now() + make_interval(secs => private.clue_seconds(p_session_id)),
            updated_at = now()
        where id = p_session_id;
    end if;
end;
$$;

-- Time-based rules: expired end requests, clue turns that ran out, and
-- finished discussion timers.
create or replace function private.sync_session(p_session_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_s public.game_sessions;
begin
    update public.discussion_end_requests
    set status = 'expired', resolved_at = now()
    where session_id = p_session_id and status = 'pending' and expires_at <= now();

    select * into v_s from public.game_sessions where id = p_session_id;
    if v_s.phase = 'clue' and not v_s.clues_complete
       and v_s.clue_turn_deadline is not null and v_s.clue_turn_deadline <= now() then
        -- The player ran out of time; their clue is simply missing.
        perform private.advance_clue_turn(p_session_id);
    elsif v_s.phase = 'discussion' and v_s.discussion_end_time is not null and v_s.discussion_end_time <= now() then
        perform private.begin_vote(p_session_id);
    end if;
end;
$$;

-- Starts the clue round. Without p_force it refuses while some players have
-- not confirmed seeing their word, so the host can be asked first.
create or replace function private.start_clues(p_session_id uuid, p_force boolean)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_players int;
    v_assigned int;
    v_waiting int;
begin
    select * into v_session from public.game_sessions where id = p_session_id for update;
    if v_session.phase <> 'reveal' then
        return jsonb_build_object('status', 'already_started', 'phase', v_session.phase);
    end if;

    select count(*) into v_players from public.game_players where session_id = p_session_id;
    select count(*) into v_assigned from public.private_player_assignments where session_id = p_session_id;
    if v_players = 0 or v_assigned < v_players then
        raise exception 'Secret words are still being dealt. Try again in a moment.';
    end if;

    select count(*) into v_waiting from public.game_players gp
    where gp.session_id = p_session_id and gp.is_alive and not (v_session.viewers ? gp.player_id::text);
    if v_waiting > 0 and not p_force then
        return jsonb_build_object('status', 'needs_confirm', 'waiting', v_waiting);
    end if;

    update public.game_sessions
    set phase = 'clue',
        clue_step = 0,
        clues_complete = false,
        clue_turn_deadline = now() + make_interval(secs => private.clue_seconds(p_session_id)),
        updated_at = now()
    where id = p_session_id;

    -- The first seat may belong to someone who has already left.
    if not exists (
        select 1 from public.game_players
        where session_id = p_session_id and is_alive
          and player_id = (v_session.turn_order->>0)::uuid
    ) then
        update public.game_sessions set clue_step = -1 where id = p_session_id;
        perform private.advance_clue_turn(p_session_id);
    end if;
    return jsonb_build_object('status', 'started');
end;
$$;

create or replace function public.ack_word_viewed(p_session_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_me text := auth.uid()::text;
begin
    update public.private_player_assignments set viewed_at = coalesce(viewed_at, now())
    where session_id = p_session_id and player_id = auth.uid();
    if not found then raise exception 'You are not in this game.'; end if;

    update public.game_sessions
    set viewers = viewers || to_jsonb(v_me), updated_at = now()
    where id = p_session_id and not (viewers ? v_me);
end;
$$;

create or replace function public.start_clue_round(p_session_id uuid, p_force boolean default false)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_host uuid;
begin
    select r.host_id into v_host from public.game_sessions gs join public.rooms r on r.id = gs.room_id
    where gs.id = p_session_id;
    if v_host is null then raise exception 'Game not found.'; end if;
    if v_host is distinct from auth.uid() then raise exception 'Only the host can start the round.'; end if;
    return private.start_clues(p_session_id, p_force);
end;
$$;

create or replace function public.start_discussion(p_session_id uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_host uuid;
begin
    select * into v_session from public.game_sessions where id = p_session_id for update;
    if not found then raise exception 'Game not found.'; end if;
    select host_id into v_host from public.rooms where id = v_session.room_id;
    if v_host is distinct from auth.uid() then raise exception 'Only the host can start the discussion.'; end if;

    if v_session.phase <> 'clue' then
        return jsonb_build_object('status', 'already_started', 'phase', v_session.phase);
    end if;
    perform private.sync_session(p_session_id);
    select * into v_session from public.game_sessions where id = p_session_id;
    if not v_session.clues_complete then
        raise exception 'The clue round is still going.';
    end if;

    perform private.begin_discussion(p_session_id);
    return jsonb_build_object('status', 'started');
end;
$$;

-- Older clients use this. It applies the same rules as the functions above.
create or replace function public.advance_game_phase(p_session_id uuid, p_target_phase text)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_session public.game_sessions;
    v_host uuid;
begin
    select * into v_session from public.game_sessions where id = p_session_id;
    if not found then raise exception 'Game not found.'; end if;
    select host_id into v_host from public.rooms where id = v_session.room_id;
    if v_host is distinct from auth.uid() then raise exception 'Only the host can advance the game.'; end if;

    if v_session.phase = 'reveal' and p_target_phase = 'clue' then
        return private.start_clues(p_session_id, true);
    elsif v_session.phase = 'clue' and p_target_phase = 'discussion' then
        return public.start_discussion(p_session_id);
    elsif v_session.phase = 'discussion' and p_target_phase = 'vote' then
        select * into v_session from public.game_sessions where id = p_session_id for update;
        if v_session.discussion_end_time > now() then
            raise exception 'Discussion ends when the timer runs out or everyone agrees to end it.';
        end if;
        perform private.begin_vote(p_session_id);
        return jsonb_build_object('phase', 'vote');
    end if;
    return jsonb_build_object('phase', v_session.phase);
end;
$$;

-- Room settings now include the time each player gets for a clue.
create or replace function public.update_room_settings(
    p_room_id uuid, p_total_rounds int, p_vote_mode text, p_vote_visibility text, p_clue_seconds int default 60
)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    if p_total_rounds not between 1 and 10 then raise exception 'Choose between 1 and 10 rounds.'; end if;
    if p_vote_mode not in ('simultaneous', 'sequential') or p_vote_visibility not in ('private', 'public') then
        raise exception 'Unknown voting option.';
    end if;
    if p_clue_seconds not between 20 and 180 then raise exception 'Clue time must be 20 to 180 seconds.'; end if;
    update public.rooms
    set total_rounds = p_total_rounds,
        config = config || jsonb_build_object('voteMode', p_vote_mode, 'voteVisibility', p_vote_visibility, 'clueSeconds', p_clue_seconds),
        updated_at = now()
    where id = p_room_id and host_id = auth.uid() and status in ('waiting', 'finished');
    if not found then raise exception 'Only the host can change settings before the game starts.'; end if;
end;
$$;
drop function if exists public.update_room_settings(uuid, int, text, text);

do $$
declare
    f text;
begin
    foreach f in array array[
        'ack_word_viewed(uuid)', 'start_clue_round(uuid, boolean)', 'start_discussion(uuid)',
        'advance_game_phase(uuid, text)', 'update_room_settings(uuid, int, text, text, int)'
    ] loop
        execute format('revoke execute on function public.%s from public, anon', f);
        execute format('grant execute on function public.%s to authenticated', f);
    end loop;
end;
$$;
revoke all on all functions in schema private from public, anon, authenticated;

notify pgrst, 'reload schema';
commit;
