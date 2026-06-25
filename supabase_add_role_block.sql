-- Run this once in the Supabase SQL editor
ALTER TABLE mosque_roles
ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN NOT NULL DEFAULT FALSE;
