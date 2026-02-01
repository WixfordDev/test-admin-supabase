-- COMPLETE TRIVIA SYSTEM FIX
-- This script fixes all issues with trivia rooms and ensures proper text-based room IDs
-- Run this as a single script in your Supabase SQL editor

-- =====================================================
-- STEP 1: SCHEMA FIXES
-- =====================================================

-- Ensure trivia_rooms table exists with proper structure
CREATE TABLE IF NOT EXISTS trivia_rooms (
  id TEXT PRIMARY KEY,
  host_user_id UUID NOT NULL,
  difficulty TEXT NOT NULL,
  max_players INTEGER NOT NULL DEFAULT 4,
  status TEXT NOT NULL DEFAULT 'lobby',
  players JSONB DEFAULT '[]'::jsonb,
  player_scores JSONB DEFAULT '{}'::jsonb,
  short_code VARCHAR(10) UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  current_question_index INTEGER DEFAULT 0,
  current_turn_index INTEGER DEFAULT 0,
  winner_user_id UUID,
  ended_at TIMESTAMP WITH TIME ZONE
);

-- Change id column from UUID to TEXT if it exists as UUID
DO $$
BEGIN
  -- Check if id column is currently UUID type and change it to TEXT
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'trivia_rooms'
    AND column_name = 'id'
    AND data_type = 'uuid'
  ) THEN
    ALTER TABLE trivia_rooms ALTER COLUMN id TYPE TEXT;
    RAISE NOTICE 'Changed trivia_rooms.id from UUID to TEXT';
  END IF;

  -- Ensure short_code column exists and has unique constraint
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'trivia_rooms'
    AND column_name = 'short_code'
  ) THEN
    ALTER TABLE trivia_rooms ADD COLUMN short_code VARCHAR(10);
  END IF;

  -- Add unique constraint on short_code if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'trivia_rooms'
    AND constraint_name = 'trivia_rooms_short_code_unique'
  ) THEN
    ALTER TABLE trivia_rooms ADD CONSTRAINT trivia_rooms_short_code_unique UNIQUE (short_code);
  END IF;

  -- Ensure primary key constraint exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'trivia_rooms'
    AND constraint_type = 'PRIMARY KEY'
  ) THEN
    ALTER TABLE trivia_rooms ADD PRIMARY KEY (id);
  END IF;

  RAISE NOTICE 'Schema fixes completed.';
END $$;

-- =====================================================
-- STEP 2: DROP EXISTING FUNCTIONS (avoid conflicts)
-- =====================================================

DROP FUNCTION IF EXISTS trivia_add_player_to_room(uuid, uuid, text);
DROP FUNCTION IF EXISTS trivia_add_player_to_room(text, uuid, text);
DROP FUNCTION IF EXISTS trivia_remove_player_from_room(uuid, uuid);
DROP FUNCTION IF EXISTS trivia_remove_player_from_room(text, uuid);
DROP FUNCTION IF EXISTS trivia_update_player_score(uuid, uuid, int);
DROP FUNCTION IF EXISTS trivia_update_player_score(text, uuid, int);
DROP FUNCTION IF EXISTS trivia_get_room_with_players(uuid);
DROP FUNCTION IF EXISTS trivia_get_room_with_players(text);
DROP FUNCTION IF EXISTS create_trivia_room(uuid, text, int);
DROP FUNCTION IF EXISTS create_trivia_room_with_short_code(uuid, text, int);
DROP FUNCTION IF EXISTS fix_room_ids();
DROP FUNCTION IF EXISTS generate_missing_short_codes();

-- =====================================================
-- STEP 3: CREATE NEW FUNCTIONS (text-based room IDs)
-- =====================================================

