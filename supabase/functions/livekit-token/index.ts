// Issues a short-lived LiveKit token to a signed-in member of a room.
// Membership and speaking rights are decided by the database.
import { AccessToken, TrackSource } from 'npm:livekit-server-sdk@2';
import { createClient } from 'npm:@supabase/supabase-js@2';

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const authorization = req.headers.get('Authorization');
  if (!authorization) return json({ error: 'Not signed in' }, 401);

  const { room_id: roomId } = await req.json().catch(() => ({ room_id: null }));
  if (typeof roomId !== 'string') return json({ error: 'room_id is required' }, 400);

  const url = Deno.env.get('LIVEKIT_URL');
  const apiKey = Deno.env.get('LIVEKIT_API_KEY');
  const apiSecret = Deno.env.get('LIVEKIT_API_SECRET');
  if (!url || !apiKey || !apiSecret) return json({ error: 'Voice is not configured' }, 503);

  // Runs as the player, so the database sees who is really asking.
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: authorization } },
  });
  const { data, error } = await supabase.rpc('get_voice_access', { p_room_id: roomId });
  if (error || !data) return json({ error: 'Not allowed in this voice room' }, 403);

  const token = new AccessToken(apiKey, apiSecret, {
    identity: data.identity,
    name: data.display_name,
    ttl: '10m',
  });
  token.addGrant({
    room: data.room_name,
    roomJoin: true,
    canSubscribe: true,
    canPublish: data.can_publish,
    canPublishSources: [TrackSource.MICROPHONE],
    canPublishData: false,
    canUpdateOwnMetadata: false,
    roomRecord: false,
  });

  return json({ url, token: await token.toJwt() });
});
