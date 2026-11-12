#!/usr/bin/env python3
"""Test Supabase connection and export word packs.

Requires a SERVICE ROLE key (secret), not the publishable key.
Get it from: Supabase Dashboard > Settings > API > service_role (secret)
"""

import os
import sys
import httpx

SUPABASE_URL = "https://vctdkitastvopatlwkhc.supabase.co"
# You need to set this to your SERVICE ROLE key (secret), not the publishable key
SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY", "YOUR_SERVICE_ROLE_KEY_HERE")


def test_connection():
    """Test if we can connect to Supabase and if word_bank table exists."""
    headers = {
        "apikey": SERVICE_KEY,
        "Authorization": f"Bearer {SERVICE_KEY}",
        "Content-Type": "application/json",
    }

    # Test basic connection
    try:
        resp = httpx.get(f"{SUPABASE_URL}/rest/v1/", headers=headers, timeout=10)
        if resp.status_code == 200:
            print("✓ Connected to Supabase API")
        else:
            print(f"✗ Connection failed: {resp.status_code} - {resp.text}")
            return False
    except Exception as e:
        print(f"✗ Connection error: {e}")
        return False

    # Test if word_bank table exists
    try:
        resp = httpx.get(
            f"{SUPABASE_URL}/rest/v1/word_bank?select=category&limit=1",
            headers=headers,
            timeout=10
        )
        if resp.status_code == 200:
            print("✓ word_bank table exists and accessible")
            return True
        elif resp.status_code == 404:
            print("✗ word_bank table not found (404)")
            print("  Run the SQL from scripts/create_word_bank_table.sql in Supabase SQL Editor")
            return False
        else:
            print(f"✗ Table check failed: {resp.status_code} - {resp.text}")
            return False
    except Exception as e:
        print(f"✗ Table check error: {e}")
        return False


def test_upsert():
    """Test a single upsert to verify write permissions."""
    headers = {
        "apikey": SERVICE_KEY,
        "Authorization": f"Bearer {SERVICE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    }

    test_row = {
        "category": "test",
        "word": "test_word",
        "hints": ["hint 1", "hint 2"],
        "fakes": ["fake 1", "fake 2"],
        "description": "Test entry",
    }

    try:
        resp = httpx.post(
            f"{SUPABASE_URL}/rest/v1/word_bank?on_conflict=category,word",
            headers=headers,
            json=[test_row],
            timeout=10
        )
        if resp.status_code in (200, 201):
            print("✓ Upsert test successful")
            # Clean up test entry
            httpx.delete(
                f"{SUPABASE_URL}/rest/v1/word_bank?category=eq.test&word=eq.test_word",
                headers=headers,
                timeout=10
            )
            return True
        else:
            print(f"✗ Upsert test failed: {resp.status_code} - {resp.text}")
            return False
    except Exception as e:
        print(f"✗ Upsert test error: {e}")
        return False


if __name__ == "__main__":
    print("=== Supabase Connection Test ===\n")
    print(f"URL: {SUPABASE_URL}")
    print(f"Key: {SERVICE_KEY[:20]}..." if len(SERVICE_KEY) > 20 else f"Key: {SERVICE_KEY}")
    print()

    if SERVICE_KEY == "YOUR_SERVICE_ROLE_KEY_HERE":
        print("⚠️  ERROR: You must set SUPABASE_SERVICE_KEY environment variable")
        print("   Get your service role key from: Supabase Dashboard > Settings > API > service_role (secret)")
        print("   NOT the publishable key!")
        sys.exit(1)

    if test_connection():
        print()
        if test_upsert():
            print("\n✅ All tests passed! Ready to export.")
            print("   Run: python -m wordforge.cli supabase-export --pack-dir output/offline_packs --no-dry-run")
        else:
            print("\n❌ Upsert test failed. Check service role key permissions.")
    else:
        print("\n❌ Connection test failed.")
        sys.exit(1)