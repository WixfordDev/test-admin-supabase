import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/remote_config/app_remote_config_helper.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/trivia/data/services/trivia_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class TriviaHomeScreen extends StatefulWidget {
  const TriviaHomeScreen({super.key});

  @override
  State<TriviaHomeScreen> createState() => _TriviaHomeScreenState();
}

class _TriviaHomeScreenState extends State<TriviaHomeScreen> {
  late AppRemoteConfigHelper _remoteConfig;
  late TriviaService _triviaService;
  final _roomCodeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _roomCodeFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  bool _isLoadingProfile = true;
  bool _hasUsername = false;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _remoteConfig = getIt<AppRemoteConfigHelper>();
    _triviaService = getIt<TriviaService>();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    _usernameController.dispose();
    _roomCodeFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = getIt<SupabaseProvider>().supabase.auth.currentUser?.id;
      if (userId != null) {
        final profile = await _triviaService.getUserProfile(userId);
        if (mounted) {
          setState(() {
            _hasUsername = profile != null;
            _currentUsername = profile?['username'] as String?;
            if (_currentUsername != null) {
              _usernameController.text = _currentUsername!;
            }
            _isLoadingProfile = false;
          });
        }
      } else {
        setState(() => _isLoadingProfile = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _setUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      _showError('Please enter a username');
      return;
    }

    if (username.length < 3) {
      _showError('Username must be at least 3 characters');
      return;
    }

    try {
      final userId = getIt<SupabaseProvider>().supabase.auth.currentUser?.id;
      if (userId == null) {
        _showError('Please sign in first');
        return;
      }

      // Check if username is available
      final isAvailable = await _triviaService.isUsernameAvailable(username);
      if (!isAvailable && username != _currentUsername) {
        _showError('Username is already taken');
        return;
      }

      // Update profile
      await _triviaService.upsertUserProfile(
        userId: userId,
        username: username,
        displayName: username,
      );

      if (mounted) {
        setState(() {
          _hasUsername = true;
          _currentUsername = username;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username saved successfully!')),
        );
      }
    } catch (e) {
      _showError('Failed to save username: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  KeyboardActionsConfig _buildKeyboardActionsConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      actions: [
        // Username input field -> shows "Close" and "Save"
        KeyboardActionsItem(
          focusNode: _usernameFocusNode,
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
                  _setUsername();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Save",
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
        // Room code input field -> shows "Close" and "Join"
        KeyboardActionsItem(
          focusNode: _roomCodeFocusNode,
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
                  _joinRoom();
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

  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text.trim();
    if (roomCode.isEmpty) {
      _showError('Please enter a room code');
      return;
    }

    if (!_hasUsername) {
      _showError('Please set your username first');
      return;
    }

    // Check if user is logged in
    final userId = getIt<SupabaseProvider>().supabase.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      context.pushNamed(Routes.login.name);
      return;
    }

    // Navigate to lobby screen with room code parameter
    // The lobby screen will handle the actual joining logic
    if (!mounted) return;
    context.pushNamed(
      Routes.triviaGroupLobby.name,
      queryParameters: {'joinRoomCode': roomCode.toLowerCase()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _remoteConfig.getTriviaConfig();
    
    // Check if feature is disabled
    if (!config.featureEnabled) {
      return AppBarScaffold(
        pageTitle: 'DeenHub Trivia',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              gapH24,
              Text(
                'Coming Soon!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              gapH12,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Trivia feature is currently under maintenance.\nCheck back soon!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppBarScaffold(
      pageTitle: 'DeenHub Trivia',
      child: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : KeyboardActions(
              config: _buildKeyboardActionsConfig(context),
              child: SingleChildScrollView(
                padding: px16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    gapH16,

                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: p12,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        gapW16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Islamic Trivia',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              gapH4,
                              Text(
                                'Test your knowledge of Qur\'an & Hadith',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  gapH24,

                  // Username Setup Section
                  Container(
                    padding: p16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      border: Border.all(
                        color: _hasUsername
                            ? Colors.green.withOpacity(0.3)
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _hasUsername ? Icons.check_circle : Icons.person,
                              color: _hasUsername
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            gapW8,
                            Text(
                              _hasUsername ? 'Your Username' : 'Set Username',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        gapH12,
                        TextField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Enter username',
                            prefixIcon: const Icon(Icons.alternate_email),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: _setUsername,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                        if (_hasUsername) ...[
                          gapH8,
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              gapW4,
                              Text(
                                'You\'re ready to play!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.green,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  gapH24,

                  // Game Modes
                  Text(
                    'Choose Your Mode',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  gapH16,

                  // Solo Mode
                  if (config.soloModeEnabled)
                    _ModeCard(
                      icon: Icons.person,
                      title: 'Solo Mode',
                      subtitle: 'Play alone at your own pace',
                      color: Colors.green,
                      enabled: _hasUsername,
                      onTap: () =>
                          context.pushNamed(Routes.triviaSoloLobby.name),
                    ),

                  if (config.soloModeEnabled && config.groupModeEnabled) gapH12,

                  // Group Mode
                  if (config.groupModeEnabled)
                    _ModeCard(
                      icon: Icons.groups,
                      title: 'Group Mode',
                      subtitle: 'Compete with friends in real-time',
                      color: Theme.of(context).colorScheme.primary,
                      enabled: _hasUsername,
                      onTap: () =>
                          context.pushNamed(Routes.triviaGroupLobby.name),
                    ),

                  // Quick Join Section
                  if (config.groupModeEnabled) ...[
                    gapH24,
                    Container(
                      padding: p16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.meeting_room,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              gapW8,
                              Text(
                                'Quick Join',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          gapH12,
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _roomCodeController,
                                  focusNode: _roomCodeFocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter room code',
                                    prefixIcon: const Icon(Icons.tag),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                              gapW8, 
                              FilledButton.icon(
                                onPressed: _hasUsername ? _joinRoom : null,
                                icon: _isLoadingProfile
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.login),
                                label: Text(_isLoadingProfile ? 'Joining...' : 'Join'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Leaderboard Button
                  gapH16,
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.pushNamed(Routes.triviaLeaderboard.name),
                    icon: const Icon(Icons.leaderboard),
                    label: const Text('View Leaderboard'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  gapH24,

                  // Info Cards
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.star,
                        label: '3 Difficulty Levels',
                        color: Colors.orange,
                      ),
                      _InfoChip(
                        icon: Icons.timer,
                        label: '30s Per Question',
                        color: Colors.red,
                      ),
                      _InfoChip(
                        icon: Icons.emoji_events,
                        label: 'Earn Points',
                        color: Colors.purple,
                      ),
                    ],
                  ),

                    gapH24,
                  ],
                ),
              ),
            ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: p16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: p12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              gapW16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    gapH4,
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: enabled
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              if (!enabled)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Tooltip(
                    message: 'Set username first',
                    child: Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
