-- Stage 2: friend codes, friend requests, blocks, reports, room invites. Safe to re-run.
begin;

create or replace function private.new_friend_code()
returns text language sql volatile as $$
    select string_agg(substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', 1 + floor(random() * 32)::int, 1), '')
    from generate_series(1, 8);
$$;

alter table public.profiles add column if not exists friend_code text;
alter table public.profiles add column if not exists last_active_at timestamptz not null default now();
update public.profiles set friend_code = private.new_friend_code() where friend_code is null;
alter table public.profiles alter column friend_code set default private.new_friend_code();
alter table public.profiles alter column friend_code set not null;
create unique index if not exists idx_profiles_friend_code on public.profiles(friend_code);

-- Profiles are reached through functions, which return only what is needed.
drop policy if exists "Profiles are viewable by everyone" on public.profiles;
drop policy if exists "Users can insert their own profile" on public.profiles;
drop policy if exists "Users can update their own profile" on public.profiles;
drop policy if exists "Users can view their own profile" on public.profiles;
create policy "Users can view their own profile" on public.profiles
    for select to authenticated using (auth.uid() = id);

create table if not exists public.friendships (
    id uuid primary key default gen_random_uuid(),
    requester_id uuid not null references public.profiles(id) on delete cascade,
    addressee_id uuid not null references public.profiles(id) on delete cascade,
    status text not null default 'pending' check (status in ('pending', 'accepted')),
    created_at timestamptz not null default now(),
    responded_at timestamptz,
    check (requester_id <> addressee_id)
);
create unique index if not exists idx_friendships_pair on public.friendships
    (least(requester_id, addressee_id), greatest(requester_id, addressee_id));
create index if not exists idx_friendships_addressee on public.friendships(addressee_id);
alter table public.friendships enable row level security;

create table if not exists public.player_blocks (
    blocker_id uuid not null references public.profiles(id) on delete cascade,
    blocked_id uuid not null references public.profiles(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (blocker_id, blocked_id),
    check (blocker_id <> blocked_id)
);
alter table public.player_blocks enable row level security;
drop policy if exists "Users can view their own blocks" on public.player_blocks;
create policy "Users can view their own blocks" on public.player_blocks
    for select to authenticated using (auth.uid() = blocker_id);

create table if not exists public.player_reports (
    id uuid primary key default gen_random_uuid(),
    reporter_id uuid not null references public.profiles(id) on delete cascade,
    reported_id uuid not null references public.profiles(id) on delete cascade,
    room_id uuid references public.rooms(id) on delete set null,
    reason text not null check (char_length(reason) between 1 and 40),
    details text check (char_length(details) <= 500),
    created_at timestamptz not null default now()
);
alter table public.player_reports enable row level security;

create table if not exists public.room_invites (
    id uuid primary key default gen_random_uuid(),
    room_id uuid not null references public.rooms(id) on delete cascade,
    room_code text not null,
    from_id uuid not null references public.profiles(id) on delete cascade,
    from_name text not null,
    to_id uuid not null references public.profiles(id) on delete cascade,
    created_at timestamptz not null default now(),
    unique (room_id, from_id, to_id)
);
create index if not exists idx_room_invites_to on public.room_invites(to_id);
alter table public.room_invites enable row level security;
drop policy if exists "Users can view invites sent to them" on public.room_invites;
create policy "Users can view invites sent to them" on public.room_invites
    for select to authenticated using (auth.uid() = to_id);

do $$
begin
    alter publication supabase_realtime add table public.room_invites;
exception when duplicate_object then null;
end;
$$;

create or replace function private.is_blocked_either_way(a uuid, b uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
    select exists (
        select 1 from public.player_blocks
        where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a)
    );
$$;

create or replace function private.are_friends(a uuid, b uuid)
returns boolean language sql stable security definer
set search_path = public, pg_temp as $$
    select exists (
        select 1 from public.friendships
        where status = 'accepted'
          and least(requester_id, addressee_id) = least(a, b)
          and greatest(requester_id, addressee_id) = greatest(a, b)
    );
$$;

create or replace function private.request_friend(p_me uuid, p_target uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_row public.friendships;
begin
    if p_target = p_me then raise exception 'That is your own code.'; end if;
    if private.is_blocked_either_way(p_me, p_target) then
        raise exception 'No player found with that code.';
    end if;

    select * into v_row from public.friendships
    where least(requester_id, addressee_id) = least(p_me, p_target)
      and greatest(requester_id, addressee_id) = greatest(p_me, p_target)
    for update;

    if found then
        if v_row.status = 'accepted' then return jsonb_build_object('status', 'already_friends'); end if;
        if v_row.requester_id = p_me then return jsonb_build_object('status', 'already_requested'); end if;
        update public.friendships set status = 'accepted', responded_at = now() where id = v_row.id;
        return jsonb_build_object('status', 'accepted');
    end if;

    if (select count(*) from public.friendships where requester_id = p_me and status = 'pending') >= 50 then
        raise exception 'You have too many pending requests.';
    end if;

    insert into public.friendships (requester_id, addressee_id) values (p_me, p_target);
    return jsonb_build_object('status', 'requested');
end;
$$;

create or replace function public.my_profile(p_display_name text default null, p_avatar int default null)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_user uuid := auth.uid();
    v_row public.profiles;
begin
    if v_user is null then raise exception 'Please sign in first.'; end if;

    insert into public.profiles (id, display_name, avatar_index)
    values (
        v_user,
        private.clean_name(p_display_name, 'Player'),
        least(greatest(coalesce(p_avatar, 0), 0), 7)
    )
    on conflict (id) do update
    set display_name = case when p_display_name is null then profiles.display_name
                            else private.clean_name(p_display_name, profiles.display_name) end,
        avatar_index = case when p_avatar is null then profiles.avatar_index
                            else least(greatest(p_avatar, 0), 7) end,
        last_active_at = now()
    returning * into v_row;

    return jsonb_build_object(
        'id', v_row.id, 'display_name', v_row.display_name,
        'avatar_index', v_row.avatar_index, 'friend_code', v_row.friend_code
    );
end;
$$;

create or replace function public.touch_presence()
returns void language sql security definer
set search_path = public, pg_temp as $$
    update public.profiles set last_active_at = now() where id = auth.uid();
$$;

create or replace function public.send_friend_request(p_code text)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_target uuid;
begin
    if auth.uid() is null then raise exception 'Please sign in first.'; end if;
    select id into v_target from public.profiles where friend_code = upper(trim(p_code));
    if v_target is null then raise exception 'No player found with that code.'; end if;
    return private.request_friend(auth.uid(), v_target);
end;
$$;

-- Add someone you are sharing a room with, without needing their code.
create or replace function public.send_friend_request_in_room(p_room_id uuid, p_player uuid)
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    if not public.is_room_member(p_room_id) or not exists (
        select 1 from public.room_players where room_id = p_room_id and player_id = p_player
    ) then
        raise exception 'That player is not in your room.';
    end if;
    return private.request_friend(auth.uid(), p_player);
end;
$$;

create or replace function public.respond_friend_request(p_friendship_id uuid, p_accept boolean)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    if p_accept then
        update public.friendships set status = 'accepted', responded_at = now()
        where id = p_friendship_id and addressee_id = auth.uid() and status = 'pending';
    else
        delete from public.friendships
        where id = p_friendship_id and addressee_id = auth.uid() and status = 'pending';
    end if;
end;
$$;

create or replace function public.remove_friend(p_friendship_id uuid)
returns void language sql security definer
set search_path = public, pg_temp as $$
    delete from public.friendships
    where id = p_friendship_id and auth.uid() in (requester_id, addressee_id);
$$;

create or replace function public.list_friends()
returns jsonb language sql stable security definer
set search_path = public, pg_temp as $$
    select coalesce(jsonb_agg(row_to_json(x) order by x.online desc, x.display_name), '[]'::jsonb)
    from (
        select f.id as friendship_id,
               p.id as user_id,
               p.display_name,
               p.avatar_index,
               case when f.status = 'accepted' then 'friend'
                    when f.addressee_id = auth.uid() then 'incoming'
                    else 'outgoing' end as status,
               (f.status = 'accepted' and p.last_active_at > now() - interval '90 seconds') as online
        from public.friendships f
        join public.profiles p
          on p.id = case when f.requester_id = auth.uid() then f.addressee_id else f.requester_id end
        where auth.uid() in (f.requester_id, f.addressee_id)
    ) x;
$$;

create or replace function public.block_player(p_player uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    if p_player = auth.uid() then raise exception 'You cannot block yourself.'; end if;
    insert into public.player_blocks (blocker_id, blocked_id)
    values (auth.uid(), p_player) on conflict do nothing;
    delete from public.friendships
    where least(requester_id, addressee_id) = least(auth.uid(), p_player)
      and greatest(requester_id, addressee_id) = greatest(auth.uid(), p_player);
end;
$$;

create or replace function public.unblock_player(p_player uuid)
returns void language sql security definer
set search_path = public, pg_temp as $$
    delete from public.player_blocks where blocker_id = auth.uid() and blocked_id = p_player;
$$;

create or replace function public.list_blocked()
returns jsonb language sql stable security definer
set search_path = public, pg_temp as $$
    select coalesce(jsonb_agg(jsonb_build_object('user_id', p.id, 'display_name', p.display_name, 'avatar_index', p.avatar_index)), '[]'::jsonb)
    from public.player_blocks b join public.profiles p on p.id = b.blocked_id
    where b.blocker_id = auth.uid();
$$;

create or replace function public.report_player(p_player uuid, p_room_id uuid, p_reason text, p_details text default null)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
begin
    if auth.uid() is null then raise exception 'Please sign in first.'; end if;
    if (select count(*) from public.player_reports
        where reporter_id = auth.uid() and created_at > now() - interval '1 hour') >= 10 then
        raise exception 'Too many reports. Please try again later.';
    end if;
    insert into public.player_reports (reporter_id, reported_id, room_id, reason, details)
    values (auth.uid(), p_player, p_room_id, left(trim(p_reason), 40), left(p_details, 500));
end;
$$;

create or replace function public.invite_friend(p_room_id uuid, p_friend uuid)
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    v_room public.rooms;
    v_name text;
begin
    select * into v_room from public.rooms where id = p_room_id;
    if not found or not public.is_room_member(p_room_id) then raise exception 'You are not in that room.'; end if;
    if v_room.status <> 'waiting' then raise exception 'The game has already started.'; end if;
    if not private.are_friends(auth.uid(), p_friend) then raise exception 'You can only invite friends.'; end if;

    select display_name into v_name from public.room_players
    where room_id = p_room_id and player_id = auth.uid();

    delete from public.room_invites where room_id = p_room_id and from_id = auth.uid() and to_id = p_friend;
    insert into public.room_invites (room_id, room_code, from_id, from_name, to_id)
    values (p_room_id, v_room.code, auth.uid(), v_name, p_friend);
end;
$$;

create or replace function public.dismiss_invite(p_invite_id uuid)
returns void language sql security definer
set search_path = public, pg_temp as $$
    delete from public.room_invites where id = p_invite_id and to_id = auth.uid();
$$;

do $$
declare
    f text;
begin
    foreach f in array array[
        'my_profile(text, int)', 'touch_presence()', 'send_friend_request(text)',
        'send_friend_request_in_room(uuid, uuid)', 'respond_friend_request(uuid, boolean)',
        'remove_friend(uuid)', 'list_friends()', 'block_player(uuid)', 'unblock_player(uuid)',
        'list_blocked()', 'report_player(uuid, uuid, text, text)',
        'invite_friend(uuid, uuid)', 'dismiss_invite(uuid)'
    ] loop
        execute format('revoke execute on function public.%s from public, anon', f);
        execute format('grant execute on function public.%s to authenticated', f);
    end loop;
end;
$$;

notify pgrst, 'reload schema';
commit;
