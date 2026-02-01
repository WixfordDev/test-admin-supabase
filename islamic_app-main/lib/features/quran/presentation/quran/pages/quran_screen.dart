import 'dart:async';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/widgets/islamic_pattern_painter.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/memorization/memorization_by_surah_widget.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/memorization/memorization_progress_widget.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/reading_mode_section.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/recently_read_widget.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/search/search_widget.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/surah_list_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deenhub/features/auth/data/services/memorization_sync_service.dart';
import 'package:deenhub/features/subscription/data/services/subscription_service.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final QuranService _quranService = QuranService();
  final MemorizationService _memorizationService = MemorizationService();
  final MemorizationSyncService _memorizationSyncService =
      getIt<MemorizationSyncService>();
  ValueNotifier<bool> uiRefresher = ValueNotifier(false);
  late TabController _tabController;
  StreamSubscription? _dataChangeSubscription;
  // Listen for subscription changes globally to refresh views
  StreamSubscription<bool>? _subscriptionStatusSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);

    // Subscribe to memorization data changes
    _subscribeToDataChanges();

    // Listen for subscription purchase updates and refresh UI immediately
    _subscriptionStatusSub = getIt<SubscriptionService>().purchaseStatusStream
        .listen((_) {
          if (!mounted) return;
          setState(() {
            // Trigger rebuild so inner widgets that read subscription state re-evaluate
            debugPrint(
              'QuranScreen: Subscription status changed, refreshing UI',
            );
          });
          uiRefresher.value = !uiRefresher.value;
        });
  }

  void _subscribeToDataChanges() {
    _dataChangeSubscription?.cancel(); // Cancel any existing subscription
    _dataChangeSubscription = _memorizationSyncService.dataChangeStream.listen(
      (changed) {
        if (mounted) {
          // Update UI when data changes
          setState(() {
            // This will trigger a rebuild with the latest data
            debugPrint('QuranScreen: Memorization data changed, refreshing UI');
          });

          // Also update the valueNotifier for any listeners
          uiRefresher.value = !uiRefresher.value;
        }
      },
      onError: (error) {
        debugPrint('QuranScreen: Error in data change stream: $error');
        // Still try to refresh UI even if there's an error
        if (mounted) {
          setState(() {
            debugPrint('QuranScreen: Forcing UI refresh after stream error');
          });
          uiRefresher.value = !uiRefresher.value;
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _dataChangeSubscription?.cancel();
    _subscriptionStatusSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // App is resumed from background, perform full sync if user is logged in
      final authBloc = getIt<AuthBloc>();
      authBloc.state.maybeMap(
        authenticated: (state) {
          // Force sync with server when app is resumed
          _memorizationSyncService.downloadMemorizationData(state.user.id);
          debugPrint(
            'QuranScreen: App resumed, syncing data for user: ${state.user.id}',
          );
        },
        orElse: () {},
      );

      // Update UI regardless
      _refreshUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 150,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.colorScheme.primary,
              // Ensure consistent solid background when scrolled
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(
                  bottom: 48,
                ), // Move title up to avoid tab overlap
                title: innerBoxIsScrolled
                    ? const SizedBox.shrink() // Hide title when scrolled to avoid overlap
                    : const Text(
                        'Quran',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primaryContainer,
                          ],
                        ),
                      ),
                    ),

                    // Decorative patterns
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      bottom: 0,
                      child: CustomPaint(
                        painter: IslamicPatternPainter(
                          patternColor: Colors.white.withValues(alpha: 0.07),
                        ),
                        size: Size.infinite,
                      ),
                    ),

                    // Bismillah - moved higher to avoid tab overlap
                    Positioned(
                      bottom: 90,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                    tabs: const [
                      Tab(text: 'Memorize'),
                      Tab(text: 'Read'),
                      Tab(text: 'Search'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Memorize Tab
            _buildMemorizeTab(),

            // Read Tab
            _buildReadTab(),

            // Search Tab
            _buildSearchTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // All Surahs Section (Reading Mode)
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.blue),
              title: const Text('All Surahs'),
              subtitle: const Text('Browse all surahs in reading mode'),
              onTap: () {
                // Navigate to Surah list in reading mode
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurahListWidget(
                      surahs: _quranService.getAllSurahs(),
                      onSurahTap: _openSurahForReadingFromSurah,
                      expanded: true,
                      isReadingMode: true,
                    ),
                  ),
                );
              },
            ),
          ),
          gapH24,
          // Recently Read Section
          StreamBuilder<bool>(
            stream: _memorizationSyncService.dataChangeStream,
            builder: (context, snapshot) {
              return ValueListenableBuilder(
                valueListenable: uiRefresher,
                builder: (context, value, child) {
                  return RecentlyReadWidget(
                    quranService: _quranService,
                    onItemTap: (surahId, verseId) {
                      _openSurahForReading(surahId);
                    },
                    memorizationService: _memorizationService,
                    key: ValueKey('recently_read_${snapshot.data}_$value'),
                  );
                },
              );
            },
          ),
          gapH24,
          // Reading Mode Section
          ReadingModeSection(
            onResumeTap: _openReadingMode,
            onSurahSelect: _openSurahForReading,
          ),
          gapH24,
          // Surahs List - No header needed, just the list
          SurahListWidget(
            surahs: _quranService.getAllSurahs(),
            onSurahTap: _openSurahForReadingFromSurah,
            isReadingMode: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMemorizeTab() {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: getIt<AuthBloc>(),
      builder: (context, authState) {
        return authState.maybeMap(
          authenticated: (state) {
            // Handle user login/switching
            _handleUserAuthenticated(state.user.id);
            return AuthenticatedMemorizeView(
              quranService: _quranService,
              memorizationService: _memorizationService,
              memorizationSyncService: _memorizationSyncService,
              uiRefresher: uiRefresher,
              isLoggedIn: true,
              userId: state.user.id,
            );
          },
          unauthenticated: (_) {
            // Handle user logout
            _handleUserUnauthenticated();
            return AuthenticatedMemorizeView(
              quranService: _quranService,
              memorizationService: _memorizationService,
              memorizationSyncService: _memorizationSyncService,
              uiRefresher: uiRefresher,
              isLoggedIn: false,
              userId: null,
            );
          },
          loading: (_) => _buildLoadingMemorizeView(),
          orElse: () {
            // Handle user logout for other states
            _handleUserUnauthenticated();
            return AuthenticatedMemorizeView(
              quranService: _quranService,
              memorizationService: _memorizationService,
              memorizationSyncService: _memorizationSyncService,
              uiRefresher: uiRefresher,
              isLoggedIn: false,
              userId: null,
            );
          },
        );
      },
    );
  }

  // Track current user ID to detect changes
  String? _currentUserId;

  /// Manual refresh method to force UI update
  void _refreshUI() {
    if (mounted) {
      setState(() {
        debugPrint('QuranScreen: Manual UI refresh triggered');
      });
      uiRefresher.value = !uiRefresher.value;
    }
  }

  /// Handle user authentication
  void _handleUserAuthenticated(String userId) {
    if (_currentUserId != userId) {
      debugPrint(
        'QuranScreen: User authenticated - $userId (previous: $_currentUserId)',
      );
      _currentUserId = userId;

      // Handle user login/switching in background
      _memorizationSyncService
          .handleUserLogin(userId)
          .then((_) {
            // Force UI refresh after login handling is complete
            _refreshUI();
            debugPrint('QuranScreen: UI refreshed after user login');
          })
          .catchError((error) {
            debugPrint('QuranScreen: Error during user login handling: $error');
            // Still refresh UI even if there's an error
            _refreshUI();
          });
    }
  }

  /// Handle user unauthentication
  void _handleUserUnauthenticated() {
    if (_currentUserId != null) {
      debugPrint(
        'QuranScreen: User unauthenticated (previous: $_currentUserId)',
      );
      _currentUserId = null;

      // Handle user logout in background
      _memorizationSyncService
          .handleUserLogout()
          .then((_) {
            // Force UI refresh after logout handling is complete
            _refreshUI();
            debugPrint('QuranScreen: UI refreshed after user logout');
          })
          .catchError((error) {
            debugPrint(
              'QuranScreen: Error during user logout handling: $error',
            );
            // Still refresh UI even if there's an error
            _refreshUI();
          });
    }
  }

  Widget _buildLoadingMemorizeView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading memorization data...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const SearchWidget(),
    );
  }

  void _openReadingMode() async {
    final lastPosition = await _memorizationService.getLastReadPosition();
    _openReadingModeView(lastPosition['surahId']!, lastPosition['verseId']!);
  }

  void _openSurahForReading(int surahId) {
    _openReadingModeView(surahId, 1);
  }

  void _openReadingModeView(int surahId, int verseId) {
    context.pushNamed(
      Routes.quranReadingMode.name,
      queryParameters: {
        'surahId': surahId.toString(),
        'verseId': verseId.toString(),
      },
    );
  }

  void _openSurahForReadingFromSurah(Surah surah) {
    _openReadingModeView(surah.number, 1);
  }
}

