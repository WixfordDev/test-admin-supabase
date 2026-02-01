-- ============================================================================
-- DIAGNOSE CURRENT DATABASE SCHEMA
-- Version: 004
-- Description: Check what tables and columns currently exist
-- ============================================================================

-- Check if mosque_adjustments table exists
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'mosque_adjustments')
        THEN 'mosque_adjustments table EXISTS'
        ELSE 'mosque_adjustments table MISSING'
    END as table_status;

-- If table exists, show its current structure
SELECT 
    'mosque_adjustments' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'mosque_adjustments'
ORDER BY ordinal_position;

-- Check for specific missing columns
SELECT 
    'adjustment_minutes' as column_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'mosque_adjustments' 
            AND column_name = 'adjustment_minutes'
        )
        THEN 'EXISTS'
        ELSE 'MISSING'
    END as status
UNION ALL
SELECT 
    'time_type' as column_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'mosque_adjustments' 
            AND column_name = 'time_type'
        )
        THEN 'EXISTS'
        ELSE 'MISSING'
    END as status
UNION ALL
SELECT 
    'change_source' as column_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'mosque_adjustments' 
            AND column_name = 'change_source'
        )
        THEN 'EXISTS'
        ELSE 'MISSING'
    END as status;

-- Check all mosque-related tables
SELECT 
    table_name,
    CASE 
        WHEN table_name = 'mosques_metadata' THEN 'Mosque basic info'
        WHEN table_name = 'mosque_adjustments' THEN 'Prayer time adjustments'
        WHEN table_name = 'mosque_time_change_history' THEN 'Change tracking'
        ELSE 'Other'
    END as purpose
FROM information_schema.tables 
WHERE table_name LIKE '%mosque%'
ORDER BY table_name;

-- Show any existing data in mosque_adjustments (if table exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'mosque_adjustments') THEN
        RAISE NOTICE 'mosque_adjustments table exists - showing sample data...';
    ELSE
        RAISE NOTICE 'mosque_adjustments table does not exist!';
    END IF;
END $$; 