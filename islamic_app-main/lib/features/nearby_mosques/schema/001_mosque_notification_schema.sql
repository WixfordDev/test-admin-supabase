-- ============================================================================
-- MOSQUE NOTIFICATION SYSTEM SCHEMA MIGRATION
-- Version: 001
-- Description: Creates tables, functions, and triggers for mosque notification system
-- ============================================================================

-- Ensure required extensions are installed
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ============================================================================
-- TABLES
-- ============================================================================

-- Table: mosques_metadata
-- Stores basic information about mosques
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

-- Table: mosque_adjustments
-- Stores prayer time adjustments for mosques
CREATE TABLE IF NOT EXISTS mosque_adjustments (
    mosque_id TEXT NOT NULL,
    prayer_name TEXT NOT NULL,
    time_type TEXT NOT NULL DEFAULT 'adhan', -- 'adhan' or 'iqamah'
    adjustment_minutes INTEGER NOT NULL DEFAULT 0,
    change_source TEXT DEFAULT 'user', -- 'user' or 'prediction'
    effective_date DATE DEFAULT CURRENT_DATE,
    changed_by TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (mosque_id, prayer_name, time_type),
    FOREIGN KEY (mosque_id) REFERENCES mosques_metadata(mosque_id) ON DELETE CASCADE
);

-- Table: mosque_time_change_history
-- Tracks all changes to mosque prayer times for notification purposes
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
    new_time TIME,
    FOREIGN KEY (mosque_id) REFERENCES mosques_metadata(mosque_id) ON DELETE CASCADE
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_mosque_id ON mosque_adjustments(mosque_id);
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_prayer_name ON mosque_adjustments(prayer_name);
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_change_source ON mosque_adjustments(change_source);
CREATE INDEX IF NOT EXISTS idx_mosque_adjustments_effective_date ON mosque_adjustments(effective_date);

CREATE INDEX IF NOT EXISTS idx_mosque_time_change_history_mosque_id ON mosque_time_change_history(mosque_id);
CREATE INDEX IF NOT EXISTS idx_mosque_time_change_history_changed_at ON mosque_time_change_history(changed_at);
CREATE INDEX IF NOT EXISTS idx_mosque_time_change_history_notification_sent ON mosque_time_change_history(notification_sent);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: update_updated_at_column
-- Updates the updated_at timestamp when a row is modified
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: track_mosque_time_change
-- Tracks changes to mosque adjustments in the history table
CREATE OR REPLACE FUNCTION track_mosque_time_change() 
RETURNS TRIGGER AS $$
DECLARE
    previous_adjustment INTEGER;
