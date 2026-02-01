import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/trivia/data/services/trivia_service.dart';
import 'package:flutter/material.dart';

class TriviaLeaderboardScreen extends StatefulWidget {
  const TriviaLeaderboardScreen({super.key});

  @override
  State<TriviaLeaderboardScreen> createState() =>
      _TriviaLeaderboardScreenState();
}

class _TriviaLeaderboardScreenState extends State<TriviaLeaderboardScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _rows = const [];
  String? _error;
  String? _currentUserId;
  int? _myPosition;

  @override
  void initState() {
    super.initState();
    _currentUserId = getIt<TriviaService>().supabaseProvider.supabase.auth.currentUser?.id;
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => _loading = true);
      final service = getIt<TriviaService>();
      final rows = await service.fetchLeaderboard(limit: 100);
      
      // Find current user's position
      int? myPos;
      if (_currentUserId != null) {
        final index = rows.indexWhere((row) => row['user_id'] == _currentUserId);
        if (index != -1) {
          myPos = index + 1;
        }
      }
      
      setState(() {
        _rows = rows;
        _myPosition = myPos;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: 'Trivia Leaderboard',
      appBarActions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
      ],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_rows.isEmpty) {
      return _buildEmptyState();
    }

    return _buildLeaderboardList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading leaderboard...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load leaderboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              color: Theme.of(context).colorScheme.primary,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'No Trivia Games Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Be the first to play and claim the top spot on the leaderboard!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Playing'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    // Separate top 3 and rest
    final topThree = _rows.take(3).toList();
    final rest = _rows.skip(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Podium for top 3
          if (topThree.isNotEmpty) ...[
            _buildPodium(topThree),
            const SizedBox(height: 32),
          ],

          // My Position Card (if not in top 3)
          if (_myPosition != null && _myPosition! > 3) ...[
            _buildMyPositionCard(),
            const SizedBox(height: 24),
          ],

          // Rest of the leaderboard
          if (rest.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rest.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                itemBuilder: (context, index) {
                  final rank = index + 4;
                  final player = rest[index];
                  final isMe = player['user_id'] == _currentUserId;
                  return _LeaderboardEntryCard(
                    rank: rank,
                    player: player,
                    isCurrentUser: isMe,
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> topThree) {
    // Arrange as: 2nd, 1st, 3rd
    final first = topThree.length > 0 ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
          ],
        ),
      ),
      child: Column(
        children: [
          // Trophy Icon and Title
          Icon(
            Icons.emoji_events,
            size: 48,
            color: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 8),
          Text(
            'Top Champions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          
          // Podium
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd Place
              if (second != null)
                Expanded(
                  child: _PodiumCard(
                    rank: 2,
                    player: second,
                    height: 140,
                    isCurrentUser: second['user_id'] == _currentUserId,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              
              const SizedBox(width: 12),
              
              // 1st Place
              if (first != null)
                Expanded(
                  child: _PodiumCard(
                    rank: 1,
                    player: first,
                    height: 180,
                    isCurrentUser: first['user_id'] == _currentUserId,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              
              const SizedBox(width: 12),
              
              // 3rd Place
              if (third != null)
                Expanded(
                  child: _PodiumCard(
                    rank: 3,
                    player: third,
                    height: 120,
                    isCurrentUser: third['user_id'] == _currentUserId,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyPositionCard() {
    if (_myPosition == null) return const SizedBox.shrink();
    
    final myData = _rows.firstWhere((row) => row['user_id'] == _currentUserId);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.15),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                '$_myPosition',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Your Position',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'YOU',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  myData['username']?.toString() ?? 'Player',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${myData['total_score'] ?? 0}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> player;
  final double height;
  final bool isCurrentUser;

  const _PodiumCard({
    required this.rank,
    required this.player,
    required this.height,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(rank);
    final username = player['username']?.toString() ?? 'Player';
    final score = player['total_score'] ?? 0;

    return Column(
      children: [
        // Trophy Icon
        Icon(
          _getTrophyIcon(rank),
          color: rankColor,
          size: rank == 1 ? 40 : 32,
        ),
        const SizedBox(height: 8),
        
        // Podium
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                rankColor.withOpacity(0.3),
                rankColor.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: rankColor.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: isCurrentUser ? [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rank Badge
              Container(
                width: rank == 1 ? 50 : 40,
                height: rank == 1 ? 50 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rankColor,
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: rank == 1 ? 24 : 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Username
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  username,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: rank == 1 ? 13 : 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              
              // Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$score',
                  style: TextStyle(
                    color: rankColor,
                    fontWeight: FontWeight.w900,
                    fontSize: rank == 1 ? 16 : 14,
                  ),
                ),
              ),
              
              // "YOU" badge
              if (isCurrentUser) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'YOU',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  IconData _getTrophyIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.workspace_premium;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }
}

class _LeaderboardEntryCard extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> player;
  final bool isCurrentUser;

  const _LeaderboardEntryCard({
    required this.rank,
    required this.player,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final username = player['username']?.toString() ?? 'Player';
    final score = player['total_score'] ?? 0;
    final gamesPlayed = player['games_played'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
            : Colors.transparent,
        border: isCurrentUser ? Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ) : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: Text(
              '$rank',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isCurrentUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),

          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'YOU',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.games,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$gamesPlayed games',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: isCurrentUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