class AuthenticatedMemorizeView extends StatefulWidget {
  final QuranService quranService;
  final MemorizationService memorizationService;
  final MemorizationSyncService memorizationSyncService;
  final ValueNotifier<bool> uiRefresher;
  final bool isLoggedIn;
  final String? userId;

  const AuthenticatedMemorizeView({
    super.key,
    required this.quranService,
    required this.memorizationService,
    required this.memorizationSyncService,
    required this.uiRefresher,
    required this.isLoggedIn,
    required this.userId,
  });

  @override
  State<AuthenticatedMemorizeView> createState() =>
      _AuthenticatedMemorizeViewState();
}

class _AuthenticatedMemorizeViewState extends State<AuthenticatedMemorizeView> {
  bool _hasSubscription = false;
  bool _isCheckingSubscription = true;
  // Listen to subscription updates within this view
  StreamSubscription<bool>? _subscriptionStatusSub;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
    // Listen for subscription purchase updates and refresh this view
    _subscriptionStatusSub = getIt<SubscriptionService>().purchaseStatusStream
        .listen((_) async {
          final hasAny = await SubscriptionService.hasAnySubscription();
          if (!mounted) return;
          setState(() {
            _hasSubscription = hasAny;
            _isCheckingSubscription = false;
          });
        });
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final hasSubscription = await SubscriptionService.hasAnySubscription();
      logger.i('hasSubscription: $hasSubscription');
      if (mounted) {
        setState(() {
          _hasSubscription = hasSubscription;
          _isCheckingSubscription = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasSubscription = false;
          _isCheckingSubscription = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _subscriptionStatusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSubscription) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking subscription status...'),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Authentication warning if not logged in
          if (!widget.isLoggedIn)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Login Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The memorization feature requires you to be logged in to save your progress.',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.pushNamed(Routes.login.name),
                    icon: const Icon(Icons.login),
                    label: const Text('Login Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

          // All Surahs Section (Memorize Mode)
          Card(
            color: Colors.green.shade50,
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.green),
              title: const Text('All Surahs'),
              subtitle: const Text('Browse all surahs for memorization'),
              onTap: () {
                if (widget.isLoggedIn && _hasSubscription) {
                  // Navigate to Surah list in memorize mode (current behavior)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahListWidget(
                        surahs: widget.quranService.getAllSurahs(),
                        onSurahTap: (surah) => _openSurah(context, surah),
                        expanded: true,
                        isReadingMode: false,
                      ),
                    ),
                  );
                } else if (!widget.isLoggedIn) {
                  _showLoginRequiredDialog(context);
                } else {
                  _showSubscriptionRequiredDialog(context);
                }
              },
            ),
          ),
          gapH24,
          // Subscription warning if not subscribed
          if (!_hasSubscription && widget.isLoggedIn)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Subscription Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The memorization feature requires an active subscription. Get Barakah Access for free or upgrade to other plans.',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.pushNamed(Routes.subscription.name),
                    icon: const Icon(Icons.card_membership),
                    label: const Text('View Subscription Plans'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade500,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

          // Memorization Progress with proper state management
          StreamBuilder<bool>(
            stream: widget.memorizationSyncService.dataChangeStream,
            builder: (context, snapshot) {
              // Use a combination of StreamBuilder and ValueListenableBuilder for maximum reactivity
              return ValueListenableBuilder(
                valueListenable: widget.uiRefresher,
                builder: (context, value, child) {
                  return MemorizationProgressWidget(
                    progress: widget.memorizationService.progress,
                    onContinuePressed: () {
                      if (widget.isLoggedIn && _hasSubscription) {
                        _continueMemorizing(context);
                      } else if (!widget.isLoggedIn) {
                        _showLoginRequiredDialog(context);
                      } else {
                        _showSubscriptionRequiredDialog(context);
                      }
                    },
                    key: ValueKey(
                      'memorization_progress_${widget.userId ?? 'guest'}_${snapshot.data}_$value',
                    ),
                  );
                },
              );
            },
          ),
          gapH24,
          // Memorization by Surah with proper state management
          StreamBuilder<bool>(
            stream: widget.memorizationSyncService.dataChangeStream,
            builder: (context, snapshot) {
              return ValueListenableBuilder(
                valueListenable: widget.uiRefresher,
                builder: (context, value, child) {
                  return MemorizationBySurahWidget(
                    memorizationBySurah: widget.memorizationService
                        .getMemorizationBySurah(),
                    quranService: widget.quranService,
                    onPracticeTap: (surahId) {
                      if (widget.isLoggedIn && _hasSubscription) {
                        _openSurahMemorization(context, surahId);
                      } else if (!widget.isLoggedIn) {
                        _showLoginRequiredDialog(context);
                      } else {
                        _showSubscriptionRequiredDialog(context);
                      }
                    },
                    key: ValueKey(
                      'memorization_by_surah_${widget.userId ?? 'guest'}_${snapshot.data}_$value',
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _continueMemorizing(BuildContext context) {
    context.pushNamed(Routes.memorizationReport.name);
  }

  void _openSurah(BuildContext context, Surah surah) {
    context.pushNamed(
      Routes.verseView.name,
      queryParameters: {
        'surahId': surah.number.toString(),
        'verseId': '1',
        'isMemorizationMode': 'true',
      },
    );
  }

  void _openSurahMemorization(BuildContext context, int surahId) {
    context.pushNamed(
      Routes.verseView.name,
      queryParameters: {
        'surahId': surahId.toString(),
        'verseId': '1',
        'isMemorizationMode': 'true',
      },
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: context.primaryColor),
              const SizedBox(width: 8),
              const Text('Login Required'),
            ],
          ),
          content: const Text(
            'You need to log in to use the memorization feature. This allows us to save your progress and sync across devices.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed(Routes.login.name);
              },
              child: const Text('Login Now'),
            ),
          ],
        );
      },
    );
  }

  void _showSubscriptionRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.workspace_premium, color: context.primaryColor),
              const SizedBox(width: 8),
              const Text('Subscription Required').expanded(),
            ],
          ),
          content: const Text(
            'The memorization feature requires an active subscription. Get Barakah Access for free or upgrade to other plans.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pushNamed(Routes.subscription.name);
              },
              child: const Text('View Plans'),
            ),
          ],
        );
      },
    );
  }
}
