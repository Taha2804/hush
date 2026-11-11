// Runs schema.sql plus every migration on an in-memory Postgres, then plays
// through the backend as several simulated users, including hostile ones.
//   cd supabase/tests && npm install && npm test
import { PGlite } from '@electric-sql/pglite';
import { readFileSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomUUID } from 'node:crypto';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const db = new PGlite();

await db.exec(`
  create role anon nologin; create role authenticated nologin; create role service_role nologin bypassrls;
  create schema auth; create schema extensions;
  create table auth.users (id uuid primary key, is_anonymous boolean default true);
  create function auth.uid() returns uuid language sql stable as
    $$ select nullif(current_setting('test.uid', true), '')::uuid $$;
  grant usage on schema public, auth to anon, authenticated;
  grant execute on function auth.uid() to anon, authenticated;
  alter default privileges in schema public grant all on tables to anon, authenticated;
  alter default privileges in schema public grant all on functions to anon, authenticated;
  create publication supabase_realtime;
`);

await db.exec(readFileSync(join(root, 'schema.sql'), 'utf8').replace(/CREATE EXTENSION[^;]*;/g, ''));
for (const f of readdirSync(join(root, 'migrations')).sort()) {
  try {
    await db.exec(readFileSync(join(root, 'migrations', f), 'utf8'));
  } catch (e) {
    console.error(`FAILED applying ${f}: ${e.message}`);
    process.exit(1);
  }
}
// Migrations must be re-runnable.
for (const f of readdirSync(join(root, 'migrations')).sort()) {
  await db.exec(readFileSync(join(root, 'migrations', f), 'utf8'));
}
console.log('migrations applied twice without error');

let passed = 0, failed = 0;
const ok = (name, cond, extra = '') => {
  if (cond) { passed++; console.log(`  ok   ${name}`); }
  else { failed++; console.log(`  FAIL ${name} ${extra}`); }
};

async function as(uid, sql, params = []) {
  await db.exec(uid
    ? `set role authenticated; set test.uid = '${uid}';`
    : `set role anon; set test.uid = '';`);
  try { return (await db.query(sql, params)).rows; }
  finally { await db.exec(`reset role; set test.uid = '';`); }
}
const rpc = async (uid, fn, args = []) => {
  const ph = args.map((_, i) => `$${i + 1}`).join(',');
  const rows = await as(uid, `select public.${fn}(${ph}) as r`, args);
  return rows[0].r;
};
const fails = async (uid, fn, args = []) => {
  try { await rpc(uid, fn, args); return null; } catch (e) { return e.message; }
};
const sqlFails = async (uid, sql) => {
  try { await as(uid, sql); return null; } catch (e) { return e.message; }
};
const user = async () => {
  const id = randomUUID();
  await db.query('insert into auth.users(id) values ($1)', [id]);
  return id;
};
const admin = async (sql, p = []) => (await db.query(sql, p)).rows;
export const ctx = { db, as, rpc, fails, sqlFails, user, admin, ok };

// ---- Stage 1: rooms ------------------------------------------------------
console.log('\nStage 1: private rooms');
const [host, p2, p3, p4, outsider] = await Promise.all([user(), user(), user(), user(), user()]);

const words = (await admin('select count(*)::int c, count(distinct category)::int k from private.word_bank'))[0];
ok('word bank is installed', words.c > 3000 && words.k > 15, JSON.stringify(words));

const room = await rpc(host, 'create_room', ['Host', 1, JSON.stringify({ mode: 'hint', imposterCount: 1, discussionSeconds: 60, junk: 'x' })]);
ok('server generates a 6-char code', /^[A-Z2-9]{6}$/.test(room.code), room.code);
ok('unknown config keys are dropped', !(await admin('select config from rooms where id=$1', [room.room_id]))[0].config.junk);

ok('anon cannot create a room', (await fails(null, 'create_room', ['x', 0, null])) !== null);
ok('anon cannot start a game', (await fails(null, 'start_online_game', [room.room_id])) !== null);
ok('wrong code is rejected', /No room/.test(await fails(p2, 'join_room', ['ZZZZZZ', 'A', 0])));
ok('outsider cannot see rooms', (await as(outsider, 'select * from rooms')).length === 0);
ok('outsider cannot see room players', (await as(outsider, 'select * from room_players')).length === 0);
await as(outsider, `insert into room_players(room_id, player_id, display_name) select '${room.room_id}', '${outsider}', 'x' where false`);
ok('outsider cannot insert themselves', (await sqlFails(outsider, `insert into room_players(room_id, player_id, display_name) values ('${room.room_id}', '${outsider}', 'x')`)) !== null);

