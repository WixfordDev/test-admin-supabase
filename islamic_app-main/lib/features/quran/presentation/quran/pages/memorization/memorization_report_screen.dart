import 'dart:async';
import 'package:flutter/material.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/core/widgets/global_media_player.dart';
import 'package:deenhub/features/auth/data/services/memorization_sync_service.dart';
import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verses_by_status_screen.dart';
import 'package:go_router/go_router.dart';

class MemorizationReportScreen extends StatefulWidget {
  const MemorizationReportScreen({super.key});

  @override
  State<MemorizationReportScreen> createState() => _MemorizationReportScreenState();
}

class _MemorizationReportScreenState extends State<MemorizationReportScreen> {
  final QuranService _quranService = QuranService();
  final MemorizationService _memorizationService = MemorizationService();
  final MemorizationSyncService _memorizationSyncService = getIt<MemorizationSyncService>();
  late Future<void> _initFuture;
  StreamSubscription? _dataChangeSubscription;
  bool _needsRefresh = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  List<Map<String, dynamic>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeData();

    // Subscribe to memorization data changes
    _subscribeToDataChanges();

    // Force sync when screen opens
    _syncWithServer();

    // Add search listener
    _searchController.addListener(_onSearchChanged);
  }
  
  Future<void> _initializeData() async {
    await _memorizationService.initialize();
  }
  
  void _subscribeToDataChanges() {
    _dataChangeSubscription = _memorizationSyncService.dataChangeStream.listen((changed) {
      if (mounted) {
        setState(() {
          _needsRefresh = true;
          debugPrint('MemorizationReportScreen: Data changed, refreshing UI');
        });
      }
    });
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Start new timer for debouncing
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          // Update filtered list when search changes
          _updateFilteredListFromCurrentData();
        });
      }
    });
  }

  void _updateFilteredList(List<Map<String, dynamic>> combinedList, Map<int, dynamic> surahMap) {
    if (_searchQuery.isEmpty) {
      _filteredList = List.from(combinedList);
    } else {
      _filteredList = combinedList.where((surah) {
        final surahId = surah['surahId'] as int;
        final surahInfo = surahMap[surahId];
        final surahNumber = surahId.toString();
        final surahName = surahInfo?.englishName.toLowerCase() ?? '';

        return surahNumber.contains(_searchQuery) ||
               surahName.contains(_searchQuery);
      }).toList();
    }
  }

  void _updateFilteredListFromCurrentData() async {
    try {
      await _memorizationService.initialize();
      final allSurahs = _quranService.getAllSurahs();
      final surahsWithProgress = _memorizationService.getMemorizationBySurah();

      // Create a map of surahId to progress data for easier lookup
      final progressMap = {
        for (var item in surahsWithProgress) item['surahId'] as int: item
      };

      // Create a combined list of all surahs with their progress
      final combinedList = allSurahs.map((surah) {
        // Get progress data if exists, or create default
        final progressData = progressMap[surah.number];

        if (progressData != null) {
          return progressData;
        } else {
          // Surah with no progress
          return {
            'surahId': surah.number,
            'memorizedCount': 0,
            'totalVerses': surah.ayahs.length,
            'progress': 0.0,
          };
        }
      }).toList();

      // Sort by progress (highest first), then by surah number
      combinedList.sort((a, b) {
        // First compare by progress
        final progressComparison = (b['progress'] as double).compareTo(a['progress'] as double);
        // If progress is the same, sort by surah number
        if (progressComparison == 0) {
          return (a['surahId'] as int).compareTo(b['surahId'] as int);
        }
        return progressComparison;
      });

      // Create a Map of surahId to Surah for easier lookup
      final surahMap = {for (var surah in allSurahs) surah.number: surah};

      _updateFilteredList(combinedList, surahMap);
    } catch (e) {
      debugPrint('Error updating filtered list: $e');
    }
  }
  
  void _syncWithServer() {
    final authBloc = getIt<AuthBloc>();
    authBloc.state.maybeMap(
      authenticated: (state) {
        // Sync with server to get latest data
        _memorizationSyncService.downloadMemorizationData(state.user.id);
      },
      orElse: () {
        // Not logged in, no sync needed
      },
    );
  }
  
  @override
  void dispose() {
    _dataChangeSubscription?.cancel();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: 'Memorization Report',
      appBarActions: [
        // Add refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              _needsRefresh = true;
              _syncWithServer();
            });
          },
        ),
      ],
      child: Stack(
        children: [
          // Main content
          FutureBuilder<void>(
            future: _needsRefresh ? _initializeData() : _initFuture,
            builder: (context, snapshot) {
              // Reset refresh flag
              if (_needsRefresh) {
                _needsRefresh = false;
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              // Get all surahs
              final allSurahs = _quranService.getAllSurahs();
              
              // Get surahs with progress
              final surahsWithProgress = _memorizationService.getMemorizationBySurah();
              
              // Create a map of surahId to progress data for easier lookup
              final progressMap = {
                for (var item in surahsWithProgress) item['surahId'] as int: item
              };
              
              // Create a combined list of all surahs with their progress
              final combinedList = allSurahs.map((surah) {
                // Get progress data if exists, or create default
                final progressData = progressMap[surah.number];
                
                if (progressData != null) {
                  return progressData;
                } else {
                  // Surah with no progress
                  return {
                    'surahId': surah.number,
                    'memorizedCount': 0,
                    'totalVerses': surah.ayahs.length,
                    'progress': 0.0,
                  };
                }
              }).toList();
              
              // Sort by progress (highest first), then by surah number
              combinedList.sort((a, b) {
                // First compare by progress
                final progressComparison = (b['progress'] as double).compareTo(a['progress'] as double);
                // If progress is the same, sort by surah number
                if (progressComparison == 0) {
                  return (a['surahId'] as int).compareTo(b['surahId'] as int);
                }
                return progressComparison;
              });
              
              // Create a Map of surahId to Surah for easier lookup
              final surahMap = {for (var surah in allSurahs) surah.number: surah};

              // Update filtered list if needed (only when data changes or search query changes)
              if (_filteredList.isEmpty || _needsRefresh) {
                _updateFilteredList(combinedList, surahMap);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // Manual refresh triggered by pull-to-refresh
                  setState(() {
                    _needsRefresh = true;
                    _syncWithServer();
                  });
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0), // Add bottom padding for media player
                  physics: const AlwaysScrollableScrollPhysics(), // Enable scrolling even with little content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overall progress
                      _buildOverallProgress(context),
                      const SizedBox(height: 24),
                      
                      // Surah progress list
                      Row(
                        children: [
                          const Text(
                            'All Surahs',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_filteredList.length}${_searchQuery.isNotEmpty ? ' of ${allSurahs.length}' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Search results (${_filteredList.length} surahs found)'
                            : 'Sorted by highest memorization progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search surahs by number or name...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) {
                          final surah = _filteredList[index];
                          final surahId = surah['surahId'] as int;
                          final surahInfo = surahMap[surahId];
                          final progress = surah['progress'] as double;
                          final memorizedCount = surah['memorizedCount'] as int;
                          final totalVerses = surah['totalVerses'] as int;
                          
                          return _buildSurahProgressItem(
                            context,
                            surahId: surahId,
                            surahName: surahInfo?.englishName ?? 'Surah $surahId',
                            progress: progress,
                            memorizedCount: memorizedCount,
                            totalVerses: totalVerses,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Global Media Player positioned at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const GlobalMediaPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(BuildContext context) {
    final progress = _memorizationService.progress;
    final theme = Theme.of(context);
    
    // Use the standard Quran verse count (6,236 verses)
    const int actualTotalVerses = 6236;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title moved outside the card
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Overall Progress',
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Percentage and progress info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quran Memorization',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${(actualTotalVerses > 0 ? progress.memorizedCount / actualTotalVerses * 100 : 0.0).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: actualTotalVerses > 0 ? progress.memorizedCount / actualTotalVerses : 0.0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Progress text
                Text(
                  '${progress.memorizedCount} of $actualTotalVerses verses memorized',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14, 
                  ),
                ),
                
                // Stats grid
                const SizedBox(height: 20),
                
                // First row of status cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        context,
                        'Memorized',
                        progress.memorizedCount.toString(),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusCard(
                        context,
                        'Reviewing',
                        progress.reviewingCount.toString(),
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Second row of status cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        context,
                        'Learning',
                        progress.learningCount.toString(),
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusCard(
                        context,
                        'Total',
                        progress.totalInProgress.toString(),
                        theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, String value, Color color) {
    return InkWell(
      onTap: () => _navigateToStatusVersesList(title),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahProgressItem(
    BuildContext context, {
    required int surahId,
    required String surahName,
    required double progress,
    required int memorizedCount,
    required int totalVerses,
  }) {
    // Calculate progress percentage for display
    final progressPercent = (progress * 100).toStringAsFixed(1);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openSurahForMemorization(surahId),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      surahId.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$memorizedCount of $totalVerses verses memorized',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(progress).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$progressPercent%',
                      style: TextStyle(
                        color: _getProgressColor(progress),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getProgressColor(double progress) {
    if (progress >= 0.75) return Colors.green;
    if (progress >= 0.5) return Colors.blue;
    if (progress >= 0.25) return Colors.orange;
    return Colors.red;
  }

  void _openSurahForMemorization(int surahId) {
    context.pushNamed(
      Routes.verseView.name,
      queryParameters: {
        'surahId': surahId.toString(),
        'verseId': '1',
        'isMemorizationMode': 'true',
      },
    );
  }

  void _navigateToStatusVersesList(String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VersesByStatusScreen(status: status),
      ),
    );
  }
}