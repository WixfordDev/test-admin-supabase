-- ============================================================================
-- VERIFICATION QUERIES FOR MOSQUE NOTIFICATION SYSTEM
-- Version: 002
-- Description: Queries to verify schema installation and test functionality
-- ============================================================================

-- ============================================================================
-- SCHEMA VERIFICATION
-- ============================================================================

-- Check if all tables exist
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE tablename IN ('mosques_metadata', 'mosque_adjustments', 'mosque_time_change_history')
ORDER BY tablename;

-- Check table structures
\d mosques_metadata
\d mosque_adjustments  
\d mosque_time_change_history

-- Verify indexes exist
SELECT 
    indexname,
    tablename,
    indexdef
FROM pg_indexes 
WHERE tablename IN ('mosque_adjustments', 'mosque_time_change_history')
ORDER BY tablename, indexname;

-- Check if functions exist
SELECT 
    proname as function_name,
    pronargs as num_args,
    prorettype::regtype as return_type
FROM pg_proc 
WHERE proname IN (
    'update_updated_at_column',
    'track_mosque_time_change', 
    'notify_mosque_time_change',
    'test_mosque_notification'
)
ORDER BY proname;

-- Check if triggers exist
SELECT 
    trigger_name,
    table_name,
    action_timing,
    event_manipulation
FROM information_schema.triggers 
WHERE table_name = 'mosque_adjustments'
ORDER BY trigger_name;

-- ============================================================================
-- DATA VERIFICATION
-- ============================================================================

-- Count records in each table
SELECT 'mosques_metadata' as table_name, COUNT(*) as record_count FROM mosques_metadata
UNION ALL
SELECT 'mosque_adjustments' as table_name, COUNT(*) as record_count FROM mosque_adjustments  
UNION ALL
SELECT 'mosque_time_change_history' as table_name, COUNT(*) as record_count FROM mosque_time_change_history;

-- Show sample data from each table (if any exists)
SELECT 'mosques_metadata' as table_name, mosque_id, name, latitude, longitude 
FROM mosques_metadata LIMIT 5;

SELECT 'mosque_adjustments' as table_name, mosque_id, prayer_name, adjustment_minutes, change_source
FROM mosque_adjustments LIMIT 5;

SELECT 'mosque_time_change_history' as table_name, mosque_id, prayer_name, new_adjustment, notification_sent
FROM mosque_time_change_history LIMIT 5;

-- ============================================================================
-- FUNCTIONALITY TESTS
-- ============================================================================

-- Test 1: Create a test mosque and adjustment
DO $$
BEGIN
    -- Insert test mosque metadata
    INSERT INTO mosques_metadata (mosque_id, name, latitude, longitude)
    VALUES ('verification_mosque_001', 'Verification Test Mosque', 40.7128, -74.0060)
    ON CONFLICT (mosque_id) DO UPDATE SET 
        name = EXCLUDED.name,
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude;
    
    -- Insert test adjustment (this should trigger our functions)
    INSERT INTO mosque_adjustments (
        mosque_id, 
        prayer_name, 
        time_type, 
        adjustment_minutes, 
        change_source,
        changed_by,
        notes
    ) VALUES (
        'verification_mosque_001',
        'fajr',
        'adhan', 
        10,
        'user',
        'verification_test',
        'Schema verification test'
    )
    ON CONFLICT (mosque_id, prayer_name, time_type) 
    DO UPDATE SET 
        adjustment_minutes = EXCLUDED.adjustment_minutes,
        change_source = EXCLUDED.change_source,
        changed_by = EXCLUDED.changed_by,
        notes = EXCLUDED.notes,
        updated_at = NOW();
    
    RAISE NOTICE 'Test mosque and adjustment created successfully';
END $$;

-- Test 2: Verify that triggers fired and history was recorded
SELECT 
    mosque_id,
    prayer_name,
    previous_adjustment,
    new_adjustment,
    change_source,
    notification_sent,
    changed_at
FROM mosque_time_change_history 
WHERE mosque_id = 'verification_mosque_001'
ORDER BY changed_at DESC;

-- Test 3: Test the notification function directly
SELECT test_mosque_notification('test_notification_mosque', 'maghrib', 15);

-- Verify the test notification created records
SELECT 
    m.mosque_id,
    m.name,
    a.prayer_name,
    a.adjustment_minutes,
    a.change_source
FROM mosques_metadata m
JOIN mosque_adjustments a ON m.mosque_id = a.mosque_id
WHERE m.mosque_id = 'test_notification_mosque';

-- Check if history record was created for test
SELECT 
    mosque_id,
    prayer_name,
    new_adjustment,
    change_source,
    notification_sent
FROM mosque_time_change_history 
WHERE mosque_id = 'test_notification_mosque'
ORDER BY changed_at DESC;

-- ============================================================================
-- PERFORMANCE VERIFICATION
-- ============================================================================

-- Check if indexes are being used (analyze query plans)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM mosque_adjustments WHERE mosque_id = 'verification_mosque_001';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM mosque_time_change_history WHERE mosque_id = 'verification_mosque_001';

-- ============================================================================
-- CLEANUP (Optional - run if you want to remove test data)
-- ============================================================================

/*
-- Uncomment to clean up test data
DELETE FROM mosque_time_change_history WHERE mosque_id IN ('verification_mosque_001', 'test_notification_mosque');
DELETE FROM mosque_adjustments WHERE mosque_id IN ('verification_mosque_001', 'test_notification_mosque');  
DELETE FROM mosques_metadata WHERE mosque_id IN ('verification_mosque_001', 'test_notification_mosque');
*/

-- ============================================================================
-- SYSTEM STATUS SUMMARY
-- ============================================================================

-- Final verification summary
SELECT 
    'Schema Status' as check_type,
    CASE 
        WHEN COUNT(*) = 3 THEN 'All tables exist ✓'
        ELSE 'Missing tables ✗'
    END as status
FROM pg_tables 
WHERE tablename IN ('mosques_metadata', 'mosque_adjustments', 'mosque_time_change_history')

UNION ALL

SELECT 
    'Functions Status' as check_type,
    CASE 
        WHEN COUNT(*) = 4 THEN 'All functions exist ✓'
        ELSE 'Missing functions ✗'
    END as status
FROM pg_proc 
WHERE proname IN (
    'update_updated_at_column',
    'track_mosque_time_change', 
    'notify_mosque_time_change',
    'test_mosque_notification'
)

UNION ALL

SELECT 
    'Triggers Status' as check_type,
    CASE 
        WHEN COUNT(*) >= 3 THEN 'Triggers active ✓'
        ELSE 'Missing triggers ✗'
    END as status
FROM information_schema.triggers 
WHERE table_name = 'mosque_adjustments';

-- Show notification system readiness
SELECT 
    'Notification System' as component,
    CASE 
        WHEN EXISTS (SELECT 1 FROM mosque_time_change_history LIMIT 1) THEN 'Ready and tested ✓'
        ELSE 'Not tested yet - run test_mosque_notification() ⚠'
    END as status; 