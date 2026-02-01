-- Trivia Array Operations - Quick Reference
-- Common queries and operations for the new array-based trivia system

-- ============================================================================
-- PLAYER OPERATIONS
-- ============================================================================

-- Add a player to a room (recommended way)
SELECT trivia_add_player_to_room(
  'room-uuid'::uuid,
  'user-uuid'::uuid,
  'PlayerName'
);

-- Remove a player from a room
SELECT trivia_remove_player_from_room(
  'room-uuid'::uuid,
  'user-uuid'::uuid
);

-- Get all players in a room
SELECT 
  id as room_id,
  jsonb_array_elements(players) as player
FROM trivia_rooms
WHERE id = 'room-uuid';

-- Count players in a room
SELECT 
  id,
  jsonb_array_length(players) as player_count,
  max_players
FROM trivia_rooms
WHERE id = 'room-uuid';

-- Check if a specific user is in a room
SELECT EXISTS(
  SELECT 1 
  FROM trivia_rooms,
  jsonb_array_elements(players) as player
  WHERE id = 'room-uuid'
    AND player->>'user_id' = 'user-uuid'
) as is_player_in_room;

-- ============================================================================
-- SCORE OPERATIONS
-- ============================================================================

-- Update a player's score (recommended way)
SELECT trivia_update_player_score(
  'room-uuid'::uuid,
  'user-uuid'::uuid,
  10 -- points to add
);

-- Get a specific player's score
SELECT 
  id as room_id,
  player_scores->>'user-uuid' as score
FROM trivia_rooms
WHERE id = 'room-uuid';

-- Get all scores in a room
SELECT 
  id as room_id,
  jsonb_each(player_scores) as player_score
FROM trivia_rooms
WHERE id = 'room-uuid';

-- Get leaderboard for a room (ordered by score)
SELECT 
  player->>'user_id' as user_id,
  player->>'display_name' as display_name,
  (player_scores->>player->>'user_id')::int as score
FROM trivia_rooms,
jsonb_array_elements(players) as player
WHERE id = 'room-uuid'
ORDER BY (player_scores->>player->>'user_id')::int DESC;

-- Reset all scores in a room
UPDATE trivia_rooms
SET player_scores = jsonb_object(
  ARRAY(
    SELECT jsonb_array_elements(players)->>'user_id'
  ),
  ARRAY(
    SELECT '0' FROM jsonb_array_elements(players)
  )
)
WHERE id = 'room-uuid';

-- ============================================================================
-- ROOM QUERIES
-- ============================================================================

-- Get complete room data with players (recommended way)
SELECT * FROM trivia_get_room_with_players('room-uuid'::uuid);

-- Get rooms with player count
SELECT 
  id,
  host_user_id,
  difficulty,
  status,
  jsonb_array_length(players) as current_players,
  max_players,
  created_at
FROM trivia_rooms
WHERE status = 'lobby'
ORDER BY created_at DESC;

-- Find rooms that are not full
SELECT 
  id,
  difficulty,
  jsonb_array_length(players) as current_players,
  max_players
FROM trivia_rooms
WHERE status = 'lobby'
  AND jsonb_array_length(players) < max_players
ORDER BY created_at DESC;

-- Get active games with player details
SELECT 
  tr.id,
  tr.difficulty,
  tr.current_question_index,
  jsonb_array_length(tr.players) as player_count,
  tr.players,
  tr.player_scores
FROM trivia_rooms tr
WHERE status = 'active';

-- ============================================================================
-- ANALYTICS QUERIES
-- ============================================================================

-- Average number of players per game
SELECT 
  difficulty,
  status,
  AVG(jsonb_array_length(players)) as avg_players,
  COUNT(*) as total_rooms
FROM trivia_rooms
GROUP BY difficulty, status;

-- Most popular player names
SELECT 
  player->>'display_name' as display_name,
  COUNT(*) as times_played
