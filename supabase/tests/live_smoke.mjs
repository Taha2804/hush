// Plays a short game against the live project as three guest players.
//   node supabase/tests/live_smoke.mjs            -> full run, then leaves
//   node supabase/tests/live_smoke.mjs ABC123     -> two bots join that room and wait
const URL = 'https://vctdkitastvopatlwkhc.supabase.co';
const KEY = 'sb_publishable_RktzXaKLDMuHxNY2jGwpGw_wcOwlIqC';

async function guest(name) {
  const r = await fetch(`${URL}/auth/v1/signup`, {
    method: 'POST', headers: { apikey: KEY, 'Content-Type': 'application/json' }, body: '{}',
  });
  const j = await r.json();
  if (!j.access_token) throw new Error(`guest sign-in failed: ${JSON.stringify(j)}`);
  const h = { apikey: KEY, Authorization: `Bearer ${j.access_token}`, 'Content-Type': 'application/json' };
  const rpc = async (fn, args = {}) => {
    const res = await fetch(`${URL}/rest/v1/rpc/${fn}`, { method: 'POST', headers: h, body: JSON.stringify(args) });
    const body = await res.text();
    if (!res.ok) throw new Error(`${name} ${fn}: ${body}`);
    return body ? JSON.parse(body) : null;
  };
  const select = async (q) => (await fetch(`${URL}/rest/v1/${q}`, { headers: h })).json();
  return { name, id: j.user.id, rpc, select };
}

const check = (label, cond) => { console.log(`${cond ? 'ok  ' : 'FAIL'} ${label}`); if (!cond) process.exitCode = 1; };

const joinCode = process.argv[2];
if (joinCode) {
  const bots = [await guest('Alex'), await guest('Sam')];
  for (const b of bots) await b.rpc('join_room', { p_code: joinCode, p_display_name: b.name, p_avatar: 2 });
  for (const b of bots) await b.rpc('toggle_ready', { p_room_id: (await b.rpc('my_active_room')).room_id, p_is_ready: true });
  const roomId = (await bots[0].rpc('my_active_room')).room_id;
  console.log('bots joined', roomId);
  await bots[0].rpc('send_room_message', { p_room_id: roomId, p_message: 'Hi from Alex 👋' });
  // Keep them connected and play their turns automatically for 10 minutes.
  const end = Date.now() + 10 * 60 * 1000;
  while (Date.now() < end) {
    for (const b of bots) {
      await b.rpc('room_heartbeat', { p_room_id: roomId }).catch(() => {});
      const [s] = await b.select(`game_sessions?room_id=eq.${roomId}&order=created_at.desc&limit=1`);
      if (s?.phase === 'clue' && s.turn_order[s.clue_step % s.turn_order.length] === b.id) {
        await b.rpc('submit_online_clue', { p_session_id: s.id, p_clue_text: `${b.name} clue` }).catch(() => {});
      }
      if (s?.phase === 'vote') {
        const target = s.turn_order.find((x) => x !== b.id);
        await b.rpc('cast_online_vote', { p_session_id: s.id, p_target_id: target }).catch(() => {});
      }
    }
    await new Promise((r) => setTimeout(r, 4000));
  }
  for (const b of bots) await b.rpc('leave_room', { p_room_id: roomId }).catch(() => {});
  process.exit(0);
}

const [a, b, c, outsider] = [await guest('Ann'), await guest('Ben'), await guest('Cat'), await guest('Out')];
const room = await a.rpc('create_room', { p_display_name: 'Ann', p_avatar: 1, p_config: { mode: 'hint', imposterCount: 1 } });
check(`room created with code ${room.code}`, /^[A-Z2-9]{6}$/.test(room.code));
await b.rpc('join_room', { p_code: room.code, p_display_name: 'Ben', p_avatar: 2 });
await c.rpc('join_room', { p_code: room.code, p_display_name: 'Cat', p_avatar: 3 });
check('outsider cannot see the room', (await outsider.select(`rooms?id=eq.${room.room_id}`)).length === 0);

const msg = await b.rpc('send_room_message', { p_room_id: room.room_id, p_message: 'Ready 😀' });
check('chat message sent', msg.message === 'Ready 😀');
check('members read chat', (await c.select(`room_messages?room_id=eq.${room.room_id}&message_type=eq.text`)).length === 1);
check('outsider cannot read chat', (await outsider.select(`room_messages?room_id=eq.${room.room_id}`)).length === 0);

const game = await a.rpc('start_online_game', { p_room_id: room.room_id });
const assigns = await Promise.all([a, b, c].map((p) => p.rpc('get_my_assignment', { p_session_id: game.session_id })));
const crew = assigns.filter((x) => !x.is_imposter);
check(`category: ${game.category}`, !!game.category);
check('one imposter, who does not get the word', assigns.filter((x) => x.is_imposter).length === 1 && assigns.find((x) => x.is_imposter).word === 'IMPOSTER');
check(`crew share the same word (${crew[0].word})`, crew.length === 2 && crew[0].word === crew[1].word);
check('voice blocked during reveal', (await b.rpc('get_voice_access', { p_room_id: room.room_id })).can_publish === false);

const f = await b.rpc('my_profile');
const res = await a.rpc('send_friend_request', { p_code: f.friend_code });
check('friend request by code', res.status === 'requested');

for (const p of [a, b, c, outsider]) {
  const active = await p.rpc('my_active_room');
  if (active) await p.rpc('leave_room', { p_room_id: active.room_id });
}
console.log('cleaned up');
