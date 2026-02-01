-- Migration: Redesign trivia_rooms to support n players with array fields
-- This migration adds players and scores arrays to trivia_rooms table

-- Step 1: Add new columns to trivia_rooms
ALTER TABLE trivia_rooms
ADD COLUMN IF NOT EXISTS players JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS player_scores JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS short_code VARCHAR(10) UNIQUE;

-- Step 1.5: Ensure id column is TEXT and add constraints
-- This ensures room IDs are text throughout the system
DO $$
BEGIN
  -- Check if id column exists and change it to TEXT if it's not already
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'trivia_rooms'
    AND column_name = 'id'
    AND data_type != 'text'
  ) THEN
    -- Change column to TEXT
    ALTER TABLE trivia_rooms ALTER COLUMN id TYPE TEXT;
    RAISE NOTICE 'Changed trivia_rooms.id to TEXT';
  END IF;

  -- Add primary key constraint if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'trivia_rooms'
    AND constraint_type = 'PRIMARY KEY'
  ) THEN
    ALTER TABLE trivia_rooms ADD PRIMARY KEY (id);
    RAISE NOTICE 'Added PRIMARY KEY constraint to trivia_rooms.id';
  END IF;

  -- Add unique constraint on short_code if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'trivia_rooms'
    AND constraint_name = 'trivia_rooms_short_code_unique'
  ) THEN
    -- First ensure short_code column exists
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'trivia_rooms'
      AND column_name = 'short_code'
    ) THEN
      ALTER TABLE trivia_rooms ADD COLUMN short_code VARCHAR(10);
    END IF;

    -- Add unique constraint
    ALTER TABLE trivia_rooms ADD CONSTRAINT trivia_rooms_short_code_unique UNIQUE (short_code);
    RAISE NOTICE 'Added UNIQUE constraint to trivia_rooms.short_code';
  END IF;
END $$;

-- Step 2: Migrate existing data from trivia_room_players to trivia_rooms
-- This will populate the players array with existing player data
UPDATE trivia_rooms tr
SET players = (
  SELECT jsonb_agg(
    jsonb_build_object(
      'user_id', trp.user_id,
      'display_name', trp.display_name,
      'joined_at', trp.joined_at
    )
  )
  FROM trivia_room_players trp
  WHERE trp.room_id = tr.id
)
WHERE EXISTS (
  SELECT 1 FROM trivia_room_players trp WHERE trp.room_id = tr.id
);

-- Step 3: Migrate existing scores from trivia_answers to trivia_rooms
-- This will populate player_scores object with aggregated scores
UPDATE trivia_rooms tr
SET player_scores = (
  SELECT jsonb_object_agg(
    user_id::text,
    total_points
  )
  FROM (
    SELECT
      ta.user_id,
      SUM(ta.points_awarded) as total_points
    FROM trivia_answers ta
    WHERE ta.room_id = tr.id
    GROUP BY ta.user_id
  ) as score_totals
)
WHERE EXISTS (
  SELECT 1 FROM trivia_answers ta WHERE ta.room_id = tr.id
);

-- Step 4: Set default empty object for rooms with no scores
UPDATE trivia_rooms
SET player_scores = '{}'::jsonb
WHERE player_scores IS NULL;

-- Step 5: Set default empty array for rooms with no players
UPDATE trivia_rooms
SET players = '[]'::jsonb
WHERE players IS NULL;

-- Step 6: Create helper functions

-- Function to add a player to a room
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
  v_room_uuid uuid;
BEGIN
  -- Convert room_id to UUID for proper lookup
  v_room_uuid := p_room_id::uuid;

  -- Get current players and max_players
  SELECT players, max_players INTO v_players, v_max_players
  FROM trivia_rooms
  WHERE id = v_room_uuid;

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
  WHERE id = v_room_uuid;

  RETURN v_new_player;
END;
$$;

