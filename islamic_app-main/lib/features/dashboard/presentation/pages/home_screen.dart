import 'dart:async';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/config/themes/decoration_styles.dart';
import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/notification_navigation_service.dart';
import 'package:deenhub/core/services/location_update_service.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/main/presentation/pages/more/more_bottom_sheet_screen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/features/nearby_mosques/presentation/cubit/nearby_mosque_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/hijri_date/hijri_date_time.dart';
// import 'package:deenhub/features/nearby_mosques/domain/models/mosque.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/common/prayers/prayer_times_helper.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/dashboard/presentation/widgets/upcoming_prayer_widget.dart';
import 'package:deenhub/features/dashboard/presentation/widgets/nearby_mosque_widget.dart';
import 'package:deenhub/features/dashboard/presentation/utils/prayer_time_utils.dart';
import 'package:deenhub/features/quran/domain/models/verse_model.dart';
import 'package:deenhub/features/hadith/domain/models/hadith.dart';
import 'package:deenhub/core/utils/feature_menu_provider.dart';
import 'package:deenhub/features/dashboard/domain/models/daily_goal.dart';
import 'package:deenhub/features/dashboard/data/services/daily_goals_service.dart';
import 'package:deenhub/main.dart';
import 'package:deenhub/features/dashboard/presentation/widgets/enhanced_daily_goals_section_widget.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // Services
  final _sharedPrefsHelper = getIt<SharedPrefsHelper>();
  final _dailyGoalsService = DailyGoalsService();
  final _nearbyMosqueCubit = getIt<NearbyMosqueCubit>();

  // Data
  PrayerLocationData? prayerData;
  LocationData? locData;
  HijriDateTime today = HijriDateTime.now();
  late HijriDateTime dateTime;
  Timer? _periodicTimer;
  final _scrollController = ScrollController();

  // Content
  VerseModel? dailyQuranVerse;
  Hadith? dailyHadith;

  // Prayer Items
  List<PrayerItem> prayerTimes = [];
  int upcomingPrayerIndex = 0;
  String remainingTime = "";

  // Daily Goals
  List<DailyGoal> dailyGoals = [];

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Color?> _colorShiftAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    dateTime = today;
    WidgetsBinding.instance.addObserver(this);

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse animation (breathing effect)
    _pulseAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Rotation animation (subtle)
    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.slowMiddle),
    );

    // Color shifting animation
    _colorShiftAnimation =
        ColorTween(
          begin: Colors.green.shade400,
          end: Colors.blue.shade500,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.slowMiddle,
          ),
        );

    // Shimmer animation
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initialize();
    _startPeriodicTimer();
    _checkNotificationLaunch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _periodicTimer?.cancel();
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkNotificationLaunch() async {
    final payload = await getIt<NotificationManager>()
        .getNotificationLaunchPayload();
    logger.i('Notification payload: $payload');
    if (payload != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      NotificationNavigationService.handleNavigation(payload);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      logger.i("App Resumed");
      prayerData = _sharedPrefsHelper.prayerLocationDataOrNull;
      setState(() {
        _updateTime();
        _startPeriodicTimer();
      });
    } else if (state == AppLifecycleState.paused) {
      logger.i("App Paused");
      _periodicTimer?.cancel();
    }
  }

  void _startPeriodicTimer() {
    // Update every second to show seconds in countdown
    const updateInterval = Duration(seconds: 1);
    _periodicTimer = Timer.periodic(updateInterval, (Timer timer) {
      setState(() {
        _updateTime();
      });
    });
  }

  void _updateTime() {
    today = HijriDateTime.now();
    dateTime = today;

    // Store previous upcoming prayer index to detect changes
    final previousUpcomingIndex = upcomingPrayerIndex;

    initPrayerTimings();

    // Update the countdown time
    if (prayerTimes.isNotEmpty && upcomingPrayerIndex < prayerTimes.length) {
      remainingTime = PrayerTimeUtils.getRemainingTime(
        prayerTimes[upcomingPrayerIndex].time,
      );

      // If upcoming prayer changed, force UI update immediately
      if (previousUpcomingIndex != upcomingPrayerIndex) {
        // Prayer time has passed, immediately update UI
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              // Force rebuild to show new prayer immediately
            });
          }
        });
      }
    }
  }

  Future<void> _initialize() async {
    await _loadPrayerData();
    await _loadDailyGoals();
    // Removed _fetchNearbyMosque() - now using cubit
  }

  Future<void> _loadPrayerData() async {
    try {
      // Get prayer location data from SharedPrefsHelper
      prayerData = _sharedPrefsHelper.prayerLocationDataOrNull;
      if (prayerData != null) {
        locData = prayerData?.toLocationData();
        initPrayerTimings();
      }
    } catch (e) {
      debugPrint('Error loading prayer data: $e');
    }
  }

  void initPrayerTimings() {
    if (locData == null && prayerData == null) return;
    if (locData == null || prayerData == null) return;

    try {
      locData = PrayerTimesHelper.getPrayerTimings(
        locData!,
        prayerData!,
        time: dateTime.toDateTime(),
        fetchOnlyMandatory: false,
      );

      if (locData?.prayerTimes != null) {
        setState(() {
          prayerTimes = locData!.prayerTimes!;

          // Find upcoming prayer
          upcomingPrayerIndex = PrayerTimeUtils.getUpcomingPrayerIndex(
            prayerTimes,
          );

          // Update remaining time
          if (prayerTimes.isNotEmpty &&
              upcomingPrayerIndex < prayerTimes.length) {
            remainingTime = PrayerTimeUtils.getRemainingTime(
              prayerTimes[upcomingPrayerIndex].time,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error calculating prayer times: $e');
    }
  }

  Future<void> _loadDailyGoals() async {
    try {
      final goals = await _dailyGoalsService.initializeTodayGoals();
      setState(() {
        dailyGoals = goals;
      });
    } catch (e) {
      setState(() {});
      debugPrint('Error loading daily goals: $e');
    }
  }

  Future<void> _handleRefresh() async {
    // Update location first if needed
    final locationUpdated = await LocationUpdateService.updateLocationIfNeeded();

    await Future.wait([
      _loadPrayerData(),
      _loadDailyGoals(),
      // Mosque data is already refreshed by LocationUpdateService if location was updated
      // But we still need to refresh if location wasn't updated
      if (!locationUpdated) _nearbyMosqueCubit.refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: DecorationStyles.appBarSystemUiOverlayStyle(
          appBarColor: context.primaryColor,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${today.hDay} ${_getHijriMonthName()}, ${today.hYear}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5),
            const Text("|"),
            const SizedBox(width: 5),
            Text(
              "${DateTime.now().day} ${_getMonthName()}, ${DateTime.now().year}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show upcoming prayer if available
                if (prayerData == null)
                  _buildLocationCta(context)
                else if (prayerTimes.isNotEmpty &&
                    upcomingPrayerIndex < prayerTimes.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: UpcomingPrayerWidget(
                      upcomingPrayer: prayerTimes[upcomingPrayerIndex],
                      remainingTime: remainingTime,
                    ),
                  ),
                // Nearby mosque section using cubit
                BlocBuilder<NearbyMosqueCubit, NearbyMosqueState>(
                  bloc: _nearbyMosqueCubit,
                  builder: (context, state) {
                    return NearbyMosqueWidget(
                      mosque:
                          _sharedPrefsHelper.prayerLocationDataOrNull == null
                          ? null
                          : (state.hasData ? state.mosques.first : null),
                      isLoading:
                          _sharedPrefsHelper.prayerLocationDataOrNull == null
                          ? false
                          : state.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Quick access menu
                _buildQuickAccessMenu(),
                const SizedBox(height: 16),

                // Inspirational tagline section
                _buildInspirationalTagline(),
                const SizedBox(height: 16),

                // Enhanced Daily Goals Section
                const EnhancedDailyGoalsSectionWidget(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInspirationalTagline() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _animationController,
        _pulseAnimation,
        _rotateAnimation,
        _colorShiftAnimation,
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade50,
                    Colors.teal.shade50,
                    Colors.blue.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.shade200.withValues(alpha: 0.3),
                  width: 1,
                ),
                // Enhanced animated box shadows
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200.withValues(
                      alpha: 0.4 + (_pulseAnimation.value - 1.0) * 0.3,
                    ),
                    blurRadius: 12 + (_pulseAnimation.value - 1.0) * 8,
                    spreadRadius: 2 + (_pulseAnimation.value - 1.0) * 2,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.teal.shade200.withValues(
                      alpha: 0.2 + (_pulseAnimation.value - 1.0) * 0.2,
                    ),
                    blurRadius: 20 + (_pulseAnimation.value - 1.0) * 10,
                    spreadRadius: 1 + (_pulseAnimation.value - 1.0) * 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated icon with shimmer effect
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade200.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 20,
                          color: Colors.green.shade600.withValues(alpha: 0.6),
                        ),
                        // Shimmer overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  _colorShiftAnimation.value?.withValues(
                                        alpha: 0.3,
                                      ) ??
                                      Colors.green.shade400.withValues(
                                        alpha: 0.3,
                                      ),
                                  Colors.transparent,
                                ],
                                stops: [
                                  max(0, _shimmerAnimation.value - 0.3),
                                  _shimmerAnimation.value,
                                  min(1, _shimmerAnimation.value + 0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text content with enhanced animations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main tagline with animated gradient
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              _colorShiftAnimation.value ??
                                  Colors.green.shade700,
                              Colors.teal.shade600,
                              Colors.blue.shade600,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'A Clear Path to Deen',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Secondary line with animated elements
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Icon(
                                  Icons.block,
                                  size: 14,
                                  color: Colors.green.shade600.withValues(
                                    alpha:
                                        0.7 +
                                        (_pulseAnimation.value - 1.0) * 0.3,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Text(
                                  'AD-Free. Always.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700.withValues(
                                      alpha:
                                          0.8 +
                                          (_pulseAnimation.value - 1.0) * 0.2,
                                    ),
                                    letterSpacing: 0.2,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.green.shade600.withValues(
                                    alpha:
                                        0.7 +
                                        (_pulseAnimation.value - 1.0) * 0.3,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Animated decorative element
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: 4,
                        height: 40 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _colorShiftAnimation.value ??
                                  Colors.green.shade400,
                              Colors.teal.shade400,
                              Colors.blue.shade400,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_colorShiftAnimation.value ??
                                          Colors.green.shade400)
                                      .withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationCta(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enable location for full experience',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nearby mosques and prayer time notifications need your location. You can enable it anytime.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  context.showBottomSheetNow(isScrollControlled: true, child: MoreBottomSheetScreen());
                },
                child: const Text('Explore features'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  // Navigate to location setup
                  GoRouter.of(
                    context,
                  ).goNamed(Routes.getPrayerTimesOnboard.name);
                },
                child: const Text('Set up location'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessMenu() {
    final features = FeatureMenuProvider.getHomeFeatures(context);
    final displayFeatures = features.take(6).toList(); // Show first 6 features

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quick Access',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to more screen
                context.showBottomSheetNow(isScrollControlled: true, child: MoreBottomSheetScreen());
              },
              child: const Text(
                'View All',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayFeatures.length,
            itemBuilder: (context, index) {
              final feature = displayFeatures[index];
              return Container(
                width: 60,
                margin: EdgeInsets.only(
                  right: index < displayFeatures.length - 1 ? 12 : 0,
                ),
                child: InkWell(
                  onTap: feature.onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: feature.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          feature.icon,
                          size: 22,
                          color: feature.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        feature.title,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getHijriMonthName() {
    final monthNames = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah',
    ];
    return monthNames[today.hMonth - 1];
  }

  String _getMonthName() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[DateTime.now().month - 1];
  }
}
