import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/services/shared_audio_service.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'dart:async';

class GlobalMediaPlayer extends StatefulWidget {
  const GlobalMediaPlayer({super.key});

  @override
  State<GlobalMediaPlayer> createState() => _GlobalMediaPlayerState();
}

class _GlobalMediaPlayerState extends State<GlobalMediaPlayer>
    with TickerProviderStateMixin {
  final SharedAudioService _audioService = SharedAudioService.instance;
  late StreamSubscription<bool> _playingSubscription;
  late StreamSubscription<bool> _loadingSubscription;
  late StreamSubscription<int> _verseSubscription;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isVisible = false;
  bool _manuallyHidden = false;
  String _currentTitle = '';
  String _currentSubtitle = '';

  // Debounce variables to prevent flickering
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _setupListeners();
    _updateVisibility();

    // Initialize SharedAudioService if not already done
    if (!_audioService.isInitialized) {
      _audioService.initialize().then((_) {
        logger.i('GlobalMediaPlayer: SharedAudioService initialized');
        _updateVisibility();
      }).catchError((e) {
        logger
            .i('GlobalMediaPlayer: Error initializing SharedAudioService: $e');
      });
    }
  }

  void _setupListeners() {
    logger.i('GlobalMediaPlayer: Setting up listeners');

    _playingSubscription = _audioService.playingStateStream.listen((isPlaying) {
      logger.i('GlobalMediaPlayer: Playing state changed: $isPlaying');
      if (mounted) {
        setState(() {
          _isPlaying = isPlaying;
          // Reset manually hidden flag when new audio starts playing
          if (isPlaying) {
            _manuallyHidden = false;
          }
        });
        _updateVisibility();
        _updateTitles();
      }
    });

    _loadingSubscription = _audioService.loadingStateStream.listen((isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading;
        });
        _updateVisibility();
      }
    });

    _verseSubscription = _audioService.currentVerseStream.listen((verseId) {
      if (mounted) {
        _updateTitles();
      }
    });
  }

  void _updateVisibility() {
    // Don't show if manually closed
    if (_manuallyHidden) {
      if (_isVisible) {
        setState(() {
          _isVisible = false;
        });
        _slideController.reverse();
      }
      return;
    }

    // Show media player only when actively playing or loading
    final shouldShow = _isPlaying || _isLoading;

    logger.i(
        'GlobalMediaPlayer: Update visibility - shouldShow: $shouldShow, _isVisible: $_isVisible, _isPlaying: $_isPlaying, _isLoading: $_isLoading');

    // Cancel any pending hide timer
    _hideTimer?.cancel();

    if (shouldShow) {
      // Show immediately
      if (!_isVisible) {
        setState(() {
          _isVisible = true;
        });
        logger.i('GlobalMediaPlayer: Showing media player');
        _slideController.forward();
      }
    } else {
      // Hide immediately when not playing or loading
      if (_isVisible) {
        setState(() {
          _isVisible = false;
        });
        logger.i('GlobalMediaPlayer: Hiding media player - not actively playing or loading');
        _slideController.reverse();
      }
    }
  }

  void _updateTitles() {
    final context = _audioService.currentContext;
    final surah = _audioService.currentSurah;
    final verseId = _audioService.currentVerseId;

    if (context == 'quran' && surah != null) {
      setState(() {
        _currentTitle = surah.name;
        _currentSubtitle = '${surah.englishName} • Verse $verseId';
      });
    } else if (context == 'prayer_guide') {
      setState(() {
        _currentTitle = 'Prayer Guide';
        _currentSubtitle = 'Learning Islamic Prayer';
      });
    } else {
      setState(() {
        _currentTitle = 'Audio Player';
        _currentSubtitle = 'Playing audio';
      });
    }
  }

  Future<void> _onPlayPause() async {
    try {
      // Stop instead of toggle to ensure cleaner state
      if (_isPlaying) {
        await _audioService.stop();
      } else {
        // If audio is not playing, restart the current context
        if (_audioService.currentContext == 'quran' &&
            _audioService.currentSurah != null) {
          // Check if surah is completed and restart from beginning if needed
          if (_audioService.surahCompleted &&
              _audioService.currentVerseId >=
                  (_audioService.currentSurah?.ayahs.length ?? 0)) {
            logger.i(
                'Surah completed, restarting from verse 1 via global media player');
            await _audioService.playQuranVerse(
              surah: _audioService.currentSurah!,
              verseId: 1, // Restart from verse 1
              playbackSpeed: 1.0,
              forceRestart: true,
            );
          } else {
            // Normal playback
            await _audioService.playQuranVerse(
              surah: _audioService.currentSurah!,
              verseId: _audioService.currentVerseId,
              playbackSpeed: 1.0,
              forceRestart:
                  true, // Always force restart when playing from the global player
            );
          }
        } else if (_audioService.currentContext == 'prayer_guide') {
          // TODO: Handle prayer guide playback
        }
      }
    } catch (e) {
      if (mounted) {
        context
            .showErrorSnackBar('Unable to control playback: ${e.toString()}');
      }
    }
  }

  Future<void> _onClose() async {
    // Stop audio and immediately hide media player
    await _audioService.stop();
    _hideTimer?.cancel();

    // Mark as manually hidden and force immediate hide
    if (mounted) {
      setState(() {
        _manuallyHidden = true;
        _isVisible = false;
        _isPlaying = false;
        _isLoading = false;
      });
      _slideController.reverse();
    }
  }

  void _onMediaPlayerTap() {
    final audioContext = _audioService.currentContext;
    final originatingScreen = _audioService.originatingScreen;

    // Priority 1: Check originating screen first for Quran content
    if (audioContext == 'quran' && _audioService.currentSurah != null) {
      if (originatingScreen == 'reading_mode') {
        context.pushNamed(
          Routes.quranReadingMode.name,
          queryParameters: {
            'surahId': _audioService.currentSurah!.number.toString(),
            'verseId': _audioService.currentVerseId.toString(),
          },
        );
      } else if (originatingScreen == 'verse_view') {
        context.pushNamed(
          Routes.verseView.name,
          queryParameters: {
            'surahId': _audioService.currentSurah!.number.toString(),
            'verseId': _audioService.currentVerseId.toString(),
            'isMemorizationMode': 'true',
          },
        );
      } else {
        context.pushNamed(
          Routes.verseView.name,
          queryParameters: {
            'surahId': _audioService.currentSurah!.number.toString(),
            'verseId': _audioService.currentVerseId.toString(),
            'isMemorizationMode': 'true',
          },
        );
      }
    } else if (audioContext == 'prayer_guide') {
      context.pushNamed(Routes.prayerGuide.name);
    } else if (originatingScreen != null) {
      // Navigate to the originating screen based on stored context
      switch (originatingScreen) {
        case 'verse_view':
          if (_audioService.currentSurah != null) {
            context.pushNamed(
              Routes.verseView.name,
              queryParameters: {
                'surahId': _audioService.currentSurah!.number.toString(),
                'verseId': _audioService.currentVerseId.toString(),
                'isMemorizationMode': 'true',
              },
            );
          }
          break;
        case 'reading_mode':
          if (_audioService.currentSurah != null) {
            context.pushNamed(
              Routes.quranReadingMode.name,
              queryParameters: {
                'surahId': _audioService.currentSurah!.number.toString(),
                'verseId': _audioService.currentVerseId.toString(),
              },
            );
          }
          break;
        case 'prayer_guide':
          context.pushNamed(Routes.prayerGuide.name);
          break;
        default:
          context.goNamed(Routes.home.name);
      }
    } else {
      context.goNamed(Routes.home.name);
    }
  }

  void _onNext() {
    if (_audioService.currentContext == 'quran' &&
        _audioService.currentSurah != null) {
      final wasPlaying = _audioService.isPlaying;

      // Stop current audio to ensure clean state
      _audioService.stop();

      // Call nextVerse to increment the verse
      _audioService.nextVerse();

      // If audio was playing, start playing the new verse after a delay
      if (wasPlaying) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _audioService.playCurrentVerse();
          }
        });
      }
    }
  }

  void _onPrevious() {
    if (_audioService.currentContext == 'quran' &&
        _audioService.currentSurah != null) {
      final wasPlaying = _audioService.isPlaying;

      // Stop current audio to ensure clean state
      _audioService.stop();

      // Call previousVerse to decrement the verse
      _audioService.previousVerse();

      // If audio was playing, start playing the new verse after a delay
      if (wasPlaying) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _audioService.playCurrentVerse();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _playingSubscription.cancel();
    _loadingSubscription.cancel();
    _verseSubscription.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show widget only when audio is playing or loading
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: _onMediaPlayerTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.primaryColor,
                context.primaryColor.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Album art / Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _audioService.currentContext == 'quran'
                        ? Icons.menu_book
                        : Icons.mosque,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                gapW12,

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: _audioService.currentContext == 'quran'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                      gapH4,
                      Text(
                        _currentSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Controls
                Row(
                  children: [
                    // Previous button (only for Quran)
                    if (_audioService.currentContext == 'quran') ...[
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        color: Colors.white,
                        iconSize: 24,
                        onPressed: _audioService.currentVerseId > 1
                            ? _onPrevious
                            : null,
                        tooltip: 'Previous Verse',
                      ),
                    ],

                    // Play/Pause button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                        iconSize: 28,
                        onPressed: _isLoading ? null : _onPlayPause,
                        tooltip: _isPlaying ? 'Pause' : 'Play',
                      ),
                    ),

                    // Next button (only for Quran)
                    if (_audioService.currentContext == 'quran') ...[
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        color: Colors.white,
                        iconSize: 24,
                        onPressed: (_audioService.currentSurah != null &&
                                _audioService.currentVerseId <
                                    _audioService.currentSurah!.ayahs.length)
                            ? _onNext
                            : null,
                        tooltip: 'Next Verse',
                      ),
                    ],

                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white.withValues(alpha: 0.8),
                      iconSize: 20,
                      onPressed: () async => await _onClose(),
                      tooltip: 'Close Player',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