-- Function to remove a player from a room
CREATE OR REPLACE FUNCTION trivia_remove_player_from_room(
  p_room_id text,
  p_user_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_room_uuid uuid;
BEGIN
  v_room_uuid := p_room_id::uuid;

  UPDATE trivia_rooms
  SET players = (
    SELECT jsonb_agg(player)
    FROM jsonb_array_elements(players) AS player
    WHERE player->>'user_id' != p_user_id::text
  ),
  player_scores = player_scores - p_user_id::text
  WHERE id = v_room_uuid;
END;
$$;

-- Function to update player score
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
  v_room_uuid uuid;
BEGIN
  v_room_uuid := p_room_id::uuid;

  -- Get current score
  SELECT COALESCE((player_scores->>p_user_id::text)::int, 0)
  INTO v_current_score
  FROM trivia_rooms
  WHERE id = v_room_uuid;

  -- Update score
  UPDATE trivia_rooms
  SET player_scores = jsonb_set(
    player_scores,
    ARRAY[p_user_id::text],
    to_jsonb(v_current_score + p_points)
  )
  WHERE id = v_room_uuid;
END;
$$;

-- Function to get room with players (for easy querying)
CREATE OR REPLACE FUNCTION trivia_get_room_with_players(p_room_id text)
RETURNS TABLE(
  room_data jsonb,
  players_data jsonb,
  scores_data jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_room_uuid uuid;
BEGIN
  v_room_uuid := p_room_id::uuid;

  RETURN QUERY
  SELECT
    to_jsonb(tr.*) - 'players' - 'player_scores' as room_data,
    tr.players as players_data,
    tr.player_scores as scores_data
  FROM trivia_rooms tr
  WHERE tr.id = v_room_uuid;
END;
$$;

-- Step 7: Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_trivia_rooms_players_gin ON trivia_rooms USING GIN (players);
CREATE INDEX IF NOT EXISTS idx_trivia_rooms_scores_gin ON trivia_rooms USING GIN (player_scores);

-- Step 8: Update RLS policies if needed
-- Grant access to functions
GRANT EXECUTE ON FUNCTION trivia_add_player_to_room(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION trivia_remove_player_from_room(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION trivia_update_player_score(uuid, uuid, int) TO authenticated;
GRANT EXECUTE ON FUNCTION trivia_get_room_with_players(uuid) TO authenticated;

-- Step 9: Generate short codes for existing rooms
-- Generate short codes for rooms that don't have them
UPDATE trivia_rooms
SET short_code = SUBSTRING(id::text FROM 1 FOR 6)
WHERE short_code IS NULL;

-- Step 10: Create function to generate unique short codes
CREATE OR REPLACE FUNCTION generate_unique_short_code()
RETURNS VARCHAR(10)
LANGUAGE plpgsql
AS $$
DECLARE
  short_code VARCHAR(10);
  attempts INT := 0;
BEGIN
  LOOP
    -- Generate a random 6-character code using first 6 chars of a UUID
    short_code := SUBSTRING(gen_random_uuid()::text FROM 1 FOR 6);

    -- Check if it's unique
    IF NOT EXISTS (SELECT 1 FROM trivia_rooms WHERE short_code = short_code) THEN
      RETURN short_code;
    END IF;

    attempts := attempts + 1;
    -- Prevent infinite loop
    IF attempts > 100 THEN
      RAISE EXCEPTION 'Could not generate unique short code after 100 attempts';
    END IF;
  END LOOP;
END;
$$;

-- Step 11: Update create room logic to generate short codes
-- This would need to be updated in the application code as well

-- Step 12: Add comments for documentation
COMMENT ON COLUMN trivia_rooms.players IS 'Array of player objects containing user_id, display_name, and joined_at';
COMMENT ON COLUMN trivia_rooms.player_scores IS 'Object mapping user_id to their current score';
COMMENT ON COLUMN trivia_rooms.short_code IS 'Unique 6-character code for easy room sharing';
COMMENT ON FUNCTION trivia_add_player_to_room IS 'Adds a player to a trivia room, checking for duplicates and room capacity';
COMMENT ON FUNCTION trivia_remove_player_from_room IS 'Removes a player from a trivia room';
COMMENT ON FUNCTION trivia_update_player_score IS 'Updates a player''s score in a trivia room';
COMMENT ON FUNCTION trivia_get_room_with_players IS 'Returns room data with separate players and scores fields';
COMMENT ON FUNCTION generate_unique_short_code IS 'Generates a unique 6-character short code for room identification';

-- Note: The old tables (trivia_room_players, trivia_answers) are kept for historical data
-- If you want to drop them after confirming the migration works, uncomment:
-- DROP TABLE IF EXISTS trivia_room_players CASCADE;
-- However, keep trivia_answers for detailed answer history if needed

