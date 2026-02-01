-- ============================================================================
-- MOSQUE FACILITIES SCHEMA MIGRATION
-- Version: 002
-- Description: Adds mosque facilities table for storing facility information
-- ============================================================================

-- Table: mosque_facilities
-- Stores facility information for mosques
CREATE TABLE IF NOT EXISTS mosque_facilities (
    mosque_id TEXT NOT NULL,
    facility_type TEXT NOT NULL,
    availability TEXT NOT NULL DEFAULT 'unknown',
    description TEXT,
    additional_info TEXT,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (mosque_id, facility_type),
    FOREIGN KEY (mosque_id) REFERENCES mosques_metadata(mosque_id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_mosque_facilities_mosque_id ON mosque_facilities(mosque_id);
CREATE INDEX IF NOT EXISTS idx_mosque_facilities_type ON mosque_facilities(facility_type);
CREATE INDEX IF NOT EXISTS idx_mosque_facilities_availability ON mosque_facilities(availability);

-- Enable Row Level Security (optional - for future user-based access control)
-- ALTER TABLE mosque_facilities ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for now (can be restricted later)
-- CREATE POLICY "Allow all operations on mosque_facilities" 
--   ON mosque_facilities FOR ALL 
--   USING (true);

-- Add trigger to update the updated_at column
CREATE TRIGGER update_mosque_facilities_updated_at
BEFORE UPDATE ON mosque_facilities
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Sample data for testing (remove in production)
-- INSERT INTO mosque_facilities (mosque_id, facility_type, availability, description) VALUES
-- ('sample_mosque_id', 'parking', 'easilyAvailable', 'Large parking lot available'),
-- ('sample_mosque_id', 'wudu', 'available', 'Clean ablution facilities'),
-- ('sample_mosque_id', 'toilets', 'available', 'Well-maintained restrooms'),
-- ('sample_mosque_id', 'womenSection', 'available', 'Separate prayer area for women');

-- Verification query
-- SELECT 'mosque_facilities table created successfully' as status; 