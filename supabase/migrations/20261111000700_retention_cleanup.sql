-- Automatic cleanup of temporary room data, storage monitoring, and the
-- schedule that runs them. Safe to re-run.
begin;

-- One row of tunable retention values. Change them with a plain UPDATE.
create table if not exists private.retention_settings (
    id boolean primary key default true check (id),
    abandoned_after interval not null default '1 hour',        -- nobody has checked in
    idle_lobby_after interval not null default '2 hours',      -- lobby with no activity
    finished_room_after interval not null default '24 hours',  -- match over
    presence_grace interval not null default '10 minutes',     -- never delete while someone is here
    invite_after interval not null default '24 hours',
    end_request_after interval not null default '1 hour',
    message_after interval not null default '24 hours',
    old_session_after interval not null default '24 hours',    -- earlier matches in a long-lived room
    report_after interval not null default '90 days',
    batch_size int not null default 500,
    storage_warn_bytes bigint not null default 400 * 1024 * 1024,  -- free plan is 500 MB
    alert_webhook_url text,
    keep_runs int not null default 200
);
insert into private.retention_settings (id) values (true) on conflict do nothing;

create table if not exists private.cleanup_runs (
    id bigint generated always as identity primary key,
    ran_at timestamptz not null default now(),
    rooms_deleted int not null default 0,
    sessions_deleted int not null default 0,
    messages_deleted int not null default 0,
    invites_deleted int not null default 0,
    requests_deleted int not null default 0,
    reports_deleted int not null default 0,
    database_bytes bigint,
    warning text,
    error text
);
create index if not exists idx_cleanup_runs_time on private.cleanup_runs(ran_at desc);

-- Cleanup scans use these.
create index if not exists idx_room_invites_created on public.room_invites(created_at);
create index if not exists idx_room_messages_created on public.room_messages(created_at);
create index if not exists idx_player_reports_created on public.player_reports(created_at);
create index if not exists idx_end_requests_resolved on public.discussion_end_requests(resolved_at) where status <> 'pending';

-- Deletes in batches until nothing is left or the safety cap is reached.
create or replace function private.cleanup_once()
returns private.cleanup_runs language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    s private.retention_settings;
    r private.cleanup_runs;
    n int;
    i int;
begin
    select * into s from private.retention_settings;
    r.ran_at := now();
    r.rooms_deleted := 0; r.sessions_deleted := 0; r.messages_deleted := 0;
    r.invites_deleted := 0; r.requests_deleted := 0; r.reports_deleted := 0;

    -- Rooms. Members, sessions, clues, votes, assignments, results, chat,
    -- invites and end requests all go with them through ON DELETE CASCADE.
    for i in 1..20 loop
        with seen as (
            select room_id, max(last_seen_at) as last_seen from public.room_players group by room_id
        ), doomed as (
            select rm.id from public.rooms rm
            left join seen on seen.room_id = rm.id
            where (seen.last_seen is null or seen.last_seen < now() - s.presence_grace)
              and (
                    seen.last_seen is null and rm.last_activity_at < now() - s.presence_grace
                 or (rm.status in ('waiting', 'playing') and coalesce(seen.last_seen, rm.last_activity_at) < now() - s.abandoned_after)
                 or (rm.status = 'waiting' and rm.last_activity_at < now() - s.idle_lobby_after)
                 or (rm.status in ('finished', 'closed') and rm.last_activity_at < now() - s.finished_room_after)
              )
            order by rm.last_activity_at
            limit s.batch_size
            for update of rm skip locked
        )
        delete from public.rooms where id in (select id from doomed);
        get diagnostics n = row_count;
        r.rooms_deleted := r.rooms_deleted + n;
        exit when n < s.batch_size;
    end loop;

    -- Earlier matches in rooms that are still in use.
    delete from public.game_sessions gs
    using public.rooms rm
    where rm.id = gs.room_id
      and gs.match_id is distinct from rm.match_id
      and gs.created_at < now() - s.old_session_after;
    get diagnostics n = row_count;
    r.sessions_deleted := n;

    delete from public.room_messages where id in (
        select id from public.room_messages where created_at < now() - s.message_after limit s.batch_size * 10
    );
    get diagnostics n = row_count;
    r.messages_deleted := n;

    delete from public.room_invites where created_at < now() - s.invite_after;
    get diagnostics n = row_count;
    r.invites_deleted := n;

    update public.discussion_end_requests set status = 'expired', resolved_at = now()
    where status = 'pending' and expires_at <= now();
    delete from public.discussion_end_requests
    where status <> 'pending' and resolved_at < now() - s.end_request_after;
    get diagnostics n = row_count;
    r.requests_deleted := n;

    delete from public.player_reports where created_at < now() - s.report_after;
    get diagnostics n = row_count;
    r.reports_deleted := n;

    -- Rounds whose word record outlived its session (normally removed by cascade).
    delete from private.session_words sw
    where not exists (select 1 from public.game_sessions gs where gs.id = sw.session_id);

    r.database_bytes := pg_database_size(current_database());
    if r.database_bytes >= s.storage_warn_bytes then
        r.warning := format('Database is %s, over the %s warning level.',
                            pg_size_pretty(r.database_bytes), pg_size_pretty(s.storage_warn_bytes));
    end if;
    return r;
