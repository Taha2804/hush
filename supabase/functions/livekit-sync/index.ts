// Called by a database trigger when a game phase changes or a player leaves.
// Applies speaking rights to people already in the call, so a player cannot
// keep talking through the secret word reveal.
import { RoomServiceClient, TrackSource } from 'npm:livekit-server-sdk@2';
import { createClient } from 'npm:@supabase/supabase-js@2';

Deno.serve(async (req) => {
  const secret = Deno.env.get('VOICE_SYNC_SECRET');
  if (!secret || req.headers.get('x-sync-secret') !== secret) {
    return new Response('Forbidden', { status: 403 });
  }

  const { room_id: roomId, remove_identity: removeIdentity } = await req.json();

  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
  const { data, error } = await supabase.rpc('voice_sync_state', { p_room_id: roomId });
  if (error || !data) return new Response('Unknown room', { status: 404 });

  const livekitUrl = Deno.env.get('LIVEKIT_URL')!.replace(/^wss:/, 'https:');
  const lk = new RoomServiceClient(livekitUrl, Deno.env.get('LIVEKIT_API_KEY')!, Deno.env.get('LIVEKIT_API_SECRET')!);

  try {
    if (removeIdentity) {
      await lk.removeParticipant(data.room_name, removeIdentity).catch(() => {});
    }
    const participants = await lk.listParticipants(data.room_name);
    await Promise.all(participants.map((p) =>
      lk.updateParticipant(data.room_name, p.identity, undefined, {
        canSubscribe: true,
        canPublish: data.can_publish,
        canPublishData: false,
        canPublishSources: [TrackSource.MICROPHONE],
      })
    ));
  } catch (_) {
    // LiveKit has no such room until someone joins voice.
  }

  return new Response('ok');
});
