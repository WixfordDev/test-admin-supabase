-- ============================================================
-- Stripe Connect Donation Module — Database Migration
-- Run once in Supabase SQL Editor
-- ============================================================

-- Table: mosque_donation_accounts
-- Stores each mosque's Stripe Express Account connection
CREATE TABLE IF NOT EXISTS mosque_donation_accounts (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mosque_id           TEXT NOT NULL UNIQUE REFERENCES mosques_metadata(mosque_id) ON DELETE CASCADE,
  provider            TEXT NOT NULL DEFAULT 'stripe',
  stripe_account_id   TEXT UNIQUE,
  account_status      TEXT NOT NULL DEFAULT 'pending',
  charges_enabled     BOOLEAN NOT NULL DEFAULT FALSE,
  payouts_enabled     BOOLEAN NOT NULL DEFAULT FALSE,
  details_submitted   BOOLEAN NOT NULL DEFAULT FALSE,
  country             TEXT,
  currency            TEXT DEFAULT 'usd',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for quick lookups by mosque
CREATE INDEX IF NOT EXISTS idx_mosque_donation_accounts_mosque_id
  ON mosque_donation_accounts (mosque_id);

-- Table: donation_transactions
-- Records every donation checkout attempt and its outcome
CREATE TABLE IF NOT EXISTS donation_transactions (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mosque_id               TEXT NOT NULL REFERENCES mosques_metadata(mosque_id) ON DELETE CASCADE,
  donor_user_id           TEXT,
  stripe_checkout_session TEXT UNIQUE,
  stripe_payment_intent   TEXT,
  amount                  INTEGER NOT NULL,
  currency                TEXT NOT NULL DEFAULT 'usd',
  platform_fee            INTEGER NOT NULL DEFAULT 0,
  mosque_amount           INTEGER NOT NULL DEFAULT 0,
  payment_method          TEXT,
  receipt_url             TEXT,
  status                  TEXT NOT NULL DEFAULT 'pending',
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_donation_transactions_mosque_id
  ON donation_transactions (mosque_id);

CREATE INDEX IF NOT EXISTS idx_donation_transactions_donor
  ON donation_transactions (donor_user_id);

CREATE INDEX IF NOT EXISTS idx_donation_transactions_session
  ON donation_transactions (stripe_checkout_session);

-- Auto-update updated_at on mosque_donation_accounts
CREATE OR REPLACE FUNCTION update_donation_account_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_donation_account_timestamp ON mosque_donation_accounts;
CREATE TRIGGER trg_update_donation_account_timestamp
  BEFORE UPDATE ON mosque_donation_accounts
  FOR EACH ROW EXECUTE FUNCTION update_donation_account_timestamp();
