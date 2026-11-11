# Voice setup (LiveKit)

Secrets live only in Supabase. Never add them to the Flutter app.

1. Create a project at https://cloud.livekit.io and note its URL (`wss://...`), API key and API secret.
2. Choose a long random value for `VOICE_SYNC_SECRET`.
3. From the repo root:

   ```
   npx supabase login
   npx supabase link --project-ref vctdkitastvopatlwkhc
   npx supabase secrets set LIVEKIT_URL=wss://... LIVEKIT_API_KEY=... LIVEKIT_API_SECRET=... VOICE_SYNC_SECRET=...
   npx supabase functions deploy livekit-token --no-verify-jwt
   npx supabase functions deploy livekit-sync --no-verify-jwt
   ```

4. In the SQL Editor, enable phase enforcement for people already in a call:

   ```sql
   create extension if not exists pg_net with schema extensions;
   insert into private.voice_settings (function_url, sync_secret)
   values ('https://vctdkitastvopatlwkhc.supabase.co/functions/v1/livekit-sync', 'SAME_VOICE_SYNC_SECRET')
   on conflict (id) do update set function_url = excluded.function_url, sync_secret = excluded.sync_secret;
   ```

Until these steps are done the app shows "Voice isn't available right now", and chat and the game keep working.
