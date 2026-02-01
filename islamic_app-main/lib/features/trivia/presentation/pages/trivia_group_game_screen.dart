import 'dart:async';

import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/trivia/data/models/trivia_question.dart';
import 'package:deenhub/features/trivia/data/services/trivia_service.dart';
import 'package:deenhub/features/trivia/presentation/widgets/trivia_game_widgets.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TriviaGroupGameScreen extends StatefulWidget {
  final Map<String, String> queryParams;
  const TriviaGroupGameScreen({super.key, required this.queryParams});

  @override
  State<TriviaGroupGameScreen> createState() => _TriviaGroupGameScreenState();
}

class _TriviaGroupGameScreenState extends State<TriviaGroupGameScreen> {
  late final TriviaService _service;
  RealtimeChannel? _gameChannel;
  RealtimeChannel? _playersChannel;

  String get _roomCode => (widget.queryParams['roomId'] ?? '').toLowerCase();
  String? _roomId; // Actual resolved UUID
  String get _difficulty => widget.queryParams['difficulty'] ?? 'easy';
  // Always turn-based in group mode (all difficulties)
  bool get _isTurnBased => true;

  List<TriviaQuestion> _questions = const [];
  int _questionIndex = 0;
  int _turnIndex = 0;
  int _secondsLeft = 30;
  int _totalQuestions = 0; // Store the total number of questions for this game
  Timer? _timer;
  bool _loading = true;
  bool _showExplanation = false;
  bool _gameFinished = false;
  int? _selectedOptionIndex;
  Set<String> _playersWhoAnswered =
  <String>{}; // Track who answered current question
  bool _questionLocked = false; // Lock question when someone answers
  bool _hintUsed = false; // Track if hint was used for current question
  Map<String, int> _playerAnswers =
  {}; // Track each player's selected option index
  bool _isTransitioning = false; // Prevent multiple simultaneous transitions
  bool _currentUserAnswered =
  false; // Track if current user answered the question
  int? _currentUserSelectedOption; // Only for current user's selection
  bool _isBonusQuestion = false; // Track if current question is a bonus
  bool _isBonusQuestionAvailable =
  false; // Track if bonus question is available
  Timer? _bonusTimer; // Timer for bonus question acceptance
  TriviaQuestion? _bonusQuestion; // Store bonus question if available
  bool _showBonusAcceptance = false; // Show bonus acceptance UI

  List<Map<String, dynamic>> _players = const [];
  Map<String, int> _scores = const {};
  String? _currentUserId;
  Map<String, Map<String, dynamic>> _userProfiles =
  const {}; // userId -> profile

