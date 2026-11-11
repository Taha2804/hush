# Hushbug – Supabase Online Multiplayer Backend

This directory contains the production-ready PostgreSQL schema, server-authoritative RPC functions, Row Level Security (RLS) policies, and deployment automation for **Hushbug Online Multiplayer**.

---

## 🚀 One-Command Deployment

You can deploy the complete backend in one step using the automated setup script:

```bash
chmod +x supabase/setup_backend.sh
./supabase/setup_backend.sh "postgresql://postgres:[YOUR-PASSWORD]@[HOST]:5432/postgres"
```

*Alternatively, if using the Supabase CLI:*
```bash
supabase link --project-ref [YOUR_PROJECT_REF]
supabase db push
```

*Or via Supabase Web Dashboard:*
Copy the entire contents of [`supabase/schema.sql`](./schema.sql) and run it in your **[Supabase SQL Editor](https://supabase.com/dashboard/project/_/sql)**.

---

## 🏛️ Database Architecture & Security

### 1. Database Tables

| Table | Purpose | Security & RLS |
| :--- | :--- | :--- |
| `profiles` | User identity, display names, chosen avatar index | Public read, user-restricted update |
| `rooms` | Active multiplayer lobbies, 6-char codes, host assignment | Public read for matchmaking, host update |
| `room_players` | Real-time presence, join timestamps, ready states | Room-scoped read, self/host update |
| `game_sessions` | Authoritative game state, turn order, phase, discussion timer | Room-participant scoped |
| `game_players` | Per-round player status (`is_alive`, elimination round) | Session-participant scoped |
| `private_player_assignments` | **CRITICAL: Secret role, secret word, hint & fake word** | **STRICT RLS**: `auth.uid() = player_id`. Zero leakage. Excluded from public Realtime. |
| `game_clues` | Clue submissions stream | Session-participant read, active player insert |
| `game_votes` | Confidential in-flight ballots | Voter-only select during voting phase |
| `game_results` | Official unmasking of imposters and scores | Revealed only when game concludes |
| `player_statistics` | Career multiplayer wins, imposter victories, win streaks | User-scoped read/update |

---

## 🔒 Server-Authoritative RPC Functions

All sensitive game logic is executed server-side via PostgreSQL functions (`SECURITY DEFINER`):

1. **`create_room(p_code, p_display_name, p_avatar, p_config)`**
   * Atomically provisions a room and marks caller as Host.
   * Auto-expires inactive rooms after 4 hours.

2. **`join_room(p_code, p_display_name, p_avatar)`**
   * Validates room capacity, code matching, and 'waiting' status.
   * Links user to the lobby with live presence.

3. **`toggle_ready(p_room_id, p_is_ready)`**
   * Toggles readiness for non-host players.

4. **`start_online_game(p_room_id, p_category, p_word, p_hint, p_fake_word, p_imposter_count, p_discussion_seconds)`**
   * **Server-authoritative**: randomly designates imposters and starter player.
   * Generates private player assignments in `private_player_assignments` (clients never allocate roles).
   * Sets game phase to `reveal` and initializes turn sequence.

5. **`get_my_assignment(p_session_id)`**
   * Safely returns only the calling player's role, secret word, and hint.

6. **`advance_game_phase(p_session_id, p_target_phase)`**
   * Host-controlled phase transition (`reveal` -> `clue` -> `discussion` -> `vote`).
   * When entering `discussion`, calculates authoritative `discussion_end_time = now() + interval`.

7. **`submit_online_clue(p_session_id, p_clue_text)`**
   * Verifies it is the active player's turn and records the clue.

8. **`cast_online_vote(p_session_id, p_target_id)`**
   * Validates that voter and target are alive, and stores confidential ballot.

9. **`tally_online_votes(p_session_id)`**
   * Tallies ballots server-side.
   * Resolves ties according to rulebook (triggers revote or imposters win).
   * Eliminates the voted player.
   * Checks win conditions (all imposters eliminated vs. imposters outnumber crew).
   * If game ends, unmasks imposters in `game_results` and transitions phase to `result`.

10. **`leave_room(p_room_id)`**
    * Gracefully handles player departures and transfers host if the host disconnects.

---

## 📱 Flutter Client Configuration

### Option A: Build-time environment defines
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Option B: In-App UI Setup Modal
Open **Online Multiplayer** in the app. Tap the **Setup** pill in the top-right header and paste your Project URL and Public Anon Key. Credentials are encrypted and saved locally in `SharedPreferences`.

### Option C: Offline Local Party Mode
Local single-device pass-and-play party mode operates **100% offline without internet access or Supabase configuration**.
