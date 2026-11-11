-- Stage 4: voice access rules. LiveKit carries the audio; this decides who may
-- join and when they may speak. Safe to re-run.
begin;

alter table public.rooms add column if not exists voice_policy jsonb not null
    default '{"clue": true, "vote": true}'::jsonb;

-- Where the sync function lives. Filled in by supabase/functions/README.md.
create table if not exists private.voice_settings (
    id boolean primary key default true check (id),
    function_url text not null,
    sync_secret text not null
);

create or replace function private.voice_open(p_room_id uuid)
returns boolean language plpgsql stable security definer
set search_path = public, pg_temp as $$
declare
    v_room public.rooms;
    v_phase text;
begin
    select * into v_room from public.rooms where id = p_room_id;
    if not found then return false; end if;
    if v_room.status <> 'playing' then return true; end if;

    select phase into v_phase from public.game_sessions
    where room_id = p_room_id order by created_at desc limit 1;

    return case v_phase
        when 'reveal' then false
        when 'clue' then coalesce((v_room.voice_policy->>'clue')::boolean, true)
        when 'vote' then coalesce((v_room.voice_policy->>'vote')::boolean, true)
        else true
    end;
end;
$$;

-- Called by the token function using the player's own login.
create or replace function public.get_voice_access(p_room_id uuid)
returns jsonb language plpgsql stable security definer
set search_path = public, pg_temp as $$
declare
    v_name text;
begin
    select display_name into v_name from public.room_players
    where room_id = p_room_id and player_id = auth.uid();
    if v_name is null then raise exception 'You are not in this room.'; end if;

    return jsonb_build_object(
        'room_name', 'hushbug_' || p_room_id,
        'identity', auth.uid(),
        'display_name', v_name,
        'can_publish', private.voice_open(p_room_id)
    );
end;
$$;

-- Called by the sync function with the service role.
create or replace function public.voice_sync_state(p_room_id uuid)
returns jsonb language sql stable security definer
set search_path = public, pg_temp as $$
    select jsonb_build_object('room_name', 'hushbug_' || p_room_id, 'can_publish', private.voice_open(p_room_id));
$$;

create or replace function public.set_voice_policy(p_room_id uuid, p_clue boolean, p_vote boolean)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    update public.rooms
    set voice_policy = jsonb_build_object('clue', p_clue, 'vote', p_vote), updated_at = now()
    where id = p_room_id and host_id = auth.uid() and status = 'waiting';
    if not found then raise exception 'Only the host can change voice rules before the game starts.'; end if;
end;
$$;

-- Tells the sync function to re-apply speaking rights on the LiveKit server.
-- Never allowed to break the game: if voice is not set up, this does nothing.
create or replace function private.notify_voice(p_room_id uuid, p_remove uuid default null)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_cfg private.voice_settings;
begin
    select * into v_cfg from private.voice_settings;
    if not found then return; end if;

    execute 'select net.http_post(url := $1, headers := $2, body := $3)'
    using v_cfg.function_url,
          jsonb_build_object('Content-Type', 'application/json', 'x-sync-secret', v_cfg.sync_secret),
          jsonb_build_object('room_id', p_room_id, 'remove_identity', p_remove);
exception when others then
    raise warning 'voice sync skipped: %', sqlerrm;
end;
$$;

create or replace function private.on_voice_session_change()
returns trigger language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    perform private.notify_voice(new.room_id);
    return null;
end;
$$;

drop trigger if exists trg_voice_session on public.game_sessions;
create trigger trg_voice_session
    after insert or update of phase on public.game_sessions
    for each row execute function private.on_voice_session_change();

create or replace function private.on_voice_room_change()
returns trigger language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    perform private.notify_voice(new.id);
    return null;
end;
$$;

drop trigger if exists trg_voice_room on public.rooms;
create trigger trg_voice_room
    after update of status, voice_policy on public.rooms
    for each row execute function private.on_voice_room_change();

create or replace function private.on_voice_member_gone()
returns trigger language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    perform private.notify_voice(old.room_id, old.player_id);
    return null;
end;
$$;

drop trigger if exists trg_voice_member on public.room_players;
create trigger trg_voice_member
    after delete on public.room_players
    for each row execute function private.on_voice_member_gone();

revoke execute on function public.get_voice_access(uuid) from public, anon;
grant execute on function public.get_voice_access(uuid) to authenticated;
revoke execute on function public.set_voice_policy(uuid, boolean, boolean) from public, anon;
grant execute on function public.set_voice_policy(uuid, boolean, boolean) to authenticated;
revoke execute on function public.voice_sync_state(uuid) from public, anon, authenticated;
grant execute on function public.voice_sync_state(uuid) to service_role;

notify pgrst, 'reload schema';
commit;
