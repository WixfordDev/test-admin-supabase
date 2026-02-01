import 'dart:async';

import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/features/trivia/data/models/trivia_question.dart';
import 'package:deenhub/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TriviaService {
  final SupabaseProvider supabaseProvider;
  TriviaService(this.supabaseProvider);

  SupabaseClient get _client => supabaseProvider.supabase;

  Future<List<TriviaQuestion>> fetchRandomQuestions({
    required String difficulty, // easy, medium, hard
    int limit = 10,
  }) async {
    try {
      // First, try to use the database function for efficient random sampling
      final result = await _client.rpc('fetch_random_trivia_questions', params: {
        'p_difficulty': difficulty,
        'p_limit': limit,
      });

      if (result != null && result.isNotEmpty) {
        final list = result;
        return list
            .map((e) => TriviaQuestion.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      }
    } catch (e) {
      print('Primary database function failed, trying offset method: $e');
      
      // Try the offset-based function as second option
      try {
        final result = await _client.rpc('fetch_random_trivia_questions_offset', params: {
          'p_difficulty': difficulty,
          'p_limit': limit,
        });

        if (result != null && result.isNotEmpty) {
          final list = result;
          return list
              .map((e) => TriviaQuestion.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false);
        }
      } catch (offsetError) {
        print('Offset database function also failed, falling back to client-side random: $offsetError');
      }
    }

    // Fallback: Use PostgreSQL RANDOM() ordering with pagination for large datasets
    return await _fetchRandomQuestionsFallback(difficulty, limit);
  }

  /// Fallback method using PostgreSQL RANDOM() ordering
  Future<List<TriviaQuestion>> _fetchRandomQuestionsFallback(
    String difficulty,
    int limit,
  ) async {
    try {
      // Use PostgreSQL's RANDOM() function for true randomness
      final res = await _client
          .from('trivia_questions')
          .select()
          .eq('difficulty', difficulty)
          .order('random()') // PostgreSQL random ordering
          .limit(limit);

      final list = (res as List);
      return list
          .map((e) => TriviaQuestion.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (e) {
      print('Random ordering failed, using client-side shuffling: $e');
      // Final fallback: fetch more questions and shuffle on client side
      return await _fetchRandomQuestionsClientSide(difficulty, limit);
    }
  }

  /// Client-side random selection for large datasets
  Future<List<TriviaQuestion>> _fetchRandomQuestionsClientSide(
    String difficulty,
    int limit,
  ) async {
    const int batchSize = 1000; // Supabase limit
    final List<TriviaQuestion> allQuestions = [];
    int offset = 0;

    // Fetch questions in batches until we have enough or no more data
    while (allQuestions.length < limit * 3) { // Fetch 3x the limit for better randomness
      try {
        final res = await _client
            .from('trivia_questions')
            .select()
            .eq('difficulty', difficulty)
            .range(offset, offset + batchSize - 1);

        final batch = (res as List);
        if (batch.isEmpty) break; // No more data

        final questions = batch
            .map((e) => TriviaQuestion.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        
        allQuestions.addAll(questions);
        offset += batchSize;

        // If we got less than batchSize, we've reached the end
        if (questions.length < batchSize) break;
      } catch (e) {
        print('Batch fetch failed at offset $offset: $e');
        break;
      }
    }

    // Shuffle and return the requested number
    allQuestions.shuffle();
    return allQuestions.take(limit).toList(growable: false);
  }

  Future<Map<String, dynamic>> createRoom({
    required String hostUserId,
    required String difficulty,
    required int maxPlayers,
  }) async {
    try {
      // Use the new room creation function that generates text room IDs
      final result = await _client.rpc('create_trivia_room', params: {
        'p_host_user_id': hostUserId,
        'p_difficulty': difficulty,
        'p_max_players': maxPlayers,
      });

      if (result != null && result.isNotEmpty) {
        final roomData = Map<String, dynamic>.from(result.first);
        final roomId = roomData['room_id'] as String;
        final shortCode = roomData['short_code'] as String;

        print('Created room with ID: $roomId, short code: $shortCode');

        // Update the returned data to include the short_code for UI
        final fullRoomData = {
          'id': roomId,
          'short_code': shortCode,
          'host_user_id': hostUserId,
          'difficulty': difficulty,
          'max_players': maxPlayers,
          'status': 'lobby',
          'players': [],
          'player_scores': {},
        };

        // Add host to players array
        try {
          print('Adding host $hostUserId to room $roomId');
          await _client.rpc('trivia_add_player_to_room', params: {
            'p_room_id': roomId,
            'p_user_id': hostUserId,
            'p_display_name': 'Host',
          });
          print('Successfully added host to room via RPC');
        } catch (rpcError) {
          print('RPC failed with error: $rpcError');
          print('RPC failed, adding host via direct update: $rpcError');
          // Fallback: manually update the arrays
          try {
            await _client.from('trivia_rooms').update({
              'players': [
                {
                  'user_id': hostUserId,
                  'display_name': 'Host',
                  'joined_at': DateTime.now().toIso8601String(),
                }
              ],
              'player_scores': {hostUserId: 0},
            }).eq('id', roomId);
            print('Successfully added host via direct update');
          } catch (directError) {
            print('Direct update also failed: $directError');
          }
        }

        return fullRoomData;
      } else {
        throw Exception('Failed to create room - no data returned');
      }
    } catch (e) {
      print('Room creation failed: $e');
      // Fallback to old method if new function doesn't exist
      return await _createRoomFallback(hostUserId, difficulty, maxPlayers);
    }
  }

  /// Fallback room creation method for backward compatibility
  Future<Map<String, dynamic>> _createRoomFallback(
    String hostUserId,
    String difficulty,
    int maxPlayers,
  ) async {
    final shortCode = await _generateShortCode();

    final Map<String, dynamic> roomData = {
      'host_user_id': hostUserId,
      'difficulty': difficulty,
      'max_players': maxPlayers,
      'status': 'lobby',
      'players': [],
      'player_scores': {},
    };

    try {
      roomData['short_code'] = shortCode;
    } catch (e) {
      print('Short code column not available: $e');
    }

    final data = await _client.from('trivia_rooms').insert(roomData).select().single();
    final roomId = data['id'] as String;

    // Add host to players array
    try {
      await _client.rpc('trivia_add_player_to_room', params: {
        'p_room_id': roomId,
        'p_user_id': hostUserId,
        'p_display_name': 'Host',
      });
    } catch (e) {
      // Final fallback
      await _client.from('trivia_rooms').update({
        'players': [{
          'user_id': hostUserId,
          'display_name': 'Host',
          'joined_at': DateTime.now().toIso8601String(),
        }],
        'player_scores': {hostUserId: 0},
      }).eq('id', roomId);
    }

    return data;
  }

  /// Generate a unique short code for a room
  Future<String> _generateShortCode() async {
    try {
      final result = await _client.rpc('generate_unique_short_code');
      return result as String;
    } catch (e) {
      print('Failed to generate short code via RPC: $e');
      // Fallback: generate a simple short code from current timestamp and random
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final random = DateTime.now().microsecondsSinceEpoch.toString();
      final combined = timestamp + random;
      // Create a hash-like short code
      final hash = combined.hashCode.abs().toString();
      return hash.substring(0, 6);
    }
  }

  /// Resolve a room code to a valid room ID
  /// This handles both room IDs and short codes
  Future<String?> resolveRoomId(String roomCode) async {
    if (roomCode.isEmpty) return null;

    final normalizedCode = roomCode.toLowerCase().trim();

    // First try to use as direct room ID
    try {
      final room = await _client
          .from('trivia_rooms')
          .select('id')
          .eq('id', normalizedCode)
          .single();

      return room['id'] as String?;
    } catch (e) {
      // Room not found as room ID, try as short code
      print('Room code $normalizedCode not found as room ID: $e');
    }

    // Try to resolve as short code
    try {
      final rooms = await _client
          .from('trivia_rooms')
          .select('id, short_code')
          .eq('short_code', normalizedCode);

      if (rooms.isNotEmpty) {
        final room = rooms.first;
        print('Found room by short code: ${room['id']}');
        return room['id'] as String?;
      }
    } catch (e) {
      print('Room code $normalizedCode not found as short code: $e');
    }

    // If short_code column doesn't exist yet, try to find by pattern matching
    // This is a fallback for when migration hasn't been applied
    if (normalizedCode.length == 6) {
      try {
        // Look for rooms where the ID starts with the short code
        final rooms = await _client
            .from('trivia_rooms')
            .select('id')
            .like('id', '$normalizedCode%')
            .limit(1);

        if (rooms.isNotEmpty) {
          final room = rooms.first;
          print('Found room by ID pattern: ${room['id']}');
          return room['id'] as String?;
        }
      } catch (patternError) {
        print('Pattern lookup also failed: $patternError');
      }
    }

    // If neither room ID nor short code works, return null
    return null;
  }

  Future<void> joinRoom({
    required String roomCode,
    required String userId,
    required String displayName,
  }) async {
    print('Joining room: $roomCode for user: $userId with name: $displayName');

    // Resolve room code to actual UUID
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found. Please check the room code and try again.');
    }

    print('Resolved room code $roomCode to UUID $roomId');

    // Use new array-based system with database function
    try {
      await _client.rpc('trivia_add_player_to_room', params: {
        'p_room_id': roomId,
        'p_user_id': userId,
        'p_display_name': displayName,
      });
      print('Successfully added player to room via RPC');
    } catch (e) {
      print('RPC failed, falling back to direct array update: $e');
      // Fallback: manually add to arrays
      try {
        // Get current room data to preserve existing arrays
        final roomData = await _client
            .from('trivia_rooms')
            .select('players, player_scores')
            .eq('id', roomId)
            .single();

        final currentPlayers = List<Map<String, dynamic>>.from(roomData['players'] ?? []);
        final currentScores = Map<String, dynamic>.from(roomData['player_scores'] ?? {});

        // Check if player already exists
        final playerExists = currentPlayers.any((p) => p['user_id'] == userId);
        if (playerExists) {
          print('Player already exists in room');
          return;
        }

        print('Before adding player - Players: $currentPlayers, Scores: $currentScores');

        // Add new player to arrays
        currentPlayers.add({
          'user_id': userId,
          'display_name': displayName,
          'joined_at': DateTime.now().toIso8601String(),
        });
        currentScores[userId] = 0;

        // Update the room with new arrays
        await _client.from('trivia_rooms').update({
          'players': currentPlayers,
          'player_scores': currentScores,
        }).eq('id', roomId);

        print('Successfully added player via direct array update');
      } catch (fallbackError) {
        print('Direct array update also failed: $fallbackError');
        // Final fallback to old table method
        try {
          await _client.from('trivia_room_players').upsert({
            'room_id': roomId,
            'user_id': userId,
            'display_name': displayName,
            'score': 0,
            'joined_at': DateTime.now().toIso8601String(),
          });
          print('Successfully added player via old table method');
        } catch (oldTableError) {
          print('Old table method also failed: $oldTableError');
        }
      }
    }
  }

  Future<Map<String, dynamic>> getRoom(String roomCode) async {
    logger.i('Getting room: $roomCode');
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    final data = await _client
        .from('trivia_rooms')
        .select()
        .eq('id', roomId)
        .single();
    logger.i('room data: $data');
    return Map<String, dynamic>.from(data as Map);
  }

  /// Get room by short code or ID
  Future<Map<String, dynamic>?> getRoomByShortCode(String shortCode) async {
    try {
      final data = await _client
          .from('trivia_rooms')
          .select()
          .eq('short_code', shortCode.toLowerCase().trim())
          .single();
      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRoomPlayers(String roomCode) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      return [];
    }

    try {
      // Try new array-based system first
      final room = await _client
          .from('trivia_rooms')
          .select('players, player_scores')
          .eq('id', roomId)
          .single();

      final players = room['players'] as List?;
      final scores = room['player_scores'] as Map?;
      print('Room $roomCode has players array: $players, scores: $scores');
      if (players != null && players.isNotEmpty) {
        // Add score information to each player
        final playersWithScores = players.map((player) {
          final userId = player['user_id'];
          final score = scores?.containsKey(userId) == true ? (scores?[userId] ?? 0) : 0;
          return {
            ...Map<String, dynamic>.from(player),
            'score': score,
          };
        }).toList();
        print('Returning ${playersWithScores.length} players with scores');
        return playersWithScores;
      }
      print('Players array is null or empty, returning empty list');
      // If players array doesn't exist, return empty list
      return [];
    } catch (e) {
      print('Failed to get players from array system: $e');
      // Fall back to old table method if new system fails
      try {
        final data = await _client
            .from('trivia_room_players')
            .select('user_id, display_name, score, joined_at')
            .eq('room_id', roomId)
            .order('joined_at');
        final list = (data as List);
        final players = list.map((item) => Map<String, dynamic>.from(item)).toList();
        print('Fallback: got ${players.length} players from old table');
        return players;
      } catch (fallbackError) {
        print('Fallback also failed: $fallbackError');
        // If both systems fail, return empty list
        return [];
      }
    }
  }

  Future<List<TriviaQuestion>> getRoomQuestions(String roomCode) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      return [];
    }

    final rows = await _client
        .from('trivia_room_questions')
        .select('order_index, question_id')
        .eq('room_id', roomId)
        .order('order_index');
    final list = (rows as List).map((e) => Map<String, dynamic>.from(e)).toList();
    if (list.isEmpty) return const [];
    final ids = list.map((e) => e['question_id'] as int).toList(growable: false);
    final qData = await _client
        .from('trivia_questions')
        .select()
        .inFilter('id', ids);
    final all = qData
        .map((e) => TriviaQuestion.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    // Preserve order
    final byId = {for (final q in all) q.id: q};
    return ids.map((id) => byId[id]!).toList(growable: false);
  }

  Future<void> startGame({
    required String roomCode,
    required String difficulty,
    required int questionCount,
  }) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    // Fetch a larger pool then pick randomly on client
    final raw = await _client
        .from('trivia_questions')
        .select()
        .eq('difficulty', difficulty)
        .limit(questionCount * 5);
    final pool = (raw as List)
        .map((e) => TriviaQuestion.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    pool.shuffle();
    final selected = pool.take(questionCount).toList(growable: false);

    // Upsert room questions in order
    int idx = 0;
    for (final q in selected) {
      await _client.from('trivia_room_questions').upsert({
        'room_id': roomId,
        'order_index': idx,
        'question_id': q.id,
      });
      idx++;
    }

    // Set room status active and reset pointers
    await _client
        .from('trivia_rooms')
        .update({
          'status': 'active',
          'current_question_index': 0,
          'current_turn_index': 0,
        })
        .eq('id', roomId);
  }

  Future<RealtimeChannel> subscribeToRoom(String roomCode,
      {void Function(Map<String, dynamic>)? onBroadcast}) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    final channelName = 'trivia_room_$roomId';
    print('Subscribing to room channel: $channelName');
    final channel = _client.realtime.channel(channelName);
    channel.onBroadcast(
      event: 'state',
      callback: (payload) {
        print('Received broadcast on room channel: $payload');
        if (onBroadcast != null) {
          onBroadcast(Map<String, dynamic>.from(payload));
        }
      },
    );
    channel.subscribe();
    print('Room subscription completed');
    return channel;
  }

  Future<RealtimeChannel> subscribeToGame(String roomCode,
      {void Function(Map<String, dynamic>)? onState,
      void Function(Map<String, dynamic>)? onAction}) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    final channelName = 'trivia_room_$roomId';
    print('Subscribing to game channel: $channelName');
    final channel = _client.realtime.channel(channelName);
    if (onState != null) {
      channel.onBroadcast(
        event: 'state',
        callback: (payload) {
          print('Received game state broadcast: $payload');
          onState(Map<String, dynamic>.from(payload));
        },
      );
    }
    if (onAction != null) {
      channel.onBroadcast(
        event: 'action',
        callback: (payload) {
          print('Received game action broadcast: $payload');
          onAction(Map<String, dynamic>.from(payload));
        },
      );
    }
    channel.subscribe();
    print('Game subscription completed');
    return channel;
  }

  Future<void> broadcastRoomState({
    required RealtimeChannel channel,
    required Map<String, dynamic> state,
  }) async {
    logger.i('Broadcasting state: $state');
    await channel.sendBroadcastMessage(event: 'state', payload: state);
    logger.i('State broadcast completed');
  }

  Future<void> sendAction({
    required RealtimeChannel channel,
    required Map<String, dynamic> action,
  }) async {
    logger.d('Sending action: $action');
    await channel.sendBroadcastMessage(event: 'action', payload: action);
    logger.d('Action broadcast completed');
  }

  Future<RealtimeChannel> subscribeToRoomPlayers(String roomCode,
      {required void Function() onChange}) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    // Subscribe to changes in the trivia_rooms table (new array-based system)
    final channel = _client.realtime.channel('public:trivia_rooms_$roomId');

    // Listen for changes to the specific room - listen to all events for array updates
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'trivia_rooms',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: roomId,
      ),
      callback: (_) {
        print('Player list changed for room: $roomCode');
        onChange();
      },
    );

    // Also keep old subscription for backward compatibility
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'trivia_room_players',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId,
      ),
      callback: (_) {
        print('Old player table changed for room: $roomId');
        onChange();
      },
    );

    channel.subscribe();
    print('Subscribed to player changes for room: $roomId');
    return channel;
  }

  Future<void> submitAnswer({
    required String roomCode,
    required String userId,
    required int questionId,
    required bool isCorrect,
    required int pointsAwarded,
  }) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    // Update score in the new array-based system
    try {
      await _client.rpc('trivia_update_player_score', params: {
        'p_room_id': roomId,
        'p_user_id': userId,
        'p_points': pointsAwarded,
      });
    } catch (e) {
      // Fall back to old table method if function doesn't exist
    }

    // Still keep detailed answer history in trivia_answers table
    await _client.from('trivia_answers').insert({
      'room_id': roomId,
      'user_id': userId,
      'question_id': questionId,
      'is_correct': isCorrect,
      'points_awarded': pointsAwarded,
      'answered_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> recordHintUsage({
    required String roomCode,
    required String userId,
    required int questionId,
    required int penaltyPoints,
  }) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    await _client.from('trivia_hint_usage').upsert({
      'room_id': roomId,
      'user_id': userId,
      'question_id': questionId,
      'penalty_points': penaltyPoints,
      'used_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateRoomProgress({
    required String roomCode,
    int? currentQuestionIndex,
    int? currentTurnIndex,
  }) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    final payload = <String, dynamic>{};
    if (currentQuestionIndex != null) payload['current_question_index'] = currentQuestionIndex;
    if (currentTurnIndex != null) payload['current_turn_index'] = currentTurnIndex;
    if (payload.isEmpty) return;
    await _client.from('trivia_rooms').update(payload).eq('id', roomId);
  }

  Future<void> finishGame({
    required String roomCode,
    required String winnerUserId,
  }) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    await _client
        .from('trivia_rooms')
        .update({
          'status': 'finished',
          'winner_user_id': winnerUserId,
          'ended_at': DateTime.now().toIso8601String(),
        })
        .eq('id', roomId);
  }

  Future<Map<String, int>> fetchRoomScores(String roomCode) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      return {};
    }

    try {
      // Try new array-based system first
      final room = await _client
          .from('trivia_rooms')
          .select('player_scores')
          .eq('id', roomId)
          .single();
      
      final scoresJson = room['player_scores'] as Map<String, dynamic>?;
      if (scoresJson != null) {
        final Map<String, int> scores = {};
        scoresJson.forEach((key, value) {
          scores[key] = (value as num).toInt();
        });
        return scores;
      }
      return {};
    } catch (e) {
      // Fall back to old table method
      final rows = await _client
          .from('trivia_answers')
          .select('user_id, points_awarded')
          .eq('room_id', roomId);
      final list = (rows as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
      final Map<String, int> totals = {};
      for (final r in list) {
        final uid = r['user_id'] as String;
        final pts = (r['points_awarded'] as num).toInt();
        totals.update(uid, (v) => v + pts, ifAbsent: () => pts);
      }
      // subtract hint penalties if present
      try {
        final penalties = await _client
            .from('trivia_hint_usage')
            .select('user_id, penalty_points')
            .eq('room_id', roomId);
        final pList = (penalties as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
        for (final r in pList) {
          final uid = r['user_id'] as String;
          final pts = (r['penalty_points'] as num).toInt();
          totals.update(uid, (v) => v - pts, ifAbsent: () => -pts);
        }
      } catch (_) {}
      return totals;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard({int limit = 50}) async {
    final res = await _client.rpc('trivia_leaderboard', params: {'limit_n': limit});
    return (res as List<dynamic>).cast<Map<String, dynamic>>();
  }

  // User Profile Management Methods

  /// Get user profile by user ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final res = await _client.rpc('get_user_profile', params: {'user_uuid': userId});
      final profiles = (res as List<dynamic>).cast<Map<String, dynamic>>();
      return profiles.isNotEmpty ? profiles.first : null;
    } catch (e) {
      // If function doesn't exist yet, fall back to direct table query
      try {
        final data = await _client
            .from('trivia_user_profiles')
            .select('user_id, username, display_name')
            .eq('user_id', userId)
            .single();
        return Map<String, dynamic>.from(data);
      } catch (_) {
        return null;
      }
    }
  }

  /// Check if a username is available (case insensitive)
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final res = await _client.rpc('is_username_available', params: {'check_username': username});
      return res as bool;
    } catch (e) {
      // If function doesn't exist yet, fall back to direct query
      try {
        final data = await _client
            .from('trivia_user_profiles')
            .select('user_id')
            .ilike('username', username)
            .limit(1);
        return (data as List).isEmpty;
      } catch (_) {
        return true; // Assume available if we can't check
      }
    }
  }

  /// Create or update user profile
  Future<Map<String, dynamic>> upsertUserProfile({
    required String userId,
    required String username,
    String? email,
    String? displayName,
  }) async {
    final data = await _client.from('trivia_user_profiles').upsert({
      'user_id': userId,
      'username': username.trim(),
      'email': email,
      'display_name': displayName ?? username.trim(),
    }).select().single();

    return Map<String, dynamic>.from(data);
  }

  /// Get or create user profile with fallback logic
  Future<Map<String, dynamic>> getOrCreateUserProfile({
    required String userId,
    String? preferredUsername,
    String? email,
  }) async {
    // First try to get existing profile
    final existingProfile = await getUserProfile(userId);
    if (existingProfile != null) {
      return existingProfile;
    }

    // If no profile exists, create one
    final authUser = supabaseProvider.supabase.auth.currentUser;
    final userEmail = email ?? authUser?.email;

    // Generate default username
    String defaultUsername = preferredUsername ??
        (userEmail != null ? userEmail.split('@')[0] : 'Player$userId'.substring(0, 10));

    // Ensure username is unique
    if (!(await isUsernameAvailable(defaultUsername))) {
      // Append numbers until we find a unique username
      int counter = 1;
      String uniqueUsername = defaultUsername;
      while (!(await isUsernameAvailable(uniqueUsername))) {
        uniqueUsername = '$defaultUsername$counter';
        counter++;
        if (counter > 100) break; // Safety break
      }
      defaultUsername = uniqueUsername;
    }

    // Create the profile
    return await upsertUserProfile(
      userId: userId,
      username: defaultUsername,
      email: userEmail,
      displayName: defaultUsername,
    );
  }

  /// Update username with uniqueness check
  Future<Map<String, dynamic>> updateUsername({
    required String userId,
    required String newUsername,
  }) async {
    // Check if username is available
    if (!(await isUsernameAvailable(newUsername))) {
      throw Exception('Username "$newUsername" is already taken. Please choose a different one.');
    }

    // Update the profile
    return await upsertUserProfile(
      userId: userId,
      username: newUsername,
      displayName: newUsername,
    );
  }

  /// Remove a player from a room (new array-based system)
  Future<void> removePlayerFromRoom({
    required String roomCode,
    required String userId,
  }) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    try {
      await _client.rpc('trivia_remove_player_from_room', params: {
        'p_room_id': roomId,
        'p_user_id': userId,
      });
    } catch (e) {
      // Fall back to direct array update
      try {
        // Get current room data to preserve existing arrays
        final roomData = await _client
            .from('trivia_rooms')
            .select('players, player_scores')
            .eq('id', roomId)
            .single();

        final currentPlayers = List<Map<String, dynamic>>.from(roomData['players'] ?? []);
        final currentScores = Map<String, dynamic>.from(roomData['player_scores'] ?? {});

        // Remove player from arrays
        currentPlayers.removeWhere((player) => player['user_id'] == userId);
        currentScores.remove(userId);

        // Update the room with updated arrays
        await _client.from('trivia_rooms').update({
          'players': currentPlayers,
          'player_scores': currentScores,
        }).eq('id', roomId);

        print('Successfully removed player via direct array update');
      } catch (fallbackError) {
        print('Direct array update also failed: $fallbackError');
        // Final fallback to old table method
        await _client
            .from('trivia_room_players')
            .delete()
            .eq('room_id', roomId)
            .eq('user_id', userId);
      }
    }
  }

  /// Get room with complete player and score data
  Future<Map<String, dynamic>> getRoomWithPlayers(String roomCode) async {
    final roomId = await resolveRoomId(roomCode);
    if (roomId == null) {
      throw Exception('Room not found');
    }

    try {
      final result = await _client.rpc('trivia_get_room_with_players', params: {
        'p_room_id': roomId,
      });

      if (result != null && result is List && result.isNotEmpty) {
        return Map<String, dynamic>.from(result.first);
      }

      // Fallback to regular getRoom
      return await getRoom(roomCode);
    } catch (e) {
      // Fallback to regular getRoom
      return await getRoom(roomCode);
    }
  }
}


