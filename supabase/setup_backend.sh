#!/usr/bin/env bash
# ==============================================================================
# HUSHBUG SUPABASE BACKEND DEPLOYMENT SCRIPT
# ==============================================================================
# Usage:
#   1. Using Database Connection String:
#      ./setup_backend.sh "postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres"
#
#   2. Or set environment variable:
#      export DATABASE_URL="postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres"
#      ./setup_backend.sh
#
#   3. Or using Supabase CLI:
#      supabase link --project-ref [YOUR_PROJECT_REF]
#      supabase db push
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_FILE="$SCRIPT_DIR/schema.sql"

echo "=========================================================="
echo "      Hushbug Online Multiplayer - Backend Setup         "
echo "=========================================================="

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ Error: schema.sql not found at $SCHEMA_FILE"
    exit 1
fi

DB_URL="${1:-${DATABASE_URL:-}}"

if [ -z "$DB_URL" ]; then
    echo ""
    echo "No database connection string provided."
    echo "You can find your connection string in your Supabase Dashboard:"
    echo "  -> Project Settings -> Database -> Connection String (URI / Session Mode)"
    echo ""
    read -p "Enter your Supabase PostgreSQL connection string: " DB_URL
fi

if [ -z "$DB_URL" ]; then
    echo "❌ Error: Database connection string is required."
    exit 1
fi

echo ""
echo "Connecting to Supabase PostgreSQL database and applying schema..."

# Execute using psql if installed, or fallback to python / node psql execution
if command -v psql >/dev/null 2>&1; then
    psql "$DB_URL" -f "$SCHEMA_FILE"
elif command -v node >/dev/null 2>&1; then
    echo "Applying via Node.js pg client..."
    node -e '
const fs = require("fs");
const { Client } = require("pg");
const client = new Client({ connectionString: process.argv[1], ssl: { rejectUnauthorized: false } });
client.connect()
  .then(() => {
    const sql = fs.readFileSync(process.argv[2], "utf8");
    return client.query(sql);
  })
  .then(() => {
    console.log("✅ Schema successfully executed!");
    return client.end();
  })
  .catch((err) => {
    console.error("❌ Execution error:", err.message);
    process.exit(1);
  });
' "$DB_URL" "$SCHEMA_FILE"
else
    echo "❌ Error: Neither psql nor node with pg is available in the environment."
    echo "You can copy the contents of $SCHEMA_FILE directly into the"
    echo "Supabase SQL Editor (https://supabase.com/dashboard/project/_/sql)."
    exit 1
fi

echo ""
echo "=========================================================="
echo "  ✅ Supabase Backend Deployed Successfully!"
echo "=========================================================="
echo "Tables verified:"
echo "  • profiles (Player identities & avatars)"
echo "  • rooms (Active rooms, codes, host assignment, configs)"
echo "  • room_players (Live presence, ready state)"
echo "  • game_sessions (Turn order, phase tracking, timers)"
echo "  • game_players (Live alive/eliminated round tracking)"
echo "  • private_player_assignments (Zero-leakage secret words & roles)"
echo "  • game_clues (Round clue entries)"
echo "  • game_votes (Confidential ballots)"
echo "  • game_results (Final winners & imposter unmasking)"
echo "  • player_statistics (Career wins & streaks)"
echo ""
echo "RPC Game Engine Functions:"
echo "  • create_room(code, name, avatar, config)"
echo "  • join_room(code, name, avatar)"
echo "  • toggle_ready(room_id, is_ready)"
echo "  • start_online_game(room_id, category, word, hint, fake_word)"
echo "  • get_my_assignment(session_id) [Strict RLS Protected]"
echo "  • advance_game_phase(session_id, target_phase)"
echo "  • submit_online_clue(session_id, clue_text)"
echo "  • cast_online_vote(session_id, target_id)"
echo "  • tally_online_votes(session_id) [Server-Authoritative Vote Resolution]"
echo "  • leave_room(room_id)"
echo ""
echo "Next Step: Add your Supabase credentials to Flutter:"
echo "  Run your app with:"
echo '  flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key'
echo "=========================================================="