await rpc(p2, 'join_room', [room.code.toLowerCase(), 'P2', 2]);
await rpc(p3, 'join_room', [room.code, 'P3', 3]);
ok('member sees the room', (await as(p2, 'select * from rooms')).length === 1);
ok('member sees all players', (await as(p2, 'select * from room_players')).length === 3);
await as(p2, `update room_players set is_host = true where player_id = '${p2}'`);
ok('player cannot make themselves host', (await admin('select is_host from room_players where player_id=$1', [p2]))[0].is_host === false);
ok('non-host cannot start', /host/i.test(await fails(p2, 'start_online_game', [room.room_id])));

const twoRoom = await rpc(p4, 'create_room', ['P4', 0, null]);
ok('too few players cannot start', /3 players/.test(await fails(p4, 'start_online_game', [twoRoom.room_id])));
await rpc(p4, 'join_room', [room.code, 'P4', 4]);
ok('joining elsewhere leaves the old room (empty room removed)', (await admin('select 1 from rooms where id=$1', [twoRoom.room_id])).length === 0);

await rpc(host, 'update_room_settings', [room.room_id, 1, 'simultaneous', 'private']);
const started = await rpc(host, 'start_online_game', [room.room_id]);
const sid = started.session_id;
ok('double start is rejected', /already running/.test(await fails(host, 'start_online_game', [room.room_id])));
ok('late joiner is rejected', /already started/.test(await fails(outsider, 'join_room', [room.code, 'X', 0])));
ok('member can rejoin mid-game', (await rpc(p2, 'join_room', [room.code, 'P2', 2])).status === 'playing');
ok('word bank is not reachable from the API', (await sqlFails(host, 'select * from private.word_bank')) !== null);
ok('outsider cannot see the session', (await as(outsider, 'select * from game_sessions')).length === 0);
ok('outsider cannot read assignments', (await fails(outsider, 'get_my_assignment', [sid])) !== null);
ok('players see only their own assignment', (await as(p2, 'select * from private_player_assignments')).length === 1);

const assigns = await admin('select * from private_player_assignments where session_id=$1', [sid]);
const imp = assigns.filter((a) => a.is_imposter);
ok('exactly one imposter', imp.length === 1);
ok('crew share one word', new Set(assigns.filter((a) => !a.is_imposter).map((a) => a.secret_word)).size === 1);
ok('imposter does not get the word', imp[0].secret_word === 'IMPOSTER' && imp[0].hint);

// Imposter must not always be first in the turn order (was a real bug).
let firstIsImp = 0;
for (let i = 0; i < 30; i++) {
  const a = await user(); const b = await user(); const c = await user();
  const r = await rpc(a, 'create_room', ['A', 0, null]);
  await rpc(b, 'join_room', [r.code, 'B', 0]); await rpc(c, 'join_room', [r.code, 'C', 0]);
  const s = await rpc(a, 'start_online_game', [r.room_id]);
  const [row] = await admin(`select (turn_order->>0)::uuid first_p from game_sessions where id=$1`, [s.session_id]);
  const [as2] = await admin(`select is_imposter from private_player_assignments where session_id=$1 and player_id=$2`, [s.session_id, row.first_p]);
  if (as2.is_imposter) firstIsImp++;
}
ok('imposter is not always first to speak', firstIsImp > 0 && firstIsImp < 30, `${firstIsImp}/30`);

ok('non-host cannot advance', /host/i.test(await fails(p2, 'advance_game_phase', [sid, 'clue'])));
ok('anon cannot advance', (await fails(null, 'advance_game_phase', [sid, 'clue'])) !== null);
let res = await rpc(host, 'advance_game_phase', [sid, 'vote']);
ok('phases cannot be skipped', res.phase === 'reveal');
await rpc(host, 'advance_game_phase', [sid, 'clue']);

const session = async () => (await admin('select * from game_sessions where id=$1', [sid]))[0];
const current = (s) => s.turn_order[s.clue_step % s.turn_order.length];
let s = await session();
const notTurn = s.turn_order.find((x) => x !== current(s));
ok('cannot give a clue out of turn', /not your turn/i.test(await fails(notTurn, 'submit_online_clue', [sid, 'hi'])));
ok('direct clue insert is blocked', (await sqlFails(current(s), `insert into game_clues(session_id, player_id, clue_step, clue_text) values ('${sid}','${current(s)}',0,'x')`)) !== null);

