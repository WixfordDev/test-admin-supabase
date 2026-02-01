import 'dart:async';

import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/trivia/data/services/trivia_service.dart';
import 'package:deenhub/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:deenhub/features/subscription/data/services/subscription_service.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class TriviaGroupLobbyScreen extends StatefulWidget {
  final Map<String, String> queryParams;
  const TriviaGroupLobbyScreen({super.key, required this.queryParams});

  @override
  State<TriviaGroupLobbyScreen> createState() => _TriviaGroupLobbyScreenState();
}

class _TriviaGroupLobbyScreenState extends State<TriviaGroupLobbyScreen> {
  late TriviaService _service;
  late SharedPrefsHelper _sharedPrefs;
  String? _roomId; // This will be the short code for display
  // ignore: unused_field
  String? _fullRoomId; // This will be the full UUID for subscriptions (stored for future use)
  Map<String, dynamic>? _roomData; // Store room data for host identification
  String _difficulty = 'easy';
  int _maxPlayers = 4;
  int _questionCount = 10;
  bool _isHost = true;
  final TextEditingController _joinController = TextEditingController();
  final FocusNode _joinFocusNode = FocusNode();
  RealtimeChannel? _channel;
  RealtimeChannel? _playersChannel;
  Map<String, dynamic> _roomState = {'players': []};
  bool _isLoading = false;
  bool? _isPremiumUser;
  String _gameUsername = '';
  String? _currentUserId;
  List<Map<String, dynamic>> _currentPlayers = [];
  bool _playersLoaded = false;
  String? _pendingJoinRoomCode; // Track room code to auto-join

  final List<Map<String, dynamic>> _difficultyLevels = [
    {
      'value': 'easy',
      'label': 'Easy',
      'description': 'Perfect for beginners',
      'points': '10 pts per question',
      'color': Colors.green,
      'icon': Icons.sentiment_satisfied,
    },
    {
      'value': 'medium',
      'label': 'Medium',
      'description': 'Test your knowledge',
      'points': '20 pts per question',
      'color': Colors.orange,
      'icon': Icons.sentiment_neutral,
    },
    {
      'value': 'hard',
      'label': 'Hard',
      'description': 'Challenge yourself',
      'points': '30 pts per question',
      'color': Colors.red,
      'icon': Icons.sentiment_dissatisfied,
    },
  ];

