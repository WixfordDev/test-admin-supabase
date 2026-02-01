-- ============================================================================
-- FIX MISSING COLUMNS - SCHEMA UPDATE
-- Version: 003
-- Description: Adds missing columns to existing mosque tables
-- ============================================================================

-- Check and add missing columns to mosque_adjustments table
DO $$
BEGIN
    -- Add adjustment_minutes column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mosque_adjustments' 
        AND column_name = 'adjustment_minutes'
    ) THEN
        ALTER TABLE mosque_adjustments ADD COLUMN adjustment_minutes INTEGER NOT NULL DEFAULT 0;
        RAISE NOTICE 'Added adjustment_minutes column to mosque_adjustments table';
    END IF;

    -- Add time_type column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mosque_adjustments' 
        AND column_name = 'time_type'
    ) THEN
        ALTER TABLE mosque_adjustments ADD COLUMN time_type TEXT NOT NULL DEFAULT 'adhan';
        RAISE NOTICE 'Added time_type column to mosque_adjustments table';
    END IF;

    -- Add change_source column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mosque_adjustments' 
        AND column_name = 'change_source'
    ) THEN
        ALTER TABLE mosque_adjustments ADD COLUMN change_source TEXT DEFAULT 'user';
        RAISE NOTICE 'Added change_source column to mosque_adjustments table';
    END IF;

    -- Add effective_date column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mosque_adjustments' 
        AND column_name = 'effective_date'
    ) THEN
        ALTER TABLE mosque_adjustments ADD COLUMN effective_date DATE DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Added effective_date column to mosque_adjustments table';
    END IF;

    -- Add changed_by column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mosque_adjustments' 
        AND column_name = 'changed_by'
    ) THEN
        ALTER TABLE mosque_adjustments ADD COLUMN changed_by TEXT;
        RAISE NOTICE 'Added changed_by column to mosque_adjustments table';
    END IF;

    -- Add notes column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mosque_adjustments' 
        AND column_name = 'notes'
    ) THEN
        ALTER TABLE mosque_adjustments ADD COLUMN notes TEXT;
        RAISE NOTICE 'Added notes column to mosque_adjustments table';
    END IF;

    -- Add created_at column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mosque_adjustments' 
        AND column_name = 'created_at'
    ) THEN
        ALTER TABLE mosque_adjustments ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added created_at column to mosque_adjustments table';
    END IF;

    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'mosque_adjustments' 
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE mosque_adjustments ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added updated_at column to mosque_adjustments table';
    END IF;
END $$;

-- ============================================================================
-- CHECK AND CREATE MISSING TABLES
-- ============================================================================

-- Create mosques_metadata table if it doesn't exist
CREATE TABLE IF NOT EXISTS mosques_metadata (
    mosque_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT,
    phone TEXT,
    website TEXT,
    additional_info TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create mosque_time_change_history table if it doesn't exist
CREATE TABLE IF NOT EXISTS mosque_time_change_history (
    id BIGSERIAL PRIMARY KEY,
    mosque_id TEXT NOT NULL,
    prayer_name TEXT NOT NULL,
    time_type TEXT NOT NULL DEFAULT 'adhan',
    previous_adjustment INTEGER,
    new_adjustment INTEGER NOT NULL,
    change_source TEXT DEFAULT 'user',
    effective_date DATE DEFAULT CURRENT_DATE,
    notification_sent BOOLEAN DEFAULT FALSE,
    notification_sent_at TIMESTAMP WITH TIME ZONE,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    previous_time TIME,
    new_time TIME
);

-- ============================================================================
-- UPDATE PRIMARY KEY IF NEEDED
-- ============================================================================

-- Check if primary key exists and add if missing
DO $$
BEGIN
    -- Check if the correct primary key exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'mosque_adjustments' 
        AND constraint_type = 'PRIMARY KEY'
    ) THEN
        -- Add primary key constraint
        ALTER TABLE mosque_adjustments 
        ADD CONSTRAINT mosque_adjustments_pkey 
        PRIMARY KEY (mosque_id, prayer_name, time_type);
        RAISE NOTICE 'Added primary key to mosque_adjustments table';
    END IF;
END $$;

-- ============================================================================
-- CREATE INDEXES IF MISSING
-- ============================================================================

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_mosque_id ON mosque_adjustments(mosque_id);
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_prayer_name ON mosque_adjustments(prayer_name);
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_change_source ON mosque_adjustments(change_source);
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_effective_date ON mosque_adjustments(effective_date);

CREATE INDEX IF NOT EXISTS idx_mosque_time_change_history_mosque_id ON mosque_time_change_history(mosque_id);
CREATE INDEX IF NOT EXISTS idx_mosque_time_change_history_changed_at ON mosque_time_change_history(changed_at);
CREATE INDEX IF NOT EXISTS idx_mosque_time_change_history_notification_sent ON mosque_time_change_history(notification_sent);

-- ============================================================================
-- VERIFY CURRENT STRUCTURE
-- ============================================================================

-- Show current table structure
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'mosque_adjustments'
ORDER BY ordinal_position;

-- Count records in tables
SELECT 
    'mosques_metadata' as table_name, 
    COUNT(*) as record_count,
    'Table exists' as status
FROM mosques_metadata
UNION ALL
SELECT 
    'mosque_adjustments' as table_name, 
    COUNT(*) as record_count,
    'Table exists' as status
FROM mosque_adjustments
UNION ALL
SELECT 
    'mosque_time_change_history' as table_name, 
    COUNT(*) as record_count,
    'Table exists' as status
FROM mosque_time_change_history;

-- ============================================================================
-- SCHEMA FIX COMPLETE
-- ============================================================================ 