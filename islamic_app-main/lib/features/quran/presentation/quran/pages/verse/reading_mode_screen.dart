
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/audio_controls_widget.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/font_size_dialog.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/quran_page_widget.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/surah_header_widget.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/surah_selection_sheet.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/verse_number_circle.dart';
import 'package:deenhub/main.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/services/shared_audio_service.dart';
import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReadingModeScreen extends StatefulWidget {
  final Surah surah;
  final int initialVerseId;

  const ReadingModeScreen({
    super.key,
    required this.surah,
    required this.initialVerseId,
  });

  @override
  State<ReadingModeScreen> createState() => _ReadingModeScreenState();
}

class _ReadingModeScreenState extends State<ReadingModeScreen>
    with SingleTickerProviderStateMixin {
  late int _currentVerseId;
  bool _isPlaying = false;
  bool _isLoading = false;
  final MemorizationService _memorizationService = MemorizationService();
  double _textSize = 26.0;
  bool _audioEnabled = true;
  late AnimationController _playPauseController;
  int _currentHighlightedWordIndex = -1;
  int _previousHighlightedWordIndex = -1;
  StreamSubscription<int>? _verseSubscription;
  StreamSubscription<int>? _highlightSubscription;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
  ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    _currentVerseId = widget.initialVerseId;
    final sharedService = SharedAudioService.instance;
    int effectiveInitialVerse = widget.initialVerseId;
    if (sharedService.currentContext == 'quran' &&
        sharedService.originatingScreen != 'reading_mode' &&
        sharedService.currentSurah?.number == widget.surah.number) {
      effectiveInitialVerse = 1;
    }
    _currentVerseId = effectiveInitialVerse;

    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _memorizationService.recordRecentlyRead(
      widget.surah.number,
      _currentVerseId,
      source: 'reading_mode',
    );

    final audioService = SharedAudioService.instance;
    _syncWithAudioService();

    if (!audioService.isInitialized) {
      audioService
          .initialize()
          .then((_) {
        if (mounted) {
          if (audioService.isPlaying &&
              audioService.originatingScreen != 'reading_mode') {
            audioService.stop();
          }
          audioService.setSurahAndVerse(
            widget.surah,
            _currentVerseId,
            screen: 'reading_mode',
          );
          audioService.setAutoAdvance(true);
          audioService.setRepeatCount(1);
          _syncWithAudioService();
        }
      })
          .catchError((e) {
        logger.e('Failed to initialize audio service: $e');
      });
    } else {
      if (audioService.isPlaying &&
          audioService.originatingScreen != 'reading_mode') {
        audioService.stop();
      }
      audioService.setSurahAndVerse(
        widget.surah,
        _currentVerseId,
        screen: 'reading_mode',
      );
      audioService.setAutoAdvance(true);
      audioService.setRepeatCount(1);
    }

    _setupAudioServiceListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerse(_currentVerseId);
    });
  }

  void _syncWithAudioService() {
    final audioService = SharedAudioService.instance;

    if (audioService.currentContext == 'quran' &&
        audioService.currentSurah?.number == widget.surah.number &&
        audioService.originatingScreen == 'reading_mode') {
      if (audioService.currentVerseId != _currentVerseId &&
          audioService.currentVerseId <= widget.surah.ayahs.length) {
        setState(() {
          _currentVerseId = audioService.currentVerseId;
        });
      }

      setState(() {
        _isPlaying = audioService.isPlaying;
        _isLoading = audioService.isLoading;
      });

      if (_isPlaying) {
        _playPauseController.forward();
      } else {
        _playPauseController.reverse();
      }

      logger.d(
        'ReadingModeScreen: Synced with audio service - playing: $_isPlaying, verse: $_currentVerseId, surah: ${widget.surah.englishName}',
      );
    } else {
      logger.d(
        'ReadingModeScreen: Audio from different screen/context, maintaining independent state',
      );
    }
  }

  void _setupAudioServiceListeners() {
    _verseSubscription = SharedAudioService.instance.currentVerseStream.listen((
        verseId,
        ) {
      if (mounted) {
        final audioService = SharedAudioService.instance;
        final currentSurahNumber = audioService.currentSurah?.number;

        if (currentSurahNumber != null &&
            currentSurahNumber != widget.surah.number) {
          // পরবর্তী সূরায় যাওয়ার আগে একটু delay দিন
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.pushReplacementNamed(
                  Routes.quranReadingMode.name,
                  queryParameters: {
                    'surahId': currentSurahNumber.toString(),
                    'verseId': verseId.toString(),
                  },
                );
              }
            });
          }
        } else if (verseId != _currentVerseId) {
          final shouldUpdateUI =
              audioService.originatingScreen == 'reading_mode' ||
                  (audioService.isPlaying &&
                      audioService.currentContext == 'quran' &&
                      audioService.currentSurah?.number == widget.surah.number);

          if (shouldUpdateUI && verseId <= widget.surah.ayahs.length) {
            setState(() {
              _currentVerseId = verseId;
              _currentHighlightedWordIndex = -1;
              _previousHighlightedWordIndex = -1;
            });
            _scrollToVerse(verseId);
            _memorizationService.recordRecentlyRead(
              widget.surah.number,
              verseId,
              source: 'reading_mode',
            );
          }
        }
      }
    });



    _highlightSubscription = SharedAudioService.instance.highlightedWordStream
        .listen((wordIndex) {
      if (mounted &&
          SharedAudioService.instance.originatingScreen == 'reading_mode') {
        setState(() {
          if (wordIndex != _currentHighlightedWordIndex) {
            _previousHighlightedWordIndex = _currentHighlightedWordIndex;
            _currentHighlightedWordIndex = wordIndex;
          }
        });
      }
    });

    SharedAudioService.instance.playingStateStream.listen((isPlaying) {
      if (mounted) {
        if (SharedAudioService.instance.originatingScreen == 'reading_mode' ||
            !isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
            if (!isPlaying) {
              _currentHighlightedWordIndex = -1;
              _previousHighlightedWordIndex = -1;
            }
          });

          if (isPlaying) {
            _playPauseController.forward();
          } else {
            _playPauseController.reverse();
          }
        }
      }
    });

    SharedAudioService.instance.loadingStateStream.listen((isLoading) {
      if (mounted &&
          SharedAudioService.instance.originatingScreen == 'reading_mode') {
        setState(() {
          _isLoading = isLoading;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioService = SharedAudioService.instance;
      if (mounted &&
          audioService.isInitialized &&
          audioService.originatingScreen == 'reading_mode') {
        final currentIsPlaying = audioService.isPlaying;
        final currentHighlightIndex = audioService.currentHighlightedWordIndex;
        final isMatchingContext =
            audioService.currentSurah?.number == widget.surah.number;

        if (isMatchingContext &&
            currentIsPlaying &&
            currentHighlightIndex >= 0) {
          setState(() {
            _currentHighlightedWordIndex = currentHighlightIndex;
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

  void _scrollToVerse(int verseId) {
    if (_currentVerseId != verseId) {
      _memorizationService.recordRecentlyRead(
        widget.surah.number,
        verseId,
        source: 'reading_mode',
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentVerseId = verseId;
        });
      }
    });

    // For Al-Fatiha, adjust index since we're skipping verse 1 (Bismillah)
    int displayIndex;
    if (widget.surah.number == 1) {
      // For Al-Fatiha: verse 1 (Bismillah) is not displayed, verse 2 is at index 1
      displayIndex = verseId - 1; // verse 2 -> index 1, verse 3 -> index 2, etc.
    } else {
      // For other surahs: normal indexing (verse 1 at index 1 after Bismillah header)
      displayIndex = verseId;
    }

    if (displayIndex >= 0 && _itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: displayIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
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
      audioService.setSurahAndVerse(
        widget.surah,
        _currentVerseId,
        screen: 'reading_mode',
      );
      audioService.setAutoAdvance(true);
      audioService.setRepeatCount(1);

      final isCurrentlyPlayingSameVerse =
          audioService.isPlaying &&
              audioService.currentSurah?.number == widget.surah.number &&
              audioService.currentVerseId == _currentVerseId &&
              audioService.originatingScreen == 'reading_mode';

      if (isCurrentlyPlayingSameVerse) {
        await audioService.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await audioService.playQuranVerse(
          surah: widget.surah,
          verseId: _currentVerseId,
          playbackSpeed: 1.0,
          forceRestart: true,
        );
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      logger.e('Error playing/stopping audio: $e');
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to control audio playback. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleAudio() {
    setState(() {
      _audioEnabled = !_audioEnabled;
      if (!_audioEnabled &&
          _isPlaying &&
          SharedAudioService.instance.isInitialized) {
        SharedAudioService.instance.stop();
        _isPlaying = false;
        _previousHighlightedWordIndex = _currentHighlightedWordIndex;
        _currentHighlightedWordIndex = -1;
        _playPauseController.reverse();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_audioEnabled ? 'Audio enabled' : 'Audio disabled'),
      ),
    );
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    _verseSubscription?.cancel();
    _highlightSubscription?.cancel();
    super.dispose();
  }

  void _onVerseTap(int verseNumber) {
    if (_isPlaying) {
      SharedAudioService.instance.stop();
    }

    setState(() {
      _currentVerseId = verseNumber;
      _currentHighlightedWordIndex = -1;
      _previousHighlightedWordIndex = -1;
      _isLoading = false;
      _isPlaying = false;
    });

    SharedAudioService.instance.setSurahAndVerse(
      widget.surah,
      verseNumber,
      screen: 'reading_mode',
    );
    SharedAudioService.instance.setAutoAdvance(true);
    SharedAudioService.instance.setRepeatCount(1);

    _scrollToVerse(verseNumber);

    if (_audioEnabled) {
      _playVerseDirectly(verseNumber);
    }
  }

  Future<void> _playVerseDirectly(int verseNumber) async {
    try {
      await SharedAudioService.instance.playQuranVerse(
        surah: widget.surah,
        verseId: verseNumber,
        playbackSpeed: 1.0,
        forceRestart: true,
      );
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      logger.e('Error playing verse $verseNumber: $e');
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      centerTitle: true,
      searchBar: SurahHeaderWidget(surah: widget.surah),
      appBarActions: [
        IconButton(
          icon: Icon(
            _audioEnabled ? Icons.volume_up : Icons.volume_off,
            color: _audioEnabled ? Colors.white : Colors.grey,
          ),
          onPressed: _toggleAudio,
          tooltip: _audioEnabled ? 'Disable Audio' : 'Enable Audio',
        ),
        IconButton(
          icon: const Icon(Icons.format_size),
          onPressed: () => _showFontSizeDialog(context),
          tooltip: 'Adjust Text Size',
        ),
        IconButton(
          icon: const Icon(Icons.menu_book),
          onPressed: () => _showSurahSelection(context),
          tooltip: 'Select Surah',
        ),
      ],
      bottomNavigationBar: _audioEnabled
          ? AudioControlsWidget(
        isPlaying: _isPlaying,
        isLoading: _isLoading,
        currentVerseId: _currentVerseId,
        totalVerses: widget.surah.number == 1
            ? widget.surah.ayahs.length - 1  // Al-Fatiha: show 6 verses (skip Bismillah)
            : widget.surah.ayahs.length,     // Other surahs: normal count
        onPlayPause: _playAudio,
        onPreviousVerse: _navigateToPreviousVerse,
        onNextVerse: _navigateToNextVerse,
        playPauseController: _playPauseController,
      )
          : null,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFFDE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  itemCount: widget.surah.number == 1
                      ? widget.surah.ayahs.length // Al-Fatiha: no Bismillah header, skip verse 1
                      : widget.surah.ayahs.length + 1, // Other surahs: +1 for Bismillah header
                  itemBuilder: (context, index) {
                    // Special handling for Surah Al-Fatiha
                    if (widget.surah.number == 1) {
                      // For Al-Fatiha: Show Bismillah in header only
                      // Skip verse 1 (Bismillah) and start from verse 2 (Alhamdulillah)
                      if (index == 0) {
                        // Show Bismillah as header (not as a verse)
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: _textSize + 2,
                                    height: 2.0,
                                    color: const Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 2,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF2E7D32).withValues(alpha: 0.4),
                                      const Color(0xFF2E7D32).withValues(alpha: 0.6),
                                      const Color(0xFF2E7D32).withValues(alpha: 0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      } else {
                        // For Al-Fatiha verses (inside the else block after index == 0)
                        final ayah = widget.surah.ayahs[index];
                        final isCurrentVerse = ayah.numberInSurah == _currentVerseId;
                        final words = _splitArabicText(ayah.text);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 8.0,
                          ),
                          child: RichText(
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              children: [
                                // Word-by-word highlighting
                                for (int i = 0; i < words.length; i++)
                                  TextSpan(
                                    text: i < words.length - 1 ? '${words[i]} ' : words[i],
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: _textSize,
                                      height: 2.5,
                                      color: isCurrentVerse && _isPlaying && i == _currentHighlightedWordIndex
                                          ? Colors.red  // Red for currently playing word
                                          : isCurrentVerse
                                          ? const Color(0xFF2E7D32)  // Green for current verse
                                          : const Color(0xFF1B1B1B),  // Black for other verses
                                      fontWeight: isCurrentVerse
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      shadows: isCurrentVerse
                                          ? [
                                        Shadow(
                                          offset: Offset(0.5, 0.5),
                                          blurRadius: 1.0,
                                          color: i == _currentHighlightedWordIndex
                                              ? Colors.red
                                              : Color(0xFF2E7D32),
                                        ),
                                      ]
                                          : null,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _onVerseTap(ayah.numberInSurah),
                                  ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: VerseNumberCircle(
                                    verseNumber: ayah.numberInSurah - 1,
                                    isCurrentVerse: isCurrentVerse,
                                    onTap: () => _onVerseTap(ayah.numberInSurah),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    }

                    // Standard handling for other surahs
                    if (index == 0) {
                      // Bismillah header for surahs except At-Tawbah
                      if (widget.surah.number == 9) {
                        // Surah At-Tawbah has no Bismillah
                        return const SizedBox.shrink();
                      } else {
                        // Show Bismillah header
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: _textSize + 2,
                                    height: 2.0,
                                    color: const Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 2,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF2E7D32).withValues(alpha: 0.4),
                                      const Color(0xFF2E7D32).withValues(alpha: 0.6),
                                      const Color(0xFF2E7D32).withValues(alpha: 0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      }
                    } else {
                      // Display regular verses (index - 1 because of Bismillah header at index 0)
                      final ayah = widget.surah.ayahs[index - 1];
                      final isCurrentVerse = ayah.numberInSurah == _currentVerseId;
                      final words = _splitArabicText(ayah.text);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: RichText(
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            children: [
                              // Word-by-word highlighting for all surahs
                              for (int i = 0; i < words.length; i++)
                                TextSpan(
                                  text: i < words.length - 1 ? '${words[i]} ' : words[i],
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: _textSize,
                                    height: 2.5,
                                    color: isCurrentVerse && _isPlaying && i == _currentHighlightedWordIndex
                                        ? Colors.red  // Red for currently playing word
                                        : isCurrentVerse
                                        ? const Color(0xFF2E7D32)  // Green for current verse
                                        : const Color(0xFF1B1B1B),  // Black for other verses
                                    fontWeight: isCurrentVerse
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    shadows: isCurrentVerse
                                        ? [
                                      Shadow(
                                        offset: Offset(0.5, 0.5),
                                        blurRadius: 1.0,
                                        color: i == _currentHighlightedWordIndex
                                            ? Colors.red
                                            : Color(0xFF2E7D32),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _onVerseTap(ayah.numberInSurah),
                                ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: VerseNumberCircle(
                                  verseNumber: ayah.numberInSurah,
                                  isCurrentVerse: isCurrentVerse,
                                  onTap: () => _onVerseTap(ayah.numberInSurah),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPreviousVerse() {
    // For Al-Fatiha, minimum verse is 2 (since we skip verse 1 - Bismillah)
    final minVerse = widget.surah.number == 1 ? 2 : 1;

    if (_currentVerseId > minVerse && SharedAudioService.instance.isInitialized) {
      final wasPlaying = _isPlaying;

      if (wasPlaying) {
        SharedAudioService.instance.stop();
      }

      setState(() {
        _currentVerseId--;
        _currentHighlightedWordIndex = -1;
        _previousHighlightedWordIndex = -1;
        _isLoading = false;
      });

      SharedAudioService.instance.setSurahAndVerse(
        widget.surah,
        _currentVerseId,
        screen: 'reading_mode',
      );
      SharedAudioService.instance.setAutoAdvance(true);
      SharedAudioService.instance.setRepeatCount(1);

      if (wasPlaying && _audioEnabled) {
        _playAudio();
      }
    }
  }

  void _navigateToNextVerse() {
    if (_currentVerseId < widget.surah.ayahs.length &&
        SharedAudioService.instance.isInitialized) {
      final wasPlaying = _isPlaying;

      if (wasPlaying) {
        SharedAudioService.instance.stop();
      }

      setState(() {
        _currentVerseId++;
        _currentHighlightedWordIndex = -1;
        _previousHighlightedWordIndex = -1;
        _isLoading = false;
      });

      SharedAudioService.instance.setSurahAndVerse(
        widget.surah,
        _currentVerseId,
        screen: 'reading_mode',
      );
      SharedAudioService.instance.setAutoAdvance(true);
      SharedAudioService.instance.setRepeatCount(1);

      if (wasPlaying && _audioEnabled) {
        _playAudio();
      }
    }
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FontSizeDialog(
        initialSize: _textSize,
        onSizeChanged: (size) {
          setState(() {
            _textSize = size;
          });
        },
      ),
    );
  }

  void _showSurahSelection(BuildContext context) {
    final QuranService quranService = QuranService();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SurahSelectionSheet(
        surahs: quranService.getAllSurahs(),
        onSurahSelected: (surah) {
          Navigator.pop(context);
          context.pushNamed(
            Routes.quranReadingMode.name,
            queryParameters: {
              'surahId': surah.number.toString(),
              'verseId': '1',
            },
          );
        },
      ),
    );
  }
}




//
// import 'package:deenhub/config/routes/routes.dart';
// import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/audio_controls_widget.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/font_size_dialog.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/quran_page_widget.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/surah_header_widget.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/surah_selection_sheet.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/verse_number_circle.dart';
// import 'package:deenhub/main.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/material.dart';
// import 'package:deenhub/core/services/shared_audio_service.dart';
// import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
// import 'package:deenhub/features/quran/data/repository/quran_service.dart';
// import 'package:deenhub/features/quran/domain/models/quran_model.dart';
// import 'package:go_router/go_router.dart';
// import 'dart:async';
// import 'package:flutter/gestures.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
//
// class ReadingModeScreen extends StatefulWidget {
//   final Surah surah;
//   final int initialVerseId;
//
//   const ReadingModeScreen({
//     super.key,
//     required this.surah,
//     required this.initialVerseId,
//   });
//
//   @override
//   State<ReadingModeScreen> createState() => _ReadingModeScreenState();
// }
//
// class _ReadingModeScreenState extends State<ReadingModeScreen>
//     with SingleTickerProviderStateMixin {
//   late int _currentVerseId;
//   bool _isPlaying = false;
//   bool _isLoading = false;
//   final MemorizationService _memorizationService = MemorizationService();
//   double _textSize = 26.0;
//   bool _audioEnabled = true;
//   late AnimationController _playPauseController;
//   int _currentHighlightedWordIndex = -1;
//   int _previousHighlightedWordIndex =
//       -1; // Track previous index for smooth transitions
//   StreamSubscription<int>? _verseSubscription;
//   StreamSubscription<int>? _highlightSubscription;
//
//   // Add scroll controller for auto-scrolling
//   final ItemScrollController _itemScrollController = ItemScrollController();
//   final ItemPositionsListener _itemPositionsListener =
//       ItemPositionsListener.create();
//
//   @override
//   void initState() {
//     super.initState();
//     _currentVerseId = widget.initialVerseId;
//     // Determine effective initial verse. If coming from a different screen/mode,
//     // force start from verse 1 for reading mode to avoid cross-mode carryover.
//     final sharedService = SharedAudioService.instance;
//     int effectiveInitialVerse = widget.initialVerseId;
//     if (sharedService.currentContext == 'quran' &&
//         sharedService.originatingScreen != 'reading_mode' &&
//         sharedService.currentSurah?.number == widget.surah.number) {
//       effectiveInitialVerse = 1;
//     }
//     _currentVerseId = effectiveInitialVerse;
//
//     _playPauseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//
//     _memorizationService.recordRecentlyRead(
//       widget.surah.number,
//       _currentVerseId,
//       source: 'reading_mode',
//     );
//
//     final audioService = SharedAudioService.instance;
//     _syncWithAudioService();
//
//     if (!audioService.isInitialized) {
//       audioService
//           .initialize()
//           .then((_) {
//             if (mounted) {
//               // Always stop audio when switching to reading_mode from any different screen
//               if (audioService.isPlaying &&
//                   audioService.originatingScreen != 'reading_mode') {
//                 audioService.stop();
//               }
//               audioService.setSurahAndVerse(
//                 widget.surah,
//                 _currentVerseId,
//                 screen: 'reading_mode',
//               );
//               audioService.setAutoAdvance(true);
//               audioService.setRepeatCount(1);
//               _syncWithAudioService();
//             }
//           })
//           .catchError((e) {
//             logger.e('Failed to initialize audio service: $e');
//           });
//     } else {
//       // Always stop audio when switching to reading_mode from any different screen
//       if (audioService.isPlaying &&
//           audioService.originatingScreen != 'reading_mode') {
//         audioService.stop();
//       }
//       audioService.setSurahAndVerse(
//         widget.surah,
//         _currentVerseId,
//         screen: 'reading_mode',
//       );
//       audioService.setAutoAdvance(true);
//       audioService.setRepeatCount(1);
//     }
//
//     _setupAudioServiceListeners();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToVerse(_currentVerseId);
//     });
//   }
//
//   void _syncWithAudioService() {
//     final audioService = SharedAudioService.instance;
//
//     // Only sync if audio is from this screen (reading_mode)
//     if (audioService.currentContext == 'quran' &&
//         audioService.currentSurah?.number == widget.surah.number &&
//         audioService.originatingScreen == 'reading_mode') {
//       if (audioService.currentVerseId != _currentVerseId &&
//           audioService.currentVerseId <= widget.surah.ayahs.length) {
//         setState(() {
//           _currentVerseId = audioService.currentVerseId;
//         });
//       }
//
//       setState(() {
//         _isPlaying = audioService.isPlaying;
//         _isLoading = audioService.isLoading;
//       });
//
//       if (_isPlaying) {
//         _playPauseController.forward();
//       } else {
//         _playPauseController.reverse();
//       }
//
//       logger.d(
//         'ReadingModeScreen: Synced with audio service - playing: $_isPlaying, verse: $_currentVerseId, surah: ${widget.surah.englishName}',
//       );
//     } else {
//       // Don't sync verse or state from other screens, just maintain our own context
//       logger.d(
//         'ReadingModeScreen: Audio from different screen/context, maintaining independent state',
//       );
//     }
//   }
//
//   void _setupAudioServiceListeners() {
//     _verseSubscription = SharedAudioService.instance.currentVerseStream.listen((
//       verseId,
//     ) {
//       // Sync verse changes if audio is playing from this screen OR if it's auto-advancing
//       if (mounted) {
//         final audioService = SharedAudioService.instance;
//         final currentSurahNumber = audioService.currentSurah?.number;
//
//         // Check if the current surah has changed (auto-advanced to next surah)
//         if (currentSurahNumber != null &&
//             currentSurahNumber != widget.surah.number) {
//           // The audio service has moved to a different surah, so we should navigate to that surah
//           if (mounted) {
//             // Navigate to the new surah in reading mode
//             context.pushReplacementNamed(
//               Routes.quranReadingMode.name,
//               queryParameters: {
//                 'surahId': currentSurahNumber.toString(),
//                 'verseId': verseId.toString(),
//               },
//             );
//           }
//         } else if (verseId != _currentVerseId) {
//           // Same surah, different verse
//           final shouldUpdateUI =
//               audioService.originatingScreen == 'reading_mode' ||
//               (audioService.isPlaying &&
//                   audioService.currentContext == 'quran' &&
//                   audioService.currentSurah?.number == widget.surah.number);
//
//           if (shouldUpdateUI && verseId <= widget.surah.ayahs.length) {
//             setState(() {
//               _currentVerseId = verseId;
//               // Reset highlights when changing verse
//               _currentHighlightedWordIndex = -1;
//               _previousHighlightedWordIndex = -1;
//             });
//             _scrollToVerse(verseId);
//             _memorizationService.recordRecentlyRead(
//               widget.surah.number,
//               verseId,
//               source: 'reading_mode',
//             );
//           }
//         }
//       }
//     });
//
//     _highlightSubscription = SharedAudioService.instance.highlightedWordStream
//         .listen((wordIndex) {
//           // Only sync highlights if audio is playing from this screen
//           if (mounted &&
//               SharedAudioService.instance.originatingScreen == 'reading_mode') {
//             setState(() {
//               if (wordIndex != _currentHighlightedWordIndex) {
//                 _previousHighlightedWordIndex = _currentHighlightedWordIndex;
//                 _currentHighlightedWordIndex = wordIndex;
//               }
//             });
//           }
//         });
//
//     SharedAudioService.instance.playingStateStream.listen((isPlaying) {
//       if (mounted) {
//         // Only sync playing state if audio is from this screen or if stopping
//         if (SharedAudioService.instance.originatingScreen == 'reading_mode' ||
//             !isPlaying) {
//           setState(() {
//             _isPlaying = isPlaying;
//             if (!isPlaying) {
//               // Only clear highlights when audio stops completely
//               _currentHighlightedWordIndex = -1;
//               _previousHighlightedWordIndex = -1;
//             }
//           });
//
//           if (isPlaying) {
//             _playPauseController.forward();
//           } else {
//             _playPauseController.reverse();
//           }
//         }
//       }
//     });
//
//     SharedAudioService.instance.loadingStateStream.listen((isLoading) {
//       // Only sync loading state if audio is from this screen
//       if (mounted &&
//           SharedAudioService.instance.originatingScreen == 'reading_mode') {
//         setState(() {
//           _isLoading = isLoading;
//         });
//       }
//     });
//
//     // Initialize highlighting immediately when audio starts (only if from this screen)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final audioService = SharedAudioService.instance;
//       if (mounted &&
//           audioService.isInitialized &&
//           audioService.originatingScreen == 'reading_mode') {
//         final currentIsPlaying = audioService.isPlaying;
//         final currentHighlightIndex = audioService.currentHighlightedWordIndex;
//         final isMatchingContext =
//             audioService.currentSurah?.number == widget.surah.number;
//
//         if (isMatchingContext &&
//             currentIsPlaying &&
//             currentHighlightIndex >= 0) {
//           setState(() {
//             _currentHighlightedWordIndex = currentHighlightIndex;
//           });
//         }
//       }
//     });
//   }
//
//   List<String> _splitArabicText(String text) {
//     final RegExp regex = RegExp(r'(\s+)|([^\s]+)');
//     final matches = regex.allMatches(text);
//     final List<String> words = [];
//
//     for (final match in matches) {
//       if (match.group(2) != null) {
//         words.add(match.group(2)!);
//       }
//     }
//
//     return words;
//   }
//
//   void _scrollToVerse(int verseId) {
//     if (_currentVerseId != verseId) {
//       _memorizationService.recordRecentlyRead(
//         widget.surah.number,
//         verseId,
//         source: 'reading_mode',
//       );
//     }
//
//     // Update the current verse in state
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         setState(() {
//           _currentVerseId = verseId;
//         });
//       }
//     });
//
//     // Scroll to the verse if the scroll controller is attached
//     final index = widget.surah.ayahs.indexWhere(
//       (ayah) => ayah.numberInSurah == verseId,
//     );
//
//     if (index >= 0 && _itemScrollController.isAttached) {
//       _itemScrollController.scrollTo(
//         index: index,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         alignment: 0.3, // Position verse closer to top for better visibility
//       );
//     }
//   }
//
//   Future<void> _playAudio() async {
//     final audioService = SharedAudioService.instance;
//
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
//
//     try {
//       // Set the current surah and verse context
//       audioService.setSurahAndVerse(
//         widget.surah,
//         _currentVerseId,
//         screen: 'reading_mode',
//       );
//       audioService.setAutoAdvance(true);
//       audioService.setRepeatCount(1);
//
//       // Check if we're currently playing the same verse
//       final isCurrentlyPlayingSameVerse =
//           audioService.isPlaying &&
//           audioService.currentSurah?.number == widget.surah.number &&
//           audioService.currentVerseId == _currentVerseId &&
//           audioService.originatingScreen == 'reading_mode';
//
//       if (isCurrentlyPlayingSameVerse) {
//         // If we're already playing this verse, just pause it
//         await audioService.pause();
//         setState(() {
//           _isPlaying = false;
//         });
//       } else {
//         // If we're not playing this verse, play it
//         await audioService.playQuranVerse(
//           surah: widget.surah,
//           verseId: _currentVerseId,
//           playbackSpeed: 1.0,
//           forceRestart: true,
//         );
//         setState(() {
//           _isPlaying = true;
//         });
//       }
//     } catch (e) {
//       logger.e('Error playing/stopping audio: $e');
//       FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Unable to control audio playback. Please try again.',
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   void _toggleAudio() {
//     setState(() {
//       _audioEnabled = !_audioEnabled;
//       if (!_audioEnabled &&
//           _isPlaying &&
//           SharedAudioService.instance.isInitialized) {
//         SharedAudioService.instance.stop();
//         _isPlaying = false;
//         _previousHighlightedWordIndex = _currentHighlightedWordIndex;
//         _currentHighlightedWordIndex = -1;
//         _playPauseController.reverse();
//       }
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(_audioEnabled ? 'Audio enabled' : 'Audio disabled'),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _playPauseController.dispose();
//     _verseSubscription?.cancel();
//     _highlightSubscription?.cancel();
//     super.dispose();
//   }
//
//   //   void _onVerseTap(int verseNumber) {
//   //     final wasPlaying = _isPlaying;
//
//   //     setState(() {
//   //       _currentVerseId = verseNumber;
//   //       // Reset highlights when changing verse
//   //       _currentHighlightedWordIndex = -1;
//   //       _previousHighlightedWordIndex = -1;
//   //       // Don't show loading during instant transitions
//   //       _isLoading = false;
//   //     });
//
//   //     // Update the audio service with the new verse
//   //     SharedAudioService.instance
//   //         .setSurahAndVerse(widget.surah, verseNumber, screen: 'reading_mode');
//   //     SharedAudioService.instance.setAutoAdvance(true);
//   //     SharedAudioService.instance.setRepeatCount(1);
//
//   //     if (_audioEnabled && SharedAudioService.instance.isInitialized) {
//   //       if (wasPlaying) {
//   //         // If audio was playing, continue playing at the new verse
//   //         _playAudio();
//   //       } else {
//   //         // If audio was not playing, just set the context to the new verse
//   //         SharedAudioService.instance.setSurahAndVerse(
//   //           widget.surah,
//   //           verseNumber,
//   //           screen: 'reading_mode'
//   //         );
//   //       }
//   //     }
//   //   }
//
//   void _onVerseTap(int verseNumber) {
//     // Stop any playing audio first
//     if (_isPlaying) {
//       SharedAudioService.instance.stop();
//     }
//
//     setState(() {
//       _currentVerseId = verseNumber;
//       _currentHighlightedWordIndex = -1;
//       _previousHighlightedWordIndex = -1;
//       _isLoading = false;
//       _isPlaying = false; // Reset state
//     });
//
//     // Update audio service
//     SharedAudioService.instance.setSurahAndVerse(
//       widget.surah,
//       verseNumber,
//       screen: 'reading_mode',
//     );
//     SharedAudioService.instance.setAutoAdvance(true);
//     SharedAudioService.instance.setRepeatCount(1);
//
//     // Scroll to verse
//     _scrollToVerse(verseNumber);
//
//     // Play audio directly (bypass _playAudio logic)
//     if (_audioEnabled) {
//       _playVerseDirectly(verseNumber);
//     }
//   }
//
//   Future<void> _playVerseDirectly(int verseNumber) async {
//     try {
//       await SharedAudioService.instance.playQuranVerse(
//         surah: widget.surah,
//         verseId: verseNumber,
//         playbackSpeed: 1.0,
//         forceRestart: true,
//       );
//       setState(() {
//         _isPlaying = true;
//       });
//     } catch (e) {
//       logger.e('Error playing verse $verseNumber: $e');
//       setState(() {
//         _isPlaying = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBarScaffold(
//       centerTitle: true,
//       searchBar: SurahHeaderWidget(surah: widget.surah),
//       appBarActions: [
//         IconButton(
//           icon: Icon(
//             _audioEnabled ? Icons.volume_up : Icons.volume_off,
//             color: _audioEnabled ? Colors.white : Colors.grey,
//           ),
//           onPressed: _toggleAudio,
//           tooltip: _audioEnabled ? 'Disable Audio' : 'Enable Audio',
//         ),
//         IconButton(
//           icon: const Icon(Icons.format_size),
//           onPressed: () => _showFontSizeDialog(context),
//           tooltip: 'Adjust Text Size',
//         ),
//         IconButton(
//           icon: const Icon(Icons.menu_book),
//           onPressed: () => _showSurahSelection(context),
//           tooltip: 'Select Surah',
//         ),
//       ],
//       bottomNavigationBar: _audioEnabled
//           ? AudioControlsWidget(
//               isPlaying: _isPlaying,
//               isLoading: _isLoading,
//               currentVerseId: _currentVerseId,
//               totalVerses: widget.surah.ayahs.length,
//               onPlayPause: _playAudio,
//               onPreviousVerse: _navigateToPreviousVerse,
//               onNextVerse: _navigateToNextVerse,
//               playPauseController: _playPauseController,
//             )
//           : null,
//       child: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFFFF8E1), Color(0xFFFFFDE7)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Column(
//             children: [
//               Expanded(
//                 child: ScrollablePositionedList.builder(
//                   itemScrollController: _itemScrollController,
//                   itemPositionsListener: _itemPositionsListener,
//                   itemCount: widget.surah.ayahs.length, // +1 for Bismillah
//                   itemBuilder: (context, index) {
//                     if (index == 0) {
//                       // Bismillah for Surah Al-Fatiha or other surahs (except Surah At-Tawbah)
//                       if (widget.surah.number == 9) {
//                         // For Al-Fatiha, the Bismillah is part of the first verse
//                         return const SizedBox.shrink();
//                       } else if (widget.surah.number == 9) {
//                         // Surah At-Tawbah doesn't have Bismillah
//                         return const SizedBox.shrink();
//                       } else {
//                         // Other surahs have Bismillah at the beginning
//                         return Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           child: Column(
//                             children: [
//                               Center(
//                                 child: Text(
//                                   'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
//                                   style: TextStyle(
//                                     fontFamily: 'Amiri',
//                                     fontSize: _textSize + 2,
//                                     height: 2.0,
//                                     color: const Color(0xFF2E7D32),
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   textDirection: TextDirection.rtl,
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               Container(
//                                 width: double.infinity,
//                                 height: 2,
//                                 margin: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Colors.transparent,
//                                       const Color(
//                                         0xFF2E7D32,
//                                       ).withValues(alpha: 0.4),
//                                       const Color(
//                                         0xFF2E7D32,
//                                       ).withValues(alpha: 0.6),
//                                       const Color(
//                                         0xFF2E7D32,
//                                       ).withValues(alpha: 0.4),
//                                       Colors.transparent,
//                                     ],
//                                   ),
//                                   borderRadius: BorderRadius.circular(1),
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                             ],
//                           ),
//                         );
//                       }
//                     } else {
//                       // Actual verses (index - 1 because of Bismillah at index 0)
//                       final ayah = widget.surah.ayahs[index - 1];
//                       final isCurrentVerse =
//                           ayah.numberInSurah == _currentVerseId;
//
//                       return Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 4.0,
//                           vertical: 8.0,
//                         ),
//                         child: RichText(
//                           textDirection: TextDirection.rtl,
//                           textAlign: TextAlign.justify,
//                           text: TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: ayah.text,
//                                 style: TextStyle(
//                                   fontFamily: 'Amiri',
//                                   fontSize: _textSize,
//                                   height: 2.5, // Consistent line height
//                                   color: isCurrentVerse
//                                       ? const Color(0xFF2E7D32)
//                                       : const Color(0xFF1B1B1B),
//                                   fontWeight: isCurrentVerse
//                                       ? FontWeight.w600
//                                       : FontWeight.w500,
//                                   shadows: isCurrentVerse
//                                       ? [
//                                           const Shadow(
//                                             offset: Offset(0.5, 0.5),
//                                             blurRadius: 1.0,
//                                             color: Color(0xFF2E7D32),
//                                           ),
//                                         ]
//                                       : null,
//                                 ),
//                                 recognizer: TapGestureRecognizer()
//                                   ..onTap = () =>
//                                       _onVerseTap(ayah.numberInSurah),
//                               ),
//                               WidgetSpan(
//                                 alignment: PlaceholderAlignment.middle,
//                                 child: VerseNumberCircle(
//                                   verseNumber: ayah.numberInSurah,
//                                   isCurrentVerse: isCurrentVerse,
//                                   onTap: () => _onVerseTap(ayah.numberInSurah),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _navigateToPreviousVerse() {
//     if (_currentVerseId > 1 && SharedAudioService.instance.isInitialized) {
//       final wasPlaying = _isPlaying;
//
//       if (wasPlaying) {
//         SharedAudioService.instance.stop();
//       }
//
//       setState(() {
//         _currentVerseId--;
//         // Reset highlights when changing verse
//         _currentHighlightedWordIndex = -1;
//         _previousHighlightedWordIndex = -1;
//         // Don't show loading during instant transitions
//         _isLoading = false;
//       });
//
//       // Update the audio service with the new verse
//       SharedAudioService.instance.setSurahAndVerse(
//         widget.surah,
//         _currentVerseId,
//         screen: 'reading_mode',
//       );
//       SharedAudioService.instance.setAutoAdvance(true);
//       SharedAudioService.instance.setRepeatCount(1);
//
//       if (wasPlaying && _audioEnabled) {
//         // Resume playback at the new verse if it was playing before
//         _playAudio();
//       }
//     }
//   }
//
//   void _navigateToNextVerse() {
//     if (_currentVerseId < widget.surah.ayahs.length &&
//         SharedAudioService.instance.isInitialized) {
//       final wasPlaying = _isPlaying;
//
//       if (wasPlaying) {
//         SharedAudioService.instance.stop();
//       }
//
//       setState(() {
//         _currentVerseId++;
//         // Reset highlights when changing verse
//         _currentHighlightedWordIndex = -1;
//         _previousHighlightedWordIndex = -1;
//         // Don't show loading during instant transitions
//         _isLoading = false;
//       });
//
//       // Update the audio service with the new verse
//       SharedAudioService.instance.setSurahAndVerse(
//         widget.surah,
//         _currentVerseId,
//         screen: 'reading_mode',
//       );
//       SharedAudioService.instance.setAutoAdvance(true);
//       SharedAudioService.instance.setRepeatCount(1);
//
//       if (wasPlaying && _audioEnabled) {
//         // Resume playback at the new verse if it was playing before
//         _playAudio();
//       }
//     }
//   }
//
//   void _showFontSizeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => FontSizeDialog(
//         initialSize: _textSize,
//         onSizeChanged: (size) {
//           setState(() {
//             _textSize = size;
//           });
//         },
//       ),
//     );
//   }
//
//   void _showSurahSelection(BuildContext context) {
//     final QuranService quranService = QuranService();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => SurahSelectionSheet(
//         surahs: quranService.getAllSurahs(),
//         onSurahSelected: (surah) {
//           Navigator.pop(context);
//           context.pushNamed(
//             Routes.quranReadingMode.name,
//             queryParameters: {
//               'surahId': surah.number.toString(),
//               'verseId': '1',
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:deenhub/config/routes/routes.dart';
// import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/audio_controls_widget.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/font_size_dialog.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/quran_page_widget.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/surah_header_widget.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/surah_selection_sheet.dart';
// import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/reading/verse_number_circle.dart';
// import 'package:deenhub/main.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/material.dart';
// import 'package:deenhub/core/services/shared_audio_service.dart';
// import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
// import 'package:deenhub/features/quran/data/repository/quran_service.dart';
// import 'package:deenhub/features/quran/domain/models/quran_model.dart';
// import 'package:go_router/go_router.dart';
// import 'dart:async';
// import 'package:flutter/gestures.dart';

// class ReadingModeScreen extends StatefulWidget {
//   final Surah surah;
//   final int initialVerseId;

//   const ReadingModeScreen({
//     super.key,
//     required this.surah,
//     required this.initialVerseId,
//   });

//   @override
//   State<ReadingModeScreen> createState() => _ReadingModeScreenState();
// }

// class _ReadingModeScreenState extends State<ReadingModeScreen>
//     with SingleTickerProviderStateMixin {
//   late int _currentVerseId;
//   bool _isPlaying = false;
//   bool _isLoading = false;
//   final MemorizationService _memorizationService = MemorizationService();
//   double _textSize = 26.0;
//   bool _audioEnabled = true;
//   late AnimationController _playPauseController;
//   int _currentHighlightedWordIndex = -1;
//   int _previousHighlightedWordIndex =
//       -1; // Track previous index for smooth transitions
//   StreamSubscription<int>? _verseSubscription;
//   StreamSubscription<int>? _highlightSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _currentVerseId = widget.initialVerseId;
//     // Determine effective initial verse. If coming from a different screen/mode,
//     // force start from verse 1 for reading mode to avoid cross-mode carryover.
//     final sharedService = SharedAudioService.instance;
//     int effectiveInitialVerse = widget.initialVerseId;
//     if (sharedService.currentContext == 'quran' &&
//         sharedService.originatingScreen != 'reading_mode' &&
//         sharedService.currentSurah?.number == widget.surah.number) {
//       effectiveInitialVerse = 1;
//     }
//     _currentVerseId = effectiveInitialVerse;

//     _playPauseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     _memorizationService.recordRecentlyRead(
//         widget.surah.number, _currentVerseId,
//         source: 'reading_mode');

//     final audioService = SharedAudioService.instance;
//     _syncWithAudioService();

//     if (!audioService.isInitialized) {
//       audioService.initialize().then((_) {
//         if (mounted) {
//           // Always stop audio when switching to reading_mode from any different screen
//           if (audioService.isPlaying &&
//               audioService.originatingScreen != 'reading_mode') {
//             audioService.stop();
//           }
//           audioService.setSurahAndVerse(
//             widget.surah,
//             _currentVerseId,
//             screen: 'reading_mode',
//           );
//           audioService.setAutoAdvance(true);
//           audioService.setRepeatCount(1);
//           _syncWithAudioService();
//         }
//       }).catchError((e) {
//         logger.e('Failed to initialize audio service: $e');
//       });
//     } else {
//       // Always stop audio when switching to reading_mode from any different screen
//       if (audioService.isPlaying &&
//           audioService.originatingScreen != 'reading_mode') {
//         audioService.stop();
//       }
//       audioService.setSurahAndVerse(
//         widget.surah,
//         _currentVerseId,
//         screen: 'reading_mode',
//       );
//       audioService.setAutoAdvance(true);
//       audioService.setRepeatCount(1);
//     }

//     _setupAudioServiceListeners();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToVerse(_currentVerseId);
//     });
//   }

//   void _syncWithAudioService() {
//     final audioService = SharedAudioService.instance;

//     // Only sync if audio is from this screen (reading_mode)
//     if (audioService.currentContext == 'quran' &&
//         audioService.currentSurah?.number == widget.surah.number &&
//         audioService.originatingScreen == 'reading_mode') {
//       if (audioService.currentVerseId != _currentVerseId &&
//           audioService.currentVerseId <= widget.surah.ayahs.length) {
//         setState(() {
//           _currentVerseId = audioService.currentVerseId;
//         });
//       }

//       setState(() {
//         _isPlaying = audioService.isPlaying;
//         _isLoading = audioService.isLoading;
//       });

//       if (_isPlaying) {
//         _playPauseController.forward();
//       } else {
//         _playPauseController.reverse();
//       }

//       logger.d(
//           'ReadingModeScreen: Synced with audio service - playing: $_isPlaying, verse: $_currentVerseId, surah: ${widget.surah.englishName}');
//     } else {
//       // Don't sync verse or state from other screens, just maintain our own context
//       logger.d(
//           'ReadingModeScreen: Audio from different screen/context, maintaining independent state');
//     }
//   }

//   void _setupAudioServiceListeners() {
//     _verseSubscription =
//         SharedAudioService.instance.currentVerseStream.listen((verseId) {
//       // Sync verse changes if audio is playing from this screen OR if it's auto-advancing
//       if (mounted) {
//         final audioService = SharedAudioService.instance;
//         final currentSurahNumber = audioService.currentSurah?.number;

//         // Check if the current surah has changed (auto-advanced to next surah)
//         if (currentSurahNumber != null && currentSurahNumber != widget.surah.number) {
//           // The audio service has moved to a different surah, so we should navigate to that surah
//           if (mounted) {
//             // Navigate to the new surah in reading mode
//             context.pushReplacementNamed(
//               Routes.quranReadingMode.name,
//               queryParameters: {
//                 'surahId': currentSurahNumber.toString(),
//                 'verseId': verseId.toString(),
//               },
//             );
//           }
//         } else if (verseId != _currentVerseId) {
//           // Same surah, different verse
//           final shouldUpdateUI = audioService.originatingScreen == 'reading_mode' ||
//                                 (audioService.isPlaying && audioService.currentContext == 'quran' &&
//                                  audioService.currentSurah?.number == widget.surah.number);

//           if (shouldUpdateUI && verseId <= widget.surah.ayahs.length) {
//             setState(() {
//               _currentVerseId = verseId;
//               // Reset highlights when changing verse
//               _currentHighlightedWordIndex = -1;
//               _previousHighlightedWordIndex = -1;
//             });
//             _scrollToVerse(verseId);
//             _memorizationService.recordRecentlyRead(widget.surah.number, verseId,
//                 source: 'reading_mode');
//           }
//         }
//       }
//     });

//     _highlightSubscription =
//         SharedAudioService.instance.highlightedWordStream.listen((wordIndex) {
//       // Only sync highlights if audio is playing from this screen
//       if (mounted && SharedAudioService.instance.originatingScreen == 'reading_mode') {
//         setState(() {
//           if (wordIndex != _currentHighlightedWordIndex) {
//             _previousHighlightedWordIndex = _currentHighlightedWordIndex;
//             _currentHighlightedWordIndex = wordIndex;
//           }
//         });
//       }
//     });

//     SharedAudioService.instance.playingStateStream.listen((isPlaying) {
//       if (mounted) {
//         // Only sync playing state if audio is from this screen or if stopping
//         if (SharedAudioService.instance.originatingScreen == 'reading_mode' || !isPlaying) {
//           setState(() {
//             _isPlaying = isPlaying;
//             if (!isPlaying) {
//               // Only clear highlights when audio stops completely
//               _currentHighlightedWordIndex = -1;
//               _previousHighlightedWordIndex = -1;
//             }
//           });

//           if (isPlaying) {
//             _playPauseController.forward();
//           } else {
//             _playPauseController.reverse();
//           }
//         }
//       }
//     });

//     SharedAudioService.instance.loadingStateStream.listen((isLoading) {
//       // Only sync loading state if audio is from this screen
//       if (mounted && SharedAudioService.instance.originatingScreen == 'reading_mode') {
//         setState(() {
//           _isLoading = isLoading;
//         });
//       }
//     });

//     // Initialize highlighting immediately when audio starts (only if from this screen)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final audioService = SharedAudioService.instance;
//       if (mounted && audioService.isInitialized && audioService.originatingScreen == 'reading_mode') {
//         final currentIsPlaying = audioService.isPlaying;
//         final currentHighlightIndex = audioService.currentHighlightedWordIndex;
//         final isMatchingContext =
//             audioService.currentSurah?.number == widget.surah.number;

//         if (isMatchingContext &&
//             currentIsPlaying &&
//             currentHighlightIndex >= 0) {
//           setState(() {
//             _currentHighlightedWordIndex = currentHighlightIndex;
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

//   void _scrollToVerse(int verseId) {
//     if (_currentVerseId != verseId) {
//       _memorizationService.recordRecentlyRead(widget.surah.number, verseId,
//           source: 'reading_mode');
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         setState(() {
//           _currentVerseId = verseId;
//         });
//       }
//     });
//   }

//   Future<void> _playAudio() async {
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
//       // Set the current surah and verse context
//       audioService.setSurahAndVerse(widget.surah, _currentVerseId,
//           screen: 'reading_mode');
//       audioService.setAutoAdvance(true);
//       audioService.setRepeatCount(1);

//       // Check if we're currently playing the same verse
//       final isCurrentlyPlayingSameVerse =
//           audioService.isPlaying &&
//           audioService.currentSurah?.number == widget.surah.number &&
//           audioService.currentVerseId == _currentVerseId &&
//           audioService.originatingScreen == 'reading_mode';

//       if (isCurrentlyPlayingSameVerse) {
//         // If we're already playing this verse, just pause it
//         await audioService.pause();
//         setState(() {
//           _isPlaying = false;
//         });
//       } else {
//         // If we're not playing this verse, play it
//         await audioService.playQuranVerse(
//           surah: widget.surah,
//           verseId: _currentVerseId,
//           playbackSpeed: 1.0,
//           forceRestart: true,
//         );
//         setState(() {
//           _isPlaying = true;
//         });
//       }
//     } catch (e) {
//       logger.e('Error playing/stopping audio: $e');
//       FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Unable to control audio playback. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _toggleAudio() {
//     setState(() {
//       _audioEnabled = !_audioEnabled;
//       if (!_audioEnabled &&
//           _isPlaying &&
//           SharedAudioService.instance.isInitialized) {
//         SharedAudioService.instance.stop();
//         _isPlaying = false;
//         _previousHighlightedWordIndex = _currentHighlightedWordIndex;
//         _currentHighlightedWordIndex = -1;
//         _playPauseController.reverse();
//       }
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//           content: Text(_audioEnabled ? 'Audio enabled' : 'Audio disabled')),
//     );
//   }

//   @override
//   void dispose() {
//     _playPauseController.dispose();
//     _verseSubscription?.cancel();
//     _highlightSubscription?.cancel();
//     super.dispose();
//   }

//   // Build continuous Quran text with proper line height and smooth highlighting
//   Widget _buildContinuousQuranText() {
//     List<InlineSpan> allSpans = [];

//     for (int i = 0; i < widget.surah.ayahs.length; i++) {
//       final ayah = widget.surah.ayahs[i];
//       final isCurrentVerse = ayah.numberInSurah == _currentVerseId;

//       if (widget.surah.number == 1 && ayah.numberInSurah == 1) {
//         // Skip Bismillah as verse 1 in Al-Fatiha
//       } else {
//         if (_audioEnabled &&
//             _isPlaying &&
//             isCurrentVerse &&
//             ayah.wordTiming != null &&
//             _currentHighlightedWordIndex >= 0) {
//           final words = _splitArabicText(ayah.text);
//           if (ayah.wordTiming!.segments.isNotEmpty && words.isNotEmpty) {
//             allSpans.addAll(_buildHighlightedWordsSpans(
//                 words, ayah.wordTiming!.segments, isCurrentVerse));
//           } else {
//             allSpans.add(_buildRegularVerseSpan(
//                 ayah.text, isCurrentVerse, ayah.numberInSurah));
//           }
//         } else {
//           allSpans.add(_buildRegularVerseSpan(
//               ayah.text, isCurrentVerse, ayah.numberInSurah));
//         }

//         allSpans.add(WidgetSpan(
//           alignment: PlaceholderAlignment.middle,
//           child: VerseNumberCircle(
//             verseNumber: ayah.numberInSurah,
//             isCurrentVerse: isCurrentVerse,
//             onTap: () => _onVerseTap(ayah.numberInSurah),
//           ),
//         ));

//         // Add divider after each verse except the last one
//         if (i < widget.surah.ayahs.length - 1) {
//           allSpans.add(const TextSpan(text: ' '));
//           allSpans.add(WidgetSpan(
//             alignment: PlaceholderAlignment.middle,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               height: 1,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.transparent,
//                     const Color(0xFF2E7D32).withValues(alpha: 0.3),
//                     const Color(0xFF2E7D32).withValues(alpha: 0.5),
//                     const Color(0xFF2E7D32).withValues(alpha: 0.3),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ));
//           allSpans.add(const TextSpan(text: ' '));
//         }
//       }
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
//       child: RichText(
//         textDirection: TextDirection.rtl,
//         textAlign: TextAlign.justify,
//         text: TextSpan(children: allSpans),
//       ),
//     );
//   }

//   void _onVerseTap(int verseNumber) {
//     final wasPlaying = _isPlaying;

//     setState(() {
//       _currentVerseId = verseNumber;
//       // Reset highlights when changing verse
//       _currentHighlightedWordIndex = -1;
//       _previousHighlightedWordIndex = -1;
//       // Don't show loading during instant transitions
//       _isLoading = false;
//     });

//     // Update the audio service with the new verse
//     SharedAudioService.instance
//         .setSurahAndVerse(widget.surah, verseNumber, screen: 'reading_mode');
//     SharedAudioService.instance.setAutoAdvance(true);
//     SharedAudioService.instance.setRepeatCount(1);

//     if (_audioEnabled && SharedAudioService.instance.isInitialized) {
//       if (wasPlaying) {
//         // If audio was playing, continue playing at the new verse
//         _playAudio();
//       } else {
//         // If audio was not playing, just set the context to the new verse
//         SharedAudioService.instance.setSurahAndVerse(
//           widget.surah,
//           verseNumber,
//           screen: 'reading_mode'
//         );
//       }
//     }
//   }

//   TextSpan _buildRegularVerseSpan(
//       String text, bool isCurrentVerse, int verseNumber) {
//     return TextSpan(
//       text: text,
//       style: TextStyle(
//         fontFamily: 'Amiri',
//         fontSize: _textSize,
//         height: 2.5, // Consistent line height
//         color:
//             isCurrentVerse ? const Color(0xFF2E7D32) : const Color(0xFF1B1B1B),
//         fontWeight: isCurrentVerse ? FontWeight.w600 : FontWeight.w500,
//         shadows: isCurrentVerse
//             ? [
//                 const Shadow(
//                   offset: Offset(0.5, 0.5),
//                   blurRadius: 1.0,
//                   color: Color(0xFF2E7D32),
//                 ),
//               ]
//             : null,
//       ),
//       recognizer: TapGestureRecognizer()
//         ..onTap = () => _onVerseTap(verseNumber),
//     );
//   }

//   List<TextSpan> _buildHighlightedWordsSpans(
//       List<String> words, List<WordSegment> segments, bool isCurrentVerse) {
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

//       spans.add(TextSpan(
//         text: words[i],
//         style: TextStyle(
//           fontFamily: 'Amiri',
//           fontSize: _textSize, // Consistent font size
//           height: 2.5, // Consistent line height - never changes
//           fontWeight: FontWeight.w600, // Consistent weight for all text
//           color: isHighlighted
//               ? const Color(0xFFD32F2F)
//               : (isCurrentVerse
//                   ? const Color(0xFF2E7D32)
//                   : const Color(0xFF1B1B1B)),
//           backgroundColor: isHighlighted
//               ? const Color(0xFFFFF3E0)
//               : (wasPreviouslyHighlighted
//                   ? const Color(0xFFFFF3E0).withValues(alpha: 0.1)
//                   : null), // Much lighter previous highlight
//           shadows: isCurrentVerse && !isHighlighted
//               ? [
//                   const Shadow(
//                     offset: Offset(0.5, 0.5),
//                     blurRadius: 1.0,
//                     color: Color(0xFF2E7D32),
//                   ),
//                 ]
//               : null,
//         ),
//       ));
//       // Add space between words only if it's not the last word
//       if (i < wordCount - 1) {
//         spans.add(const TextSpan(text: ' '));
//       }
//     }

//     return spans;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBarScaffold(
//       centerTitle: true,
//       searchBar: SurahHeaderWidget(surah: widget.surah),
//       appBarActions: [
//         IconButton(
//           icon: Icon(
//             _audioEnabled ? Icons.volume_up : Icons.volume_off,
//             color: _audioEnabled ? Colors.white : Colors.grey,
//           ),
//           onPressed: _toggleAudio,
//           tooltip: _audioEnabled ? 'Disable Audio' : 'Enable Audio',
//         ),
//         IconButton(
//           icon: const Icon(Icons.format_size),
//           onPressed: () => _showFontSizeDialog(context),
//           tooltip: 'Adjust Text Size',
//         ),
//         IconButton(
//           icon: const Icon(Icons.menu_book),
//           onPressed: () => _showSurahSelection(context),
//           tooltip: 'Select Surah',
//         ),
//       ],
//       bottomNavigationBar: _audioEnabled
//           ? AudioControlsWidget(
//               isPlaying: _isPlaying,
//               isLoading: _isLoading,
//               currentVerseId: _currentVerseId,
//               totalVerses: widget.surah.ayahs.length,
//               onPlayPause: _playAudio,
//               onPreviousVerse: _navigateToPreviousVerse,
//               onNextVerse: _navigateToNextVerse,
//               playPauseController: _playPauseController,
//             )
//           : null,
//       child: QuranPageWidget(
//         surah: widget.surah,
//         textSize: _textSize,
//         continuousText: _buildContinuousQuranText(),
//       ),
//     );
//   }

//   void _navigateToPreviousVerse() {
//     if (_currentVerseId > 1 && SharedAudioService.instance.isInitialized) {
//       final wasPlaying = _isPlaying;

//       if (wasPlaying) {
//         SharedAudioService.instance.stop();
//       }

//       setState(() {
//         _currentVerseId--;
//         // Reset highlights when changing verse
//         _currentHighlightedWordIndex = -1;
//         _previousHighlightedWordIndex = -1;
//         // Don't show loading during instant transitions
//         _isLoading = false;
//       });

//       // Update the audio service with the new verse
//       SharedAudioService.instance.setSurahAndVerse(
//           widget.surah, _currentVerseId,
//           screen: 'reading_mode');
//       SharedAudioService.instance.setAutoAdvance(true);
//       SharedAudioService.instance.setRepeatCount(1);

//       if (wasPlaying && _audioEnabled) {
//         // Resume playback at the new verse if it was playing before
//         _playAudio();
//       }
//     }
//   }

//   void _navigateToNextVerse() {
//     if (_currentVerseId < widget.surah.ayahs.length &&
//         SharedAudioService.instance.isInitialized) {
//       final wasPlaying = _isPlaying;

//       if (wasPlaying) {
//         SharedAudioService.instance.stop();
//       }

//       setState(() {
//         _currentVerseId++;
//         // Reset highlights when changing verse
//         _currentHighlightedWordIndex = -1;
//         _previousHighlightedWordIndex = -1;
//         // Don't show loading during instant transitions
//         _isLoading = false;
//       });

//       // Update the audio service with the new verse
//       SharedAudioService.instance.setSurahAndVerse(
//           widget.surah, _currentVerseId,
//           screen: 'reading_mode');
//       SharedAudioService.instance.setAutoAdvance(true);
//       SharedAudioService.instance.setRepeatCount(1);

//       if (wasPlaying && _audioEnabled) {
//         // Resume playback at the new verse if it was playing before
//         _playAudio();
//       }
//     }
//   }

//   void _showFontSizeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => FontSizeDialog(
//         initialSize: _textSize,
//         onSizeChanged: (size) {
//           setState(() {
//             _textSize = size;
//           });
//         },
//       ),
//     );
//   }

//   void _showSurahSelection(BuildContext context) {
//     final QuranService quranService = QuranService();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => SurahSelectionSheet(
//         surahs: quranService.getAllSurahs(),
//         onSurahSelected: (surah) {
//           Navigator.pop(context);
//           context.pushNamed(
//             Routes.quranReadingMode.name,
//             queryParameters: {
//               'surahId': surah.number.toString(),
//               'verseId': '1',
//             },
//           );
//         },
//       ),
//     );
//   }
// }
