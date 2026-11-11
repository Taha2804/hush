// Stages 2-4 backend checks. Imported by backend_test.mjs.
export async function run({ rpc, fails, sqlFails, as, user, admin, ok }) {
  console.log('\nStage 2: friends');
  const [a, b, c] = [await user(), await user(), await user()];
  const pa = await rpc(a, 'my_profile', ['Ann', 1]);
  const pb = await rpc(b, 'my_profile', ['Bob', 2]);
  await rpc(c, 'my_profile', ['Cat', 3]);
  ok('profiles get an 8-char friend code', /^[A-Z2-9]{8}$/.test(pa.friend_code));
  ok('other profiles are private', (await as(a, 'select * from profiles')).length === 1);
  ok('own code is rejected', /own code/.test(await fails(a, 'send_friend_request', [pa.friend_code])));
  ok('bad code is rejected', /No player/.test(await fails(a, 'send_friend_request', ['AAAAAAAA'])));
  ok('friend request sent', (await rpc(a, 'send_friend_request', [pb.friend_code])).status === 'requested');
  const inc = await rpc(b, 'list_friends');
  ok('request shows as incoming', inc[0].status === 'incoming' && inc[0].display_name === 'Ann');
  await rpc(c, 'respond_friend_request', [inc[0].friendship_id, true]);
  ok('a third party cannot accept', (await rpc(b, 'list_friends'))[0].status === 'incoming');
  await rpc(b, 'respond_friend_request', [inc[0].friendship_id, true]);
  ok('accepted', (await rpc(a, 'list_friends'))[0].status === 'friend');

  const room = await rpc(a, 'create_room', ['Ann', 1, null]);
  ok('non-friends cannot be invited', /only invite friends/.test(await fails(a, 'invite_friend', [room.room_id, c])));
  await rpc(a, 'invite_friend', [room.room_id, b]);
  ok('invite reaches only the recipient', (await as(b, 'select * from room_invites')).length === 1 && (await as(c, 'select * from room_invites')).length === 0);

  await rpc(b, 'block_player', [a]);
  ok('blocking ends the friendship', (await rpc(a, 'list_friends')).length === 0);
  ok('blocked player cannot re-add', /No player/.test(await fails(a, 'send_friend_request', [pb.friend_code])));
  await rpc(b, 'report_player', [a, room.room_id, 'spam', null]);
  ok('reports are not readable', (await as(b, 'select * from player_reports')).length === 0);

  console.log('\nStage 3: chat');
  const [m1, m2, m3, out] = [await user(), await user(), await user(), await user()];
  const r = await rpc(m1, 'create_room', ['M1', 0, null]);
  await rpc(m2, 'join_room', [r.code, 'M2', 0]);
  await rpc(m3, 'join_room', [r.code, 'M3', 0]);
  const msg = await rpc(m1, 'send_room_message', [r.room_id, ' hello 😀 ', null]);
  ok('members can send (emoji intact)', msg.message === 'hello 😀' && msg.sender_name === 'M1');
  ok('members can read', (await as(m2, `select * from room_messages where message_type='text'`)).length === 1);
  ok('outsiders cannot read', (await as(out, 'select * from room_messages')).length === 0);
  ok('outsiders cannot send', /not in this room/.test(await fails(out, 'send_room_message', [r.room_id, 'hi', null])));
  ok('direct insert is blocked', (await sqlFails(m1, `insert into room_messages(room_id, message) values ('${r.room_id}','x')`)) !== null);
  ok('over-long message rejected', /500/.test(await fails(m2, 'send_room_message', [r.room_id, 'x'.repeat(501), null])));
  ok('empty message rejected', /empty/.test(await fails(m2, 'send_room_message', [r.room_id, '   ', null])));
  ok('duplicate spam rejected', /just sent/.test(await fails(m1, 'send_room_message', [r.room_id, 'hello 😀', null])));
  const cid = '11111111-1111-4111-8111-111111111111';
  const s1 = await rpc(m2, 'send_room_message', [r.room_id, 'once', cid]);
  const s2 = await rpc(m2, 'send_room_message', [r.room_id, 'once', cid]);
  ok('a retry does not duplicate', s1.id === s2.id);
  for (let i = 0; i < 4; i++) await rpc(m3, 'send_room_message', [r.room_id, `m${i}`, null]);
  await rpc(m3, 'send_room_message', [r.room_id, 'm5', null]);
  ok('rate limit applies', /too quickly/.test(await fails(m3, 'send_room_message', [r.room_id, 'm6', null])));
  ok('cannot delete another player\'s message', /own messages/.test(await fails(m2, 'delete_room_message', [msg.id])));
  await rpc(m1, 'delete_room_message', [s1.id]);
  await rpc(m2, 'delete_room_message', [msg.id]).catch(() => {});
  const del = (await admin('select message, deleted_at from room_messages where id=$1', [s1.id]))[0];
  ok('host moderation removes the text', del.deleted_at && del.message === '');
  await rpc(m1, 'moderate_player', [r.room_id, m2, 'mute']);
  ok('muted player cannot send', /muted/.test(await fails(m2, 'send_room_message', [r.room_id, 'x', null])));
  ok('non-host cannot moderate', /host/.test(await fails(m3, 'moderate_player', [r.room_id, m2, 'kick'])));
  const ev = async () => (await admin(`select array_agg(system_event) e from room_messages where room_id=$1 and message_type='system'`, [r.room_id]))[0].e;
  ok('join notices posted', (await ev()).filter((x) => x === 'joined').length >= 2);
  await rpc(m1, 'moderate_player', [r.room_id, m3, 'kick']);
  ok('kick posts a notice', (await ev()).includes('left'));
  ok('kicked player loses access', (await as(m3, 'select * from room_messages')).length === 0);
  await rpc(m2, 'leave_room', [r.room_id]);
  await rpc(m1, 'leave_room', [r.room_id]);
  ok('last player leaving removes room and chat', (await admin('select 1 from room_messages where room_id=$1', [r.room_id])).length === 0);

  console.log('\nStage 4: voice rules');
  const [h, v2, v3, stranger] = [await user(), await user(), await user(), await user()];
  const vr = await rpc(h, 'create_room', ['H', 0, null]);
  await rpc(v2, 'join_room', [vr.code, 'V2', 0]);
  await rpc(v3, 'join_room', [vr.code, 'V3', 0]);
  const canPub = async () => (await rpc(v2, 'get_voice_access', [vr.room_id])).can_publish;
  ok('stranger cannot get voice access', /not in this room/.test(await fails(stranger, 'get_voice_access', [vr.room_id])));
  ok('anon cannot get voice access', (await fails(null, 'get_voice_access', [vr.room_id])) !== null);
  ok('lobby voice is open', (await canPub()) === true);
  ok('non-host cannot set voice rules', /host/i.test(await fails(v2, 'set_voice_policy', [vr.room_id, false, true])));
  await rpc(h, 'set_voice_policy', [vr.room_id, false, false]);
  const g = await rpc(h, 'start_online_game', [vr.room_id]);
  ok('reveal blocks voice', (await canPub()) === false);
  await rpc(h, 'advance_game_phase', [g.session_id, 'clue']);
  ok('clue follows host setting', (await canPub()) === false);
  await rpc(h, 'advance_game_phase', [g.session_id, 'discussion']);
  ok('discussion opens voice', (await canPub()) === true);
  await admin(`update game_sessions set discussion_end_time = now() - interval '1 second' where id = $1`, [g.session_id]);
  await rpc(h, 'advance_game_phase', [g.session_id, 'vote']);
  ok('vote follows host setting', (await canPub()) === false);
  ok('rules are locked once started', /before the game/.test(await fails(h, 'set_voice_policy', [vr.room_id, true, true])));
  ok('sync state is not callable by players', (await fails(h, 'voice_sync_state', [vr.room_id])) !== null);
  ok('voice secrets are unreachable', (await sqlFails(h, 'select * from private.voice_settings')) !== null);

  await stage5({ rpc, fails, sqlFails, as, user, admin, ok });
  await descriptions({ rpc, user, admin, ok });
}