await rpc(current(s), 'submit_online_clue', [sid, 'first']);
s = await session();
ok('host cannot skip a connected player', /still connected/.test(await fails(host, 'skip_clue_turn', [sid])));
const dropped = current(s);
await admin(`update room_players set last_seen_at = now() - interval '2 minutes' where player_id = $1 and room_id = $2`, [dropped, room.room_id]);
if (dropped !== host) {
  await rpc(host, 'room_heartbeat', [room.room_id]);
} else {
  await rpc(s.turn_order.find((x) => x !== host), 'room_heartbeat', [room.room_id]);
}
ok('silent player is marked disconnected', (await admin('select is_connected from room_players where player_id=$1 and room_id=$2', [dropped, room.room_id]))[0].is_connected === false);
const hostNow = (await admin('select host_id from rooms where id=$1', [room.room_id]))[0].host_id;
ok('host passes on when host goes silent', dropped === host ? hostNow !== host : hostNow === host);
await rpc(hostNow, 'skip_clue_turn', [sid]);
s = await session();
ok('host can skip a disconnected player', current(s) !== dropped);
await rpc(dropped, 'room_heartbeat', [room.room_id]);
ok('returning player is connected again', (await admin('select is_connected from room_players where player_id=$1 and room_id=$2', [dropped, room.room_id]))[0].is_connected === true);

while ((await session()).phase === 'clue') {
  s = await session();
  await rpc(current(s), 'submit_online_clue', [sid, `clue ${s.clue_step}`]);
}
s = await session();
ok('last clue moves the game to discussion', s.phase === 'discussion');
ok('discussion timer is fresh', new Date(s.discussion_end_time) > new Date());
ok('host cannot cut discussion short', /timer/.test(await fails(hostNow, 'advance_game_phase', [sid, 'vote'])));
await admin(`update game_sessions set discussion_end_time = now() - interval '1 second' where id = $1`, [sid]);
await rpc(p2 === hostNow ? p3 : p2, 'sync_game', [sid]);
ok('timer running out opens voting', (await session()).phase === 'vote');

const players = s.turn_order;
const impId = imp[0].player_id;
const crew = players.filter((x) => x !== impId);
ok('tally with no votes is rejected', /voted/i.test(await fails(hostNow, 'tally_online_votes', [sid])));
ok('cannot vote for yourself', /yourself/i.test(await fails(crew[0], 'cast_online_vote', [sid, crew[0]])));
ok('direct vote insert is blocked', (await sqlFails(crew[0], `insert into game_votes(session_id, voter_id, target_id) values ('${sid}','${crew[0]}','${impId}')`)) !== null);

await rpc(crew[0], 'cast_online_vote', [sid, impId]);
await rpc(crew[1], 'cast_online_vote', [sid, crew[0]]);
ok('non-host cannot tally', /host/i.test(await fails(players.find((x) => x !== hostNow), 'tally_online_votes', [sid])));
res = await rpc(hostNow, 'tally_online_votes', [sid]);
ok('a tie triggers a revote', res.tie === true);
for (const c of crew) await rpc(c, 'cast_online_vote', [sid, impId]);
res = await rpc(hostNow, 'tally_online_votes', [sid]);
ok('catching the imposter wins for crew', res.winner === 'crew', JSON.stringify(res));
ok('match over after the last round', (await admin('select status from rooms where id=$1', [room.room_id]))[0].status === 'finished');
ok('results visible to members', (await as(crew[0], 'select * from game_results where session_id=$1', [sid])).length === 1);
ok('results hidden from outsiders', (await as(outsider, 'select * from game_results')).length === 0);

const second = await rpc(hostNow, 'start_online_game', [room.room_id]);
const wordIds = await admin('select word_id from private.session_words where room_id=$1', [room.room_id]);
ok('next game uses a new word', new Set(wordIds.map((w) => w.word_id)).size === 2);

// Imposter leaving decides the game.
const [imp2] = await admin('select player_id from private_player_assignments where session_id=$1 and is_imposter', [second.session_id]);
await rpc(imp2.player_id, 'leave_room', [room.room_id]);
ok('imposter leaving ends the game', (await admin('select phase, win_reason from game_sessions where id=$1', [second.session_id]))[0].win_reason === 'imposterLeft');
const active = await rpc(crew[0] === imp2.player_id ? crew[1] : crew[0], 'my_active_room');
ok('my_active_room finds the room', active && active.room_id === room.room_id);

const extra = await import('./stages.mjs').catch((e) => {
  if (e.code === 'ERR_MODULE_NOT_FOUND') return null;
  throw e;
});
if (extra) await extra.run(ctx);

console.log(`\n${passed} passed, ${failed} failed`);
process.exit(failed ? 1 : 0);
