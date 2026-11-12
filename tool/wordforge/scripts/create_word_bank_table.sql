-- Run this in Supabase SQL Editor (Dashboard > SQL Editor)
-- Creates the word_bank table in the 'private' schema

-- Enable UUID extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create private schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS private;

-- Create word_bank table
CREATE TABLE IF NOT EXISTS private.word_bank (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category TEXT NOT NULL,
    word TEXT NOT NULL,
    hints TEXT[] NOT NULL,
    fakes TEXT[] NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(category, word)
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_word_bank_category ON private.word_bank(category);
CREATE INDEX IF NOT EXISTS idx_word_bank_word ON private.word_bank(word);

-- Enable Row Level Security (RLS)
ALTER TABLE private.word_bank ENABLE ROW LEVEL SECURITY;

-- Policy: Allow read access to authenticated users
CREATE POLICY "Allow read for authenticated users" ON private.word_bank
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy: Allow insert/update for service role only (admin)
CREATE POLICY "Allow write for service role" ON private.word_bank
    FOR ALL USING (auth.role() = 'service_role');

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION private.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to auto-update updated_at
CREATE TRIGGER update_word_bank_updated_at
    BEFORE UPDATE ON private.word_bank
    FOR EACH ROW
    EXECUTE FUNCTION private.update_updated_at_column();

-- Grant permissions
GRANT USAGE ON SCHEMA private TO service_role;
GRANT ALL ON private.word_bank TO service_role;
GRANT SELECT ON private.word_bank TO authenticated;

-- Verify table creation
SELECT * FROM private.word_bank LIMIT 1;