BEGIN
    -- Get the previous adjustment if it exists
    SELECT adjustment_minutes INTO previous_adjustment 
    FROM mosque_time_change_history 
    WHERE mosque_id = NEW.mosque_id 
        AND prayer_name = NEW.prayer_name 
        AND time_type = NEW.time_type
    ORDER BY changed_at DESC 
    LIMIT 1;
    
    -- Record the change in history with new fields
    INSERT INTO mosque_time_change_history (
        mosque_id, 
        prayer_name,
        time_type,
        previous_adjustment,
        new_adjustment,
        change_source,
        effective_date
    ) VALUES (
        NEW.mosque_id,
        NEW.prayer_name,
        NEW.time_type,
        previous_adjustment,
        NEW.adjustment_minutes,
        COALESCE(NEW.change_source, 'user'),
        COALESCE(NEW.effective_date, CURRENT_DATE)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: notify_mosque_time_change
-- Sends webhook notification when mosque times are changed
CREATE OR REPLACE FUNCTION notify_mosque_time_change() 
RETURNS TRIGGER AS $$
DECLARE
    mosque_name TEXT;
    previous_adjustment INTEGER;
    change_record_id BIGINT;
    webhook_url TEXT;
    webhook_response_id UUID;
    should_notify BOOLEAN := FALSE;
    time_difference INTEGER;
    webhook_body JSONB;
    auth_header TEXT;
BEGIN
    -- Get mosque name for the notification
    SELECT name INTO mosque_name 
    FROM mosques_metadata 
    WHERE mosque_id = NEW.mosque_id;
    
    -- If mosque not found in metadata, skip notification
    IF mosque_name IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Get the previous adjustment for comparison
    SELECT adjustment_minutes INTO previous_adjustment 
    FROM mosque_time_change_history 
    WHERE mosque_id = NEW.mosque_id 
        AND prayer_name = NEW.prayer_name 
        AND time_type = NEW.time_type
    ORDER BY changed_at DESC 
    LIMIT 1 OFFSET 1;
    
    -- Calculate time difference
    time_difference := COALESCE(ABS(NEW.adjustment_minutes - COALESCE(previous_adjustment, 0)), 0);
    
    -- Determine if we should send notification based on change source
    IF COALESCE(NEW.change_source, 'user') = 'user' THEN
        -- For user changes, always notify regardless of time difference
        should_notify := TRUE;
    ELSE
        -- For prediction changes, only notify if difference is 5+ minutes
        should_notify := (time_difference >= 5);
    END IF;
    
    -- Send notification if criteria met
    IF should_notify THEN
        
        -- Get the latest change record ID
        SELECT id INTO change_record_id
        FROM mosque_time_change_history 
        WHERE mosque_id = NEW.mosque_id 
            AND prayer_name = NEW.prayer_name 
            AND time_type = NEW.time_type
            AND new_adjustment = NEW.adjustment_minutes
        ORDER BY changed_at DESC 
        LIMIT 1;
        
        -- Construct the webhook URL
        webhook_url := 'https://gbfgotocraqfbzovzzum.supabase.co/functions/v1/fcm-mosque-notification';
        
        -- Prepare the authorization header
        auth_header := 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdiZmdvdG9jcmFxZmJ6b3Z6enVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4NzA1NTQsImV4cCI6MjA2MjQ0NjU1NH0.HTmRSjrliQghBFyb2C9i-E8u2Qxa1pgbRdA_X3VC7mQ';
        
        -- Prepare the request body with mosque name included
        webhook_body := jsonb_build_object(
            'mosque_id', NEW.mosque_id,
            'mosque_name', mosque_name,
            'prayer_name', NEW.prayer_name,
            'time_type', COALESCE(NEW.time_type, 'adhan'),
            'adjustment_minutes', NEW.adjustment_minutes,
            'previous_adjustment', previous_adjustment,
            'change_source', COALESCE(NEW.change_source, 'user'),
            'effective_date', COALESCE(NEW.effective_date, CURRENT_DATE),
            'notification_id', change_record_id
        );
        
        -- Make HTTP request to Edge Function with error handling
        BEGIN
            SELECT net.http_post(
                url := webhook_url,
                headers := jsonb_build_object(
                    'Content-Type', 'application/json',
                    'Authorization', auth_header
                ),
                body := webhook_body
            ) INTO webhook_response_id;
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Log error but don't fail the transaction
                NULL;
        END;
        
    END IF;
    
    RETURN NEW;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the transaction
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: test_mosque_notification
-- Test function to trigger notifications manually
CREATE OR REPLACE FUNCTION test_mosque_notification(
    test_mosque_id TEXT DEFAULT 'test_mosque_123',
    test_prayer_name TEXT DEFAULT 'fajr',
    test_adjustment INTEGER DEFAULT 15
) RETURNS VOID AS $$
BEGIN
    -- First ensure the mosque exists in metadata
    INSERT INTO mosques_metadata (mosque_id, name, latitude, longitude)
    VALUES (test_mosque_id, 'Test Mosque', 40.7128, -74.0060)
    ON CONFLICT (mosque_id) DO UPDATE SET 
        name = EXCLUDED.name,
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude;
    
    -- Insert or update a mosque adjustment to trigger the notification
    INSERT INTO mosque_adjustments (
        mosque_id, 
        prayer_name, 
        time_type, 
        adjustment_minutes, 
        change_source,
        effective_date,
        changed_by,
        notes
    ) VALUES (
        test_mosque_id,
        test_prayer_name,
        'adhan',
        test_adjustment,
        'user',
        CURRENT_DATE,
        'test_user',
        'Testing notification system'
    )
    ON CONFLICT (mosque_id, prayer_name, time_type) 
    DO UPDATE SET 
        adjustment_minutes = EXCLUDED.adjustment_minutes,
        change_source = EXCLUDED.change_source,
        effective_date = EXCLUDED.effective_date,
        changed_by = EXCLUDED.changed_by,
        notes = EXCLUDED.notes,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update updated_at column for mosques_metadata
DROP TRIGGER IF EXISTS update_mosques_metadata_updated_at ON mosques_metadata;
CREATE TRIGGER update_mosques_metadata_updated_at
    BEFORE UPDATE ON mosques_metadata
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Update updated_at column for mosque_adjustments
DROP TRIGGER IF EXISTS update_mosque_adjustments_updated_at ON mosque_adjustments;
CREATE TRIGGER update_mosque_adjustments_updated_at
    BEFORE UPDATE ON mosque_adjustments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Track mosque time changes (runs first)
DROP TRIGGER IF EXISTS mosque_time_change_trigger ON mosque_adjustments;
CREATE TRIGGER mosque_time_change_trigger
    AFTER INSERT OR UPDATE ON mosque_adjustments
    FOR EACH ROW
    EXECUTE FUNCTION track_mosque_time_change();

-- Trigger: Send notification webhook (runs second)
DROP TRIGGER IF EXISTS mosque_notification_webhook_trigger ON mosque_adjustments;
CREATE TRIGGER mosque_notification_webhook_trigger
    AFTER INSERT OR UPDATE ON mosque_adjustments
    FOR EACH ROW
    EXECUTE FUNCTION notify_mosque_time_change();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE mosques_metadata IS 'Stores basic information about mosques including location and contact details';
COMMENT ON TABLE mosque_adjustments IS 'Stores prayer time adjustments with change tracking for notifications';
COMMENT ON TABLE mosque_time_change_history IS 'Tracks all changes to mosque prayer times for audit and notification purposes';

COMMENT ON COLUMN mosque_adjustments.change_source IS 'Source of change: user (manual update) or prediction (automatic calculation)';
COMMENT ON COLUMN mosque_adjustments.effective_date IS 'Date when the time change takes effect';
COMMENT ON COLUMN mosque_adjustments.changed_by IS 'Optional identifier of who made the change';

-- ============================================================================
-- SCHEMA MIGRATION COMPLETE
-- ============================================================================ 