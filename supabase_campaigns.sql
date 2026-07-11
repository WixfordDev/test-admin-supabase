-- ============================================================
-- Mosque Donation Campaigns — Migration
-- Run once in Supabase SQL Editor
-- ============================================================

-- Table: mosque_campaigns
CREATE TABLE IF NOT EXISTS mosque_campaigns (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mosque_id        TEXT NOT NULL REFERENCES mosques_metadata(mosque_id) ON DELETE CASCADE,
  title            TEXT NOT NULL,
  description      TEXT NOT NULL,
  category         TEXT NOT NULL DEFAULT 'general',
  cover_image_url  TEXT,
  goal_amount      INTEGER NOT NULL,
  raised_amount    INTEGER NOT NULL DEFAULT 0,
  currency         TEXT NOT NULL DEFAULT 'usd',
  start_date       DATE,
  end_date         DATE,
  is_active        BOOLEAN NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mosque_campaigns_mosque_id
  ON mosque_campaigns (mosque_id);

CREATE INDEX IF NOT EXISTS idx_mosque_campaigns_active
  ON mosque_campaigns (mosque_id, is_active);

-- Add campaign_id to donation_transactions
ALTER TABLE donation_transactions
  ADD COLUMN IF NOT EXISTS campaign_id UUID REFERENCES mosque_campaigns(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_donation_transactions_campaign
  ON donation_transactions (campaign_id);

-- Safe atomic increment for raised_amount
CREATE OR REPLACE FUNCTION increment_campaign_raised(p_campaign_id UUID, p_amount INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE mosque_campaigns
  SET raised_amount = raised_amount + p_amount
  WHERE id = p_campaign_id;
END;
$$ LANGUAGE plpgsql;

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_campaign_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_campaign_timestamp ON mosque_campaigns;
CREATE TRIGGER trg_update_campaign_timestamp
  BEFORE UPDATE ON mosque_campaigns
  FOR EACH ROW EXECUTE FUNCTION update_campaign_timestamp();
