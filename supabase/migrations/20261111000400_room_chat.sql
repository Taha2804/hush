-- Stage 3: room text chat, automatic room notices, host moderation. Safe to re-run.
begin;

alter table public.room_players add column if not exists chat_muted boolean not null default false;

create table if not exists public.room_messages (
    id uuid primary key default gen_random_uuid(),
    room_id uuid not null references public.rooms(id) on delete cascade,
    sender_id uuid references public.profiles(id) on delete set null,
    sender_name text not null default '',
    sender_avatar int not null default 0,
    message text not null check (char_length(message) <= 500),
    message_type text not null default 'text' check (message_type in ('text', 'system')),
    system_event text,
    client_id uuid,
    created_at timestamptz not null default now(),
    deleted_at timestamptz
);
create index if not exists idx_room_messages_room_time on public.room_messages(room_id, created_at desc);
create index if not exists idx_room_messages_rate on public.room_messages(sender_id, created_at desc);
create unique index if not exists idx_room_messages_client on public.room_messages(sender_id, client_id);

alter table public.room_messages enable row level security;
drop policy if exists "Room members can read messages" on public.room_messages;
create policy "Room members can read messages" on public.room_messages
    for select to authenticated using (public.is_room_member(room_id));
-- No insert, update or delete rules: writes go through the functions below.

do $$
begin
    alter publication supabase_realtime add table public.room_messages;
exception when duplicate_object then null;
end;
$$;

create or replace function private.post_notice(p_room_id uuid, p_event text, p_text text)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    -- During a room delete the row is already gone; there is nobody to tell.
    if exists (select 1 from public.rooms where id = p_room_id) then
        insert into public.room_messages (room_id, message, message_type, system_event)
        values (p_room_id, p_text, 'system', p_event);
    end if;
end;
$$;

create or replace function private.on_room_player_change()
returns trigger language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    if tg_op = 'INSERT' then
        perform private.post_notice(new.room_id, 'joined', new.display_name || ' joined the room');
    elsif tg_op = 'DELETE' then
        perform private.post_notice(old.room_id, 'left', old.display_name || ' left the room');
    elsif old.is_connected and not new.is_connected then
        perform private.post_notice(new.room_id, 'disconnected', new.display_name || ' lost connection');
    elsif new.is_connected and not old.is_connected then
        perform private.post_notice(new.room_id, 'reconnected', new.display_name || ' is back');
    end if;
    return null;
end;
$$;

drop trigger if exists trg_room_player_notices on public.room_players;
create trigger trg_room_player_notices
    after insert or delete or update of is_connected on public.room_players
    for each row execute function private.on_room_player_change();

create or replace function private.on_room_change()
returns trigger language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_name text;
begin
    if new.host_id is distinct from old.host_id then
        select display_name into v_name from public.room_players
        where room_id = new.id and player_id = new.host_id;
        perform private.post_notice(new.id, 'host', coalesce(v_name, 'Someone') || ' is now the host');
    end if;
    if new.status = 'playing' and old.status <> 'playing' then
        perform private.post_notice(new.id, 'starting', 'Game starting!');
    end if;
    return null;
end;
$$;

drop trigger if exists trg_room_notices on public.rooms;
create trigger trg_room_notices
    after update of host_id, status on public.rooms
    for each row execute function private.on_room_change();

create or replace function public.send_room_message(p_room_id uuid, p_message text, p_client_id uuid default null)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_user uuid := auth.uid();
    v_me public.room_players;
    v_text text := trim(regexp_replace(coalesce(p_message, ''), '[[:cntrl:]]+', ' ', 'g'));
    v_row public.room_messages;
    v_last text;
    v_last_at timestamptz;
begin
    select * into v_me from public.room_players where room_id = p_room_id and player_id = v_user;
    if not found then raise exception 'You are not in this room.'; end if;
    if v_me.chat_muted then raise exception 'The host has muted you in this room.'; end if;
    if v_text = '' then raise exception 'Message is empty.'; end if;
    if char_length(v_text) > 500 then raise exception 'Messages can be up to 500 characters.'; end if;

    -- A retry of a message that already arrived returns the original.
    if p_client_id is not null then
        select * into v_row from public.room_messages where sender_id = v_user and client_id = p_client_id;
        if found then return to_jsonb(v_row); end if;
    end if;

    if (select count(*) from public.room_messages
        where sender_id = v_user and created_at > now() - interval '10 seconds') >= 5
       or (select count(*) from public.room_messages
           where sender_id = v_user and created_at > now() - interval '1 minute') >= 30 then
        raise exception 'You are sending messages too quickly.';
    end if;

    select message, created_at into v_last, v_last_at from public.room_messages
    where sender_id = v_user and room_id = p_room_id and deleted_at is null
    order by created_at desc limit 1;
    if v_last = v_text and v_last_at > now() - interval '5 seconds' then
        raise exception 'You just sent that.';
    end if;

    insert into public.room_messages (room_id, sender_id, sender_name, sender_avatar, message, client_id)
    values (p_room_id, v_user, v_me.display_name, v_me.avatar_index, v_text, p_client_id)
    returning * into v_row;

    return to_jsonb(v_row);
end;
$$;

-- Your own messages, or anyone's if you are the host.
create or replace function public.delete_room_message(p_message_id uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_msg public.room_messages;
    v_host uuid;
begin
    select * into v_msg from public.room_messages where id = p_message_id;
    if not found or not public.is_room_member(v_msg.room_id) then
        raise exception 'Message not found.';
    end if;
    if v_msg.message_type <> 'text' then raise exception 'That message cannot be deleted.'; end if;

    select host_id into v_host from public.rooms where id = v_msg.room_id;
    if auth.uid() is distinct from v_msg.sender_id and auth.uid() is distinct from v_host then
        raise exception 'You can only delete your own messages.';
    end if;

    update public.room_messages set message = '', deleted_at = now() where id = p_message_id;
end;
$$;

create or replace function public.moderate_player(p_room_id uuid, p_player uuid, p_action text)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_host uuid;
begin
    select host_id into v_host from public.rooms where id = p_room_id;
    if v_host is distinct from auth.uid() then raise exception 'Only the host can do that.'; end if;
    if p_player = auth.uid() then raise exception 'You cannot do that to yourself.'; end if;

    if p_action = 'kick' then
        perform private.remove_player(p_room_id, p_player);
    elsif p_action in ('mute', 'unmute') then
        update public.room_players set chat_muted = (p_action = 'mute')
        where room_id = p_room_id and player_id = p_player;
    else
        raise exception 'Unknown action.';
    end if;
end;
$$;

do $$
declare
    f text;
begin
    foreach f in array array[
        'send_room_message(uuid, text, uuid)', 'delete_room_message(uuid)', 'moderate_player(uuid, uuid, text)'
    ] loop
        execute format('revoke execute on function public.%s from public, anon', f);
        execute format('grant execute on function public.%s to authenticated', f);
    end loop;
end;
$$;

notify pgrst, 'reload schema';
commit;