async function stage5({ rpc, fails, sqlFails, as, user, admin, ok }) {
  console.log('\nRounds, turns, votes, early end');
  const ps = [await user(), await user(), await user(), await user()];
  const [h] = ps;
  const room = await rpc(h, 'create_room', ['H', 0, null]);
  for (const [i, p] of ps.slice(1).entries()) await rpc(p, 'join_room', [room.code, `P${i}`, 0]);
  ok('non-host cannot change settings', /host/i.test(await fails(ps[1], 'update_room_settings', [room.room_id, 2, 'sequential', 'public'])));
  ok('rounds are limited to 1-10', /between 1 and 10/.test(await fails(h, 'update_room_settings', [room.room_id, 11, 'sequential', 'public'])));
  await rpc(h, 'update_room_settings', [room.room_id, 2, 'sequential', 'public']);

  const g1 = await rpc(h, 'start_online_game', [room.room_id]);
  const sid = g1.session_id;
  const sess = async () => (await admin('select * from game_sessions where id=$1', [sid]))[0];
  ok('round 1 of 2 recorded', (await admin('select current_round, total_rounds from rooms where id=$1', [room.room_id]))[0].current_round === 1);
  ok('next round is blocked mid-round', /Finish this round/.test(await fails(h, 'start_next_round', [room.room_id])));

  await rpc(h, 'advance_game_phase', [sid, 'clue']);
  while ((await sess()).phase === 'clue') {
    const s = await sess();
    await rpc(s.turn_order[s.clue_step % s.turn_order.length], 'submit_online_clue', [sid, 'c']);
  }

  // Early end: one refusal cancels, cooldown applies, unanimous agreement ends it.
  const req = await rpc(ps[1], 'request_end_discussion', [sid]);
  ok('only one request at a time', /already waiting/.test(await fails(ps[2], 'request_end_discussion', [sid])));
  ok('outsider cannot answer', (await fails(await user(), 'respond_end_discussion', [req.request_id, true])) !== null);
  await rpc(ps[2], 'respond_end_discussion', [req.request_id, true]);
  ok('duplicate answers are rejected', /already answered/.test(await fails(ps[2], 'respond_end_discussion', [req.request_id, true])));
  await rpc(ps[3], 'respond_end_discussion', [req.request_id, false]);
  ok('one refusal keeps discussing', (await sess()).phase === 'discussion');
  ok('cooldown before asking again', /wait a moment/.test(await fails(ps[0], 'request_end_discussion', [sid])));
  await admin(`update discussion_end_requests set created_at = now() - interval '1 minute' where session_id = $1`, [sid]);
  const req2 = await rpc(ps[0], 'request_end_discussion', [sid]);
  await admin(`update discussion_end_requests set expires_at = now() - interval '1 second' where id = $1`, [req2.request_id]);
  ok('unanswered request expires', (await rpc(ps[1], 'respond_end_discussion', [req2.request_id, true])).status === 'expired');
  await admin(`update discussion_end_requests set created_at = now() - interval '1 minute' where session_id = $1`, [sid]);
  const req3 = await rpc(ps[0], 'request_end_discussion', [sid]);
  for (const p of ps.slice(1)) await rpc(p, 'respond_end_discussion', [req3.request_id, true]);
  ok('everyone agreeing opens voting', (await sess()).phase === 'vote');

  // Turn-based, locked, private-until-closed voting.
  let s = await sess();
  const order = s.turn_order;
  const [imp] = (await admin('select player_id from private_player_assignments where session_id=$1 and is_imposter', [sid]));
  const target = (v) => (v === imp.player_id ? order.find((x) => x !== v) : imp.player_id);
  ok('out-of-turn vote is rejected', /your turn/.test(await fails(order[1], 'cast_online_vote', [sid, target(order[1])])));
  await rpc(order[0], 'cast_online_vote', [sid, target(order[0])]);
  ok('same vote retried is fine', (await rpc(order[0], 'cast_online_vote', [sid, target(order[0])])).status === 'recorded');
  ok('vote cannot be changed', /locked in/.test(await fails(order[0], 'cast_online_vote', [sid, order.find((x) => x !== order[0] && x !== target(order[0]))])));
  s = await sess();
  ok('ballot list shows who voted', s.voters.length === 1 && s.voters[0] === order[0]);
  ok('other ballots stay hidden', (await as(order[1], 'select * from game_votes where session_id=$1', [sid])).length === 0);
  for (const v of order.slice(1)) await rpc(v, 'cast_online_vote', [sid, target(v)]);
  s = await sess();
  ok('last vote closes voting automatically', s.phase === 'result' && s.last_vote_summary.ballots);

  ok('scores recorded', (await rpc(h, 'match_standings', [room.room_id])).some((x) => x.points > 0));
  ok('standings hidden from outsiders', (await rpc(await user(), 'match_standings', [room.room_id])).length === 0);
  const g2 = await rpc(h, 'start_next_round', [room.room_id]);
  ok('round 2 starts', (await admin('select match_round from game_sessions where id=$1', [g2.session_id]))[0].match_round === 2);

  console.log('\nInvites and joining');
  const fresh = await user();
  ok('peek: started game', (await rpc(fresh, 'peek_room', [room.code])).status === 'started');
  ok('peek: member can rejoin', (await rpc(ps[1], 'peek_room', [room.code])).status === 'member');
  ok('peek: unknown code', (await rpc(null, 'peek_room', ['QQQQQQ'])).status === 'not_found');
  const r2 = await rpc(fresh, 'create_room', ['F', 0, null]);
  ok('peek works before sign-in', (await rpc(null, 'peek_room', [` ${r2.code.toLowerCase()} `])).status === 'open');
  await admin(`update rooms set expires_at = now() - interval '1 minute' where id = $1`, [r2.room_id]);
  ok('expired room cannot be joined', /expired/.test(await fails(await user(), 'join_room', [r2.code, 'X', 0])));

  console.log('\nCleanup');
  const live = await rpc(await user(), 'create_room', ['L', 0, null]);
  const idle = await rpc(await user(), 'create_room', ['I', 0, null]);
  const gone = await rpc(await user(), 'create_room', ['G', 0, null]);
  await admin(`update room_players set last_seen_at = now() - interval '3 hours' where room_id = any($1)`, [[idle.room_id, gone.room_id]]);
  await admin(`update rooms set last_activity_at = now() - interval '3 hours' where id = $1`, [idle.room_id]);
  await admin(`update rooms set status='playing', last_activity_at = now() - interval '3 hours' where id = $1`, [live.room_id]);
  await admin(`select private.run_cleanup()`);
  const left = (await admin('select id from rooms where id = any($1)', [[live.room_id, idle.room_id, gone.room_id]])).map((x) => x.id);
  ok('idle lobby removed', !left.includes(idle.room_id));
  ok('abandoned room removed', !left.includes(gone.room_id));
  ok('room with a player present is kept', left.includes(live.room_id));
  ok('cascade removed their chat', (await admin('select 1 from room_messages where room_id = any($1)', [[idle.room_id, gone.room_id]])).length === 0);
  await admin(`select private.run_cleanup()`);
  const runs = await admin('select * from private.cleanup_runs order by ran_at');
  ok('cleanup is repeatable and recorded', runs.length >= 2 && runs.every((x) => x.error === null), JSON.stringify(runs.map((x) => x.error)));
  ok('players cannot run cleanup', (await sqlFails(h, 'select private.run_cleanup()')) !== null);
  ok('storage report available', (await admin('select * from private.storage_report()')).length > 0);
}

export async function descriptions({ rpc, user, admin, ok }) {
  console.log('\nWord descriptions');
  const [a, b, c] = [await user(), await user(), await user()];
  const r = await rpc(a, 'create_room', ['A', 0, null]);
  await rpc(b, 'join_room', [r.code, 'B', 0]);
  await rpc(c, 'join_room', [r.code, 'C', 0]);
  const g = await rpc(a, 'start_online_game', [r.room_id]);
  const cards = await Promise.all([a, b, c].map((p) => rpc(p, 'get_my_assignment', [g.session_id])));
  ok('crew get a description', cards.filter((x) => !x.is_imposter).every((x) => x.description && x.description.length > 5));
  ok('imposter gets no description', cards.filter((x) => x.is_imposter).every((x) => x.description === null));
}