FROM trivia_rooms,
jsonb_array_elements(players) as player
GROUP BY player->>'display_name'
ORDER BY times_played DESC
LIMIT 10;

-- Total games played by each user
SELECT 
  player->>'user_id' as user_id,
  player->>'display_name' as display_name,
  COUNT(DISTINCT tr.id) as games_played,
  SUM((tr.player_scores->>player->>'user_id')::int) as total_score
FROM trivia_rooms tr,
jsonb_array_elements(tr.players) as player
WHERE tr.status = 'finished'
GROUP BY player->>'user_id', player->>'display_name'
ORDER BY total_score DESC
LIMIT 20;

-- ============================================================================
-- MAINTENANCE OPERATIONS
-- ============================================================================

-- Clean up empty rooms older than 1 hour
DELETE FROM trivia_rooms
WHERE status = 'lobby'
  AND jsonb_array_length(players) = 0
  AND created_at < NOW() - INTERVAL '1 hour';

-- Fix rooms with mismatched player/score data
UPDATE trivia_rooms
SET player_scores = (
  SELECT jsonb_object_agg(
    player->>'user_id',
    COALESCE((player_scores->>player->>'user_id')::int, 0)
  )
  FROM jsonb_array_elements(players) as player
)
WHERE jsonb_array_length(players) != (
  SELECT COUNT(*) FROM jsonb_object_keys(player_scores)
);

-- Verify data integrity
SELECT 
  id,
  CASE 
    WHEN jsonb_array_length(players) = (SELECT COUNT(*) FROM jsonb_object_keys(player_scores))
    THEN 'OK'
    ELSE 'MISMATCH'
  END as data_integrity,
  jsonb_array_length(players) as player_count,
  (SELECT COUNT(*) FROM jsonb_object_keys(player_scores)) as score_count
FROM trivia_rooms
WHERE status IN ('lobby', 'active');

-- ============================================================================
-- MIGRATION VERIFICATION
-- ============================================================================

-- Compare old vs new system data
SELECT 
  tr.id,
  jsonb_array_length(tr.players) as new_system_count,
  COUNT(DISTINCT trp.user_id) as old_system_count,
  CASE 
    WHEN jsonb_array_length(tr.players) = COUNT(DISTINCT trp.user_id)
    THEN '✓ Match'
    ELSE '✗ Mismatch'
  END as status
FROM trivia_rooms tr
LEFT JOIN trivia_room_players trp ON tr.id = trp.room_id
GROUP BY tr.id, tr.players
HAVING jsonb_array_length(tr.players) != COUNT(DISTINCT trp.user_id);

-- Validate all functions exist
SELECT 
  routine_name,
  routine_type,
  CASE 
    WHEN routine_name IN (
      'trivia_add_player_to_room',
      'trivia_remove_player_from_room', 
      'trivia_update_player_score',
      'trivia_get_room_with_players'
    )
    THEN '✓ Required'
    ELSE '○ Optional'
  END as importance
FROM information_schema.routines
WHERE routine_name LIKE 'trivia_%'
  AND routine_schema = 'public'
ORDER BY routine_name;

-- ============================================================================
-- PERFORMANCE TESTING
-- ============================================================================

-- Test query performance - new system
EXPLAIN ANALYZE
SELECT * FROM trivia_rooms WHERE id = 'room-uuid';

-- Test query performance - old system
EXPLAIN ANALYZE
SELECT tr.*, 
  array_agg(jsonb_build_object(
    'user_id', trp.user_id,
    'display_name', trp.display_name
  )) as players
FROM trivia_rooms tr
LEFT JOIN trivia_room_players trp ON tr.id = trp.room_id
WHERE tr.id = 'room-uuid'
GROUP BY tr.id;

-- Index usage check
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan as times_used,
  idx_tup_read as tuples_read
FROM pg_stat_user_indexes
WHERE tablename IN ('trivia_rooms', 'trivia_room_players')
ORDER BY idx_scan DESC;