end;
$$;

-- Entry point for the schedule. Never runs twice at once, always records a
-- summary, and alerts after three failures in a row when a webhook is set.
create or replace function private.run_cleanup()
returns void language plpgsql security definer
set search_path = public, pg_temp as $$
declare
    s private.retention_settings;
    r private.cleanup_runs;
    v_failures int;
begin
    if not pg_try_advisory_xact_lock(hashtext('hushbug_cleanup')) then return; end if;
    select * into s from private.retention_settings;

    begin
        r := private.cleanup_once();
    exception when others then
        r.ran_at := now();
        r.error := sqlerrm;
    end;

    insert into private.cleanup_runs (ran_at, rooms_deleted, sessions_deleted, messages_deleted, invites_deleted,
                                      requests_deleted, reports_deleted, database_bytes, warning, error)
    values (r.ran_at, coalesce(r.rooms_deleted, 0), coalesce(r.sessions_deleted, 0), coalesce(r.messages_deleted, 0),
            coalesce(r.invites_deleted, 0), coalesce(r.requests_deleted, 0), coalesce(r.reports_deleted, 0),
            r.database_bytes, r.warning, r.error);

    delete from private.cleanup_runs where id not in (
        select id from private.cleanup_runs order by ran_at desc limit s.keep_runs
    );

    if s.alert_webhook_url is not null then
        select count(*) into v_failures from (
            select error from private.cleanup_runs order by ran_at desc limit 3
        ) last3 where error is not null;
        if v_failures = 3 or r.warning is not null then
            begin
                execute 'select net.http_post(url := $1, body := $2)'
                using s.alert_webhook_url,
                      jsonb_build_object('text', coalesce('Hushbug cleanup failing: ' || r.error, 'Hushbug: ' || r.warning));
            exception when others then
                raise warning 'cleanup alert failed: %', sqlerrm;
            end;
        end if;
    end if;
end;
$$;

-- Largest tables, for the SQL Editor: select * from private.storage_report();
create or replace function private.storage_report()
returns table (table_name text, total_size text, total_bytes bigint, row_estimate bigint)
language sql stable security definer
set search_path = public, pg_temp as $$
    select format('%I.%I', n.nspname, c.relname), pg_size_pretty(pg_total_relation_size(c.oid)),
           pg_total_relation_size(c.oid), c.reltuples::bigint
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where c.relkind = 'r' and n.nspname in ('public', 'private', 'auth')
    order by pg_total_relation_size(c.oid) desc
    limit 20;
$$;

revoke all on all functions in schema private from public, anon, authenticated;

-- Run every 15 minutes. Needs the pg_cron extension (Dashboard > Integrations > Cron).
do $$
begin
    create extension if not exists pg_cron;
    perform cron.unschedule(jobid) from cron.job where jobname = 'hushbug-cleanup';
    perform cron.schedule('hushbug-cleanup', '*/15 * * * *', 'select private.run_cleanup()');
exception when others then
    raise warning 'Cleanup not scheduled (%). Enable pg_cron and re-run this file.', sqlerrm;
end;
$$;

commit;
