-- Campfire Supabase Migration
-- Run this in Supabase SQL Editor: https://hrulsakkhelwnsvpnakx.supabase.co

-- 1. Members table
CREATE TABLE IF NOT EXISTS members (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  "group" TEXT NOT NULL CHECK ("group" IN ('A', 'B', 'C')),
  avatar_url TEXT,
  color TEXT NOT NULL,
  bio TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Confirmations table
CREATE TABLE IF NOT EXISTS confirmations (
  id SERIAL PRIMARY KEY,
  member_name TEXT NOT NULL UNIQUE,
  confirmed BOOLEAN DEFAULT TRUE,
  confirmed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Packing checklist table
CREATE TABLE IF NOT EXISTS packing_checks (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  item_key TEXT NOT NULL,
  checked BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, item_key)
);

-- 4. Seed initial members
INSERT INTO members (id, name, "group", color, bio) VALUES
  (1,  'Kathy',  'A', '#1565c0', ''),
  (2,  '鼎凱',   'A', '#1976d2', ''),
  (3,  'Arth',   'B', '#c62828', ''),
  (4,  'Mars',   'B', '#d32f2f', ''),
  (5,  '石膏',   'B', '#e53935', ''),
  (6,  'Ella',   'B', '#ef5350', ''),
  (7,  'Emma',   'B', '#f44336', ''),
  (8,  'George', 'B', '#e57373', ''),
  (9,  '小資',   'B', '#ef9a9a', ''),
  (10, '傑森',   'B', '#ffcdd2', ''),
  (11, '菀倩',   'C', '#ef6c00', ''),
  (12, 'Kedens', 'C', '#f57c00', '')
ON CONFLICT (id) DO NOTHING;

-- 5. Enable RLS (Row Level Security)
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE confirmations ENABLE ROW LEVEL SECURITY;
ALTER TABLE packing_checks ENABLE ROW LEVEL SECURITY;

-- 6. Policies: allow anon read/write for this simple app
CREATE POLICY "Allow all read members" ON members FOR SELECT USING (true);
CREATE POLICY "Allow all update members" ON members FOR UPDATE USING (true);

CREATE POLICY "Allow all read confirmations" ON confirmations FOR SELECT USING (true);
CREATE POLICY "Allow all insert confirmations" ON confirmations FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all read packing" ON packing_checks FOR SELECT USING (true);
CREATE POLICY "Allow all upsert packing" ON packing_checks FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow all update packing" ON packing_checks FOR UPDATE USING (true);

-- 7. Packing claims table
CREATE TABLE IF NOT EXISTS packing_claims (
  id SERIAL PRIMARY KEY,
  item_key TEXT NOT NULL UNIQUE,
  claimed_by TEXT NOT NULL,
  claimed_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE packing_claims ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all read packing_claims" ON packing_claims FOR SELECT USING (true);
CREATE POLICY "Allow all insert packing_claims" ON packing_claims FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow all update packing_claims" ON packing_claims FOR UPDATE USING (true);
CREATE POLICY "Allow all delete packing_claims" ON packing_claims FOR DELETE USING (true);

-- Pre-assign: 快煮壺 → Ella
INSERT INTO packing_claims (item_key, claimed_by) VALUES ('group-2-12', 'Ella')
ON CONFLICT (item_key) DO NOTHING;

-- 8. Auto-update updated_at on members
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER members_updated_at
  BEFORE UPDATE ON members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
