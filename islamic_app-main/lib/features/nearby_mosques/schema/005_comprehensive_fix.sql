-- ============================================================================
-- COMPREHENSIVE FIX FOR MISSING COLUMNS
-- Version: 005
-- Description: Thorough fix for adjustment_minutes column and complete schema
-- ============================================================================

-- Step 1: Check what actually exists in the database
SELECT 'Checking all tables with mosque in name...' as step;

SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE tablename LIKE '%mosque%'
ORDER BY tablename;

-- Step 2: Check the exact structure of mosque_adjustments if it exists
SELECT 'Current mosque_adjustments structure (if exists):' as step;

SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'mosque_adjustments'
ORDER BY ordinal_position;

-- Step 3: Drop and recreate the table if needed (safer approach)
DO $$
BEGIN
    -- Check if table exists and has wrong structure
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'mosque_adjustments') THEN
        -- Check if adjustment_minutes column is missing
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'mosque_adjustments' 
            AND column_name = 'adjustment_minutes'
        ) THEN
            RAISE NOTICE 'Table exists but missing adjustment_minutes column. Recreating table...';
            
            -- Backup any existing data
            CREATE TABLE IF NOT EXISTS mosque_adjustments_backup AS 
            SELECT * FROM mosque_adjustments;
            
            -- Drop the old table
            DROP TABLE IF EXISTS mosque_adjustments CASCADE;
            
            RAISE NOTICE 'Old table dropped and backed up';
        ELSE
            RAISE NOTICE 'Table exists and has adjustment_minutes column';
        END IF;
    ELSE
        RAISE NOTICE 'mosque_adjustments table does not exist';
    END IF;
END $$;

-- Step 4: Create the table with correct structure
CREATE TABLE IF NOT EXISTS mosque_adjustments (
    mosque_id TEXT NOT NULL,
    prayer_name TEXT NOT NULL,
    time_type TEXT NOT NULL DEFAULT 'adhan',
    adjustment_minutes INTEGER NOT NULL DEFAULT 0,
    change_source TEXT DEFAULT 'user',
    effective_date DATE DEFAULT CURRENT_DATE,
    changed_by TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (mosque_id, prayer_name, time_type)
);

-- Step 5: Ensure other required tables exist
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

-- Step 6: Create indexes
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_mosque_id ON mosque_adjustments(mosque_id);
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_prayer_name ON mosque_adjustments(prayer_name);
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_change_source ON mosque_adjustments(change_source);

-- Step 7: Restore any backed up data if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'mosque_adjustments_backup') THEN
        -- Try to restore data with proper column mapping
        INSERT INTO mosque_adjustments (
            mosque_id, 
            prayer_name, 
            time_type,
            adjustment_minutes,
            created_at
        )
        SELECT 
            mosque_id, 
            prayer_name,
            COALESCE(time_type, 'adhan') as time_type,
            COALESCE(adjustment_minutes, 0) as adjustment_minutes,
            COALESCE(created_at, NOW()) as created_at
        FROM mosque_adjustments_backup
        ON CONFLICT (mosque_id, prayer_name, time_type) DO NOTHING;
        
        RAISE NOTICE 'Data restored from backup';
        
        -- Drop the backup table
        DROP TABLE mosque_adjustments_backup;
    END IF;
END $$;

-- Step 8: Final verification
SELECT 'FINAL VERIFICATION:' as step;

-- Show the final table structure
SELECT 
    'mosque_adjustments' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'mosque_adjustments'
ORDER BY ordinal_position;

-- Test insert to verify it works
DO $$
BEGIN
    -- Try a test insert
    INSERT INTO mosque_adjustments (
        mosque_id, 
        prayer_name, 
        time_type, 
        adjustment_minutes
    ) VALUES (
        'test_mosque_fix', 
        'fajr', 
        'adhan', 
        15
    ) ON CONFLICT (mosque_id, prayer_name, time_type) DO UPDATE SET
        adjustment_minutes = EXCLUDED.adjustment_minutes;
    
    RAISE NOTICE 'Test insert successful!';
    
    -- Clean up test data
    DELETE FROM mosque_adjustments WHERE mosque_id = 'test_mosque_fix';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Test insert failed: %', SQLERRM;
END $$;

-- Step 9: Check if adjustment_minutes column definitely exists now
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'mosque_adjustments' 
            AND column_name = 'adjustment_minutes'
        )
        THEN '✅ adjustment_minutes column EXISTS and ready to use!'
        ELSE '❌ adjustment_minutes column STILL MISSING - contact support'
    END as final_status;

-- ============================================================================
-- COMPREHENSIVE FIX COMPLETE
-- ============================================================================ 