-- Function to create a trivia room with proper text ID and short code
CREATE OR REPLACE FUNCTION create_trivia_room(
  p_host_user_id uuid,
  p_difficulty text,
  p_max_players int
)
RETURNS TABLE(
  room_id text,
  short_code text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_room_id text;
  v_short_code text;
  v_attempts int := 0;
BEGIN
  -- Generate a unique room ID (text format)
  LOOP
    v_room_id := 'room_' || SUBSTRING(gen_random_uuid()::text FROM 1 FOR 8);
    EXIT WHEN NOT EXISTS (SELECT 1 FROM trivia_rooms WHERE id = v_room_id);
    v_attempts := v_attempts + 1;
    EXIT WHEN v_attempts > 100; -- Prevent infinite loop
  END LOOP;

  RAISE NOTICE 'Generated room ID: %', v_room_id;

  -- Generate a unique short code
  LOOP
    v_short_code := SUBSTRING(gen_random_uuid()::text FROM 1 FOR 6);
    EXIT WHEN NOT EXISTS (SELECT 1 FROM trivia_rooms WHERE short_code = v_short_code);
    v_attempts := v_attempts + 1;
    EXIT WHEN v_attempts > 100; -- Prevent infinite loop
  END LOOP;

  -- Create the room with text ID and short code
  INSERT INTO trivia_rooms (
    id,
    host_user_id,
    difficulty,
    max_players,
    status,
    players,
    player_scores,
    short_code
  ) VALUES (
    v_room_id,
    p_host_user_id,
    p_difficulty,
    p_max_players,
    'lobby',
    '[]'::jsonb,
    '{}'::jsonb,
    v_short_code
  );

  -- Return the created room info
  room_id := v_room_id;
  short_code := v_short_code;

  RETURN NEXT;
END;
$$;

-- Function to add a player to a room (room_id as text)
CREATE OR REPLACE FUNCTION trivia_add_player_to_room(
  p_room_id text,
  p_user_id uuid,
  p_display_name text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_players jsonb;
  v_player_exists boolean;
  v_max_players int;
  v_current_count int;
  v_new_player jsonb;
BEGIN
  -- Get current players and max_players (room_id is already text)
  SELECT players, max_players INTO v_players, v_max_players
  FROM trivia_rooms
  WHERE id = p_room_id;

  -- Check if room exists
  IF v_players IS NULL THEN
    RAISE EXCEPTION 'Room not found';
  END IF;

  -- Check if player already exists
  SELECT EXISTS(
    SELECT 1 FROM jsonb_array_elements(v_players) AS player
    WHERE player->>'user_id' = p_user_id::text
  ) INTO v_player_exists;

  IF v_player_exists THEN
    RAISE EXCEPTION 'Player already in room';
  END IF;

  -- Check if room is full
  SELECT jsonb_array_length(v_players) INTO v_current_count;
  IF v_current_count >= v_max_players THEN
    RAISE EXCEPTION 'Room is full';
  END IF;

  -- Create new player object
  v_new_player := jsonb_build_object(
    'user_id', p_user_id::text,
    'display_name', p_display_name,
    'joined_at', NOW()
  );

  -- Add player to array
  UPDATE trivia_rooms
  SET players = players || v_new_player,
      player_scores = player_scores || jsonb_build_object(p_user_id::text, 0)
  WHERE id = p_room_id;

  RETURN v_new_player;
END;
$$;

-- Function to remove a player from a room (room_id as text)
CREATE OR REPLACE FUNCTION trivia_remove_player_from_room(
  p_room_id text,
  p_user_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE trivia_rooms
  SET players = (
    SELECT jsonb_agg(player)
    FROM jsonb_array_elements(players) AS player
    WHERE player->>'user_id' != p_user_id::text
  ),
  player_scores = player_scores - p_user_id::text
  WHERE id = p_room_id;
END;
$$;

-- Function to update player score (room_id as text)
CREATE OR REPLACE FUNCTION trivia_update_player_score(
  p_room_id text,
  p_user_id uuid,
  p_points int
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_score int;
BEGIN
  -- Get current score
  SELECT COALESCE((player_scores->>p_user_id::text)::int, 0)
  INTO v_current_score
  FROM trivia_rooms
  WHERE id = p_room_id;

  -- Update score
  UPDATE trivia_rooms
  SET player_scores = jsonb_set(
    player_scores,
    ARRAY[p_user_id::text],
    to_jsonb(v_current_score + p_points)
  )
  WHERE id = p_room_id;
END;
$$;

-- Function to get room with players (room_id as text)
CREATE OR REPLACE FUNCTION trivia_get_room_with_players(p_room_id text)
RETURNS TABLE(
  room_data jsonb,
  players_data jsonb,
  scores_data jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    to_jsonb(tr.*) - 'players' - 'player_scores' as room_data,
    tr.players as players_data,
    tr.player_scores as scores_data
  FROM trivia_rooms tr
  WHERE tr.id = p_room_id;
END;
$$;

-- =====================================================
-- STEP 4: DATA MIGRATION
-- =====================================================

-- Fix existing rooms with invalid room IDs
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

    RAISE NOTICE 'Fixing room ID from % to %', room_record.id, new_room_id;

    -- Update the room ID to the new format
    UPDATE trivia_rooms
    SET id = new_room_id
    WHERE id = room_record.id;

    RAISE NOTICE 'Fixed room ID from % to %', room_record.id, new_room_id;
  END LOOP;

  RAISE NOTICE 'Room ID fixes completed.';
END $$;

-- Generate unique short codes for existing rooms
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

-- =====================================================
-- STEP 5: GRANT PERMISSIONS
-- =====================================================

GRANT EXECUTE ON FUNCTION create_trivia_room(uuid, text, int) TO authenticated;
GRANT EXECUTE ON FUNCTION trivia_add_player_to_room(text, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION trivia_remove_player_from_room(text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION trivia_update_player_score(text, uuid, int) TO authenticated;
GRANT EXECUTE ON FUNCTION trivia_get_room_with_players(text) TO authenticated;

-- =====================================================
-- STEP 6: VERIFICATION
-- =====================================================

-- Show final results
SELECT
  'Migration completed successfully!' as status,
  COUNT(*) as total_rooms,
  COUNT(*) FILTER (WHERE id LIKE 'room_%' AND length(id) = 14) as valid_room_ids,
  COUNT(*) FILTER (WHERE short_code IS NOT NULL AND length(short_code) = 6) as rooms_with_short_codes
FROM trivia_rooms;
