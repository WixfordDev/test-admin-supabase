-- Standalone script to fix existing trivia rooms
-- Run this directly in your Supabase SQL editor after applying migrations

-- 1. Fix room IDs that don't follow the proper format
DO $$
DECLARE
  room_record RECORD;
  new_room_id text;
  attempts int;
BEGIN
  RAISE NOTICE 'Starting room ID fixes...';

  -- Find rooms where ID doesn't follow the expected pattern
  FOR room_record IN
    SELECT id FROM trivia_rooms
    WHERE id NOT LIKE 'room_%' OR length(id) != 14
  LOOP
    -- Generate a new room ID in the format 'room_xxxxxxxx'
    attempts := 0;
    LOOP
      new_room_id := 'room_' || SUBSTRING(gen_random_uuid()::text FROM 1 FOR 8);
      EXIT WHEN NOT EXISTS (SELECT 1 FROM trivia_rooms WHERE id = new_room_id);
      attempts := attempts + 1;
      EXIT WHEN attempts > 100;
    END LOOP;

    -- Update the room ID to the new format
    UPDATE trivia_rooms
    SET id = new_room_id
    WHERE id = room_record.id;

    RAISE NOTICE 'Fixed room ID from % to %', room_record.id, new_room_id;
  END LOOP;

  RAISE NOTICE 'Room ID fixes completed.';
END $$;

-- 2. Generate short codes for rooms that don't have them
DO $$
DECLARE
  room_record RECORD;
  new_short_code text;
  attempts int;
BEGIN
  RAISE NOTICE 'Starting short code generation...';

  -- Find rooms without short codes or with invalid short codes
  FOR room_record IN
    SELECT id FROM trivia_rooms
    WHERE short_code IS NULL OR length(short_code) != 6
  LOOP
    -- Generate a unique short code
    attempts := 0;
    LOOP
      new_short_code := SUBSTRING(gen_random_uuid()::text FROM 1 FOR 6);
      EXIT WHEN NOT EXISTS (SELECT 1 FROM trivia_rooms WHERE short_code = new_short_code);
      attempts := attempts + 1;
      EXIT WHEN attempts > 100;
    END LOOP;

    -- Update the room with the new short code
    UPDATE trivia_rooms
    SET short_code = new_short_code
    WHERE id = room_record.id;

    RAISE NOTICE 'Generated short code % for room %', new_short_code, room_record.id;
  END LOOP;

  RAISE NOTICE 'Short code generation completed.';
END $$;

-- 3. Verify the fixes
SELECT
  'Room ID fixes completed' as message,
  COUNT(*) as total_rooms,
  COUNT(*) FILTER (WHERE id LIKE 'room_%' AND length(id) = 14) as valid_room_ids,
  COUNT(*) FILTER (WHERE short_code IS NOT NULL AND length(short_code) = 6) as rooms_with_short_codes
FROM trivia_rooms;