  @override
  void initState() {
    super.initState();
    _service = getIt<TriviaService>();
    _sharedPrefs = getIt<SharedPrefsHelper>();
    _currentUserId = _service.supabaseProvider.supabase.auth.currentUser?.id;
    
    // Check if we have a room code to auto-join from query parameters
    final joinRoomCode = widget.queryParams['joinRoomCode'];
    if (joinRoomCode != null && joinRoomCode.isNotEmpty) {
      _pendingJoinRoomCode = joinRoomCode;
      _joinController.text = joinRoomCode;
    }
    
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    if (_isUserLoggedIn() && _currentUserId != null) {
      _isPremiumUser = await SubscriptionService.hasActiveSubscription();

      // Try to load username from local storage first
      _gameUsername = _sharedPrefs.triviaUsername ?? '';

      // If no local username, try to get from database or create profile
      if (_gameUsername.isEmpty) {
        try {
          final profile = await _service.getOrCreateUserProfile(
            userId: _currentUserId!,
            email: _service.supabaseProvider.supabase.auth.currentUser?.email,
          );
          _gameUsername = profile['username'] ?? '';

          // Save to local storage for future use
          if (_gameUsername.isNotEmpty) {
            _sharedPrefs.setTriviaUsername = _gameUsername;
          }
        } catch (e) {
          // Fallback to email prefix
          final user = _service.supabaseProvider.supabase.auth.currentUser;
          _gameUsername = user?.email?.split('@')[0] ?? 'Player';
        }
      }

      if (mounted) setState(() {});
      
      // If we have a pending room code to join, trigger the join after initialization
      if (_pendingJoinRoomCode != null && mounted) {
        // Small delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _pendingJoinRoomCode != null) {
            _joinGame();
          }
        });
      }
    }
  }

  String? _getUserId() {
    // Get authenticated user ID - login required for trivia
    final authUserId = _service.supabaseProvider.supabase.auth.currentUser?.id;
    return authUserId;
  }

  bool _isUserLoggedIn() {
    return _service.supabaseProvider.supabase.auth.currentUser != null;
  }

  VoidCallback? _getHostButtonAction() {
    if (!_isUserLoggedIn()) {
      return () => context.pushNamed(Routes.login.name);
    }
    if (_isPremiumUser == false) {
      return () => context.pushNamed(Routes.subscription.name);
    }
    return _hostGame;
  }

  IconData _getHostButtonIcon() {
    if (!_isUserLoggedIn()) return Icons.login;
    if (_isPremiumUser == false) return Icons.workspace_premium;
    return Icons.play_circle_filled_rounded;
  }

  String _getHostButtonText() {
    if (_isLoading) return 'Creating Room...';
    if (!_isUserLoggedIn()) return 'Login to Host Game';
    if (_isPremiumUser == false) return 'Upgrade to Premium';
    return 'Host Game (Premium)';
  }

  Future<void> _hostGame() async {
    setState(() => _isLoading = true);
    try {
      // Check if user is logged in
      if (!_isUserLoggedIn()) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        context.pushNamed(Routes.login.name);
        return;
      }

      final isPro = await SubscriptionService.hasActiveSubscription();
      if (!isPro) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        context.pushNamed(Routes.subscription.name);
        return;
      }

      final userId = _getUserId();
      if (userId == null) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required. Please login.')),
        );
        return;
      }

      final data = await _service.createRoom(
        hostUserId: userId,
        difficulty: _difficulty,
        maxPlayers: _maxPlayers,
      );
      final fullRoomId = data['id'].toString().toLowerCase();
      final shortCode = data['short_code'] as String? ?? fullRoomId.substring(0, 6);

      // Update host's display name in the room
      final actualDisplayName = _gameUsername.isNotEmpty ? _gameUsername : 'Host';
      await _service.joinRoom(
        roomCode: fullRoomId,
        userId: userId,
        displayName: actualDisplayName,
      );
      // Initialize player list - wait a moment for database consistency
      await Future.delayed(const Duration(milliseconds: 500));
      final initialPlayers = await _service.getRoomPlayers(fullRoomId);
      print('Host: Room $fullRoomId has ${initialPlayers.length} players initially: ${initialPlayers.map((p) => p['display_name']).toList()}');

      // Ensure current user is in the player list
      final isUserInRoom = initialPlayers.any((p) => p['user_id'] == userId);
      if (!isUserInRoom) {
        print('Host: Current user not found in player list, re-joining room');
        await _service.joinRoom(
          roomCode: fullRoomId,
          userId: userId,
          displayName: actualDisplayName,
        );
        // Refresh player list after re-joining
        await Future.delayed(const Duration(milliseconds: 300));
        final refreshedPlayers = await _service.getRoomPlayers(fullRoomId);
        initialPlayers.clear();
        initialPlayers.addAll(refreshedPlayers);
        print('Host: After re-join, room has ${refreshedPlayers.length} players: ${refreshedPlayers.map((p) => p['display_name']).toList()}');
      }

      setState(() {
        _roomId = shortCode; // Use short code for display
        _fullRoomId = fullRoomId; // Store full UUID for subscriptions
        _roomData = data; // Store room data for host identification
        _isHost = true;
        _isLoading = false;
        _currentPlayers = initialPlayers;
        _playersLoaded = true;
      });
      _subscribe(fullRoomId); // Subscribe using full UUID
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating room: $e')));
    }
  }

  Future<void> _joinGame() async {
    final roomIdInput = _joinController.text.trim();
    if (roomIdInput.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a room code.')),
        );
      }
      // Clear pending join code if empty
      _pendingJoinRoomCode = null;
      return; 
    } 

    // Convert room code to lowercase for case-insensitive matching
    final roomCode = roomIdInput.toLowerCase();

    setState(() => _isLoading = true);
    try {
      // Check if user is logged in
      if (!_isUserLoggedIn()) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        context.pushNamed(Routes.login.name);
        return;
      }

      final userId = _getUserId();
      if (userId == null) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required. Please login.')),
        );
        return;
      }

      // Resolve room code to full UUID
      final fullRoomId = await _service.resolveRoomId(roomCode);
      if (fullRoomId == null) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room not found. Please check the room code and try again.')),
        );
        return;
      }

      // Validate that the room exists before trying to join
      final roomData = await _service.getRoom(fullRoomId);
      if (roomData.isEmpty) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room not found. Please check the room code and try again.')),
        );
        return;
      }

      // Check if room is in a joinable state
      final roomStatus = roomData['status'] as String?;
      if (roomStatus == 'finished') {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This game has already finished.')),
        );
        return;
      }

      // If room is already active, navigate to game screen immediately
      if (roomStatus == 'active') {
        logger.i('Room is already active, navigating directly to game screen');
        setState(() => _isLoading = false);
        if (!mounted) return;
        context.pushNamed(
          Routes.triviaGroupGame.name,
          queryParameters: {
            'roomId': roomCode, // Pass the original room code for display
            'difficulty': roomData['difficulty'] as String? ?? 'easy',
          },
        );
        return;
      }

      // Check if room is full
      final currentPlayers = await _service.getRoomPlayers(fullRoomId);
      final maxPlayers = roomData['max_players'] as int? ?? 4;
      if (currentPlayers.length >= maxPlayers) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This room is full. Try joining another room.')),
        );
        return;
      }

      // User successfully authenticated and room validated

      // Generate a unique display name for the player
      String displayName;
      if (_gameUsername.isNotEmpty) {
        displayName = _gameUsername;
      } else {
        // Get current players to determine the next available player number
        final currentPlayers = await _service.getRoomPlayers(fullRoomId);
        int playerNumber = 2; // Start from 2 since host is Player 1
        while (currentPlayers.any((p) => p['display_name'] == 'Player $playerNumber')) {
          playerNumber++;
        }
        displayName = 'Player $playerNumber';
      }

      await _service.joinRoom(
        roomCode: fullRoomId,
        userId: userId,
        displayName: displayName,
      );
      // Initialize player list - wait for database consistency and retry if needed
      await Future.delayed(const Duration(milliseconds: 500));

      // Try to load players multipl e times to handle timing issues
      List<Map<String, dynamic>> initialPlayers = [];
      int attempts = 0;
      const maxAttempts = 3;

      while (attempts < maxAttempts && initialPlayers.isEmpty) {
        initialPlayers = await _service.getRoomPlayers(fullRoomId);
        print('Join: Room $fullRoomId has ${initialPlayers.length} players (attempt ${attempts + 1}): ${initialPlayers.map((p) => p['display_name']).toList()}');

        if (initialPlayers.isEmpty) {
          attempts++;
          if (attempts < maxAttempts) {
            await Future.delayed(const Duration(milliseconds: 500));
            print('Retrying player load for room $fullRoomId');
          }
        } else {
          print('Successfully loaded ${initialPlayers.length} players on attempt ${attempts + 1}');
        }
      }

      // Debug: Check if current user should be in the list
      if (!initialPlayers.any((p) => p['user_id'] == userId)) {
        print('Warning: Current user $userId not found in initial players list');
      }

      // Ensure current user is in the player list
      final isUserInRoom = initialPlayers.any((p) => p['user_id'] == userId);
      if (!isUserInRoom && attempts < maxAttempts) {
        print('Join: Current user not found in player list, re-joining room');
        await _service.joinRoom(
          roomCode: fullRoomId,
          userId: userId,
          displayName: displayName,
        );
        // Refresh player list after re-joining
        await Future.delayed(const Duration(milliseconds: 500));
        final refreshedPlayers = await _service.getRoomPlayers(fullRoomId);
        initialPlayers.clear();
        initialPlayers.addAll(refreshedPlayers);
        print('Join: After re-join, room has ${refreshedPlayers.length} players: ${refreshedPlayers.map((p) => p['display_name']).toList()}');
      }
 
      // Check current room status after joining
      final currentRoomData = await _service.getRoom(fullRoomId);
      final currentRoomStatus = currentRoomData['status'] as String?;

      // Get room data for host identification
      final roomDataForDisplay = await _service.getRoom(fullRoomId);

      setState(() {
        _roomId = roomCode; // Use the original room code for display
        _fullRoomId = fullRoomId; // Store full UUID for subscriptions
        _roomData = roomDataForDisplay; // Store room data for host identification
        _isHost = false;
        _isLoading = false;
        _currentPlayers = initialPlayers;
        _playersLoaded = true;
        _pendingJoinRoomCode = null; // Clear pending join code after successful join
      });

      // If room is already active, navigate to game screen immediately
      if (currentRoomStatus == 'active') {
        logger.i('Room became active after joining, navigating to game screen');
        if (!mounted) return;
        context.pushNamed(
          Routes.triviaGroupGame.name,
          queryParameters: {
            'roomId': roomCode,
            'difficulty': currentRoomData['difficulty'] as String? ?? 'easy',
          },
        );
        return;
      }

      _subscribe(fullRoomId); // Subscribe using the resolved UUID

      // Force an initial refresh after subscription is set up
      Future.delayed(const Duration(milliseconds: 1000), () async {
        if (mounted && !_isHost) {
          print('Forcing initial player list refresh for room: $fullRoomId');
          final players = await _service.getRoomPlayers(fullRoomId);
          if (mounted) {
            setState(() {
              _currentPlayers = players;
              _playersLoaded = true;
              print('Initial refresh loaded ${players.length} players');
            });
          }
        }
      });
    } catch (e) {
      logger.e(e);
      setState(() {
        _isLoading = false;
        _pendingJoinRoomCode = null; // Clear pending join code on error
      });
      if (!mounted) return;

      // Provide user-friendly error messages without technical details
      String errorMessage;
      if (e.toString().contains('violates foreign key constraint')) {
        errorMessage = 'Room not found. Please check the room code and try again.';
      } else if (e.toString().contains('duplicate key value')) {
        errorMessage = 'You are already in this room.';
      } else if (e.toString().contains('connection') || e.toString().contains('network')) {
        errorMessage = 'Connection error. Please check your internet connection and try again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      } else {
        errorMessage = 'Failed to join room. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }


  Future<void> _subscribe(String roomId) async {
    _channel?.unsubscribe();
    _channel = await _service.subscribeToRoom(
      roomId,
      onBroadcast: (payload) {
        if (!mounted) return;

        // Debug logging for real-time updates
        logger.i('Received broadcast: $payload');
        logger.i('Current isHost: $_isHost, roomId: $_roomId');

        setState(() {
          _roomState = payload;
        });

        // Handle game start - navigate to game screen when status becomes active
        final status = payload['status'] as String?;
        logger.i('Room status changed to: $status');

        if (status == 'active' && !_isHost) {
          logger.i('Non-host player navigating to game screen');
          // Clean up lobby subscriptions before navigating
          _channel?.unsubscribe();
          _playersChannel?.unsubscribe();
          _channel = null;
          _playersChannel = null;

          // Small delay to ensure state is updated before navigation
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _roomId != null) {
              logger.i('Navigating to game screen with roomId: $_roomId');
              context.pushNamed(
                Routes.triviaGroupGame.name,
                queryParameters: {
                  'roomId': _roomId!,
                  'difficulty': _difficulty,
                },
              );
            }
          });
        }

        // Handle player left notifications
        if (payload['type'] == 'player_left_lobby') {
          final displayName = payload['display_name'] ?? 'A player';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$displayName has left the room'),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
    _playersChannel?.unsubscribe();
    _playersChannel = await _service.subscribeToRoomPlayers(
      roomId,
      onChange: () async {
        if (!mounted) return;
        print('Player list subscription triggered for room: $roomId');
        final players = await _service.getRoomPlayers(roomId);
        print('Fetched ${players.length} players for room: $roomId');
        setState(() {
          _currentPlayers = players;
          _playersLoaded = true;
          _roomState = {
            ..._roomState,
            'players': players
                .map((e) => e['display_name'] ?? 'Player')
                .toList(),
          };
        });
        print('Real-time subscription updated players: ${players.length} players loaded');
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (_roomId == null) {
      // If not in a room, just allow back navigation
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Leave Room?'),
        content: const Text(
          'Are you sure you want to leave the room? Other players will be notified that you have left.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop(true);

              // Notify other players that this player has left
              try {
                if (_channel != null) {
                  await _service.sendAction(
                    channel: _channel!,
                    action: {
                      'type': 'player_left_lobby',
                      'user_id': _currentUserId,
                      'display_name': _gameUsername.isNotEmpty ? _gameUsername : 'A player',
                    },
                  );
                }
              } catch (e) {
                // Continue with exit even if notification fails
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Leave Room'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _playersChannel?.unsubscribe();
    _joinController.dispose();
    _joinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostLabel = _isHost ? 'Host' : 'Guest';
    final selectedDifficultyData = _difficultyLevels.firstWhere(
      (level) => level['value'] == _difficulty,
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: AppBarScaffold(
      pageTitle: 'Group Mode',
      appBarActions: _roomId != null
          ? [
              IconButton(
                onPressed: () => _shareRoomId(context),
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share Room Code',
              ),
            ]
          : null,
      child: KeyboardActions(
        config: _buildKeyboardActionsConfig(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),

            if (_roomId == null) ...[
              // Login Required Message (if not logged in)
              if (!_isUserLoggedIn()) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Login Required',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              'Please login to host or join trivia games',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pushNamed(Routes.login.name),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Welcome Section
              _buildWelcomeSection(context),

              const SizedBox(height: 20),

              // Host Game Section
              _buildHostGameSection(context),

              const SizedBox(height: 20),

              // Join Game Section
              _buildJoinGameSection(context),

              const SizedBox(height: 24),
            ] else ...[
              // Room Active Section
              _buildRoomActiveSection(
                context,
                hostLabel,
                selectedDifficultyData,
              ),

              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    ),
    ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.groups_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multiplayer Trivia',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Real-time Islamic knowledge battles',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostGameSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Host a New Game',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // Difficulty Selection
          _buildDifficultySection(context),

          const SizedBox(height: 16),

          // Game Settings
          _buildGameSettingsSection(context),

          const SizedBox(height: 20),

          // Host Game Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : (_getHostButtonAction()),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_getHostButtonIcon()),
              label: Text(_getHostButtonText()),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Difficulty',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: _difficultyLevels
                .map(
                  (level) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _DifficultyChip(
                        level: level,
                        isSelected: _difficulty == level['value'],
                        onTap: () =>
                            setState(() => _difficulty = level['value']),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.settings_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _CompactSettingChip(
                icon: Icons.people_rounded,
                value: '$_maxPlayers',
                onTap: () => _showMaxPlayersDialog(),
              ),
              const SizedBox(width: 8),
              _CompactSettingChip(
                icon: Icons.quiz_rounded,
                value: '$_questionCount',
                onTap: () => _showQuestionCountDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMaxPlayersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Max Players'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [2, 3, 4, 5, 6, 7, 8, 9, 10].map((num) => ListTile(
                title: Text('$num Players'),
                leading: Radio<int>(
                  value: num,
                  groupValue: _maxPlayers,
                  onChanged: (val) {
                    setState(() => _maxPlayers = val ?? 4);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() => _maxPlayers = num);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuestionCountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Number of Questions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [5, 10, 15, 20].map((num) => ListTile(
            title: Text('$num Questions'),
            leading: Radio<int>(
              value: num,
              groupValue: _questionCount,
              onChanged: (val) {
                setState(() => _questionCount = val ?? 10);
                Navigator.pop(context);
              },
            ),
            onTap: () {
              setState(() => _questionCount = num);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }


  Widget _buildJoinGameSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Or Join Existing Game',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _joinController,
                  focusNode: _joinFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Enter Room Code',
                    hintText: 'e.g., ABC123',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.meeting_room_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : (_isUserLoggedIn() ? _joinGame : () => context.pushNamed(Routes.login.name)),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_isUserLoggedIn() ? Icons.login_rounded : Icons.login),
                    label: Text(_isLoading ? 'Joining...' : (_isUserLoggedIn() ? 'Join Game' : 'Login to Join Game')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomActiveSection(
    BuildContext context,
    String hostLabel,
    Map<String, dynamic> selectedDifficultyData,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Compact Room Overview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Room Header Row
                Row(
                  children: [
                    // Room Icon and ID
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.15),
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        _isHost
                            ? Icons.workspace_premium_rounded
                            : Icons.person_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Room Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Room: ',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                              Text(
                                _roomId!,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontFamily: 'monospace',
                                      letterSpacing: 1.2,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Role: $hostLabel • ${_currentPlayers.length}/$_maxPlayers Players',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Copy Room Code Button
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _roomId!));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Room code copied to clipboard',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.copy_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      tooltip: 'Copy Room Code',
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Game Settings Row
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      // Difficulty
                      Expanded(
                        child: _CompactStatItem(
                          icon: selectedDifficultyData['icon'],
                          label: selectedDifficultyData['label'],
                          value: selectedDifficultyData['points'],
                          color: selectedDifficultyData['color'],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),

                      // Questions
                      Expanded(
                        child: _CompactStatItem(
                          icon: Icons.quiz_rounded,
                          label: 'Questions',
                          value: '$_questionCount',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),

                      // Timer
                      Expanded(
                        child: _CompactStatItem(
                          icon: Icons.timer_rounded,
                          label: 'Time',
                          value: '30s',
                          color: Colors.red.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Players List
          _buildPlayersListSection(context),

          const SizedBox(height: 20),

          // Action Button
          if (_isHost) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  if (_roomId == null) return;
                  final roomId = _roomId!;

                  logger.i('Host starting game for room: $roomId');

                  await _service.startGame(
                    roomCode: roomId,
                    difficulty: _difficulty,
                    questionCount: _questionCount,
                  );

                  final channel = await _service.subscribeToGame(roomId);
                  logger.i('Host broadcasting game start state');

                  // Small delay to ensure channel is ready
                  await Future.delayed(const Duration(milliseconds: 200));

                  await _service.broadcastRoomState(
                    channel: channel,
                    state: {
                      'status': 'active',
                      'current_question_index': 0,
                      'current_turn_index': 0,
                    },
                  );

                  // Additional delay before navigation to ensure broadcast is sent
                  await Future.delayed(const Duration(milliseconds: 100));

                  logger.i('Host navigating to game screen');
                  // Clean up lobby subscriptions before navigating
                  _channel?.unsubscribe();
                  _playersChannel?.unsubscribe();
                  _channel = null;
                  _playersChannel = null;

                  if (!mounted) return;
                  context.pushNamed(
                    Routes.triviaGroupGame.name,
                    queryParameters: {
                      'roomId': roomId,
                      'difficulty': _difficulty,
                    },
                  );
                },
                icon: const Icon(Icons.play_circle_filled_rounded),
                label: const Text('Start Game'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Waiting for host to start the game...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayersListSection(BuildContext context) {
    // Organize players: host first, then current player, then others
    final organizedPlayers = _organizePlayersForDisplay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.group_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Players in Room',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Show loading indicator if players are not loaded yet
              if (!_playersLoaded && _currentPlayers.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loading players...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Show organized players
                ...organizedPlayers.map((playerInfo) => _PlayerTile(
                  name: playerInfo['name'] as String,
                  isHost: playerInfo['isHost'] as bool,
                  isCurrentPlayer: playerInfo['isCurrentPlayer'] as bool,
                  color: playerInfo['color'] as Color,
                  isEmpty: playerInfo['isEmpty'] as bool? ?? false,
                )),

              // Empty slots (only show if players are loaded)
              if (_playersLoaded)
                for (int i = organizedPlayers.length; i < _maxPlayers; i++)
                  _PlayerTile(
                    name: 'Waiting for player...',
                    isHost: false,
                    isCurrentPlayer: false,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    isEmpty: true,
                  ),
            ],
          ),
        ),
      ],
    );
  }

  /// Organize players for display: host first, then current player, then others
  List<Map<String, dynamic>> _organizePlayersForDisplay() {
    final List<Map<String, dynamic>> organized = [];

    if (_roomData == null) return organized;

    final hostUserId = _roomData!['host_user_id'] as String?;
    final currentUserId = _currentUserId;

    // Add host first (if exists in players list)
    if (hostUserId != null) {
      final hostPlayer = _currentPlayers.where((p) => p['user_id'] == hostUserId).toList();
      if (hostPlayer.isNotEmpty) {
        organized.add({
          'name': hostPlayer.first['display_name']?.toString() ?? 'Host',
          'isHost': true,
          'isCurrentPlayer': hostUserId == currentUserId,
          'color': Colors.amber.shade600,
          'isEmpty': false,
        });
      }
    }

    // Add current player (if not host and not already added)
    if (currentUserId != null && currentUserId != hostUserId) {
      organized.add({
        'name': _gameUsername.isNotEmpty ? _gameUsername : 'You',
        'isHost': false,
        'isCurrentPlayer': true,
        'color': Theme.of(context).colorScheme.primary,
        'isEmpty': false,
      });
    }

    // Add other players (excluding host and current player)
    for (final player in _currentPlayers) {
      final playerUserId = player['user_id'] as String?;
      if (playerUserId != hostUserId && playerUserId != currentUserId) {
        organized.add({
          'name': player['display_name']?.toString() ?? 'Player',
          'isHost': false,
          'isCurrentPlayer': false,
          'color': Theme.of(context).colorScheme.onSurfaceVariant,
          'isEmpty': false,
        });
      }
    }

    return organized;
  }

  KeyboardActionsConfig _buildKeyboardActionsConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      actions: [
        // Join room input field -> shows "Close" and "Join"
        KeyboardActionsItem(
          focusNode: _joinFocusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  node.unfocus();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            (node) {
              return GestureDetector(
                onTap: () {
                  node.unfocus();
                  _joinGame();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Join",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  Future<void> _shareRoomId(BuildContext context) async {
    if (_roomId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No room to share')));
      return;
    }

    final shareText =
        '''
🎮 Join my Islamic Trivia Game!

Room Code: $_roomId

Test your knowledge of Qur'an, Hadith & Islamic history!

Download DeenHub to join: [Your App Store Link]

#IslamicTrivia #DeenHub #IslamicKnowledge
''';

    try {
      await Share.share(
        shareText,
        subject: 'Join Islamic Trivia Game - $_roomId',
      );
    } catch (e) {
      // Fallback to clipboard if share fails
      await Clipboard.setData(ClipboardData(text: _roomId!));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Share not available, room code copied to clipboard',
          ),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }
}

class _DifficultyChip extends StatelessWidget {
  final Map<String, dynamic> level;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected
                ? level['color'].withOpacity(0.12)
                : Theme.of(context).colorScheme.surface.withOpacity(0.8),
            border: Border.all(
              color: isSelected
                  ? level['color']
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  level['icon'],
                  color: isSelected
                      ? level['color']
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                level['label'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? level['color']
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSettingChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _CompactSettingChip({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CompactStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final String name;
  final bool isHost;
  final bool isCurrentPlayer;
  final Color color;
  final bool isEmpty;

  const _PlayerTile({
    required this.name,
    required this.isHost,
    required this.isCurrentPlayer,
    required this.color,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isCurrentPlayer
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface.withOpacity(0.6),
        border: Border.all(
          color: isCurrentPlayer
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEmpty ? color.withOpacity(0.1) : color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: isEmpty
                ? Icon(
                    Icons.person_add_rounded,
                    color: color.withOpacity(0.5),
                    size: 20,
                  )
                : Icon(
                    isHost
                        ? Icons.workspace_premium_rounded
                        : Icons.person_rounded,
                    color: color,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isEmpty
                              ? Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withOpacity(0.7)
                              : Theme.of(context).colorScheme.onSurface,
                          fontStyle: isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                          fontWeight: isCurrentPlayer
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isHost && !isEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade700,
                          size: 14,
                        ),
                      ),
                    ],
                  ],
                ),
                if (isCurrentPlayer) ...[
                  const SizedBox(height: 2),
                  Text(
                    'You',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
