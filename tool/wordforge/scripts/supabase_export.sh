#!/bin/bash
# Supabase Export Script for Hushbug WordForge
# Run this after creating the word_bank table in Supabase

# Supabase credentials (you need SERVICE ROLE key, not publishable)
# Get it from: Supabase Dashboard > Settings > API > service_role (secret)
export SUPABASE_URL="https://vctdkitastvopatlwkhc.supabase.co"
export SUPABASE_SERVICE_KEY="YOUR_SERVICE_ROLE_KEY_HERE"

# Change to wordforge directory
cd /c/Users/badam/Desktop/hush/tool/wordforge

# Run export (dry-run first to verify)
echo "=== Dry run ==="
python -m wordforge.cli supabase-export --pack-dir output/offline_packs --dry-run

echo ""
read -p "Proceed with actual export? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "=== Actual export ==="
    python -m wordforge.cli supabase-export --pack-dir output/offline_packs --no-dry-run
else
    echo "Export cancelled"
fi