  @override
  void initState() {
    super.initState();
    _service = getIt<TriviaService>();
    _currentUserId = _service.supabaseProvider.supabase.auth.currentUser?.id;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadGameData();
      await _subscribeToUpdates();
    });
  }

  Future<void> _loadGameData() async {
    try {
      // First resolve the room code to UUID
      final resolvedRoomId = await _service.resolveRoomId(_roomCode);
      if (resolvedRoomId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Room not found. Please check the room code.'),
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      _roomId = resolvedRoomId; // Store the resolved UUID

      // Now validate that the room exists and is in active state
      final roomData = await _service.getRoom(_roomId!);
      if (roomData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Room not found or has been deleted.'),
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      final roomStatus = roomData['status'] as String?;
      if (roomStatus == 'finished') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This game has already finished.')),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      // Load all data in parallel for faster loading
      final results = await Future.wait([
        _service.getRoomQuestions(_roomId!),
        _service.getRoomPlayers(_roomId!),
        _service.fetchRoomScores(_roomId!),
      ]);

      final questions = results[0] as List<TriviaQuestion>;
      final players = results[1] as List<Map<String, dynamic>>;
      final scores = results[2] as Map<String, int>;

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions found for this room.')),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      // Load user profiles for all players in parallel with timeout
      final userProfiles = <String, Map<String, dynamic>>{};
      final profileFutures = <Future<void>>[];

      for (final player in players) {
        final userId = player['user_id'] as String;
        profileFutures.add(_loadUserProfileWithTimeout(userId, userProfiles));
      }

      // Wait for all profile requests to complete with timeout
      try {
        await Future.wait(profileFutures, eagerError: true);
      } catch (e) {
        logger.w('Some profile requests timed out: $e');
        // Continue with partial profile data
      }

      if (mounted) {
        setState(() {
          _questions = questions;
          _totalQuestions = questions
              .length; // Set the total number of questions for this game
          _players = players;
          _scores = scores;
          _userProfiles = userProfiles;
          _loading = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);

        String errorMessage = 'Failed to load game data';
        if (e.toString().contains('violates foreign key constraint')) {
          errorMessage = 'Room not found. The game may have been deleted.';
        } else if (e.toString().contains('connection')) {
          errorMessage =
          'Connection error. Please check your internet connection.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        Navigator.of(context).pop();
      }
    }
  }

  /// Load user profile with timeout to prevent hanging
  Future<void> _loadUserProfileWithTimeout(
      String userId,
      Map<String, Map<String, dynamic>> userProfiles,
      ) async {
    try {
      // Create a timeout for profile loading
      final profile = await _service
          .getUserProfile(userId)
          .timeout(
        const Duration(seconds: 3), // 3 second timeout for each profile
        onTimeout: () => null, // Return null if timeout occurs
      );

      if (profile != null) {
        userProfiles[userId] = profile;
      }
    } catch (e) {
      // Profile loading failed, continue with other profiles
      logger.w('Failed to load profile for user $userId: $e');
    }
  }

  // Future<void> _subscribeToUpdates() async {
  //   if (_roomId == null) return; // Safety check

  //   _gameChannel?.unsubscribe();
  //   _gameChannel = await _service.subscribeToGame(
  //     _roomId!,
  //     onState: (state) {
  //       if (!mounted) return;

  //       final newQuestionIndex =
  //           (state['current_question_index'] as num?)?.toInt() ??
  //           _questionIndex;
  //       final newTurnIndex =
  //           (state['current_turn_index'] as num?)?.toInt() ?? _turnIndex;

  //       // Check if question changed
  //       final questionChanged = newQuestionIndex != _questionIndex;

  //       if (questionChanged) {
  //         print('Question changed from $_questionIndex to $newQuestionIndex');
  //         _timer?.cancel(); // Cancel old timer

  //         setState(() {
  //           _questionIndex = newQuestionIndex;
  //           _turnIndex = newTurnIndex;
  //           _selectedOptionIndex = null;
  //           _showExplanation = false;
  //           _playersWhoAnswered.clear();
  //           _questionLocked = false;
  //           _hintUsed = false; // Reset hint for new question
  //           _playerAnswers.clear(); // Reset player answers
  //           _currentUserAnswered = false; // Reset current user answered flag
  //           _currentUserSelectedOption = null; // Reset current user's selection
  //         });

  //         _restartTimer(); // Start fresh timer
  //       } else {
  //         // Only turn index changed
  //         setState(() {
  //           _turnIndex = newTurnIndex;
  //         });
  //       }
  //     },
  //     onAction: (action) async {
  //       if (!mounted) return;

  //       final type = action['type'];
  //       if (type == 'reveal') {
  //         // Only set explanation if not already showing (to prevent duplicate timers)
  //         if (!_showExplanation) {
  //           setState(() => _showExplanation = true);

  //           // All players start 8-second countdown to next question
  //           Future.delayed(const Duration(seconds: 8), () {
  //             if (mounted && !_gameFinished && _showExplanation) {
  //               _nextQuestion();
  //             }
  //           });
  //         }
  //       } else if (type == 'next') {
  //         // State reset is now handled in onState callback
  //         // Just log that we received the action
  //         print('Received next action');
  //       } else if (type == 'player_answered') {
  //         // Someone answered - lock the question for others and show their selection
  //         final answerUserId = action['user_id'] as String?;
  //         final selectedOption = action['selected_option'] as int?;

  //         if (answerUserId != null && selectedOption != null && mounted) {
  //           setState(() {
  //             _playersWhoAnswered.add(answerUserId);
  //             _questionLocked = true; // Lock question when someone answers
  //             _playerAnswers[answerUserId] =
  //                 selectedOption; // Store their answer

  //             // If this is not the current user, show the answering player's selection
  //             if (answerUserId != _currentUserId) {
  //               _selectedOptionIndex = selectedOption;
  //             }
  //           });
  //         }
  //       } else if (type == 'player_left') {
  //         // Show notification when a player leaves
  //         final displayName = action['display_name'] ?? 'A player';
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('$displayName has left the game'),
  //               duration: const Duration(seconds: 3),
  //               behavior: SnackBarBehavior.floating,
  //             ),
  //           );
  //         }

  //         // Check if there's only one player left (current player), then end the game
  //         final players = await _service.getRoomPlayers(_roomId!);
  //         if (players.length <= 1) {
  //           // All other players have left, end the game
  //           if (mounted && !_gameFinished) {
  //             _gameFinished = true;

  //             // Finish the game in the database
  //             final sortedScores = _scores.entries.toList()
  //               ..sort((a, b) => b.value.compareTo(a.value));
  //             final winnerUserId = sortedScores.isEmpty
  //                 ? (_currentUserId ?? '')
  //                 : sortedScores.first.key;

  //             await _service.finishGame(
  //               roomCode: _roomId!,
  //               winnerUserId: winnerUserId,
  //             );

  //             // Show game ended message
  //             if (mounted) {
  //               await showDialog(
  //                 context: context,
  //                 barrierDismissible: false,
  //                 builder: (context) => AlertDialog(
  //                   title: const Row(
  //                     children: [
  //                       Icon(
  //                         Icons.warning_amber_rounded,
  //                         color: Colors.orange,
  //                         size: 28,
  //                       ),
  //                       SizedBox(width: 8),
  //                       Text('Game Ended'),
  //                     ],
  //                   ),
  //                   content: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       const Text(
  //                         'Game ended because other players left.',
  //                         style: TextStyle(fontSize: 16),
  //                       ),
  //                       const SizedBox(height: 16),
  //                       Text(
  //                         'Final Scores',
  //                         style: Theme.of(context).textTheme.titleMedium
  //                             ?.copyWith(fontWeight: FontWeight.bold),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       ...(_scores.entries.toList()
  //                             ..sort((a, b) => b.value.compareTo(a.value)))
  //                           .map((entry) {
  //                             final profile = _userProfiles[entry.key];
  //                             final displayName =
  //                                 profile?['username'] ??
  //                                 profile?['display_name'] ??
  //                                 _players.firstWhere(
  //                                   (p) => p['user_id'] == entry.key,
  //                                   orElse: () => {'display_name': 'Player'},
  //                                 )['display_name'] ??
  //                                 'Player';
  //                             final isMe = entry.key == _currentUserId;

  //                             return Padding(
  //                               padding: const EdgeInsets.symmetric(
  //                                 vertical: 2,
  //                               ),
  //                               child: Row(
  //                                 children: [
  //                                   Expanded(
  //                                     child: Text(
  //                                       isMe
  //                                           ? '$displayName (You)'
  //                                           : displayName,
  //                                       style: const TextStyle(
  //                                         fontWeight: FontWeight.w500,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Text(
  //                                     '${entry.value} pts',
  //                                     style: const TextStyle(
  //                                       fontWeight: FontWeight.w600,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           })
  //                           .toList(),
  //                     ],
  //                   ),
  //                   actions: [
  //                     FilledButton(
  //                       onPressed: () {
  //                         Navigator.of(context).pop(); // Close dialog
  //                         // Navigate to trivia home screen
  //                         if (mounted) {
  //                           clearAndNavigate(Routes.triviaGroupLobby.name);
  //                         }
  //                       },
  //                       child: const Text('Back to Home'),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             }
  //           }
  //         }
  //       } else if (type == 'player_left_and_end_game') {
  //         // When a player leaves and ends the game for everyone
  //         final displayName = action['display_name'] ?? 'A player';
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(
  //                 '$displayName has left the game. Game ended for all players.',
  //               ),
  //               duration: const Duration(seconds: 3),
  //               behavior: SnackBarBehavior.floating,
  //             ),
  //           );
  //         }

  //         // End the game immediately for all players
  //         if (mounted && !_gameFinished) {
  //           _gameFinished = true;

  //           // Show game ended message
  //           if (mounted) {
  //             await showDialog(
  //               context: context,
  //               barrierDismissible: false,
  //               builder: (context) => AlertDialog(
  //                 title: const Row(
  //                   children: [
  //                     Icon(
  //                       Icons.warning_amber_rounded,
  //                       color: Colors.orange,
  //                       size: 28,
  //                     ),
  //                     SizedBox(width: 8),
  //                     Text('Game Ended'),
  //                   ],
  //                 ),
  //                 content: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     const Text(
  //                       'Game ended because a player left.',
  //                       style: TextStyle(fontSize: 16),
  //                     ),
  //                     const SizedBox(height: 16),
  //                     Text(
  //                       'Final Scores',
  //                       style: Theme.of(context).textTheme.titleMedium
  //                           ?.copyWith(fontWeight: FontWeight.bold),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     ...(_scores.entries.toList()
  //                           ..sort((a, b) => b.value.compareTo(a.value)))
  //                         .map((entry) {
  //                           final profile = _userProfiles[entry.key];
  //                           final displayName =
  //                               profile?['username'] ??
  //                               profile?['display_name'] ??
  //                               _players.firstWhere(
  //                                 (p) => p['user_id'] == entry.key,
  //                                 orElse: () => {'display_name': 'Player'},
  //                               )['display_name'] ??
  //                               'Player';
  //                           final isMe = entry.key == _currentUserId;

  //                           return Padding(
  //                             padding: const EdgeInsets.symmetric(vertical: 2),
  //                             child: Row(
  //                               children: [
  //                                 Expanded(
  //                                   child: Text(
  //                                     isMe ? '$displayName (You)' : displayName,
  //                                     style: const TextStyle(
  //                                       fontWeight: FontWeight.w500,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 Text(
  //                                   '${entry.value} pts',
  //                                   style: const TextStyle(
  //                                     fontWeight: FontWeight.w600,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           );
  //                         })
  //                         .toList(),
  //                   ],
  //                 ),
  //                 actions: [
  //                   FilledButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop(); // Close dialog
  //                       // Navigate to trivia home screen
  //                       if (mounted) {
  //                         clearAndNavigate(Routes.triviaGroupLobby.name);
  //                       }
  //                     },
  //                     child: const Text('Back to Home'),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           }
  //         }
  //       } else if (type == 'bonus_question') {
  //         // Handle bonus question offer to the opponent
  //         final questionData = action['question'] as Map<String, dynamic>?;
  //         final opponentId = action['opponent_id'] as String?;

  //         // Check if this bonus question is for the current user
  //         if (opponentId == _currentUserId && questionData != null && mounted) {
  //           final question = TriviaQuestion.fromJson(questionData);

  //           // Show bonus question acceptance UI
  //           setState(() {
  //             _isBonusQuestionAvailable = true;
  //             _bonusQuestion = question;
  //             _showBonusAcceptance = true;
  //           });

  //           // Start 10-second timer for bonus question acceptance
  //           _bonusTimer?.cancel();
  //           int countdown = 10;

  //           _bonusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //             if (!mounted) {
  //               timer.cancel();
  //               return;
  //             }

  //             if (countdown <= 0) {
  //               timer.cancel();
  //               // Timeout - user didn't accept the bonus question
  //               if (mounted) {
  //                 setState(() {
  //                   _isBonusQuestionAvailable = false;
  //                   _showBonusAcceptance = false;
  //                 });

  //                 // Advance to the next question in the regular flow since bonus was not accepted in time
  //                 _nextQuestion();
  //               }
  //             } else {
  //               countdown--;
  //             }
  //           });
  //         }
  //       }

  //       // Refresh scores
  //       final scores = await _service.fetchRoomScores(_roomId!);
  //       if (mounted) {
  //         setState(() => _scores = scores);
  //       }
  //     },
  //   );

  //   _playersChannel?.unsubscribe();
  //   _playersChannel = await _service.subscribeToRoomPlayers(
  //     _roomId!,
  //     onChange: () async {
  //       final players = await _service.getRoomPlayers(_roomId!);
  //       if (mounted) {
  //         setState(() => _players = players);
  //       }
  //     },
  //   );
  // }

  Future<void> _subscribeToUpdates() async {
    if (_roomId == null) return;

    _gameChannel?.unsubscribe();
    _gameChannel = await _service.subscribeToGame(
      _roomId!,
      onState: (state) {
        if (!mounted) return;

        final newQuestionIndex =
            (state['current_question_index'] as num?)?.toInt() ??
                _questionIndex;
        final newTurnIndex =
            (state['current_turn_index'] as num?)?.toInt() ?? _turnIndex;

        final questionChanged = newQuestionIndex != _questionIndex;

        if (questionChanged) {
          print('Question changed from $_questionIndex to $newQuestionIndex');
          _timer?.cancel();

          setState(() {
            _questionIndex = newQuestionIndex;
            _turnIndex = newTurnIndex;
            _selectedOptionIndex = null;
            _showExplanation = false;
            _playersWhoAnswered.clear();
            _questionLocked = false;
            _hintUsed = false;
            _playerAnswers.clear();
            _currentUserAnswered = false;
            _currentUserSelectedOption = null;
            // Reset bonus question state when question changes
            _isBonusQuestion = false;
            _showBonusAcceptance = false;
            _bonusQuestion = null;
            _isBonusQuestionAvailable = false;
          });

          _restartTimer();
        } else {
          setState(() {
            _turnIndex = newTurnIndex;
          });
        }
      },
      onAction: (action) async {
        if (!mounted) return;

        final type = action['type'];

        if (type == 'reveal') {
          if (!_showExplanation) {
            setState(() => _showExplanation = true);

            // Only auto-advance if this is NOT a bonus question scenario
            // If bonus question was offered, wait for opponent to answer
            Future.delayed(const Duration(seconds: 8), () {
              if (mounted && !_gameFinished && _showExplanation) {
                // Check if we're waiting for bonus question answer
                if (!_isBonusQuestionAvailable && !_showBonusAcceptance) {
                  _nextQuestion();
                }
              }
            });
          }
        } else if (type == 'next') {
          print('Received next action');
        } else if (type == 'player_answered') {
          final answerUserId = action['user_id'] as String?;
          final selectedOption = action['selected_option'] as int?;
          final isCorrect = action['is_correct'] as bool?;
          final isBonus = action['is_bonus'] as bool? ?? false;

          if (answerUserId != null && selectedOption != null && mounted) {
            setState(() {
              _playersWhoAnswered.add(answerUserId);
              _questionLocked = true;
              _playerAnswers[answerUserId] = selectedOption;

              if (answerUserId != _currentUserId) {
                _selectedOptionIndex = selectedOption;
              }
            });

            // If this was a bonus question answer, proceed to next question
            if (isBonus) {
              // Bonus question was answered, now we can proceed
              Future.delayed(const Duration(seconds: 8), () {
                if (mounted && !_gameFinished) {
                  _nextQuestion();
                }
              });
            }
          }
        } else if (type == 'bonus_question') {
          // Handle bonus question offer to the current user
          final questionData = action['question'] as Map<String, dynamic>?;
          final opponentId = action['opponent_id'] as String?;

          // Check if this bonus question is for the current user
          if (opponentId == _currentUserId && questionData != null && mounted) {
            final question = TriviaQuestion.fromJson(questionData);

            // Show bonus question acceptance UI
            setState(() {
              _isBonusQuestionAvailable = true;
              _bonusQuestion = question;
              _showBonusAcceptance = true;
            });

            // Start 10-second timer for bonus question acceptance
            _bonusTimer?.cancel();
            int countdown = 10;

            _bonusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (!mounted) {
                timer.cancel();
                return;
              }

              if (countdown <= 0) {
                timer.cancel();
                // Timeout - user didn't accept the bonus question
                if (mounted) {
                  setState(() {
                    _isBonusQuestionAvailable = false;
                    _showBonusAcceptance = false;
                    _bonusQuestion = null;
                  });

                  // Advance to the next question since bonus was not accepted
                  _nextQuestion();
                }
              } else {
                countdown--;
              }
            });
          }
        } else if (type == 'player_left') {
          final displayName = action['display_name'] ?? 'A player';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$displayName has left the game'),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          final players = await _service.getRoomPlayers(_roomId!);
          if (players.length <= 1) {
            if (mounted && !_gameFinished) {
              _gameFinished = true;

              final sortedScores = _scores.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final winnerUserId = sortedScores.isEmpty
                  ? (_currentUserId ?? '')
                  : sortedScores.first.key;

              await _service.finishGame(
                roomCode: _roomId!,
                winnerUserId: winnerUserId,
              );

              if (mounted) {
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text('Game Ended'),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Game ended because other players left.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Final Scores',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...(_scores.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value)))
                            .map((entry) {
                          final profile = _userProfiles[entry.key];
                          final displayName =
                              profile?['username'] ??
                                  profile?['display_name'] ??
                                  _players.firstWhere(
                                        (p) => p['user_id'] == entry.key,
                                    orElse: () => {'display_name': 'Player'},
                                  )['display_name'] ??
                                  'Player';
                          final isMe = entry.key == _currentUserId;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isMe
                                        ? '$displayName (You)'
                                        : displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${entry.value} pts',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                            .toList(),
                      ],
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (mounted) {
                            clearAndNavigate(Routes.triviaGroupLobby.name);
                          }
                        },
                        child: const Text('Back to Home'),
                      ),
                    ],
                  ),
                );
              }
            }
          }
        } else if (type == 'player_left_and_end_game') {
          final displayName = action['display_name'] ?? 'A player';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$displayName has left the game. Game ended for all players.',
                ),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (mounted && !_gameFinished) {
            _gameFinished = true;

            if (mounted) {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text('Game Ended'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game ended because a player left.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Final Scores',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...(_scores.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)))
                          .map((entry) {
                        final profile = _userProfiles[entry.key];
                        final displayName =
                            profile?['username'] ??
                                profile?['display_name'] ??
                                _players.firstWhere(
                                      (p) => p['user_id'] == entry.key,
                                  orElse: () => {'display_name': 'Player'},
                                )['display_name'] ??
                                'Player';
                        final isMe = entry.key == _currentUserId;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isMe ? '$displayName (You)' : displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value} pts',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                          .toList(),
                    ],
                  ),
                  actions: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (mounted) {
                          clearAndNavigate(Routes.triviaGroupLobby.name);
                        }
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              );
            }
          }
        }

        // Refresh scores
        final scores = await _service.fetchRoomScores(_roomId!);
        if (mounted) {
          setState(() => _scores = scores);
        }
      },
    );

    _playersChannel?.unsubscribe();
    _playersChannel = await _service.subscribeToRoomPlayers(
      _roomId!,
      onChange: () async {
        final players = await _service.getRoomPlayers(_roomId!);
        if (mounted) {
          setState(() => _players = players);
        }
      },
    );
  }

  void _startTimer() {
    _timer?.cancel();
    if (!mounted) return;

    setState(() => _secondsLeft = 30);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          timer.cancel();
          _onTimeUp();
        }
      });
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() => _secondsLeft = 30);
      _startTimer();
    }
  }

  Future<void> _onTimeUp() async {
    if (!mounted || _showExplanation) return;

    setState(() => _showExplanation = true);

    // Broadcast that timer expired (reveal the answer)
    await _service.sendAction(
      channel: _gameChannel!,
      action: {'type': 'reveal', 'question_index': _questionIndex},
    );

    // Ensure consistent 8-second delay before auto-navigation
    // Only if no one answered (if someone answered, they trigger the advance)
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && !_gameFinished && _showExplanation) {
        _nextQuestion();
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (!mounted || _gameFinished) return;

    // Prevent multiple simultaneous calls
    if (_isTransitioning) return;
    setState(() => _isTransitioning = true);

    if (_questionIndex + 1 >= _questions.length) {
      await _finishGame();
      if (mounted) {
        setState(() => _isTransitioning = false);
      }
      return;
    }

    final nextIndex = _questionIndex + 1;

    // Only the first player to call this will succeed
    try {
      final newTurnIndex = _isTurnBased
          ? (_turnIndex + 1) % (_players.length == 0 ? 1 : _players.length)
          : 0;

      await _service.updateRoomProgress(
        roomCode: _roomId!,
        currentQuestionIndex: nextIndex,
        currentTurnIndex: newTurnIndex,
      );

      logger.d(
        'Successfully updated progress. Broadcasting state change: $_roomId, nextIndex: $nextIndex, turnIndex: $newTurnIndex',
      );

      // Broadcast the state change to OTHER players
      await _service.broadcastRoomState(
        channel: _gameChannel!,
        state: {
          'current_question_index': nextIndex,
          'current_turn_index': newTurnIndex,
        },
      );

      // Also send the action for logging purposes
      await _service.sendAction(
        channel: _gameChannel!,
        action: {'type': 'next', 'question_index': nextIndex},
      );

      // IMPORTANT: Update our own local state immediately (don't wait for broadcast)
      // Cancel the timer first
      _timer?.cancel();

      if (mounted) {
        setState(() {
          _questionIndex = nextIndex;
          _turnIndex = newTurnIndex;
          _selectedOptionIndex = null;
          _showExplanation = false;
          _playersWhoAnswered.clear();
          _questionLocked = false;
          _hintUsed = false;
          _playerAnswers.clear();
          _currentUserAnswered = false;
          _currentUserSelectedOption = null;
        });

        // Restart timer for new question
        _restartTimer();
      }
    } catch (e) {
      // Another player already advanced - this is normal in multiplayer
      // Just log it and rely on receiving the broadcast from the other player
      logger.w('Another player already advanced to next question: $e');
      // Don't update local state here - wait for the broadcast from the successful player
    } finally {
      if (mounted) {
        setState(() => _isTransitioning = false);
      }
    }
  }

  Future<void> _finishGame() async {
    if (_gameFinished) return;

    setState(() => _gameFinished = true);

    final sortedScores = _scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final winnerUserId = sortedScores.isEmpty
        ? (_currentUserId ?? '')
        : sortedScores.first.key;

    await _service.finishGame(roomCode: _roomId!, winnerUserId: winnerUserId);

    // Show game results
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text('Game Complete!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Final Scores',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...sortedScores.map((entry) {
                final profile = _userProfiles[entry.key];
                final displayName =
                    profile?['username'] ??
                        profile?['display_name'] ??
                        _players.firstWhere(
                              (p) => p['user_id'] == entry.key,
                          orElse: () => {'display_name': 'Player'},
                        )['display_name'] ??
                        'Player';
                final isWinner = entry.key == winnerUserId;
                final isMe = entry.key == _currentUserId;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      if (isWinner)
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 20,
                        )
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isMe ? '$displayName (You)' : displayName,
                          style: TextStyle(
                            fontWeight: isWinner
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value} pts',
                        style: TextStyle(
                          fontWeight: isWinner
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isWinner ? Colors.amber : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to trivia home screen
                if (mounted) {
                  clearAndNavigate(Routes.triviaGroupLobby.name);
                }
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      );
    }
  }

  // Future<void> _onAnswer(int optionIndex) async {
  //   if (_showExplanation || !mounted) return;

  //   // Check if question is locked or user has already answered
  //   if (_questionLocked || _playersWhoAnswered.contains(_currentUserId)) {
  //     return;
  //   }

  //   if (_isTurnBased && _players.isNotEmpty) {
  //     final myIndex = _players.indexWhere(
  //       (p) => p['user_id'] == _currentUserId,
  //     );
  //     if (myIndex != _turnIndex) return; // Not my turn
  //   }

  //   final question = _isBonusQuestion
  //       ? _bonusQuestion!
  //       : _questions[_questionIndex];
  //   final selectedOption = question.options[optionIndex];
  //   final isCorrect =
  //       selectedOption.trim().toLowerCase() ==
  //       question.answer.trim().toLowerCase();

  //   final points = _difficulty == 'easy'
  //       ? 10
  //       : _difficulty == 'medium'
  //       ? 20
  //       : 30;

  //   // For bonus questions, award original points + bonus
  //   final bonusPoints = _isBonusQuestion ? 5 : 0;
  //   final totalPoints = isCorrect ? points + bonusPoints : 0;

  //   try {
  //     await _service.submitAnswer(
  //       roomCode: _roomId!,
  //       userId: _currentUserId ?? 'anon',
  //       questionId: question.id,
  //       isCorrect: isCorrect,
  //       pointsAwarded: totalPoints,
  //     );
  //   } catch (e) {
  //     logger.e('Failed to submit answer: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to submit answer: ${e.toString()}')),
  //       );
  //     }
  //     // Continue with UI updates even if submission fails
  //   }

  //   // If this is a bonus question, we need to handle the transition differently
  //   if (_isBonusQuestion) {
  //     // Immediately lock question and track this user's answer
  //     setState(() {
  //       _currentUserSelectedOption =
  //           optionIndex; // Store current user's selection
  //       _selectedOptionIndex = optionIndex;
  //       _showExplanation = true;
  //       _questionLocked = true;
  //       _playersWhoAnswered.add(_currentUserId ?? '');
  //       _currentUserAnswered = true; // Mark that current user answered
  //     });

  //     // Notify other players that someone answered with the selected option
  //     await _service.sendAction(
  //       channel: _gameChannel!,
  //       action: {
  //         'type': 'player_answered',
  //         'user_id': _currentUserId,
  //         'question_index': _questionIndex,
  //         'selected_option': optionIndex, // Send the selected option index
  //       },
  //     );

  //     // Broadcast reveal to all players
  //     await _service.sendAction(
  //       channel: _gameChannel!,
  //       action: {'type': 'reveal', 'question_index': _questionIndex},
  //     );

  //     // Start 8-second timer for this player (in case we don't receive our own broadcast)
  //     // The onAction callback will check _showExplanation to prevent duplicate timers
  //     Future.delayed(const Duration(seconds: 8), () {
  //       if (mounted && !_gameFinished && _showExplanation) {
  //         // After bonus question, go back to regular question flow
  //         setState(() {
  //           _isBonusQuestion = false;
  //           _showBonusAcceptance = false;
  //         });

  //         // Advance to the next question in the regular flow
  //         _nextQuestion();
  //       }
  //     });
  //   } else {
  //     // Regular question flow
  //     final isIncorrect = !isCorrect;

  //     // Immediately lock question and track this user's answer
  //     setState(() {
  //       _currentUserSelectedOption =
  //           optionIndex; // Store current user's selection
  //       _selectedOptionIndex = optionIndex;
  //       _showExplanation = true;
  //       _questionLocked = true;
  //       _playersWhoAnswered.add(_currentUserId ?? '');
  //       _currentUserAnswered = true; // Mark that current user answered
  //     });

  //     // If the current player answered incorrectly, offer bonus question to opponent
  //     if (isIncorrect && _isTurnBased && _players.length > 1) {
  //       // Find the opponent (the other player)
  //       final opponent = _players.firstWhere(
  //         (p) => p['user_id'] != _currentUserId,
  //         orElse: () => _players[0], // Fallback if no other player
  //       );

  //       if (opponent['user_id'] != _currentUserId) {
  //         // Send bonus question to opponent with 10-second acceptance timer
  //         await _service.sendAction(
  //           channel: _gameChannel!,
  //           action: {
  //             'type': 'bonus_question',
  //             'question': question.toJson(), // Send the question data
  //             'opponent_id': opponent['user_id'],
  //             'current_player_id': _currentUserId,
  //           },
  //         );
  //       }
  //     }

  //     // Notify other players that someone answered with the selected option
  //     await _service.sendAction(
  //       channel: _gameChannel!,
  //       action: {
  //         'type': 'player_answered',
  //         'user_id': _currentUserId,
  //         'question_index': _questionIndex,
  //         'selected_option': optionIndex, // Send the selected option index
  //       },
  //     );

  //     // Broadcast reveal to all players
  //     await _service.sendAction(
  //       channel: _gameChannel!,
  //       action: {'type': 'reveal', 'question_index': _questionIndex},
  //     );

  //     // Start 8-second timer for this player (in case we don't receive our own broadcast)
  //     // The onAction callback will check _showExplanation to prevent duplicate timers
  //     Future.delayed(const Duration(seconds: 8), () {
  //       if (mounted && !_gameFinished && _showExplanation) {
  //         _nextQuestion();
  //       }
  //     });
  //   }
  // }

  Future<void> _onAnswer(int optionIndex) async {
    if (_showExplanation || !mounted) return;

    // Check if question is locked or user has already answered
    if (_questionLocked || _playersWhoAnswered.contains(_currentUserId)) {
      return;
    }

    if (_isTurnBased && _players.isNotEmpty) {
      final myIndex = _players.indexWhere(
            (p) => p['user_id'] == _currentUserId,
      );
      if (myIndex != _turnIndex) return; // Not my turn
    }

    final question = _isBonusQuestion
        ? _bonusQuestion!
        : _questions[_questionIndex];
    final selectedOption = question.options[optionIndex];
    final isCorrect =
        selectedOption.trim().toLowerCase() ==
            question.answer.trim().toLowerCase();

    final points = _difficulty == 'easy'
        ? 10
        : _difficulty == 'medium'
        ? 20
        : 30;

    // For bonus questions, award original points + bonus (only if correct)
    final bonusPoints = _isBonusQuestion ? 5 : 0;
    final totalPoints = isCorrect ? points + bonusPoints : 0;

    try {
      await _service.submitAnswer(
        roomCode: _roomId!,
        userId: _currentUserId ?? 'anon',
        questionId: question.id,
        isCorrect: isCorrect,
        pointsAwarded: totalPoints,
      );
    } catch (e) {
      logger.e('Failed to submit answer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit answer: ${e.toString()}')),
        );
      }
    }

    // If this is a bonus question, handle transition
    if (_isBonusQuestion) {
      setState(() {
        _currentUserSelectedOption = optionIndex;
        _selectedOptionIndex = optionIndex;
        _showExplanation = true;
        _questionLocked = true;
        _playersWhoAnswered.add(_currentUserId ?? '');
        _currentUserAnswered = true;
      });

      // Notify other players with is_correct field
      await _service.sendAction(
        channel: _gameChannel!,
        action: {
          'type': 'player_answered',
          'user_id': _currentUserId,
          'question_index': _questionIndex,
          'selected_option': optionIndex,
          'is_correct': isCorrect,
          'is_bonus': true, // Mark this as bonus question answer
        },
      );

      await _service.sendAction(
        channel: _gameChannel!,
        action: {'type': 'reveal', 'question_index': _questionIndex},
      );

      // After bonus question, wait 8 seconds then go to next question
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted && !_gameFinished && _showExplanation) {
          setState(() {
            _isBonusQuestion = false;
            _showBonusAcceptance = false;
            _bonusQuestion = null;
          });

          // Now advance to the NEXT question in the regular flow
          _nextQuestion();
        }
      });
    } else {
      // Regular question flow
      final isIncorrect = !isCorrect;

      setState(() {
        _currentUserSelectedOption = optionIndex;
        _selectedOptionIndex = optionIndex;
        _showExplanation = true;
        _questionLocked = true;
        _playersWhoAnswered.add(_currentUserId ?? '');
        _currentUserAnswered = true;
      });

      // ✅ যদি wrong answer হয়, opponent কে bonus question offer করুন (same question)
      if (isIncorrect && _isTurnBased && _players.length > 1) {
        final opponent = _players.firstWhere(
              (p) => p['user_id'] != _currentUserId,
          orElse: () => _players[0],
        );

        if (opponent['user_id'] != _currentUserId) {
          // Send the SAME question as bonus to opponent
          await _service.sendAction(
            channel: _gameChannel!,
            action: {
              'type': 'bonus_question',
              'question': question.toJson(), // Same question
              'opponent_id': opponent['user_id'],
              'current_player_id': _currentUserId,
            },
          );
        }
      }

      // Notify other players with is_correct field
      await _service.sendAction(
        channel: _gameChannel!,
        action: {
          'type': 'player_answered',
          'user_id': _currentUserId,
          'question_index': _questionIndex,
          'selected_option': optionIndex,
          'is_correct': isCorrect,
          'is_bonus': false,
        },
      );

      await _service.sendAction(
        channel: _gameChannel!,
        action: {'type': 'reveal', 'question_index': _questionIndex},
      );

      // Wait 8 seconds before proceeding
      // If opponent gets bonus, they need to answer first before next question
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted && !_gameFinished && _showExplanation) {
          // Only advance if no bonus question was offered
          // If bonus was offered, opponent will advance after answering
          if (!isIncorrect) {
            _nextQuestion();
          }
        }
      });
    }
  }

  Color _getTimerColor() {
    if (_secondsLeft > 20) return Colors.green;
    if (_secondsLeft > 10) return Colors.orange;
    return Colors.red;
  }

  Future<void> _onGetClue() async {
    if (_hintUsed || _showExplanation || !mounted) return;

    // Check if it's user's turn
    if (_isTurnBased && _players.isNotEmpty) {
      final myIndex = _players.indexWhere(
            (p) => p['user_id'] == _currentUserId,
      );
      if (myIndex != _turnIndex) return; // Not my turn
    }

    // Calculate penalty points based on difficulty
    final penaltyPoints = _difficulty == 'easy'
        ? 3
        : _difficulty == 'medium'
        ? 6
        : 9;

    // Show confirmation dialog with point deduction information
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text('Use Hint?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Using a hint will help you answer the question but will deduct points from your score.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.amber.shade800,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Points to be deducted: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '-$penaltyPoints pts',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const TextSpan(text: '\n\nDifficulty: '),
                          TextSpan(
                            text: _difficulty.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Use Hint'),
          ),
        ],
      ),
    );

    // If user didn't confirm, return
    if (confirmed != true) return;

    setState(() {
      _hintUsed = true;
    });

    // Record hint usage in database
    try {
      final question = _questions[_questionIndex];
      await _service.recordHintUsage(
        roomCode: _roomId!,
        userId: _currentUserId ?? 'anon',
        questionId: question.id,
        penaltyPoints: penaltyPoints,
      );

      // Directly update player score to deduct penalty (without creating an answer record)
      // This uses the trivia_update_player_score RPC function
      try {
        await _service.supabaseProvider.supabase.rpc(
          'trivia_update_player_score',
          params: {
            'p_room_id': _roomId!,
            'p_user_id': _currentUserId ?? 'anon',
            'p_points': -penaltyPoints,
          },
        );
      } catch (e) {
        logger.e('Failed to update score for hint: $e');
      }

      // Refresh scores to reflect penalty
      final scores = await _service.fetchRoomScores(_roomId!);
      if (mounted) {
        setState(() => _scores = scores);
      }
    } catch (e) {
      print('Failed to record hint usage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to use hint: ${e.toString()}')),
        );
      }
    }
  }

  int _getHintPenalty() {
    return _difficulty == 'easy'
        ? 3
        : _difficulty == 'medium'
        ? 6
        : 9;
  }

  String _getRandomIslamicFact() {
    const facts = [
      "The Quran was revealed over a period of 23 years to Prophet Muhammad (peace be upon him).",
      "The first word revealed in the Quran was 'Iqra' (Read) in Surah Al-Alaq, verse 1.",
      "There are 114 chapters (Surahs) in the Quran, with 6,236 verses (Ayahs).",
      "The longest Surah in the Quran is Al-Baqarah with 286 verses.",
      "The shortest Surah in the Quran is Al-Kawthar with only 3 verses.",
      "The word 'Quran' appears 70 times in the Quran itself.",
      "Prophet Muhammad (peace be upon him) received his first revelation in the Cave of Hira.",
      "The Quran was memorized and preserved by the Companions during the Prophet's lifetime.",
      "The first Surah of the Quran is Al-Fatiha, known as the 'Opening'.",
      "The Quran mentions 25 prophets by name, including Adam, Noah, Abraham, Moses, Jesus, and Muhammad (peace be upon them all).",
      "The word 'Islam' appears 14 times in the Quran.",
      "The Quran was revealed in Arabic, and it is considered the literal word of God in Islamic belief.",
      "The last Surah of the Quran is An-Nas, which along with Surah Al-Falaq, is known as 'Al-Mu'awwidhatayn'.",
      "The Quran was compiled into a book during the time of Caliph Abu Bakr (may Allah be pleased with him).",
      "The Quran has been preserved in its original form for over 1400 years.",
    ];

    // // Use a simple hash of current time to get a pseudo-random fact
    // final randomIndex = DateTime.now().millisecondsSinceEpoch % facts.length;
    // return facts[randomIndex];
    // Current time in seconds since epoch
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Divide by 30 to get 30-second interval, then mod by facts.length
    final index = (now ~/ 30) % facts.length;
    return facts[index];
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text(
          'Are you sure you want to leave the game? This will end the game for all players.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () async {
              // Notify other players that this player has left and end the game for everyone
              try {
                await _service.sendAction(
                  channel: _gameChannel!,
                  action: {
                    'type': 'player_left_and_end_game',
                    'user_id': _currentUserId,
                    'display_name':
                    _userProfiles[_currentUserId]?['username'] ??
                        _userProfiles[_currentUserId]?['display_name'] ??
                        'A player',
                  },
                );

                // Also finish the game in the database
                final sortedScores = _scores.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final winnerUserId = sortedScores.isEmpty
                    ? (_currentUserId ?? '')
                    : sortedScores.first.key;

                await _service.finishGame(
                  roomCode: _roomId!,
                  winnerUserId: winnerUserId,
                );
              } catch (e) {
                // Continue with exit even if notification fails
                print('Failed to notify players of exit: $e');
              }

              // Close dialog first
              Navigator.of(context).pop(true);

              // Navigate to trivia home screen
              if (mounted) {
                // remove until trivia home
                clearAndNavigate(Routes.triviaGroupLobby.name);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Exit Game'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void clearAndNavigate(String path) {
    while (context.canPop() == true) {
      context.pop();
    }
    context.pushReplacement(path);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bonusTimer?.cancel();
    _gameChannel?.unsubscribe();
    _playersChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: TriviaLoadingScreen());
    }

    if (_questions.isEmpty) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(title: const Text('Group Game')),
          body: const Center(child: Text('No questions available')),
        ),
      );
    }

    final question = _questions[_questionIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: AppBarScaffold(
        pageTitle: 'Group Game',
        appBarActions: [
          IconButton(
            onPressed: () async {
              if (_roomId != null) {
                await _service.updateRoomProgress(
                  roomCode: _roomId!,
                  currentQuestionIndex: _questionIndex,
                  currentTurnIndex: _turnIndex,
                );
              }
            },
            icon: const Icon(Icons.sync),
            tooltip: 'Sync',
          ),
        ],
        child: TriviaBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Players Section
                _PlayersSection(
                  players: _players,
                  scores: _scores,
                  currentUserId: _currentUserId,
                  turnIndex: _turnIndex,
                  isTurnBased: _isTurnBased,
                  userProfiles: _userProfiles,
                ),

                const SizedBox(height: 16),

                // Game Info
                _GameInfoSection(
                  questionIndex: _questionIndex,
                  totalQuestions: _totalQuestions,
                  secondsLeft: _secondsLeft,
                  timerColor: _getTimerColor(),
                  difficulty: _difficulty,
                ),

                const SizedBox(height: 20),

                // Show opponent view when it's not the current player's turn and someone else is answering
                if (_isTurnBased &&
                    _players.isNotEmpty &&
                    _currentUserId != null &&
                    _players.indexWhere(
                          (p) => p['user_id'] == _currentUserId,
                    ) !=
                        _turnIndex &&
                    !_playersWhoAnswered.contains(_currentUserId))
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_search,
                              color: Colors.blue.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your opponent is answering a question...',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getRandomIslamicFact(),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                    color: Colors.amber.shade800,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                // Show locked status when someone else answered
                else if (_questionLocked &&
                    !_playersWhoAnswered.contains(_currentUserId))
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock,
                          color: Colors.orange.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Another player has answered. Waiting for the explanation...',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                // Question Section (only show when it's the current player's turn)
                else
                  Column(
                    children: [
                      // Question Section
                      TriviaQuestionSection(question: question.question),

                      const SizedBox(height: 20),

                      // Options Section
                      TriviaOptionsSection(
                        options: question.options,
                        selectedOptionIndex:
                        _selectedOptionIndex, // Show whoever answered (current user or other player)
                        correctOptionIndex: _showExplanation
                            ? question.options.indexWhere(
                              (option) =>
                          option.trim().toLowerCase() ==
                              question.answer.trim().toLowerCase(),
                        )
                            : null,
                        showExplanation:
                        _showExplanation ||
                            _questionLocked ||
                            _playersWhoAnswered.contains(_currentUserId),
                        onAnswer: _onAnswer,
                      ),

                      // Hint Section
                      TriviaHintSection(
                        hint: question.hint,
                        hintUsed: _hintUsed,
                        penaltyPoints: _getHintPenalty(),
                        onGetClue: _onGetClue,
                        disabled:
                        _showExplanation ||
                            _questionLocked ||
                            _playersWhoAnswered.contains(_currentUserId),
                      ),
                    ],
                  ),

                // Bonus Question Acceptance UI
                if (_showBonusAcceptance && _bonusQuestion != null)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bonus Question!',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The opponent answered incorrectly. You have a chance to earn bonus points!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.amber.shade700),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            'You have 10 seconds to accept this bonus question',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Question: ${_bonusQuestion!.question}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  // Cancel the bonus timer
                                  _bonusTimer?.cancel();

                                  // Accept bonus question
                                  setState(() {
                                    _isBonusQuestion = true;
                                    _showBonusAcceptance = false;
                                    _selectedOptionIndex = null;
                                    _showExplanation = false;
                                    _playersWhoAnswered.clear();
                                    _questionLocked = false;
                                    _hintUsed = false;
                                    _playerAnswers.clear();
                                    _currentUserAnswered = false;
                                    _currentUserSelectedOption = null;
                                    _isBonusQuestionAvailable = false;
                                  });

                                  // Restart timer for bonus question (30 seconds)
                                  _restartTimer();
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Accept'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Cancel the bonus timer
                                  _bonusTimer?.cancel();

                                  // Decline bonus question
                                  setState(() {
                                    _isBonusQuestionAvailable = false;
                                    _showBonusAcceptance = false;
                                    _bonusQuestion = null;
                                  });

                                  // Advance to the next question in the regular flow
                                  _nextQuestion();
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('Decline'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                // Next Question Button (only for answering player) - Below hint section
                else if (_showExplanation &&
                    _currentUserAnswered &&
                    !_gameFinished)
                  TriviaSkipButton(onSkip: _nextQuestion),

                // Explanation Section (only for current user if they answered)
                if (_showExplanation && _currentUserAnswered)
                  TriviaExplanationSection(
                    explanation: question.context,
                    funFact: question.funFact,
                    isCorrect:
                    _currentUserSelectedOption != null &&
                        question.options[_currentUserSelectedOption!]
                            .trim()
                            .toLowerCase() ==
                            question.answer.trim().toLowerCase(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayersSection extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  final Map<String, int> scores;
  final String? currentUserId;
  final int turnIndex;
  final bool isTurnBased;
  final Map<String, Map<String, dynamic>> userProfiles;

  const _PlayersSection({
    required this.players,
    required this.scores,
    required this.currentUserId,
    required this.turnIndex,
    required this.isTurnBased,
    required this.userProfiles,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: players.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          final player = players[index];
          final userId = player['user_id'] as String;
          final isMyTurn = isTurnBased && index == turnIndex;
          final score = scores[userId] ?? 0;
          final isMe = userId == currentUserId;

          // Get display name from profile or fallback to room display_name
          final profile = userProfiles[userId];
          final displayName =
              profile?['username'] ??
                  profile?['display_name'] ??
                  player['display_name']?.toString() ??
                  'Player';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: isMyTurn ? 3 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: isMyTurn
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isMe
                          ? Theme.of(context).colorScheme.primary
                          : isMyTurn
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMe ? Icons.person : Icons.person_outline,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isMyTurn
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        isMyTurn && isMe
                            ? 'Your Turn'
                            : isMyTurn
                            ? 'Playing'
                            : 'Waiting',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: isMyTurn
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isMyTurn
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$score',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GameInfoSection extends StatelessWidget {
  final int questionIndex;
  final int totalQuestions;
  final int secondsLeft;
  final Color timerColor;
  final String difficulty;

  const _GameInfoSection({
    required this.questionIndex,
    required this.totalQuestions,
    required this.secondsLeft,
    required this.timerColor,
    required this.difficulty,
  });

  int get pointsForQuestion {
    switch (difficulty) {
      case 'easy':
        return 10;
      case 'medium':
        return 20;
      case 'hard':
        return 30;
      default:
        return 10; // Default to easy
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.question_answer,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Q${questionIndex + 1}/$totalQuestions',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: timerColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: timerColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$secondsLeft',
                      style: TextStyle(
                        color: timerColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Points display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+${pointsForQuestion} pts',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';

// import 'package:deenhub/config/routes/routes.dart';
// import 'package:deenhub/core/di/app_injections.dart';
// import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
// import 'package:deenhub/features/trivia/data/models/trivia_question.dart';
// import 'package:deenhub/features/trivia/data/services/trivia_service.dart';
// import 'package:deenhub/features/trivia/presentation/widgets/trivia_game_widgets.dart';
// import 'package:deenhub/main.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class TriviaGroupGameScreen extends StatefulWidget {
//   final Map<String, String> queryParams;
//   const TriviaGroupGameScreen({super.key, required this.queryParams});

//   @override
//   State<TriviaGroupGameScreen> createState() => _TriviaGroupGameScreenState();
// }

// class _TriviaGroupGameScreenState extends State<TriviaGroupGameScreen> {
//   late final TriviaService _service;
//   RealtimeChannel? _gameChannel;
//   RealtimeChannel? _playersChannel;

//   String get _roomCode => (widget.queryParams['roomId'] ?? '').toLowerCase();
//   String? _roomId; // Actual resolved UUID
//   String get _difficulty => widget.queryParams['difficulty'] ?? 'easy';
//   // Always turn-based in group mode (all difficulties)
//   bool get _isTurnBased => true;

//   List<TriviaQuestion> _questions = const [];
//   int _questionIndex = 0;
//   int _turnIndex = 0;
//   int _secondsLeft = 30;
//   Timer? _timer;
//   bool _loading = true;
//   bool _showExplanation = false;
//   bool _gameFinished = false;
//   int? _selectedOptionIndex;
//   Set<String> _playersWhoAnswered =
//       <String>{}; // Track who answered current question
//   bool _questionLocked = false; // Lock question when someone answers
//   bool _hintUsed = false; // Track if hint was used for current question
//   Map<String, int> _playerAnswers =
//       {}; // Track each player's selected option index
//   bool _isTransitioning = false; // Prevent multiple simultaneous transitions
//   bool _currentUserAnswered =
//       false; // Track if current user answered the question
//   int? _currentUserSelectedOption; // Only for current user's selection
//   bool _isBonusQuestion = false; // Track if current question is a bonus
//   bool _isBonusQuestionAvailable = false; // Track if bonus question is available
//   Timer? _bonusTimer; // Timer for bonus question acceptance
//   TriviaQuestion? _bonusQuestion; // Store bonus question if available
//   bool _showBonusAcceptance = false; // Show bonus acceptance UI

//   List<Map<String, dynamic>> _players = const [];
//   Map<String, int> _scores = const {};
//   String? _currentUserId;
//   Map<String, Map<String, dynamic>> _userProfiles =
//       const {}; // userId -> profile

//   @override
//   void initState() {
//     super.initState();
//     _service = getIt<TriviaService>();
//     _currentUserId = _service.supabaseProvider.supabase.auth.currentUser?.id;

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadGameData();
//       await _subscribeToUpdates();
//     });
//   }

//   Future<void> _loadGameData() async {
//     try {
//       // First resolve the room code to UUID
//       final resolvedRoomId = await _service.resolveRoomId(_roomCode);
//       if (resolvedRoomId == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Room not found. Please check the room code.'),
//             ),
//           );
//           Navigator.of(context).pop();
//         }
//         return;
//       }

//       _roomId = resolvedRoomId; // Store the resolved UUID

//       // Now validate that the room exists and is in active state
//       final roomData = await _service.getRoom(_roomId!);
//       if (roomData.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Room not found or has been deleted.'),
//             ),
//           );
//           Navigator.of(context).pop();
//         }
//         return;
//       }

//       final roomStatus = roomData['status'] as String?;
//       if (roomStatus == 'finished') {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('This game has already finished.')),
//           );
//           Navigator.of(context).pop();
//         }
//         return;
//       }

//       // Load all data in parallel for faster loading
//       final results = await Future.wait([
//         _service.getRoomQuestions(_roomId!),
//         _service.getRoomPlayers(_roomId!),
//         _service.fetchRoomScores(_roomId!),
//       ]);

//       final questions = results[0] as List<TriviaQuestion>;
//       final players = results[1] as List<Map<String, dynamic>>;
//       final scores = results[2] as Map<String, int>;

//       if (questions.isEmpty) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('No questions found for this room.')),
//           );
//           Navigator.of(context).pop();
//         }
//         return;
//       }

//       // Load user profiles for all players in parallel with timeout
//       final userProfiles = <String, Map<String, dynamic>>{};
//       final profileFutures = <Future<void>>[];

//       for (final player in players) {
//         final userId = player['user_id'] as String;
//         profileFutures.add(
//           _loadUserProfileWithTimeout(userId, userProfiles)
//         );
//       }

//       // Wait for all profile requests to complete with timeout
//       try {
//         await Future.wait(profileFutures, eagerError: true);
//       } catch (e) {
//         logger.w('Some profile requests timed out: $e');
//         // Continue with partial profile data
//       }

//       if (mounted) {
//         setState(() {
//           _questions = questions;
//           _players = players;
//           _scores = scores;
//           _userProfiles = userProfiles;
//           _loading = false;
//         });
//         _startTimer();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _loading = false);

//         String errorMessage = 'Failed to load game data';
//         if (e.toString().contains('violates foreign key constraint')) {
//           errorMessage = 'Room not found. The game may have been deleted.';
//         } else if (e.toString().contains('connection')) {
//           errorMessage =
//               'Connection error. Please check your internet connection.';
//         }

//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(errorMessage)));
//         Navigator.of(context).pop();
//       }
//     }
//   }

//   /// Load user profile with timeout to prevent hanging
//   Future<void> _loadUserProfileWithTimeout(String userId, Map<String, Map<String, dynamic>> userProfiles) async {
//     try {
//       // Create a timeout for profile loading
//       final profile = await _service.getUserProfile(userId).timeout(
//         const Duration(seconds: 3), // 3 second timeout for each profile
//         onTimeout: () => null, // Return null if timeout occurs
//       );

//       if (profile != null) {
//         userProfiles[userId] = profile;
//       }
//     } catch (e) {
//       // Profile loading failed, continue with other profiles
//       logger.w('Failed to load profile for user $userId: $e');
//     }
//   }

//   Future<void> _subscribeToUpdates() async {
//     if (_roomId == null) return; // Safety check

//     _gameChannel?.unsubscribe();
//     _gameChannel = await _service.subscribeToGame(
//       _roomId!,
//       onState: (state) {
//         if (!mounted) return;

//         final newQuestionIndex =
//             (state['current_question_index'] as num?)?.toInt() ??
//             _questionIndex;
//         final newTurnIndex =
//             (state['current_turn_index'] as num?)?.toInt() ?? _turnIndex;

//         // Check if question changed
//         final questionChanged = newQuestionIndex != _questionIndex;

//         if (questionChanged) {
//           print('Question changed from $_questionIndex to $newQuestionIndex');
//           _timer?.cancel(); // Cancel old timer

//           setState(() {
//             _questionIndex = newQuestionIndex;
//             _turnIndex = newTurnIndex;
//             _selectedOptionIndex = null;
//             _showExplanation = false;
//             _playersWhoAnswered.clear();
//             _questionLocked = false;
//             _hintUsed = false; // Reset hint for new question
//             _playerAnswers.clear(); // Reset player answers
//             _currentUserAnswered = false; // Reset current user answered flag
//             _currentUserSelectedOption = null; // Reset current user's selection
//           });

//           _restartTimer(); // Start fresh timer
//         } else {
//           // Only turn index changed
//           setState(() {
//             _turnIndex = newTurnIndex;
//           });
//         }
//       },
//       onAction: (action) async {
//         if (!mounted) return;

//         final type = action['type'];
//         if (type == 'reveal') {
//           // Only set explanation if not already showing (to prevent duplicate timers)
//           if (!_showExplanation) {
//             setState(() => _showExplanation = true);

//             // All players start 8-second countdown to next question
//             Future.delayed(const Duration(seconds: 8), () {
//               if (mounted && !_gameFinished && _showExplanation) {
//                 _nextQuestion();
//               }
//             });
//           }
//         } else if (type == 'next') {
//           // State reset is now handled in onState callback
//           // Just log that we received the action
//           print('Received next action');
//         } else if (type == 'player_answered') {
//           // Someone answered - lock the question for others and show their selection
//           final answerUserId = action['user_id'] as String?;
//           final selectedOption = action['selected_option'] as int?;

//           if (answerUserId != null && selectedOption != null && mounted) {
//             setState(() {
//               _playersWhoAnswered.add(answerUserId);
//               _questionLocked = true; // Lock question when someone answers
//               _playerAnswers[answerUserId] =
//                   selectedOption; // Store their answer

//               // If this is not the current user, show the answering player's selection
//               if (answerUserId != _currentUserId) {
//                 _selectedOptionIndex = selectedOption;
//               }
//             });
//           }
//         } else if (type == 'player_left') {
//           // Show notification when a player leaves
//           final displayName = action['display_name'] ?? 'A player';
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('$displayName has left the game'),
//                 duration: const Duration(seconds: 3),
//                 behavior: SnackBarBehavior.floating,
//               ),
//             );
//           }
//         } else if (type == 'bonus_question') {
//           // Handle bonus question offer to the opponent
//           final questionData = action['question'] as Map<String, dynamic>?;
//           final opponentId = action['opponent_id'] as String?;

//           // Check if this bonus question is for the current user
//           if (opponentId == _currentUserId && questionData != null && mounted) {
//             final question = TriviaQuestion.fromJson(questionData);

//             // Show bonus question acceptance UI
//             setState(() {
//               _isBonusQuestionAvailable = true;
//               _bonusQuestion = question;
//               _showBonusAcceptance = true;
//             });

//             // Start 10-second timer for bonus question acceptance
//             _bonusTimer?.cancel();
//             int countdown = 10;

//             _bonusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//               if (!mounted) {
//                 timer.cancel();
//                 return;
//               }

//               if (countdown <= 0) {
//                 timer.cancel();
//                 // Timeout - user didn't accept the bonus question
//                 if (mounted) {
//                   setState(() {
//                     _isBonusQuestionAvailable = false;
//                     _showBonusAcceptance = false;
//                   });

//                   // Advance to the next question in the regular flow since bonus was not accepted in time
//                   _nextQuestion();
//                 }
//               } else {
//                 countdown--;
//               }
//             });
//           }
//         }

//         // Refresh scores
//         final scores = await _service.fetchRoomScores(_roomId!);
//         if (mounted) {
//           setState(() => _scores = scores);
//         }
//       },
//     );

//     _playersChannel?.unsubscribe();
//     _playersChannel = await _service.subscribeToRoomPlayers(
//       _roomId!,
//       onChange: () async {
//         final players = await _service.getRoomPlayers(_roomId!);
//         if (mounted) {
//           setState(() => _players = players);
//         }
//       },
//     );
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     if (!mounted) return;

//     setState(() => _secondsLeft = 30);

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       setState(() {
//         _secondsLeft--;
//         if (_secondsLeft <= 0) {
//           timer.cancel();
//           _onTimeUp();
//         }
//       });
//     });
//   }

//   void _restartTimer() {
//     _timer?.cancel();
//     if (mounted) {
//       setState(() => _secondsLeft = 30);
//       _startTimer();
//     }
//   }

//   Future<void> _onTimeUp() async {
//     if (!mounted || _showExplanation) return;

//     setState(() => _showExplanation = true);

//     // Broadcast that timer expired (reveal the answer)
//     await _service.sendAction(
//       channel: _gameChannel!,
//       action: {'type': 'reveal', 'question_index': _questionIndex},
//     );

//     // Ensure consistent 8-second delay before auto-navigation
//     // Only if no one answered (if someone answered, they trigger the advance)
//     Future.delayed(const Duration(seconds: 8), () {
//       if (mounted && !_gameFinished && _showExplanation) {
//         _nextQuestion();
//       }
//     });
//   }

//   Future<void> _nextQuestion() async {
//     if (!mounted || _gameFinished) return;

//     // Prevent multiple simultaneous calls
//     if (_isTransitioning) return;
//     setState(() => _isTransitioning = true);

//     if (_questionIndex + 1 >= _questions.length) {
//       await _finishGame();
//       if (mounted) {
//         setState(() => _isTransitioning = false);
//       }
//       return;
//     }

//     final nextIndex = _questionIndex + 1;

//     // Only the first player to call this will succeed
//     try {
//       final newTurnIndex = _isTurnBased
//           ? (_turnIndex + 1) % (_players.length == 0 ? 1 : _players.length)
//           : 0;

//       await _service.updateRoomProgress(
//         roomCode: _roomId!,
//         currentQuestionIndex: nextIndex,
//         currentTurnIndex: newTurnIndex,
//       );

//       logger.d(
//         'Successfully updated progress. Broadcasting state change: $_roomId, nextIndex: $nextIndex, turnIndex: $newTurnIndex',
//       );

//       // Broadcast the state change to OTHER players
//       await _service.broadcastRoomState(
//         channel: _gameChannel!,
//         state: {
//           'current_question_index': nextIndex,
//           'current_turn_index': newTurnIndex,
//         },
//       );

//       // Also send the action for logging purposes
//       await _service.sendAction(
//         channel: _gameChannel!,
//         action: {'type': 'next', 'question_index': nextIndex},
//       );

//       // IMPORTANT: Update our own local state immediately (don't wait for broadcast)
//       // Cancel the timer first
//       _timer?.cancel();

//       if (mounted) {
//         setState(() {
//           _questionIndex = nextIndex;
//           _turnIndex = newTurnIndex;
//           _selectedOptionIndex = null;
//           _showExplanation = false;
//           _playersWhoAnswered.clear();
//           _questionLocked = false;
//           _hintUsed = false;
//           _playerAnswers.clear();
//           _currentUserAnswered = false;
//           _currentUserSelectedOption = null;
//         });

//         // Restart timer for new question
//         _restartTimer();
//       }
//     } catch (e) {
//       // Another player already advanced - this is normal in multiplayer
//       // Just log it and rely on receiving the broadcast from the other player
//       logger.w('Another player already advanced to next question: $e');
//       // Don't update local state here - wait for the broadcast from the successful player
//     } finally {
//       if (mounted) {
//         setState(() => _isTransitioning = false);
//       }
//     }
//   }

//   Future<void> _finishGame() async {
//     if (_gameFinished) return;

//     setState(() => _gameFinished = true);

//     final sortedScores = _scores.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     final winnerUserId = sortedScores.isEmpty
//         ? (_currentUserId ?? '')
//         : sortedScores.first.key;

//     await _service.finishGame(roomCode: _roomId!, winnerUserId: winnerUserId);

//     // Show game results
//     if (mounted) {
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Row(
//             children: [
//               Icon(Icons.emoji_events, color: Colors.amber, size: 28),
//               SizedBox(width: 8),
//               Text('Game Complete!'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Final Scores',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               ...sortedScores.map((entry) {
//                 final profile = _userProfiles[entry.key];
//                 final displayName =
//                     profile?['username'] ??
//                     profile?['display_name'] ??
//                     _players.firstWhere(
//                       (p) => p['user_id'] == entry.key,
//                       orElse: () => {'display_name': 'Player'},
//                     )['display_name'] ??
//                     'Player';
//                 final isWinner = entry.key == winnerUserId;
//                 final isMe = entry.key == _currentUserId;

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Row(
//                     children: [
//                       if (isWinner)
//                         const Icon(
//                           Icons.emoji_events,
//                           color: Colors.amber,
//                           size: 20,
//                         )
//                       else
//                         const SizedBox(width: 20),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           isMe ? '$displayName (You)' : displayName,
//                           style: TextStyle(
//                             fontWeight: isWinner
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         '${entry.value} pts',
//                         style: TextStyle(
//                           fontWeight: isWinner
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                           color: isWinner ? Colors.amber : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ],
//           ),
//           actions: [
//             FilledButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//                 // Navigate to trivia home screen
//                 if (mounted) {
//                   clearAndNavigate(Routes.triviaGroupLobby.name);
//                 }
//               },
//               child: const Text('Back to Home'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Future<void> _onAnswer(int optionIndex) async {
//     if (_showExplanation || !mounted) return;

//     // Check if question is locked or user has already answered
//     if (_questionLocked || _playersWhoAnswered.contains(_currentUserId)) {
//       return;
//     }

//     if (_isTurnBased && _players.isNotEmpty) {
//       final myIndex = _players.indexWhere(
//         (p) => p['user_id'] == _currentUserId,
//       );
//       if (myIndex != _turnIndex) return; // Not my turn
//     }

//     final question = _isBonusQuestion ? _bonusQuestion! : _questions[_questionIndex];
//     final selectedOption = question.options[optionIndex];
//     final isCorrect =
//         selectedOption.trim().toLowerCase() ==
//         question.answer.trim().toLowerCase();

//     final points = _difficulty == 'easy'
//         ? 10
//         : _difficulty == 'medium'
//         ? 20
//         : 30;

//     // For bonus questions, award original points + bonus
//     final bonusPoints = _isBonusQuestion ? 5 : 0;
//     final totalPoints = isCorrect ? points + bonusPoints : 0;

//     try {
//       await _service.submitAnswer(
//         roomCode: _roomId!,
//         userId: _currentUserId ?? 'anon',
//         questionId: question.id,
//         isCorrect: isCorrect,
//         pointsAwarded: totalPoints,
//       );
//     } catch (e) {
//       logger.e('Failed to submit answer: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit answer: ${e.toString()}')),
//         );
//       }
//       // Continue with UI updates even if submission fails
//     }

//     // If this is a bonus question, we need to handle the transition differently
//     if (_isBonusQuestion) {
//       // Immediately lock question and track this user's answer
//       setState(() {
//         _currentUserSelectedOption =
//             optionIndex; // Store current user's selection
//         _selectedOptionIndex = optionIndex;
//         _showExplanation = true;
//         _questionLocked = true;
//         _playersWhoAnswered.add(_currentUserId ?? '');
//         _currentUserAnswered = true; // Mark that current user answered
//       });

//       // Notify other players that someone answered with the selected option
//       await _service.sendAction(
//         channel: _gameChannel!,
//         action: {
//           'type': 'player_answered',
//           'user_id': _currentUserId,
//           'question_index': _questionIndex,
//           'selected_option': optionIndex, // Send the selected option index
//         },
//       );

//       // Broadcast reveal to all players
//       await _service.sendAction(
//         channel: _gameChannel!,
//         action: {'type': 'reveal', 'question_index': _questionIndex},
//       );

//       // Start 8-second timer for this player (in case we don't receive our own broadcast)
//       // The onAction callback will check _showExplanation to prevent duplicate timers
//       Future.delayed(const Duration(seconds: 8), () {
//         if (mounted && !_gameFinished && _showExplanation) {
//           // After bonus question, go back to regular question flow
//           setState(() {
//             _isBonusQuestion = false;
//             _showBonusAcceptance = false;
//           });

//           // Advance to the next question in the regular flow
//           _nextQuestion();
//         }
//       });
//     } else {
//       // Regular question flow
//       final isIncorrect = !isCorrect;

//       // Immediately lock question and track this user's answer
//       setState(() {
//         _currentUserSelectedOption =
//             optionIndex; // Store current user's selection
//         _selectedOptionIndex = optionIndex;
//         _showExplanation = true;
//         _questionLocked = true;
//         _playersWhoAnswered.add(_currentUserId ?? '');
//         _currentUserAnswered = true; // Mark that current user answered
//       });

//       // If the current player answered incorrectly, offer bonus question to opponent
//       if (isIncorrect && _isTurnBased && _players.length > 1) {
//         // Find the opponent (the other player)
//         final opponent = _players.firstWhere(
//           (p) => p['user_id'] != _currentUserId,
//           orElse: () => _players[0], // Fallback if no other player
//         );

//         if (opponent['user_id'] != _currentUserId) {
//           // Send bonus question to opponent with 10-second acceptance timer
//           await _service.sendAction(
//             channel: _gameChannel!,
//             action: {
//               'type': 'bonus_question',
//               'question': question.toJson(), // Send the question data
//               'opponent_id': opponent['user_id'],
//               'current_player_id': _currentUserId,
//             },
//           );
//         }
//       }

//       // Notify other players that someone answered with the selected option
//       await _service.sendAction(
//         channel: _gameChannel!,
//         action: {
//           'type': 'player_answered',
//           'user_id': _currentUserId,
//           'question_index': _questionIndex,
//           'selected_option': optionIndex, // Send the selected option index
//         },
//       );

//       // Broadcast reveal to all players
//       await _service.sendAction(
//         channel: _gameChannel!,
//         action: {'type': 'reveal', 'question_index': _questionIndex},
//       );

//       // Start 8-second timer for this player (in case we don't receive our own broadcast)
//       // The onAction callback will check _showExplanation to prevent duplicate timers
//       Future.delayed(const Duration(seconds: 8), () {
//         if (mounted && !_gameFinished && _showExplanation) {
//           _nextQuestion();
//         }
//       });
//     }
//   }

//   Color _getTimerColor() {
//     if (_secondsLeft > 20) return Colors.green;
//     if (_secondsLeft > 10) return Colors.orange;
//     return Colors.red;
//   }

//   Future<void> _onGetClue() async {
//     if (_hintUsed || _showExplanation || !mounted) return;

//     // Check if it's user's turn
//     if (_isTurnBased && _players.isNotEmpty) {
//       final myIndex = _players.indexWhere(
//         (p) => p['user_id'] == _currentUserId,
//       );
//       if (myIndex != _turnIndex) return; // Not my turn
//     }

//     // Calculate penalty points based on difficulty
//     final penaltyPoints = _difficulty == 'easy'
//         ? 3
//         : _difficulty == 'medium'
//         ? 6
//         : 9;

//     // Show confirmation dialog with point deduction information
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.lightbulb, color: Colors.amber),
//             SizedBox(width: 8),
//             Text('Use Hint?'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Using a hint will help you answer the question but will deduct points from your score.',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.amber.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.amber.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.amber.shade700),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: RichText(
//                       text: TextSpan(
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: Colors.amber.shade800,
//                         ),
//                         children: [
//                           const TextSpan(
//                             text: 'Points to be deducted: ',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           TextSpan(
//                             text: '-$penaltyPoints pts',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                           const TextSpan(
//                             text: '\n\nDifficulty: ',
//                           ),
//                           TextSpan(
//                             text: _difficulty.toUpperCase(),
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Use Hint'),
//           ),
//         ],
//       ),
//     );

//     // If user didn't confirm, return
//     if (confirmed != true) return;

//     setState(() {
//       _hintUsed = true;
//     });

//     // Record hint usage in database
//     try {
//       final question = _questions[_questionIndex];
//       await _service.recordHintUsage(
//         roomCode: _roomId!,
//         userId: _currentUserId ?? 'anon',
//         questionId: question.id,
//         penaltyPoints: penaltyPoints,
//       );

//       // Directly update player score to deduct penalty (without creating an answer record)
//       // This uses the trivia_update_player_score RPC function
//       try {
//         await _service.supabaseProvider.supabase.rpc(
//           'trivia_update_player_score',
//           params: {
//             'p_room_id': _roomId!,
//             'p_user_id': _currentUserId ?? 'anon',
//             'p_points': -penaltyPoints,
//           },
//         );
//       } catch (e) {
//         logger.e('Failed to update score for hint: $e');
//       }

//       // Refresh scores to reflect penalty
//       final scores = await _service.fetchRoomScores(_roomId!);
//       if (mounted) {
//         setState(() => _scores = scores);
//       }
//     } catch (e) {
//       print('Failed to record hint usage: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to use hint: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   int _getHintPenalty() {
//     return _difficulty == 'easy'
//         ? 3
//         : _difficulty == 'medium'
//         ? 6
//         : 9;
//   }

//   String _getRandomIslamicFact() {
//     const facts = [
//       "The Quran was revealed over a period of 23 years to Prophet Muhammad (peace be upon him).",
//       "The first word revealed in the Quran was 'Iqra' (Read) in Surah Al-Alaq, verse 1.",
//       "There are 114 chapters (Surahs) in the Quran, with 6,236 verses (Ayahs).",
//       "The longest Surah in the Quran is Al-Baqarah with 286 verses.",
//       "The shortest Surah in the Quran is Al-Kawthar with only 3 verses.",
//       "The word 'Quran' appears 70 times in the Quran itself.",
//       "Prophet Muhammad (peace be upon him) received his first revelation in the Cave of Hira.",
//       "The Quran was memorized and preserved by the Companions during the Prophet's lifetime.",
//       "The first Surah of the Quran is Al-Fatiha, known as the 'Opening'.",
//       "The Quran mentions 25 prophets by name, including Adam, Noah, Abraham, Moses, Jesus, and Muhammad (peace be upon them all).",
//       "The word 'Islam' appears 14 times in the Quran.",
//       "The Quran was revealed in Arabic, and it is considered the literal word of God in Islamic belief.",
//       "The last Surah of the Quran is An-Nas, which along with Surah Al-Falaq, is known as 'Al-Mu'awwidhatayn'.",
//       "The Quran was compiled into a book during the time of Caliph Abu Bakr (may Allah be pleased with him).",
//       "The Quran has been preserved in its original form for over 1400 years.",
//     ];

//     // Use a simple hash of current time to get a pseudo-random fact
//     final randomIndex = DateTime.now().millisecondsSinceEpoch % facts.length;
//     return facts[randomIndex];
//   }

//   Future<bool> _onWillPop() async {
//     final result = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Exit Game?'),
//         content: const Text(
//           'Are you sure you want to leave the game? Other players will be notified that you have left.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Stay'),
//           ),
//           FilledButton(
//             onPressed: () async {
//               // Notify other players that this player has left
//               try {
//                 await _service.sendAction(
//                   channel: _gameChannel!,
//                   action: {
//                     'type': 'player_left',
//                     'user_id': _currentUserId,
//                     'display_name':
//                         _userProfiles[_currentUserId]?['username'] ??
//                         _userProfiles[_currentUserId]?['display_name'] ??
//                         'A player',
//                   },
//                 );
//               } catch (e) {
//                 // Continue with exit even if notification fails
//                 print('Failed to notify players of exit: $e');
//               }

//               // Close dialog first
//               Navigator.of(context).pop(true);

//               // Navigate to trivia home screen
//               if (mounted) {
//                 // remove until trivia home
//                 clearAndNavigate(Routes.triviaGroupLobby.name);
//               }
//             },
//             style: FilledButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Exit Game'),
//           ),
//         ],
//       ),
//     );

//     return result ?? false;
//   }

//   void clearAndNavigate(String path) {
//     while (context.canPop() == true) {
//       context.pop();
//     }
//     context.pushReplacement(path);
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _bonusTimer?.cancel();
//     _gameChannel?.unsubscribe();
//     _playersChannel?.unsubscribe();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(body: TriviaLoadingScreen());
//     }

//     if (_questions.isEmpty) {
//       return WillPopScope(
//         onWillPop: _onWillPop,
//         child: Scaffold(
//           appBar: AppBar(title: const Text('Group Game')),
//           body: const Center(child: Text('No questions available')),
//         ),
//       );
//     }

//     final question = _questions[_questionIndex];

//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: AppBarScaffold(
//         pageTitle: 'Group Game',
//         appBarActions: [
//           IconButton(
//             onPressed: () async {
//               if (_roomId != null) {
//                 await _service.updateRoomProgress(
//                   roomCode: _roomId!,
//                   currentQuestionIndex: _questionIndex,
//                   currentTurnIndex: _turnIndex,
//                 );
//               }
//             },
//             icon: const Icon(Icons.sync),
//             tooltip: 'Sync',
//           ),
//         ],
//         child: TriviaBackground(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Players Section
//                 _PlayersSection(
//                   players: _players,
//                   scores: _scores,
//                   currentUserId: _currentUserId,
//                   turnIndex: _turnIndex,
//                   isTurnBased: _isTurnBased,
//                   userProfiles: _userProfiles,
//                 ),

//                 const SizedBox(height: 16),

//                 // Game Info
//                 _GameInfoSection(
//                   questionIndex: _questionIndex,
//                   totalQuestions: _questions.length,
//                   secondsLeft: _secondsLeft,
//                   timerColor: _getTimerColor(),
//                 ),

//                 const SizedBox(height: 20),

//                 // Show opponent view when it's not the current player's turn and someone else is answering
//                 if (_isTurnBased &&
//                     _players.isNotEmpty &&
//                     _currentUserId != null &&
//                     _players.indexWhere((p) => p['user_id'] == _currentUserId) != _turnIndex &&
//                     !_playersWhoAnswered.contains(_currentUserId))
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     margin: const EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.blue.shade200),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.person_search,
//                               color: Colors.blue.shade600,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 'Your opponent is answering a question...',
//                                 style: Theme.of(context).textTheme.bodySmall
//                                     ?.copyWith(
//                                       color: Colors.blue.shade700,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.blue.shade100),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.lightbulb_outline,
//                                 color: Colors.amber.shade700,
//                                 size: 16,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   _getRandomIslamicFact(),
//                                   style: Theme.of(context).textTheme.bodySmall
//                                       ?.copyWith(
//                                         color: Colors.amber.shade800,
//                                         fontStyle: FontStyle.italic,
//                                       ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 // Show locked status when someone else answered
//                 else if (_questionLocked &&
//                     !_playersWhoAnswered.contains(_currentUserId))
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     margin: const EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.orange.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.lock,
//                           color: Colors.orange.shade600,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             'Another player has answered. Waiting for the explanation...',
//                             style: Theme.of(context).textTheme.bodySmall
//                                 ?.copyWith(
//                                   color: Colors.orange.shade700,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 // Question Section (only show when it's the current player's turn)
//                 else
//                   Column(
//                     children: [
//                       // Question Section
//                       TriviaQuestionSection(question: question.question),

//                       const SizedBox(height: 20),

//                       // Options Section
//                       TriviaOptionsSection(
//                         options: question.options,
//                         selectedOptionIndex:
//                             _selectedOptionIndex, // Show whoever answered (current user or other player)
//                         correctOptionIndex: _showExplanation
//                             ? question.options.indexWhere(
//                                 (option) =>
//                                     option.trim().toLowerCase() ==
//                                     question.answer.trim().toLowerCase(),
//                               )
//                             : null,
//                         showExplanation:
//                             _showExplanation ||
//                             _questionLocked ||
//                             _playersWhoAnswered.contains(_currentUserId),
//                         onAnswer: _onAnswer,
//                       ),

//                       // Hint Section
//                       TriviaHintSection(
//                         hint: question.hint,
//                         hintUsed: _hintUsed,
//                         penaltyPoints: _getHintPenalty(),
//                         onGetClue: _onGetClue,
//                         disabled:
//                             _showExplanation ||
//                             _questionLocked ||
//                             _playersWhoAnswered.contains(_currentUserId),
//                       ),
//                     ],
//                   ),

//                 // Bonus Question Acceptance UI
//                 if (_showBonusAcceptance && _bonusQuestion != null)
//                   Container(
//                     margin: const EdgeInsets.only(top: 16),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.amber.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.amber.shade200),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.star_rounded,
//                               color: Colors.amber.shade700,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Bonus Question!',
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.amber.shade800,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'The opponent answered incorrectly. You have a chance to earn bonus points!',
//                           style: Theme.of(context).textTheme.bodyMedium
//                               ?.copyWith(
//                             color: Colors.amber.shade700,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.amber.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.amber.shade300),
//                           ),
//                           child: Text(
//                             'You have 10 seconds to accept this bonus question',
//                             style: Theme.of(context).textTheme.bodySmall
//                                 ?.copyWith(
//                               color: Colors.amber.shade800,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           'Question: ${_bonusQuestion!.question}',
//                           style: Theme.of(context).textTheme.bodyMedium
//                               ?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: Colors.amber.shade900,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Expanded(
//                               child: FilledButton.icon(
//                                 onPressed: () {
//                                   // Accept bonus question
//                                   setState(() {
//                                     _isBonusQuestion = true;
//                                     _showBonusAcceptance = false;
//                                     _questionIndex = _questionIndex; // Keep same index for bonus
//                                     _selectedOptionIndex = null;
//                                     _showExplanation = false;
//                                     _playersWhoAnswered.clear();
//                                     _questionLocked = false;
//                                     _hintUsed = false;
//                                     _playerAnswers.clear();
//                                     _currentUserAnswered = false;
//                                     _currentUserSelectedOption = null;
//                                   });

//                                   // Restart timer for bonus question
//                                   _restartTimer();

//                                   // Update turn to current player since they accepted the bonus question
//                                   if (_isTurnBased && _players.isNotEmpty) {
//                                     final myIndex = _players.indexWhere(
//                                       (p) => p['user_id'] == _currentUserId,
//                                     );
//                                     if (mounted) {
//                                       setState(() {
//                                         _turnIndex = myIndex;
//                                       });
//                                     }
//                                   }
//                                 },
//                                 icon: const Icon(Icons.check),
//                                 label: const Text('Accept'),
//                                 style: FilledButton.styleFrom(
//                                   backgroundColor: Colors.green,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: OutlinedButton.icon(
//                                 onPressed: () {
//                                   // Decline bonus question
//                                   setState(() {
//                                     _isBonusQuestionAvailable = false;
//                                     _showBonusAcceptance = false;
//                                   });

//                                   // Advance to the next question in the regular flow since bonus was declined
//                                   _nextQuestion();
//                                 },
//                                 icon: const Icon(Icons.close),
//                                 label: const Text('Decline'),
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor: Colors.red,
//                                   side: BorderSide(color: Colors.red),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   )
//                 // Next Question Button (only for answering player) - Below hint section
//                 else if (_showExplanation && _currentUserAnswered && !_gameFinished)
//                   TriviaSkipButton(onSkip: _nextQuestion),

//                 // Explanation Section (only for current user if they answered)
//                 if (_showExplanation && _currentUserAnswered)
//                   TriviaExplanationSection(
//                     explanation: question.context,
//                     funFact: question.funFact,
//                     isCorrect:
//                         _currentUserSelectedOption != null &&
//                         question.options[_currentUserSelectedOption!]
//                                 .trim()
//                                 .toLowerCase() ==
//                             question.answer.trim().toLowerCase(),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _PlayersSection extends StatelessWidget {
//   final List<Map<String, dynamic>> players;
//   final Map<String, int> scores;
//   final String? currentUserId;
//   final int turnIndex;
//   final bool isTurnBased;
//   final Map<String, Map<String, dynamic>> userProfiles;

//   const _PlayersSection({
//     required this.players,
//     required this.scores,
//     required this.currentUserId,
//     required this.turnIndex,
//     required this.isTurnBased,
//     required this.userProfiles,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 60,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: players.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 6),
//         itemBuilder: (_, index) {
//           final player = players[index];
//           final userId = player['user_id'] as String;
//           final isMyTurn = isTurnBased && index == turnIndex;
//           final score = scores[userId] ?? 0;
//           final isMe = userId == currentUserId;

//           // Get display name from profile or fallback to room display_name
//           final profile = userProfiles[userId];
//           final displayName =
//               profile?['username'] ??
//               profile?['display_name'] ??
//               player['display_name']?.toString() ??
//               'Player';

//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 4),
//             elevation: isMyTurn ? 3 : 1,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             color: isMyTurn
//                 ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
//                 : Theme.of(context).colorScheme.surface,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: isMe
//                           ? Theme.of(context).colorScheme.primary
//                           : isMyTurn
//                           ? Theme.of(context).colorScheme.secondary
//                           : Theme.of(
//                               context,
//                             ).colorScheme.outline.withOpacity(0.6),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       isMe ? Icons.person : Icons.person_outline,
//                       size: 12,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         displayName,
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: isMyTurn
//                               ? Theme.of(context).colorScheme.primary
//                               : Theme.of(context).colorScheme.onSurface,
//                         ),
//                       ),
//                       const SizedBox(height: 0),
//                       Text(
//                         isMyTurn && isMe
//                             ? 'Your Turn'
//                             : isMyTurn
//                             ? 'Playing'
//                             : 'Waiting',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           fontSize: 10,
//                           color: isMyTurn
//                               ? Theme.of(context).colorScheme.primary
//                               : Theme.of(context).colorScheme.onSurfaceVariant,
//                           fontWeight: isMyTurn
//                               ? FontWeight.w600
//                               : FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 6),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 6,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.star_rounded,
//                           size: 12,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                         const SizedBox(width: 2),
//                         Text(
//                           '$score',
//                           style: Theme.of(context).textTheme.bodySmall
//                               ?.copyWith(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w700,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _GameInfoSection extends StatelessWidget {
//   final int questionIndex;
//   final int totalQuestions;
//   final int secondsLeft;
//   final Color timerColor;

//   const _GameInfoSection({
//     required this.questionIndex,
//     required this.totalQuestions,
//     required this.secondsLeft,
//     required this.timerColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.primaryContainer.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.question_answer,
//                     size: 16,
//                     color: Theme.of(context).colorScheme.onPrimaryContainer,
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Q${questionIndex + 1}/$totalQuestions',
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).colorScheme.onPrimaryContainer,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: timerColor.withOpacity(0.1),
//                 shape: BoxShape.circle,
//                 border: Border.all(color: timerColor, width: 2),
//               ),
//               child: Center(
//                 child: Text(
//                   '$secondsLeft',
//                   style: TextStyle(
//                     color: timerColor,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }