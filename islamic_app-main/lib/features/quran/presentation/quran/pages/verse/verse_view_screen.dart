import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/notification/services/memorization_reminder_service.dart';
import 'package:deenhub/core/services/ai_usage/ai_usage_tracking_service.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/memorization_reading_mode_widgets.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/surah_header_widget.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/verse_card_widget.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/verse_view/verse_view_dialogs.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/settings/models/verse_view_settings.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/core/services/shared_audio_service.dart';
import 'package:deenhub/features/quran/domain/models/memorization_model.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:deenhub/features/ai_chatbot/domain/models/chatgpt_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:deenhub/features/auth/data/services/memorization_sync_service.dart';
import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:deenhub/features/subscription/data/services/subscription_service.dart';
import 'package:deenhub/core/widgets/dialog/report_dialog.dart';
import 'dart:async';

class VerseViewScreen extends StatefulWidget {
  final Surah surah;
  final int initialVerseId;
  final bool isMemorizationMode;
  final bool isResultVerse;

  const VerseViewScreen({
    super.key,
    required this.surah,
    required this.initialVerseId,
    this.isMemorizationMode = true,
    this.isResultVerse = false,
  });

  @override
  State<VerseViewScreen> createState() => _VerseViewScreenState();
}

class _VerseViewScreenState extends State<VerseViewScreen>
    with WidgetsBindingObserver {
  late int _currentVerseId;
  bool _isPlaying = false;
  final MemorizationSyncService _memorizationSyncService =
      getIt<MemorizationSyncService>();
  final ChatGPTService _chatGPTService = ChatGPTService();
  late ScrollController _scrollController;
  int _repeatCount = 1;
  bool _autoAdvance = true;
  Map<int, MemorizationStatus> _verseStatuses = {};
  final Map<int, String> _verseExplanations = {};
  final Map<int, bool> _isLoadingExplanation = {};
  String? _userId;
  bool _notificationScheduled = false;
  String _selectedLanguage = 'en'; // 'en' for English, 'bn' for Bengali

  // Add subscription checking state
  bool _hasSubscription = false;
  bool _isCheckingSubscription = true;
  // Listen to subscription updates
  StreamSubscription<bool>? _subscriptionStatusSub;

  double _playbackSpeed = 1.0;
  Timer? _recentlyReadTimer;
  int _lastRecordedVerseId = -1;
  bool _singleVerseMode = false;
  int _currentHighlightedWordIndex = -1;
  int _previousHighlightedWordIndex = -1;

  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<bool>? _loadingSubscription;
  StreamSubscription<int>? _verseSubscription;
  StreamSubscription<int>? _highlightSubscription;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  late VerseViewSettings _verseViewSettings;

  @override
  void initState() {
    super.initState();
    _currentVerseId = widget.initialVerseId;
    logger.i('initialVerseId: $_currentVerseId');
    _scrollController = ScrollController();

    WidgetsBinding.instance.addObserver(this);
    _getCurrentUserId();
    _checkSubscriptionStatus();
    // Listen for subscription purchase updates
    _subscriptionStatusSub = getIt<SubscriptionService>().purchaseStatusStream
        .listen((success) async {
          final hasAny = await SubscriptionService.hasAnySubscription();
          if (!mounted) return;
          setState(() {
            _hasSubscription = hasAny;
            _isCheckingSubscription = false;
          });
        });
    _recordRecentlyRead(widget.surah.number, _currentVerseId);
    _loadVerseStatuses();
    _loadVerseViewSettings();
    _repeatCount = 1;
    SharedAudioService.instance.setRepeatCount(_repeatCount);
    _autoAdvance = SharedAudioService.instance.autoAdvance;

    final audioService = SharedAudioService.instance;
    final bool fromSearch = widget.isResultVerse;

    // Determine effective initial verse. If coming from a different screen/mode
    // for the same surah (and not from search), force start from verse 1.
    int effectiveInitialVerse = widget.initialVerseId;
    if (!fromSearch &&
        audioService.currentContext == 'quran' &&
        audioService.originatingScreen != 'verse_view' &&
        audioService.currentSurah?.number == widget.surah.number) {
      effectiveInitialVerse = 1;
    }
    _currentVerseId = effectiveInitialVerse;
    logger.i('initialVerseId (effective): $_currentVerseId');

    if (!audioService.isInitialized) {
      audioService
          .initialize()
          .then((_) {
            if (mounted) {
              // Always stop audio when switching to verse_view from any different screen
              if (audioService.isPlaying &&
                  audioService.originatingScreen != 'verse_view') {
                audioService.stop();
              }

              if (fromSearch) {
                setState(() {
                  _currentVerseId = widget.initialVerseId;
                });
                audioService.setSurahAndVerse(
                  widget.surah,
                  _currentVerseId,
                  screen: 'verse_view',
                );
              } else {
                // Always use the current verse from this screen, don't sync with audio service
                audioService.setSurahAndVerse(
                  widget.surah,
                  _currentVerseId,
                  screen: 'verse_view',
                );
              }
            }
          })
          .catchError((e) {
            logger.e('Failed to initialize audio service: $e');
          });
    } else {
      // Always stop audio when switching to verse_view from any different screen
      if (audioService.isPlaying &&
          audioService.originatingScreen != 'verse_view') {
        audioService.stop();
      }

      if (fromSearch) {
        if (_currentVerseId != widget.initialVerseId) {
          setState(() {
            _currentVerseId = widget.initialVerseId;
          });
        }
        audioService.setSurahAndVerse(
          widget.surah,
          _currentVerseId,
          screen: 'verse_view',
        );
      } else {
        // Always use the current verse from this screen, don't sync with audio service
        audioService.setSurahAndVerse(
          widget.surah,
          _currentVerseId,
          screen: 'verse_view',
        );
      }
    }

    _setupAudioServiceListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerse(_currentVerseId);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _scheduleMemorizationNotificationOnExit();
    }
  }

  void _getCurrentUserId() {
    final prefsHelper = getIt<SharedPrefsHelper>();
    if (prefsHelper.isLoggedIn) {
      _userId = prefsHelper.userId;
      return;
    }

    final authState = getIt<AuthBloc>().state;
    authState.maybeMap(
      authenticated: (authenticatedState) {
        _userId = authenticatedState.user.id;
      },
      orElse: () {},
    );
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final hasSubscription = await SubscriptionService.hasAnySubscription();
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

  void _recordRecentlyRead(int surahId, int verseId) {
    if (_lastRecordedVerseId == verseId) {
      return;
    }

    _recentlyReadTimer?.cancel();

    _recentlyReadTimer = Timer(const Duration(milliseconds: 500), () {
      if (_userId != null) {
        _lastRecordedVerseId = verseId;
        _memorizationSyncService.recordRecentlyRead(
          _userId,
          surahId,
          verseId,
          source: 'verse_view',
        );
      }
    });
  }

  void _setupAudioServiceListeners() {
    final audioService = SharedAudioService.instance;

    _playingSubscription = audioService.playingStateStream.listen((isPlaying) {
      if (mounted) {
        // Only sync playing state if audio is from this screen or if stopping
        if (audioService.originatingScreen == 'verse_view' || !isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
            if (!isPlaying) {
              // Only clear highlights when audio stops completely
              _currentHighlightedWordIndex = -1;
              _previousHighlightedWordIndex = -1;
            }
          });
        }
      }
    });

    _loadingSubscription = audioService.loadingStateStream.listen((isLoading) {
      // Loading state tracking removed - not currently used in UI
      // Only keeping subscription for potential future use
    });

    _verseSubscription = audioService.currentVerseStream.listen((verseId) {
      // Sync verse changes if audio is playing from this screen OR if it's auto-advancing
      if (mounted) {
        final currentSurahNumber = audioService.currentSurah?.number;

        // Check if the current surah has changed (auto-advanced to next surah)
        if (currentSurahNumber != null &&
            currentSurahNumber != widget.surah.number) {
          // The audio service has moved to a different surah, so we should navigate to that surah
          if (mounted) {
            // Navigate to the new surah in verse view mode
            context.pushReplacementNamed(
              Routes.verseView.name,
              queryParameters: {
                'surahId': currentSurahNumber.toString(),
                'verseId': verseId.toString(),
                'isMemorizationMode': widget.isMemorizationMode.toString(),
              },
            );
          }
        } else if (verseId != _currentVerseId &&
            verseId <= widget.surah.ayahs.length) {
          // Same surah, different verse

          // More permissive condition: scroll if audio is playing from verse_view OR if it's auto-advancing
          final shouldUpdateUI =
              audioService.originatingScreen == 'verse_view' ||
              (audioService.isPlaying &&
                  audioService.currentContext == 'quran' &&
                  audioService.currentSurah?.number == widget.surah.number);

          if (shouldUpdateUI) {
            setState(() {
              _currentVerseId = verseId;
              // Reset highlights when changing verse
              _currentHighlightedWordIndex = -1;
              _previousHighlightedWordIndex = -1;
              _repeatCount = 1;
            });
            audioService.setRepeatCount(_repeatCount);

            // IMPORTANT: Always scroll when verse changes during playback
            _scrollToVerse(verseId);
            _recordRecentlyRead(widget.surah.number, verseId);
          }
        }
      }
    });

    _highlightSubscription = audioService.highlightedWordStream.listen((
      wordIndex,
    ) {
      // Only sync highlights if audio is playing from this screen
      if (mounted && audioService.originatingScreen == 'verse_view') {
        setState(() {
          if (wordIndex != _currentHighlightedWordIndex) {
            _previousHighlightedWordIndex = _currentHighlightedWordIndex;
            _currentHighlightedWordIndex = wordIndex;
          }
        });
      }
    });

    // Initialize highlighting immediately when audio starts (only if from this screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && audioService.originatingScreen == 'verse_view') {
        final currentIsPlaying = audioService.isPlaying;
        final currentVerseId = audioService.currentVerseId;
        final currentHighlightIndex = audioService.currentHighlightedWordIndex;

        final isMatchingContext =
            audioService.currentSurah?.number == widget.surah.number;

        if (isMatchingContext) {
          setState(() {
            _isPlaying = currentIsPlaying;
            if (currentVerseId != _currentVerseId) {
              _currentVerseId = currentVerseId;
              _scrollToVerse(currentVerseId);
            }
            // Initialize highlighting immediately if audio is playing
            if (currentIsPlaying && currentHighlightIndex >= 0) {
              _currentHighlightedWordIndex = currentHighlightIndex;
            }
          });
        }
      }
    });
  }

  List<String> _splitArabicText(String text) {
    final RegExp regex = RegExp(r'(\s+)|([^\s]+)');
    final matches = regex.allMatches(text);
    final List<String> words = [];

    for (final match in matches) {
      if (match.group(2) != null) {
        words.add(match.group(2)!);
      }
    }

    return words;
  }

  void _loadVerseViewSettings() {
    final prefsHelper = getIt<SharedPrefsHelper>();
    final settingsJson = prefsHelper.getVerseViewSettings();
    _verseViewSettings = VerseViewSettings.fromJson(settingsJson ?? {});
  }

  Future<void> _loadVerseStatuses() async {
    Map<int, MemorizationStatus> statuses = {};

    try {
      for (var ayah in widget.surah.ayahs) {
        try {
          final status = await _memorizationSyncService.getVerseProgress(
            _userId,
            widget.surah.number,
            ayah.numberInSurah,
          );
          statuses[ayah.numberInSurah] =
              status ?? MemorizationStatus.notStarted;
        } catch (e) {
          logger.e(
            'Error getting verse status for surah ${widget.surah.number}, verse ${ayah.numberInSurah}: $e',
          );
          statuses[ayah.numberInSurah] = MemorizationStatus.notStarted;
        }
      }

      if (mounted) {
        setState(() {
          _verseStatuses = statuses;
        });
      }
    } catch (e) {
      logger.e('Error loading verse statuses: $e');
      if (mounted) {
        setState(() {
          _verseStatuses = statuses;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scheduleMemorizationNotificationOnExit();
    _playingSubscription?.cancel();
    _loadingSubscription?.cancel();
    _verseSubscription?.cancel();
    _highlightSubscription?.cancel();
    _recentlyReadTimer?.cancel();
    _scrollController.dispose();
    // Cancel subscription listener
    _subscriptionStatusSub?.cancel();
    super.dispose();
  }

  Future<void> _scheduleMemorizationNotificationOnExit() async {
    if (_notificationScheduled) {
      logger.i('Notification already scheduled, skipping...');
      return;
    }

    try {
      _notificationScheduled = true;

      await getIt<MemorizationReminderService>().scheduleMemorizationReminder(
        surahNumber: widget.surah.number,
        verseNumber: _currentVerseId,
        surahName: widget.surah.englishName,
      );

      logger.i(
        'Memorization reminder scheduled for verse $_currentVerseId in ${widget.surah.englishName}',
      );
    } catch (e) {
      logger.e('Error scheduling memorization reminder on exit: $e');
      _notificationScheduled = false;
    }
  }

  void _scrollToVerse(int verseId) {
    final index = widget.surah.ayahs.indexWhere(
      (ayah) => ayah.numberInSurah == verseId,
    );
    _recordRecentlyRead(widget.surah.number, verseId);

    if (index >= 0) {
      // Use addPostFrameCallback to ensure controller is attached
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _itemScrollController.isAttached) {
          try {
            _itemScrollController.scrollTo(
              index: index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.3,
            );
            logger.d('Scrolled to verse $verseId at index $index');
          } catch (e) {
            logger.e('Error scrolling to verse: $e');
          }
        } else {
          logger.w(
            'Cannot scroll: mounted=$mounted, attached=${_itemScrollController.isAttached}',
          );
        }
      });
    }
  }

  Ayah _getCurrentAyah() {
    return widget.surah.ayahs.firstWhere(
      (ayah) => ayah.numberInSurah == _currentVerseId,
      orElse: () => widget.surah.ayahs.first,
    );
  }

  void _navigateToNextVerse() {
    if (_currentVerseId < widget.surah.ayahs.length) {
      final audioService = SharedAudioService.instance;
      final wasPlaying = audioService.isPlaying;

      if (wasPlaying) {
        audioService.stop();
      }

      setState(() {
        _currentVerseId++;
        _repeatCount = 1;
        // Reset highlights when changing verse
        _currentHighlightedWordIndex = -1;
        _previousHighlightedWordIndex = -1;
      });

      audioService.setSurahAndVerse(
        widget.surah,
        _currentVerseId,
        screen: 'verse_view',
      );
      audioService.setRepeatCount(_repeatCount);
      audioService.setAutoAdvance(_autoAdvance);

      // Smooth scroll to the next verse
      _scrollToVerse(_currentVerseId);

      if (wasPlaying) {
        // Instant playback - no delay
        _playCurrentAudio();
      }
    }
  }

  void _navigateToPreviousVerse() {
    if (_currentVerseId > 1) {
      final audioService = SharedAudioService.instance;
      final wasPlaying = audioService.isPlaying;

      if (wasPlaying) {
        audioService.stop();
      }

      setState(() {
        _currentVerseId--;
        _repeatCount = 1;
        // Reset highlights when changing verse
        _currentHighlightedWordIndex = -1;
        _previousHighlightedWordIndex = -1;
      });

      audioService.setSurahAndVerse(
        widget.surah,
        _currentVerseId,
        screen: 'verse_view',
      );
      audioService.setRepeatCount(_repeatCount);
      audioService.setAutoAdvance(_autoAdvance);

      // Smooth scroll to the previous verse
      _scrollToVerse(_currentVerseId);

      if (wasPlaying) {
        // Instant playback - no delay
        _playCurrentAudio();
      }
    }
  }

  Future<void> _playAudio() async {
    final audioService = SharedAudioService.instance;

    if (!audioService.isInitialized) {
      try {
        await audioService.initialize();
      } catch (e) {
        logger.e('Failed to initialize audio service: $e');
        if (mounted) {
          context.showErrorSnackBar(
            'Audio service not available. Please try again.',
          );
        }
        return;
      }
    }

    try {
      logger.d(
        'VerseViewScreen: Attempting to play audio - isPlaying: ${audioService.isPlaying}',
      );

      audioService.setSurahAndVerse(
        widget.surah,
        _currentVerseId,
        screen: 'verse_view',
      );
      audioService.setRepeatCount(_repeatCount);
      audioService.setAutoAdvance(_autoAdvance);

      logger.d(
        'VerseViewScreen: Applied settings - Repeat: $_repeatCount, Auto-advance: $_autoAdvance',
      );

      if (audioService.isPlaying) {
        await audioService.pause();
        logger.d('VerseViewScreen: Audio paused');
      } else {
        int targetVerseId = _currentVerseId;
        bool shouldForceRestart = false;

        if (audioService.surahCompleted &&
            _currentVerseId >= widget.surah.ayahs.length) {
          logger.d('VerseViewScreen: Surah completed, restarting from verse 1');
          targetVerseId = 1;
          setState(() {
            _currentVerseId = 1;
            _repeatCount = 1;
          });
          shouldForceRestart = true;
        } else {
          final isSameVerse =
              audioService.currentSurah?.number == widget.surah.number &&
              audioService.currentVerseId == _currentVerseId &&
              audioService.originatingScreen == 'verse_view';
          shouldForceRestart = !isSameVerse;
        }

        await audioService.playQuranVerse(
          surah: widget.surah,
          verseId: targetVerseId,
          playbackSpeed: _playbackSpeed,
          forceRestart: shouldForceRestart,
        );
        logger.d(
          'VerseViewScreen: Audio started playing (verse: $targetVerseId, forceRestart: $shouldForceRestart)',
        );
      }
    } catch (e) {
      logger.e('Error playing/pausing audio: $e');

      if (mounted) {
        context.showErrorSnackBar(
          'Unable to control audio playback. Please try again.',
        );
      }
    }
  }

  Future<void> _playCurrentAudio() async {
    final ayah = _getCurrentAyah();
    _recordRecentlyRead(widget.surah.number, ayah.numberInSurah);

    final audioService = SharedAudioService.instance;

    if (!audioService.isInitialized) {
      try {
        await audioService.initialize();
      } catch (e) {
        logger.e('Failed to initialize audio service: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Audio service not available. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    try {
      if (audioService.isPlaying) {
        await audioService.stop();
      }

      audioService.setSurahAndVerse(
        widget.surah,
        ayah.numberInSurah,
        screen: 'verse_view',
      );
      audioService.setRepeatCount(_repeatCount);
      audioService.setAutoAdvance(_autoAdvance);

      logger.d(
        'VerseViewScreen: Starting verse ${ayah.numberInSurah} with settings - Repeat: $_repeatCount, Auto-advance: $_autoAdvance, Total verses: ${widget.surah.ayahs.length}',
      );

      final isSameVerse =
          audioService.currentSurah?.number == widget.surah.number &&
          audioService.currentVerseId == ayah.numberInSurah &&
          audioService.originatingScreen == 'verse_view';

      await audioService.playQuranVerse(
        surah: widget.surah,
        verseId: ayah.numberInSurah,
        playbackSpeed: _playbackSpeed,
        forceRestart: !isSameVerse,
      );

      logger.d('VerseViewScreen: Started playing verse ${ayah.numberInSurah}');
    } catch (e) {
      logger.e('Error playing audio: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to play audio. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateMemorizationStatus(MemorizationStatus status) async {
    final prefsHelper = getIt<SharedPrefsHelper>();
    final isLoggedIn = prefsHelper.isLoggedIn;

    if (!isLoggedIn) {
      _showLoginRequiredDialog('memorization status');
      return;
    }

    if (!_hasSubscription) {
      _showSubscriptionRequiredDialog();
      return;
    }

    try {
      await _memorizationSyncService.saveVerseProgress(
        _userId,
        widget.surah.number,
        _currentVerseId,
        status,
      );

      if (mounted) {
        setState(() {
          _verseStatuses[_currentVerseId] = status;
        });

        context.showSnackBar(
          'Verse marked as ${status.toString().split('.').last}',
        );
      }
    } catch (e) {
      logger.e('Error updating memorization status: $e');
      if (mounted) {
        context.showErrorSnackBar('Failed to update status: Please try again');
      }
    }
  }

  void _decreaseRepeatCount() {
    if (_repeatCount > 1) {
      setState(() {
        _repeatCount--;
      });
      SharedAudioService.instance.setRepeatCount(_repeatCount);
    }
  }

  void _increaseRepeatCount() {
    setState(() {
      _repeatCount++;
    });
    SharedAudioService.instance.setRepeatCount(_repeatCount);
  }

  Color _getStatusColor(int verseId) => _verseStatuses[verseId].getColorValue();
  IconData _getStatusIcon(int verseId) =>
      _verseStatuses[verseId].getIconValue();

  Future<void> _getAIExplanation(int verseId) async {
    final prefsHelper = getIt<SharedPrefsHelper>();
    final isLoggedIn = prefsHelper.isLoggedIn;

    if (!isLoggedIn) {
      setState(() {
        _verseExplanations[verseId] =
            "⚠️ Login Required: You need to log in to use the AI explanation feature.";
        _isLoadingExplanation[verseId] = false;
      });
      return;
    }

    // Check for DeenHub Pro subscription
    final hasDeenHubPro = await SubscriptionService.isDeenHubProSubscribed();
    if (!hasDeenHubPro) {
      setState(() {
        _verseExplanations[verseId] =
            "⚠️ DeenHub Pro Required: AI explanation is available exclusively for DeenHub Pro subscribers.";
        _isLoadingExplanation[verseId] = false;
      });
      _showAISubscriptionRequiredDialog();
      return;
    }

    // Check monthly token limit before sending message
    final usageTracker = AIUsageTrackingService();
    final canMakeRequest = await usageTracker.canMakeRequest(
      estimatedTokens: 500, // Estimate for a typical request
    );

    if (!canMakeRequest) {
      setState(() {
        _verseExplanations[verseId] =
            "⚠️ Monthly Limit Exceeded: You have reached your monthly limit for AI explanations.";
        _isLoadingExplanation[verseId] = false;
      });
      _showMonthlyLimitExceededDialog();
      return;
    }

    if (_isLoadingExplanation[verseId] == true) {
      return;
    }

    setState(() {
      _isLoadingExplanation[verseId] = true;
    });

    try {
      final ayah = widget.surah.ayahs.firstWhere(
        (ayah) => ayah.numberInSurah == verseId,
        orElse: () => widget.surah.ayahs.first,
      );

      final prompt =
          'Quran Surah ${widget.surah.number} Verse ${ayah.numberInSurah} - Explain the verse and give me the context of this verse. Don\'t write the verse. Please write in concise';

      final explanation = await _chatGPTService.getResponse(prompt);

      setState(() {
        _verseExplanations[verseId] = explanation.text;
        _isLoadingExplanation[verseId] = false;
      });
    } catch (e) {
      setState(() {
        _verseExplanations[verseId] =
            'Error loading explanation: ${e.toString()}';
        _isLoadingExplanation[verseId] = false;
      });
    }
  }

  void _toggleSingleVerseMode() {
    setState(() {
      _singleVerseMode = !_singleVerseMode;
    });

    if (_singleVerseMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse(_currentVerseId);
      });
    }

    context.showSnackBar(
      _singleVerseMode
          ? 'Single verse mode enabled'
          : 'All verses mode enabled',
    );
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });

    if (SharedAudioService.instance.isPlaying) {
      SharedAudioService.instance.setSpeed(_playbackSpeed);
    }

    context.showSnackBar('Playback speed set to ${speed}x');
  }

  Widget _buildArabicTextWithHighlighting(Ayah ayah, bool isCurrentVerse) {
    final shouldHighlight =
        _isPlaying &&
        isCurrentVerse &&
        ayah.wordTiming != null &&
        ayah.wordTiming!.segments.isNotEmpty &&
        _currentHighlightedWordIndex >= 0;

    if (!shouldHighlight) {
      return RichText(
        text: TextSpan(
          text: ayah.text,
          style: TextStyle(
            fontSize: 20,
            height: 2.5, // Consistent line height with highlighting
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold, // Consistent weight
            color: isCurrentVerse ? const Color(0xFF293241) : Colors.black,
          ),
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      );
    }

    final words = _splitArabicText(ayah.text);

    if (words.isEmpty) {
      return RichText(
        text: TextSpan(
          text: ayah.text,
          style: TextStyle(
            fontSize: 20,
            height: 2.5, // Consistent line height with highlighting
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold, // Consistent weight
            color: isCurrentVerse ? const Color(0xFF293241) : Colors.black,
          ),
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      );
    }

    return RichText(
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: _buildHighlightedWordsSpans(
          words,
          ayah.wordTiming!.segments,
          isCurrentVerse,
        ),
      ),
    );
  }

  List<TextSpan> _buildHighlightedWordsSpans(
    List<String> words,
    List<WordSegment> segments,
    bool isCurrentVerse,
  ) {
    final List<TextSpan> spans = [];
    final int wordCount = words.length;

    for (int i = 0; i < wordCount; i++) {
      bool isHighlighted = false;
      bool wasPreviouslyHighlighted = false;

      // Check current highlight
      if (_currentHighlightedWordIndex >= 0 &&
          _currentHighlightedWordIndex < segments.length) {
        final currentSegment = segments[_currentHighlightedWordIndex];
        if (i >= currentSegment.wordStartIndex &&
            i < currentSegment.wordEndIndex) {
          isHighlighted = true;
        }
      }

      // Check previous highlight only if not currently highlighted
      if (_previousHighlightedWordIndex >= 0 &&
          _previousHighlightedWordIndex < segments.length &&
          !isHighlighted) {
        final previousSegment = segments[_previousHighlightedWordIndex];
        if (i >= previousSegment.wordStartIndex &&
            i < previousSegment.wordEndIndex) {
          wasPreviouslyHighlighted = true;
        }
      }

      spans.add(
        TextSpan(
          text: words[i] + (i < wordCount - 1 ? ' ' : ''),
          style: TextStyle(
            fontSize: 20, // Consistent font size
            height: 2.5, // Consistent line height - never changes
            fontWeight: FontWeight.bold, // Consistent weight for all text
            fontFamily: 'Amiri',
            wordSpacing: 0,
            color: isHighlighted
                ? const Color(0xFFD32F2F)
                : (isCurrentVerse ? const Color(0xFF293241) : Colors.black),
            backgroundColor: isHighlighted
                ? const Color(0xFFFFF3E0)
                : (wasPreviouslyHighlighted
                      ? const Color(0xFFFFF3E0).withValues(alpha: 0.1)
                      : null), // Much lighter previous highlight
          ),
        ),
      );
    }

    return spans;
  }

  void _showLoginRequiredDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) => LoginRequiredDialog(feature: feature),
    );
  }

  void _showSubscriptionRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SubscriptionRequiredDialog(),
    );
  }

  void _showAISubscriptionRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const AiSubscriptionRequiredDialog(),
    );
  }

  void _showMonthlyLimitExceededDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const MonthlyLimitExceededDialog(),
    );
  }

  void _showAIExplanationReportDialog(int verseNumber, String explanation) {
    // Check if user is logged in
    final prefsHelper = getIt<SharedPrefsHelper>();
    final isLoggedIn = prefsHelper.isLoggedIn;

    if (!isLoggedIn) {
      _showLoginRequiredDialog('report');
      return;
    }

    ReportDialog.showAIExplanationReport(
      context,
      explanation: explanation,
      surahNumber: widget.surah.number,
      verseNumber: verseNumber,
      additionalContext: {
        'surah_name': widget.surah.englishName,
        'surah_arabic_name': widget.surah.name,
        'total_verses': widget.surah.ayahs.length,
        'is_memorization_mode': widget.isMemorizationMode,
      },
    );
  }

  final selectedBgColor = Color(0xFFB2DFDB);
  final unselectedBgColor = Color(0xFF80CBC4);
  final selectedTextColor = Color(0xFF00695C);
  final unselectedTextColor = Color(0xFF004D40);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          await _scheduleMemorizationNotificationOnExit();
        }
      },
      child: AppBarScaffold(
        centerTitle: true,
        searchBar: SurahHeaderWidget(surah: widget.surah),
        appBarActions: [
          IconButton(
            icon: Icon(
              _singleVerseMode ? Icons.fullscreen : Icons.view_list,
              color: Colors.white,
            ),
            onPressed: _toggleSingleVerseMode,
            tooltip: _singleVerseMode ? 'Focus Mode On' : 'Focus Mode Off',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              await context.pushNamed(Routes.verseViewSettings.name);
              // Always reload settings when returning from settings screen
              _loadVerseViewSettings();
              setState(() {});
            },
            tooltip: 'Verse View Settings',
          ),
        ],
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        child: Column(
          children: [
            // Subscription warning if logged in but not subscribed
            if (_userId != null &&
                !_hasSubscription &&
                !_isCheckingSubscription)
              const SubscriptionRequiredView(),
            ControlButtonsWidget(
              singleVerseMode: _singleVerseMode,
              selectedLanguage: _selectedLanguage,
              selectedBgColor: selectedBgColor,
              unselectedBgColor: unselectedBgColor,
              selectedTextColor: selectedTextColor,
              unselectedTextColor: unselectedTextColor,
              onToggleSingleVerseMode: _toggleSingleVerseMode,
              onLanguageChanged: (language) {
                setState(() {
                  _selectedLanguage = language;
                });
              },
            ),
            gapH8,
            if (_singleVerseMode)
              SingleVerseNavigationWidget(
                currentVerseId: _currentVerseId,
                totalVerses: widget.surah.ayahs.length,
                onPreviousVerse: _navigateToPreviousVerse,
                onNextVerse: _navigateToNextVerse,
              ),
            Expanded(
              child: ScrollablePositionedList.builder(
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                itemCount: _singleVerseMode ? 1 : widget.surah.ayahs.length,
                itemBuilder: (context, index) {
                  final ayah = _singleVerseMode
                      ? _getCurrentAyah()
                      : widget.surah.ayahs[index];

                  final isCurrentVerse = ayah.numberInSurah == _currentVerseId;
                  final verseStatus = _verseStatuses[ayah.numberInSurah];

                  if (_singleVerseMode && !isCurrentVerse) {
                    return const SizedBox.shrink();
                  }

                  return VerseCardWidget(
                    ayah: ayah,
                    isCurrentVerse: isCurrentVerse,
                    verseStatus: verseStatus,
                    isResultVerse: widget.isResultVerse,
                    isMemorizationMode:
                        widget.isMemorizationMode && _hasSubscription,
                    isPlaying: _isPlaying,
                    arabicTextWidget: _buildArabicTextWithHighlighting(
                      ayah,
                      isCurrentVerse,
                    ),
                    currentHighlightedWordIndex: _currentHighlightedWordIndex,
                    verseExplanations: _verseExplanations,
                    isLoadingExplanation: _isLoadingExplanation,
                    repeatCount: _repeatCount,
                    playbackSpeed: _playbackSpeed,
                    selectedLanguage: _selectedLanguage,
                    onVerseTap: () {
                      setState(() {
                        _currentVerseId = ayah.numberInSurah;
                        _repeatCount = 1;
                        // Reset highlights when changing verse
                        _currentHighlightedWordIndex = -1;
                        _previousHighlightedWordIndex = -1;
                        // Don't show loading during instant transitions

                        if (_isPlaying) {
                          SharedAudioService.instance.stop();
                        }
                      });

                      // Smooth scroll to the tapped verse
                      _scrollToVerse(ayah.numberInSurah);
                    },
                    onPlayAudio: () async {
                      SharedAudioService.instance.setSurahAndVerse(
                        widget.surah,
                        _currentVerseId,
                        screen: 'verse_view',
                      );
                      SharedAudioService.instance.setRepeatCount(_repeatCount);
                      SharedAudioService.instance.setAutoAdvance(_autoAdvance);
                      logger.d(
                        'VerseViewScreen: Play button pressed - Repeat: $_repeatCount, Auto-advance: $_autoAdvance',
                      );
                      await _playAudio();
                    },
                    onPlayOtherVerse: () {
                      setState(() {
                        _currentVerseId = ayah.numberInSurah;
                        _repeatCount = 1;
                        // Reset highlights when changing verse
                        _currentHighlightedWordIndex = -1;
                        _previousHighlightedWordIndex = -1;
                        // Don't show loading during instant transitions
                      });

                      SharedAudioService.instance.setSurahAndVerse(
                        widget.surah,
                        ayah.numberInSurah,
                        screen: 'verse_view',
                      );
                      SharedAudioService.instance.setRepeatCount(_repeatCount);
                      SharedAudioService.instance.setAutoAdvance(_autoAdvance);

                      // Smooth scroll to the verse before playing
                      _scrollToVerse(ayah.numberInSurah);

                      // Instant playback - no delay
                      SharedAudioService.instance.playQuranVerse(
                        surah: widget.surah,
                        verseId: ayah.numberInSurah,
                        playbackSpeed: _playbackSpeed,
                        forceRestart: true,
                      );
                    },
                    onGetAIExplanation: () =>
                        _getAIExplanation(ayah.numberInSurah),
                    onRemoveExplanation: () {
                      setState(() {
                        _verseExplanations.remove(ayah.numberInSurah);
                      });
                    },
                    onDecreaseRepeatCount: _decreaseRepeatCount,
                    onIncreaseRepeatCount: _increaseRepeatCount,
                    onChangePlaybackSpeed: _changePlaybackSpeed,
                    onUpdateMemorizationStatus: _updateMemorizationStatus,
                    onShowLoginRequiredDialog: _showLoginRequiredDialog,
                    getStatusColor: _getStatusColor,
                    getStatusIcon: _getStatusIcon,
                    onReportAIExplanation: _showAIExplanationReportDialog,
                    onShowSubscriptionRequiredDialog:
                        _showSubscriptionRequiredDialog,
                    verseViewSettings: _verseViewSettings,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:deenhub/config/routes/routes.dart';
// import 'package:deenhub/config/themes/styles.dart';
// import 'package:deenhub/core/di/app_injections.dart';
// import 'package:deenhub/core/notification/services/memorization_reminder_service.dart';
// import 'package:deenhub/core/services/ai_usage/ai_usage_tracking_service.dart';
// import 'package:deenhub/core/services/shared_prefs_helper.dart';
// import 'package:deenhub/core/utils/view_utils.dart';
// import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/memorization_reading_mode_widgets.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/surah_header_widget.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/verse_card_widget.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/verse_view/verse_view_dialogs.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/settings/models/verse_view_settings.dart';
// import 'package:deenhub/main.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:deenhub/core/services/shared_audio_service.dart';
// import 'package:deenhub/features/quran/domain/models/memorization_model.dart';
// import 'package:deenhub/features/quran/domain/models/quran_model.dart';
// import 'package:deenhub/features/ai_chatbot/domain/models/chatgpt_service.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import 'package:deenhub/features/auth/data/services/memorization_sync_service.dart';
// import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:deenhub/features/subscription/data/services/subscription_service.dart';
// import 'package:deenhub/core/widgets/dialog/report_dialog.dart';
// import 'dart:async';

// class VerseViewScreen extends StatefulWidget {
//   final Surah surah;
//   final int initialVerseId;
//   final bool isMemorizationMode;
//   final bool isResultVerse;

//   const VerseViewScreen({
//     super.key,
//     required this.surah,
//     required this.initialVerseId,
//     this.isMemorizationMode = true,
//     this.isResultVerse = false,
//   });

//   @override
//   State<VerseViewScreen> createState() => _VerseViewScreenState();
// }

// class _VerseViewScreenState extends State<VerseViewScreen>
//     with WidgetsBindingObserver {
//   late int _currentVerseId;
//   bool _isPlaying = false;
//   final MemorizationSyncService _memorizationSyncService =
//       getIt<MemorizationSyncService>();
//   final ChatGPTService _chatGPTService = ChatGPTService();
//   late ScrollController _scrollController;
//   int _repeatCount = 1;
//   bool _autoAdvance = true;
//   Map<int, MemorizationStatus> _verseStatuses = {};
//   final Map<int, String> _verseExplanations = {};
//   final Map<int, bool> _isLoadingExplanation = {};
//   String? _userId;
//   bool _notificationScheduled = false;
//   String _selectedLanguage = 'en'; // 'en' for English, 'bn' for Bengali

//   // Add subscription checking state
//   bool _hasSubscription = false;
//   bool _isCheckingSubscription = true;
//   // Listen to subscription updates
//   StreamSubscription<bool>? _subscriptionStatusSub;

//   double _playbackSpeed = 1.0;
//   Timer? _recentlyReadTimer;
//   int _lastRecordedVerseId = -1;
//   bool _singleVerseMode = false;
//   int _currentHighlightedWordIndex = -1;
//   int _previousHighlightedWordIndex = -1;

//   StreamSubscription<bool>? _playingSubscription;
//   StreamSubscription<bool>? _loadingSubscription;
//   StreamSubscription<int>? _verseSubscription;
//   StreamSubscription<int>? _highlightSubscription;

//   final ItemScrollController _itemScrollController = ItemScrollController();
//   final ItemPositionsListener _itemPositionsListener =
//       ItemPositionsListener.create();

//   late VerseViewSettings _verseViewSettings;

//   @override
//   void initState() {
//     super.initState();
//     _currentVerseId = widget.initialVerseId;
//     logger.i('initialVerseId: $_currentVerseId');
//     _scrollController = ScrollController();

//     WidgetsBinding.instance.addObserver(this);
//     _getCurrentUserId();
//     _checkSubscriptionStatus();
//     // Listen for subscription purchase updates
//     _subscriptionStatusSub = getIt<SubscriptionService>().purchaseStatusStream
//         .listen((success) async {
//           final hasAny = await SubscriptionService.hasAnySubscription();
//           if (!mounted) return;
//           setState(() {
//             _hasSubscription = hasAny;
//             _isCheckingSubscription = false;
//           });
//         });
//     _recordRecentlyRead(widget.surah.number, _currentVerseId);
//     _loadVerseStatuses();
//     _loadVerseViewSettings();
//     _repeatCount = 1;
//     SharedAudioService.instance.setRepeatCount(_repeatCount);
//     _autoAdvance = SharedAudioService.instance.autoAdvance;

//     final audioService = SharedAudioService.instance;
//     final bool fromSearch = widget.isResultVerse;

//     // Determine effective initial verse. If coming from a different screen/mode
//     // for the same surah (and not from search), force start from verse 1.
//     int effectiveInitialVerse = widget.initialVerseId;
//     if (!fromSearch &&
//         audioService.currentContext == 'quran' &&
//         audioService.originatingScreen != 'verse_view' &&
//         audioService.currentSurah?.number == widget.surah.number) {
//       effectiveInitialVerse = 1;
//     }
//     _currentVerseId = effectiveInitialVerse;
//     logger.i('initialVerseId (effective): $_currentVerseId');

//     if (!audioService.isInitialized) {
//       audioService
//           .initialize()
//           .then((_) {
//             if (mounted) {
//               // Always stop audio when switching to verse_view from any different screen
//               if (audioService.isPlaying &&
//                   audioService.originatingScreen != 'verse_view') {
//                 audioService.stop();
//               }

//               if (fromSearch) {
//                 setState(() {
//                   _currentVerseId = widget.initialVerseId;
//                 });
//                 audioService.setSurahAndVerse(
//                   widget.surah,
//                   _currentVerseId,
//                   screen: 'verse_view',
//                 );
//               } else {
//                 // Always use the current verse from this screen, don't sync with audio service
//                 audioService.setSurahAndVerse(
//                   widget.surah,
//                   _currentVerseId,
//                   screen: 'verse_view',
//                 );
//               }
//             }
//           })
//           .catchError((e) {
//             logger.e('Failed to initialize audio service: $e');
//           });
//     } else {
//       // Always stop audio when switching to verse_view from any different screen
//       if (audioService.isPlaying &&
//           audioService.originatingScreen != 'verse_view') {
//         audioService.stop();
//       }

//       if (fromSearch) {
//         if (_currentVerseId != widget.initialVerseId) {
//           setState(() {
//             _currentVerseId = widget.initialVerseId;
//           });
//         }
//         audioService.setSurahAndVerse(
//           widget.surah,
//           _currentVerseId,
//           screen: 'verse_view',
//         );
//       } else {
//         // Always use the current verse from this screen, don't sync with audio service
//         audioService.setSurahAndVerse(
//           widget.surah,
//           _currentVerseId,
//           screen: 'verse_view',
//         );
//       }
//     }

//     _setupAudioServiceListeners();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToVerse(_currentVerseId);
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       _scheduleMemorizationNotificationOnExit();
//     }
//   }

//   void _getCurrentUserId() {
//     final prefsHelper = getIt<SharedPrefsHelper>();
//     if (prefsHelper.isLoggedIn) {
//       _userId = prefsHelper.userId;
//       return;
//     }

//     final authState = getIt<AuthBloc>().state;
//     authState.maybeMap(
//       authenticated: (authenticatedState) {
//         _userId = authenticatedState.user.id;
//       },
//       orElse: () {},
//     );
//   }

//   Future<void> _checkSubscriptionStatus() async {
//     try {
//       final hasSubscription = await SubscriptionService.hasAnySubscription();
//       if (mounted) {
//         setState(() {
//           _hasSubscription = hasSubscription;
//           _isCheckingSubscription = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _hasSubscription = false;
//           _isCheckingSubscription = false;
//         });
//       }
//     }
//   }

//   void _recordRecentlyRead(int surahId, int verseId) {
//     if (_lastRecordedVerseId == verseId) {
//       return;
//     }

//     _recentlyReadTimer?.cancel();

//     _recentlyReadTimer = Timer(const Duration(milliseconds: 500), () {
//       if (_userId != null) {
//         _lastRecordedVerseId = verseId;
//         _memorizationSyncService.recordRecentlyRead(
//           _userId,
//           surahId,
//           verseId,
//           source: 'verse_view',
//         );
//       }
//     });
//   }

//   void _setupAudioServiceListeners() {
//     final audioService = SharedAudioService.instance;

//     _playingSubscription = audioService.playingStateStream.listen((isPlaying) {
//       if (mounted) {
//         // Only sync playing state if audio is from this screen or if stopping
//         if (audioService.originatingScreen == 'verse_view' || !isPlaying) {
//           setState(() {
//             _isPlaying = isPlaying;
//             if (!isPlaying) {
//               // Only clear highlights when audio stops completely
//               _currentHighlightedWordIndex = -1;
//               _previousHighlightedWordIndex = -1;
//             }
//           });
//         }
//       }
//     });

//     _loadingSubscription = audioService.loadingStateStream.listen((isLoading) {
//       // Loading state tracking removed - not currently used in UI
//       // Only keeping subscription for potential future use
//     });

//     _verseSubscription = audioService.currentVerseStream.listen((verseId) {
//       // Sync verse changes if audio is playing from this screen OR if it's auto-advancing
//       if (mounted) {
//         final currentSurahNumber = audioService.currentSurah?.number;

//         // Check if the current surah has changed (auto-advanced to next surah)
//         if (currentSurahNumber != widget.surah.number) {
//           // The audio service has moved to a different surah, so we should navigate to that surah
//           if (mounted) {
//             // Navigate to the new surah in verse view mode
//             context.pushReplacementNamed(
//               Routes.verseView.name,
//               queryParameters: {
//                 'surahId': currentSurahNumber.toString(),
//                 'verseId': verseId.toString(),
//                 'isMemorizationMode': widget.isMemorizationMode.toString(),
//               },
//             );
//           }
//         } else if (verseId != _currentVerseId) {
//           // Same surah, different verse
//           final shouldUpdateUI = audioService.originatingScreen == 'verse_view' ||
//                                 (audioService.isPlaying && audioService.currentContext == 'quran' &&
//                                  audioService.currentSurah?.number == widget.surah.number);

//           if (shouldUpdateUI && verseId <= widget.surah.ayahs.length) {
//             setState(() {
//               _currentVerseId = verseId;
//               // Reset highlights when changing verse
//               _currentHighlightedWordIndex = -1;
//               _previousHighlightedWordIndex = -1;
//               _repeatCount = 1;
//             });
//             audioService.setRepeatCount(_repeatCount);

//             // Smooth scroll to the new verse
//             _scrollToVerse(verseId);
//             _recordRecentlyRead(widget.surah.number, verseId);
//           }
//         }
//       }
//     });

//     _highlightSubscription = audioService.highlightedWordStream.listen((
//       wordIndex,
//     ) {
//       // Only sync highlights if audio is playing from this screen
//       if (mounted && audioService.originatingScreen == 'verse_view') {
//         setState(() {
//           if (wordIndex != _currentHighlightedWordIndex) {
//             _previousHighlightedWordIndex = _currentHighlightedWordIndex;
//             _currentHighlightedWordIndex = wordIndex;
//           }
//         });
//       }
//     });

//     // Initialize highlighting immediately when audio starts (only if from this screen)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && audioService.originatingScreen == 'verse_view') {
//         final currentIsPlaying = audioService.isPlaying;
//         final currentVerseId = audioService.currentVerseId;
//         final currentHighlightIndex = audioService.currentHighlightedWordIndex;

//         final isMatchingContext =
//             audioService.currentSurah?.number == widget.surah.number;

//         if (isMatchingContext) {
//           setState(() {
//             _isPlaying = currentIsPlaying;
//             if (currentVerseId != _currentVerseId) {
//               _currentVerseId = currentVerseId;
//               _scrollToVerse(currentVerseId);
//             }
//             // Initialize highlighting immediately if audio is playing
//             if (currentIsPlaying && currentHighlightIndex >= 0) {
//               _currentHighlightedWordIndex = currentHighlightIndex;
//             }
//           });
//         }
//       }
//     });
//   }

//   List<String> _splitArabicText(String text) {
//     final RegExp regex = RegExp(r'(\s+)|([^\s]+)');
//     final matches = regex.allMatches(text);
//     final List<String> words = [];

//     for (final match in matches) {
//       if (match.group(2) != null) {
//         words.add(match.group(2)!);
//       }
//     }

//     return words;
//   }

//   void _loadVerseViewSettings() {
//     final prefsHelper = getIt<SharedPrefsHelper>();
//     final settingsJson = prefsHelper.getVerseViewSettings();
//     _verseViewSettings = VerseViewSettings.fromJson(settingsJson ?? {});
//   }

//   Future<void> _loadVerseStatuses() async {
//     Map<int, MemorizationStatus> statuses = {};

//     try {
//       for (var ayah in widget.surah.ayahs) {
//         try {
//           final status = await _memorizationSyncService.getVerseProgress(
//             _userId,
//             widget.surah.number,
//             ayah.numberInSurah,
//           );
//           statuses[ayah.numberInSurah] =
//               status ?? MemorizationStatus.notStarted;
//         } catch (e) {
//           logger.e(
//             'Error getting verse status for surah ${widget.surah.number}, verse ${ayah.numberInSurah}: $e',
//           );
//           statuses[ayah.numberInSurah] = MemorizationStatus.notStarted;
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _verseStatuses = statuses;
//         });
//       }
//     } catch (e) {
//       logger.e('Error loading verse statuses: $e');
//       if (mounted) {
//         setState(() {
//           _verseStatuses = statuses;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _scheduleMemorizationNotificationOnExit();
//     _playingSubscription?.cancel();
//     _loadingSubscription?.cancel();
//     _verseSubscription?.cancel();
//     _highlightSubscription?.cancel();
//     _recentlyReadTimer?.cancel();
//     _scrollController.dispose();
//     // Cancel subscription listener
//     _subscriptionStatusSub?.cancel();
//     super.dispose();
//   }

//   Future<void> _scheduleMemorizationNotificationOnExit() async {
//     if (_notificationScheduled) {
//       logger.i('Notification already scheduled, skipping...');
//       return;
//     }

//     try {
//       _notificationScheduled = true;

//       await getIt<MemorizationReminderService>().scheduleMemorizationReminder(
//         surahNumber: widget.surah.number,
//         verseNumber: _currentVerseId,
//         surahName: widget.surah.englishName,
//       );

//       logger.i(
//         'Memorization reminder scheduled for verse $_currentVerseId in ${widget.surah.englishName}',
//       );
//     } catch (e) {
//       logger.e('Error scheduling memorization reminder on exit: $e');
//       _notificationScheduled = false;
//     }
//   }

//   void _scrollToVerse(int verseId) {
//     final index = widget.surah.ayahs.indexWhere(
//       (ayah) => ayah.numberInSurah == verseId,
//     );
//     _recordRecentlyRead(widget.surah.number, verseId);

//     if (index >= 0 && _itemScrollController.isAttached) {
//       // Instant scrolling for quick transitions
//       _itemScrollController.scrollTo(
//         index: index,
//         duration: const Duration(
//           milliseconds: 200,
//         ), // Reduced duration for quicker scrolling
//         curve: Curves.easeInOut,
//         alignment: 0.3, // Position verse closer to top for better visibility
//       );
//     }
//   }

//   Ayah _getCurrentAyah() {
//     return widget.surah.ayahs.firstWhere(
//       (ayah) => ayah.numberInSurah == _currentVerseId,
//       orElse: () => widget.surah.ayahs.first,
//     );
//   }

//   void _navigateToNextVerse() {
//     if (_currentVerseId < widget.surah.ayahs.length) {
//       final audioService = SharedAudioService.instance;
//       final wasPlaying = audioService.isPlaying;

//       if (wasPlaying) {
//         audioService.stop();
//       }

//       setState(() {
//         _currentVerseId++;
//         _repeatCount = 1;
//         // Reset highlights when changing verse
//         _currentHighlightedWordIndex = -1;
//         _previousHighlightedWordIndex = -1;
//       });

//       audioService.setSurahAndVerse(
//         widget.surah,
//         _currentVerseId,
//         screen: 'verse_view',
//       );
//       audioService.setRepeatCount(_repeatCount);
//       audioService.setAutoAdvance(_autoAdvance);

//       // Smooth scroll to the next verse
//       _scrollToVerse(_currentVerseId);

//       if (wasPlaying) {
//         // Instant playback - no delay
//         _playCurrentAudio();
//       }
//     }
//   }

//   void _navigateToPreviousVerse() {
//     if (_currentVerseId > 1) {
//       final audioService = SharedAudioService.instance;
//       final wasPlaying = audioService.isPlaying;

//       if (wasPlaying) {
//         audioService.stop();
//       }

//       setState(() {
//         _currentVerseId--;
//         _repeatCount = 1;
//         // Reset highlights when changing verse
//         _currentHighlightedWordIndex = -1;
//         _previousHighlightedWordIndex = -1;
//       });

//       audioService.setSurahAndVerse(
//         widget.surah,
//         _currentVerseId,
//         screen: 'verse_view',
//       );
//       audioService.setRepeatCount(_repeatCount);
//       audioService.setAutoAdvance(_autoAdvance);

//       // Smooth scroll to the previous verse
//       _scrollToVerse(_currentVerseId);

//       if (wasPlaying) {
//         // Instant playback - no delay
//         _playCurrentAudio();
//       }
//     }
//   }

//   Future<void> _playAudio() async {
//     final audioService = SharedAudioService.instance;

//     if (!audioService.isInitialized) {
//       try {
//         await audioService.initialize();
//       } catch (e) {
//         logger.e('Failed to initialize audio service: $e');
//         if (mounted) {
//           context.showErrorSnackBar(
//             'Audio service not available. Please try again.',
//           );
//         }
//         return;
//       }
//     }

//     try {
//       logger.d(
//         'VerseViewScreen: Attempting to play audio - isPlaying: ${audioService.isPlaying}',
//       );

//       audioService.setSurahAndVerse(
//         widget.surah,
//         _currentVerseId,
//         screen: 'verse_view',
//       );
//       audioService.setRepeatCount(_repeatCount);
//       audioService.setAutoAdvance(_autoAdvance);

//       logger.d(
//         'VerseViewScreen: Applied settings - Repeat: $_repeatCount, Auto-advance: $_autoAdvance',
//       );

//       if (audioService.isPlaying) {
//         await audioService.pause();
//         logger.d('VerseViewScreen: Audio paused');
//       } else {
//         int targetVerseId = _currentVerseId;
//         bool shouldForceRestart = false;

//         if (audioService.surahCompleted &&
//             _currentVerseId >= widget.surah.ayahs.length) {
//           logger.d('VerseViewScreen: Surah completed, restarting from verse 1');
//           targetVerseId = 1;
//           setState(() {
//             _currentVerseId = 1;
//             _repeatCount = 1;
//           });
//           shouldForceRestart = true;
//         } else {
//           final isSameVerse =
//               audioService.currentSurah?.number == widget.surah.number &&
//               audioService.currentVerseId == _currentVerseId &&
//               audioService.originatingScreen == 'verse_view';
//           shouldForceRestart = !isSameVerse;
//         }

//         await audioService.playQuranVerse(
//           surah: widget.surah,
//           verseId: targetVerseId,
//           playbackSpeed: _playbackSpeed,
//           forceRestart: shouldForceRestart,
//         );
//         logger.d(
//           'VerseViewScreen: Audio started playing (verse: $targetVerseId, forceRestart: $shouldForceRestart)',
//         );
//       }
//     } catch (e) {
//       logger.e('Error playing/pausing audio: $e');

//       if (mounted) {
//         context.showErrorSnackBar(
//           'Unable to control audio playback. Please try again.',
//         );
//       }
//     }
//   }

//   Future<void> _playCurrentAudio() async {
//     final ayah = _getCurrentAyah();
//     _recordRecentlyRead(widget.surah.number, ayah.numberInSurah);

//     final audioService = SharedAudioService.instance;

//     if (!audioService.isInitialized) {
//       try {
//         await audioService.initialize();
//       } catch (e) {
//         logger.e('Failed to initialize audio service: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Audio service not available. Please try again.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//         return;
//       }
//     }

//     try {
//       if (audioService.isPlaying) {
//         await audioService.stop();
//       }

//       audioService.setSurahAndVerse(
//         widget.surah,
//         ayah.numberInSurah,
//         screen: 'verse_view',
//       );
//       audioService.setRepeatCount(_repeatCount);
//       audioService.setAutoAdvance(_autoAdvance);

//       logger.d(
//         'VerseViewScreen: Starting verse ${ayah.numberInSurah} with settings - Repeat: $_repeatCount, Auto-advance: $_autoAdvance, Total verses: ${widget.surah.ayahs.length}',
//       );

//       final isSameVerse =
//           audioService.currentSurah?.number == widget.surah.number &&
//           audioService.currentVerseId == ayah.numberInSurah &&
//           audioService.originatingScreen == 'verse_view';

//       await audioService.playQuranVerse(
//         surah: widget.surah,
//         verseId: ayah.numberInSurah,
//         playbackSpeed: _playbackSpeed,
//         forceRestart: !isSameVerse,
//       );

//       logger.d('VerseViewScreen: Started playing verse ${ayah.numberInSurah}');
//     } catch (e) {
//       logger.e('Error playing audio: $e');

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Unable to play audio. Please try again later.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _updateMemorizationStatus(MemorizationStatus status) async {
//     final prefsHelper = getIt<SharedPrefsHelper>();
//     final isLoggedIn = prefsHelper.isLoggedIn;

//     if (!isLoggedIn) {
//       _showLoginRequiredDialog('memorization status');
//       return;
//     }

//     if (!_hasSubscription) {
//       _showSubscriptionRequiredDialog();
//       return;
//     }

//     try {
//       await _memorizationSyncService.saveVerseProgress(
//         _userId,
//         widget.surah.number,
//         _currentVerseId,
//         status,
//       );

//       if (mounted) {
//         setState(() {
//           _verseStatuses[_currentVerseId] = status;
//         });

//         context.showSnackBar(
//           'Verse marked as ${status.toString().split('.').last}',
//         );
//       }
//     } catch (e) {
//       logger.e('Error updating memorization status: $e');
//       if (mounted) {
//         context.showErrorSnackBar('Failed to update status: Please try again');
//       }
//     }
//   }

//   void _decreaseRepeatCount() {
//     if (_repeatCount > 1) {
//       setState(() {
//         _repeatCount--;
//       });
//       SharedAudioService.instance.setRepeatCount(_repeatCount);
//     }
//   }

//   void _increaseRepeatCount() {
//     setState(() {
//       _repeatCount++;
//     });
//     SharedAudioService.instance.setRepeatCount(_repeatCount);
//   }

//   Color _getStatusColor(int verseId) => _verseStatuses[verseId].getColorValue();
//   IconData _getStatusIcon(int verseId) =>
//       _verseStatuses[verseId].getIconValue();

//   Future<void> _getAIExplanation(int verseId) async {
//     final prefsHelper = getIt<SharedPrefsHelper>();
//     final isLoggedIn = prefsHelper.isLoggedIn;

//     if (!isLoggedIn) {
//       setState(() {
//         _verseExplanations[verseId] =
//             "⚠️ Login Required: You need to log in to use the AI explanation feature.";
//         _isLoadingExplanation[verseId] = false;
//       });
//       return;
//     }

//     // Check for DeenHub Pro subscription
//     final hasDeenHubPro = await SubscriptionService.isDeenHubProSubscribed();
//     if (!hasDeenHubPro) {
//       setState(() {
//         _verseExplanations[verseId] =
//             "⚠️ DeenHub Pro Required: AI explanation is available exclusively for DeenHub Pro subscribers.";
//         _isLoadingExplanation[verseId] = false;
//       });
//       _showAISubscriptionRequiredDialog();
//       return;
//     }

//     // Check monthly token limit before sending message
//     final usageTracker = AIUsageTrackingService();
//     final canMakeRequest = await usageTracker.canMakeRequest(
//       estimatedTokens: 500, // Estimate for a typical request
//     );

//     if (!canMakeRequest) {
//       setState(() {
//         _verseExplanations[verseId] =
//             "⚠️ Monthly Limit Exceeded: You have reached your monthly limit for AI explanations.";
//         _isLoadingExplanation[verseId] = false;
//       });
//       _showMonthlyLimitExceededDialog();
//       return;
//     }

//     if (_isLoadingExplanation[verseId] == true) {
//       return;
//     }

//     setState(() {
//       _isLoadingExplanation[verseId] = true;
//     });

//     try {
//       final ayah = widget.surah.ayahs.firstWhere(
//         (ayah) => ayah.numberInSurah == verseId,
//         orElse: () => widget.surah.ayahs.first,
//       );

//       final prompt =
//           'Quran Surah ${widget.surah.number} Verse ${ayah.numberInSurah} - Explain the verse and give me the context of this verse. Don\'t write the verse. Please write in concise';

//       final explanation = await _chatGPTService.getResponse(prompt);

//       setState(() {
//         _verseExplanations[verseId] = explanation.text;
//         _isLoadingExplanation[verseId] = false;
//       });
//     } catch (e) {
//       setState(() {
//         _verseExplanations[verseId] =
//             'Error loading explanation: ${e.toString()}';
//         _isLoadingExplanation[verseId] = false;
//       });
//     }
//   }

//   void _toggleSingleVerseMode() {
//     setState(() {
//       _singleVerseMode = !_singleVerseMode;
//     });

//     if (_singleVerseMode) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _scrollToVerse(_currentVerseId);
//       });
//     }

//     context.showSnackBar(
//       _singleVerseMode
//           ? 'Single verse mode enabled'
//           : 'All verses mode enabled',
//     );
//   }

//   void _changePlaybackSpeed(double speed) {
//     setState(() {
//       _playbackSpeed = speed;
//     });

//     if (SharedAudioService.instance.isPlaying) {
//       SharedAudioService.instance.setSpeed(_playbackSpeed);
//     }

//     context.showSnackBar('Playback speed set to ${speed}x');
//   }

//   Widget _buildArabicTextWithHighlighting(Ayah ayah, bool isCurrentVerse) {
//     final shouldHighlight =
//         _isPlaying &&
//         isCurrentVerse &&
//         ayah.wordTiming != null &&
//         ayah.wordTiming!.segments.isNotEmpty &&
//         _currentHighlightedWordIndex >= 0;

//     if (!shouldHighlight) {
//       return RichText(
//         text: TextSpan(
//           text: ayah.text,
//           style: TextStyle(
//             fontSize: 20,
//             height: 2.5, // Consistent line height with highlighting
//             fontFamily: 'Amiri',
//             fontWeight: FontWeight.bold, // Consistent weight
//             color: isCurrentVerse ? const Color(0xFF293241) : Colors.black,
//           ),
//         ),
//         textAlign: TextAlign.right,
//         textDirection: TextDirection.rtl,
//       );
//     }

//     final words = _splitArabicText(ayah.text);

//     if (words.isEmpty) {
//       return RichText(
//         text: TextSpan(
//           text: ayah.text,
//           style: TextStyle(
//             fontSize: 20,
//             height: 2.5, // Consistent line height with highlighting
//             fontFamily: 'Amiri',
//             fontWeight: FontWeight.bold, // Consistent weight
//             color: isCurrentVerse ? const Color(0xFF293241) : Colors.black,
//           ),
//         ),
//         textAlign: TextAlign.right,
//         textDirection: TextDirection.rtl,
//       );
//     }

//     return RichText(
//       textAlign: TextAlign.right,
//       textDirection: TextDirection.rtl,
//       text: TextSpan(
//         children: _buildHighlightedWordsSpans(
//           words,
//           ayah.wordTiming!.segments,
//           isCurrentVerse,
//         ),
//       ),
//     );
//   }

//   List<TextSpan> _buildHighlightedWordsSpans(
//     List<String> words,
//     List<WordSegment> segments,
//     bool isCurrentVerse,
//   ) {
//     final List<TextSpan> spans = [];
//     final int wordCount = words.length;

//     for (int i = 0; i < wordCount; i++) {
//       bool isHighlighted = false;
//       bool wasPreviouslyHighlighted = false;

//       // Check current highlight
//       if (_currentHighlightedWordIndex >= 0 &&
//           _currentHighlightedWordIndex < segments.length) {
//         final currentSegment = segments[_currentHighlightedWordIndex];
//         if (i >= currentSegment.wordStartIndex &&
//             i < currentSegment.wordEndIndex) {
//           isHighlighted = true;
//         }
//       }

//       // Check previous highlight only if not currently highlighted
//       if (_previousHighlightedWordIndex >= 0 &&
//           _previousHighlightedWordIndex < segments.length &&
//           !isHighlighted) {
//         final previousSegment = segments[_previousHighlightedWordIndex];
//         if (i >= previousSegment.wordStartIndex &&
//             i < previousSegment.wordEndIndex) {
//           wasPreviouslyHighlighted = true;
//         }
//       }

//       spans.add(
//         TextSpan(
//           text: words[i] + (i < wordCount - 1 ? ' ' : ''),
//           style: TextStyle(
//             fontSize: 20, // Consistent font size
//             height: 2.5, // Consistent line height - never changes
//             fontWeight: FontWeight.bold, // Consistent weight for all text
//             fontFamily: 'Amiri',
//             wordSpacing: 0,
//             color: isHighlighted
//                 ? const Color(0xFFD32F2F)
//                 : (isCurrentVerse ? const Color(0xFF293241) : Colors.black),
//             backgroundColor: isHighlighted
//                 ? const Color(0xFFFFF3E0)
//                 : (wasPreviouslyHighlighted
//                       ? const Color(0xFFFFF3E0).withValues(alpha: 0.1)
//                       : null), // Much lighter previous highlight
//           ),
//         ),
//       );
//     }

//     return spans;
//   }

//   void _showLoginRequiredDialog(String feature) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => LoginRequiredDialog(feature: feature),
//     );
//   }

//   void _showSubscriptionRequiredDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => const SubscriptionRequiredDialog(),
//     );
//   }

//   void _showAISubscriptionRequiredDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => const AiSubscriptionRequiredDialog(),
//     );
//   }

//   void _showMonthlyLimitExceededDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => const MonthlyLimitExceededDialog(),
//     );
//   }

//   void _showAIExplanationReportDialog(int verseNumber, String explanation) {
//     // Check if user is logged in
//     final prefsHelper = getIt<SharedPrefsHelper>();
//     final isLoggedIn = prefsHelper.isLoggedIn;

//     if (!isLoggedIn) {
//       _showLoginRequiredDialog('report');
//       return;
//     }

//     ReportDialog.showAIExplanationReport(
//       context,
//       explanation: explanation,
//       surahNumber: widget.surah.number,
//       verseNumber: verseNumber,
//       additionalContext: {
//         'surah_name': widget.surah.englishName,
//         'surah_arabic_name': widget.surah.name,
//         'total_verses': widget.surah.ayahs.length,
//         'is_memorization_mode': widget.isMemorizationMode,
//       },
//     );
//   }

//   final selectedBgColor = Color(0xFFB2DFDB);
//   final unselectedBgColor = Color(0xFF80CBC4);
//   final selectedTextColor = Color(0xFF00695C);
//   final unselectedTextColor = Color(0xFF004D40);

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true,
//       onPopInvoked: (didPop) async {
//         if (didPop) {
//           await _scheduleMemorizationNotificationOnExit();
//         }
//       },
//       child: AppBarScaffold(
//         centerTitle: true,
//         searchBar: SurahHeaderWidget(surah: widget.surah),
//         appBarActions: [
//           IconButton(
//             icon: Icon(
//               _singleVerseMode ? Icons.fullscreen : Icons.view_list,
//               color: Colors.white,
//             ),
//             onPressed: _toggleSingleVerseMode,
//             tooltip: _singleVerseMode ? 'Focus Mode On' : 'Focus Mode Off',
//           ),
//             IconButton(
//             icon: const Icon(
//               Icons.settings,
//               color: Colors.white,
//             ),
//             onPressed: () async {
//               await context.pushNamed(Routes.verseViewSettings.name);
//               // Always reload settings when returning from settings screen
//               _loadVerseViewSettings();
//               setState(() {});
//             },
//             tooltip: 'Verse View Settings',
//           ),
//         ],
//         padding: const EdgeInsetsDirectional.symmetric(
//           horizontal: 8,
//           vertical: 8,
//         ),
//         child: Column(
//           children: [
//             // Subscription warning if logged in but not subscribed
//             if (_userId != null &&
//                 !_hasSubscription &&
//                 !_isCheckingSubscription)
//               const SubscriptionRequiredView(),
//             ControlButtonsWidget(
//               singleVerseMode: _singleVerseMode,
//               selectedLanguage: _selectedLanguage,
//               selectedBgColor: selectedBgColor,
//               unselectedBgColor: unselectedBgColor,
//               selectedTextColor: selectedTextColor,
//               unselectedTextColor: unselectedTextColor,
//               onToggleSingleVerseMode: _toggleSingleVerseMode,
//               onLanguageChanged: (language) {
//                 setState(() {
//                   _selectedLanguage = language;
//                 });
//               },
//             ),
//             gapH8,
//             if (_singleVerseMode)
//               SingleVerseNavigationWidget(
//                 currentVerseId: _currentVerseId,
//                 totalVerses: widget.surah.ayahs.length,
//                 onPreviousVerse: _navigateToPreviousVerse,
//                 onNextVerse: _navigateToNextVerse,
//               ),
//             Expanded(
//               child: ScrollablePositionedList.builder(
//                 itemScrollController: _itemScrollController,
//                 itemPositionsListener: _itemPositionsListener,
//                 itemCount: _singleVerseMode ? 1 : widget.surah.ayahs.length,
//                 itemBuilder: (context, index) {
//                   final ayah = _singleVerseMode
//                       ? _getCurrentAyah()
//                       : widget.surah.ayahs[index];

//                   final isCurrentVerse = ayah.numberInSurah == _currentVerseId;
//                   final verseStatus = _verseStatuses[ayah.numberInSurah];

//                   if (_singleVerseMode && !isCurrentVerse) {
//                     return const SizedBox.shrink();
//                   }

//                   return VerseCardWidget(
//                     ayah: ayah,
//                     isCurrentVerse: isCurrentVerse,
//                     verseStatus: verseStatus,
//                     isResultVerse: widget.isResultVerse,
//                     isMemorizationMode:
//                         widget.isMemorizationMode && _hasSubscription,
//                     isPlaying: _isPlaying,
//                     arabicTextWidget: _buildArabicTextWithHighlighting(
//                       ayah,
//                       isCurrentVerse,
//                     ),
//                     currentHighlightedWordIndex: _currentHighlightedWordIndex,
//                     verseExplanations: _verseExplanations,
//                     isLoadingExplanation: _isLoadingExplanation,
//                     repeatCount: _repeatCount,
//                     playbackSpeed: _playbackSpeed,
//                     selectedLanguage: _selectedLanguage,
//                     onVerseTap: () {
//                       setState(() {
//                         _currentVerseId = ayah.numberInSurah;
//                         _repeatCount = 1;
//                         // Reset highlights when changing verse
//                         _currentHighlightedWordIndex = -1;
//                         _previousHighlightedWordIndex = -1;
//                         // Don't show loading during instant transitions

//                         if (_isPlaying) {
//                           SharedAudioService.instance.stop();
//                         }
//                       });

//                       // Smooth scroll to the tapped verse
//                       _scrollToVerse(ayah.numberInSurah);
//                     },
//                     onPlayAudio: () async {
//                       SharedAudioService.instance.setSurahAndVerse(
//                         widget.surah,
//                         _currentVerseId,
//                         screen: 'verse_view',
//                       );
//                       SharedAudioService.instance.setRepeatCount(_repeatCount);
//                       SharedAudioService.instance.setAutoAdvance(_autoAdvance);
//                       logger.d(
//                         'VerseViewScreen: Play button pressed - Repeat: $_repeatCount, Auto-advance: $_autoAdvance',
//                       );
//                       await _playAudio();
//                     },
//                     onPlayOtherVerse: () {
//                       setState(() {
//                         _currentVerseId = ayah.numberInSurah;
//                         _repeatCount = 1;
//                         // Reset highlights when changing verse
//                         _currentHighlightedWordIndex = -1;
//                         _previousHighlightedWordIndex = -1;
//                         // Don't show loading during instant transitions
//                       });

//                       SharedAudioService.instance.setSurahAndVerse(
//                         widget.surah,
//                         ayah.numberInSurah,
//                         screen: 'verse_view',
//                       );
//                       SharedAudioService.instance.setRepeatCount(_repeatCount);
//                       SharedAudioService.instance.setAutoAdvance(_autoAdvance);

//                       // Smooth scroll to the verse before playing
//                       _scrollToVerse(ayah.numberInSurah);

//                       // Instant playback - no delay
//                       SharedAudioService.instance.playQuranVerse(
//                         surah: widget.surah,
//                         verseId: ayah.numberInSurah,
//                         playbackSpeed: _playbackSpeed,
//                         forceRestart: true,
//                       );
//                     },
//                     onGetAIExplanation: () =>
//                         _getAIExplanation(ayah.numberInSurah),
//                     onRemoveExplanation: () {
//                       setState(() {
//                         _verseExplanations.remove(ayah.numberInSurah);
//                       });
//                     },
//                     onDecreaseRepeatCount: _decreaseRepeatCount,
//                     onIncreaseRepeatCount: _increaseRepeatCount,
//                     onChangePlaybackSpeed: _changePlaybackSpeed,
//                     onUpdateMemorizationStatus: _updateMemorizationStatus,
//                     onShowLoginRequiredDialog: _showLoginRequiredDialog,
//                     getStatusColor: _getStatusColor,
//                     getStatusIcon: _getStatusIcon,
//                     onReportAIExplanation: _showAIExplanationReportDialog,
//                     onShowSubscriptionRequiredDialog:
//                         _showSubscriptionRequiredDialog,
//                     verseViewSettings: _verseViewSettings,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
