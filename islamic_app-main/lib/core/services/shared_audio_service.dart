import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/main.dart';

/// Unified audio service for all audio playback in the app
/// Handles Quran recitation, prayer guide audio, and other audio needs
///
/// This service follows the singleton pattern and manages a single AudioPlayer
/// instance to avoid platform conflicts and ensure proper resource management.
///
/// PLATFORM-SPECIFIC BACKGROUND AUDIO HANDLING:
/// - iOS: Requires complex audio session configuration for background playback
/// - Android: Uses NO audio session configuration for maximum compatibility.
///   Many Android devices work better without any audio session setup, which
///   restores the previous working behavior and avoids device-specific issues.
class SharedAudioService {
  static SharedAudioService? _instance;
  static SharedAudioService get instance =>
      _instance ??= SharedAudioService._();

  SharedAudioService._();

  // Core audio player - only one instance throughout the app lifecycle
  AudioPlayer? _audioPlayer;
  bool _isDisposed = false;
  bool _isInitializing = false; // Add flag to prevent multiple initializations

  // Current playback state
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _currentContext; // 'quran' or 'prayer_guide'

  // Quran-specific state
  Surah? _currentSurah;
  int _currentVerseId = 1;
  int _currentHighlightedWordIndex = -1;

  // Playback settings
  int _repeatCount = 1;
  int _currentRepeat = 0;
  bool _autoAdvance = true;
  double _playbackSpeed = 1.0;

  // Context tracking
  String? _originatingScreen;
  int? _lastPlayedSurahId;
  int? _lastPlayedVerseId;

  // Flag to prevent multiple completion handlers from firing
  bool _isHandlingCompletion = false;

  // Stream controllers
  StreamController<bool>? _playingStateController;
  StreamController<bool>? _loadingStateController;
  StreamController<int>? _currentVerseController;
  StreamController<int>? _highlightedWordController;

  // Stream subscriptions
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;

  // Audio file mappings for prayer guide
  static const Map<String, String> _prayerAudioFiles = {
    'fatiha': 'assets/audio/prayer_guide/surah_fatiha.mp3',
    'takbir': 'assets/audio/prayer_guide/allahu_akbar.mp3',
    'ruku': 'assets/audio/prayer_guide/subhana_rabbiyal_adheem.mp3',
    'sujud': 'assets/audio/prayer_guide/subhana_rabbiyal_ala.mp3',
    'tashahhud': 'assets/audio/prayer_guide/tashahhud.mp3',
    'durood': 'assets/audio/prayer_guide/durood_ibrahim.mp3',
    'tasleem': 'assets/audio/prayer_guide/assalamu_alaykum.mp3',
    'qunoot': 'assets/audio/prayer_guide/dua_qunoot.mp3',
    'standing_from_ruku':
        'assets/audio/prayer_guide/sami_allahu_liman_hamidah.mp3',
    'between_sujud': 'assets/audio/prayer_guide/rabbi_ghfir_li.mp3',
  };

  // Flag to track if surah has completely finished
  bool _surahCompleted = false;

  // Public getters
  bool get isInitialized => _audioPlayer != null && !_isDisposed;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get currentContext => _currentContext;
  int get currentVerseId => _currentVerseId;
  int get currentHighlightedWordIndex => _currentHighlightedWordIndex;
  Surah? get currentSurah => _currentSurah;
  int get repeatCount => _repeatCount;
  bool get autoAdvance => _autoAdvance;
  String? get originatingScreen => _originatingScreen;
  bool get surahCompleted => _surahCompleted;

  // Stream getters
  Stream<bool> get playingStateStream =>
      _playingStateController?.stream ?? const Stream.empty();
  Stream<bool> get loadingStateStream =>
      _loadingStateController?.stream ?? const Stream.empty();
  Stream<int> get currentVerseStream =>
      _currentVerseController?.stream ?? const Stream.empty();
  Stream<int> get highlightedWordStream =>
      _highlightedWordController?.stream ?? const Stream.empty();

  /// Initialize the audio service with optimizations for faster loading
  /// This must be called before using any audio functionality
  Future<void> initialize() async {
    if (_isDisposed) {
      logger.w('Attempting to initialize disposed SharedAudioService');
      return;
    }

    if (isInitialized) {
      logger.d('SharedAudioService already initialized');
      return;
    }

    // Prevent multiple concurrent initializations
    if (_isInitializing) {
      logger.d('SharedAudioService initialization already in progress');
      return;
    }

    _isInitializing = true;

    try {
      logger.i('Initializing SharedAudioService...');

      // Create stream controllers first (fastest)
      await _createStreamControllers();

      // Configure audio session for iOS background playback
      await _configureAudioSession();

      // Create audio player (can be slower)
      await _createAudioPlayer();

      // Setup listeners and emit initial state
      _setupAudioPlayerListeners();
      _emitInitialState();

      logger.i('SharedAudioService initialized successfully');
    } catch (e) {
      logger.e('Failed to initialize SharedAudioService: $e');
      await _cleanup();
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  /// Create stream controllers
  Future<void> _createStreamControllers() async {
    // Close existing controllers if any
    await _closeStreamControllers();

    _playingStateController = StreamController<bool>.broadcast();
    _loadingStateController = StreamController<bool>.broadcast();
    _currentVerseController = StreamController<int>.broadcast();
    _highlightedWordController = StreamController<int>.broadcast();
  }

  /// Configure audio session for background playback on both iOS and Android
  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;

      if (Platform.isIOS) {
        // iOS requires complex configuration for background audio
        await session.configure(const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ));

        // Set audio session active for iOS background audio - required
        await session.setActive(true);
        logger.i('iOS audio session configured for background playback');
      } else {
        // For Android, skip audio session configuration entirely
        // Many Android devices work better without any audio session configuration
        // This restores the previous working behavior
        logger.i('Android: Skipping audio session configuration for better compatibility');
        // Audio will work without explicit session configuration on most Android devices
      }
    } catch (e) {
      logger.w('Failed to configure audio session: $e');
      // Don't throw error - audio session configuration is optional, especially for Android
    }
  }

  /// Ensure audio session is active for background playback on both platforms
  Future<void> _ensureAudioSessionActive() async {
    try {
      final session = await AudioSession.instance;

      if (Platform.isIOS) {
        // iOS requires active audio session for background playback
        await session.setActive(true);
        logger.d('iOS audio session ensured active for background playback');
      } else {
        // For Android, skip session activation entirely for better compatibility
        logger.d('Android: Skipping audio session activation for better compatibility');
        // Audio will work without explicit session activation on most Android devices
      }
    } catch (e) {
      logger.w('Failed to ensure audio session is active: $e');
      // Don't throw error - this is an optimization, not a requirement
    }
  }

  /// Create audio player with optimizations and faster error handling
  Future<void> _createAudioPlayer() async {
    // Dispose existing player if any
    await _disposeAudioPlayer();

    try {
      _audioPlayer = AudioPlayer();

      // Pre-configure audio player settings for better performance - use parallel execution
      await Future.wait([
        _audioPlayer!.setSpeed(1.0),
        _audioPlayer!.setVolume(1.0),
      ]);

      logger.d('AudioPlayer created and configured successfully');
    } catch (e) {
      logger.e('Failed to create AudioPlayer: $e');

      // Simplified retry without delay for faster recovery
      try {
        _audioPlayer = AudioPlayer();
        // Skip configuration on retry for faster recovery
        logger.d('AudioPlayer created on retry');
      } catch (retryError) {
        logger.e('Failed to create AudioPlayer on retry: $retryError');
        throw Exception('Unable to create AudioPlayer: $retryError');
      }
    }
  }

  /// Setup audio player event listeners
  void _setupAudioPlayerListeners() {
    if (_audioPlayer == null) return;

    // Listen to player state changes
    _playerStateSubscription = _audioPlayer!.playerStateStream.listen(
      _handlePlayerStateChange,
      onError: (error) {
        logger.e('Player state stream error: $error');
        _handleStreamError();
      },
    );

    // Listen to position changes for word highlighting
    _positionSubscription = _audioPlayer!.positionStream.listen(
      _handlePositionChange,
      onError: (error) {
        logger.e('Position stream error: $error');
      },
    );
  }

  /// Handle player state changes
  void _handlePlayerStateChange(PlayerState state) {
    if (_isDisposed) return;

    final wasLoading = _isLoading;
    final wasPlaying = _isPlaying;

    // Update loading state
    _isLoading = state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering;

    // Update playing state
    _isPlaying = state.playing &&
        state.processingState != ProcessingState.completed &&
        state.processingState != ProcessingState.idle;

    // Emit state changes
    if (wasLoading != _isLoading) {
      _emitLoadingState();
    }

    if (wasPlaying != _isPlaying) {
      _emitPlayingState();
    }

    // Handle completion - only when actually completed (not on other state changes)
    if (state.processingState == ProcessingState.completed &&
        !_isHandlingCompletion) {
      _handleAudioCompletion();
    }
  }

  /// Handle position changes for word highlighting
  void _handlePositionChange(Duration position) {
    if (_isDisposed ||
        !_isPlaying ||
        _currentContext != 'quran' ||
        _currentSurah == null) {
      // Reset highlighting when not playing
      if (_currentHighlightedWordIndex != -1) {
        _currentHighlightedWordIndex = -1;
        _emitHighlightedWord();
      }
      return;
    }

    final ayah = _getCurrentAyah();
    if (ayah?.wordTiming == null || ayah!.wordTiming!.segments.isEmpty) {
      // Reset highlighting if no timing data
      if (_currentHighlightedWordIndex != -1) {
        _currentHighlightedWordIndex = -1;
        _emitHighlightedWord();
      }
      return;
    }

    final segments = ayah.wordTiming!.segments;
    final positionMs = position.inMilliseconds;
    int newWordIndex = -1;

    // Find current word based on timing
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (positionMs >= segment.startMsec && positionMs <= segment.endMsec) {
        newWordIndex = i;
        break;
      }
    }

    // Debug log for timing sync
    if (newWordIndex != _currentHighlightedWordIndex) {
      logger.d(
          'Word highlighting: position=${positionMs}ms, wordIndex=$newWordIndex/${segments.length}');
    }

    // Update highlighted word if changed
    if (newWordIndex != _currentHighlightedWordIndex) {
      _currentHighlightedWordIndex = newWordIndex;
      _emitHighlightedWord();
    }
  }

  /// Handle audio completion
  void _handleAudioCompletion() {
    if (_isDisposed) return;

    // Use flag to prevent multiple handlers from firing
    _isHandlingCompletion = true;

    logger.d(
        'Audio completed - Context: $_currentContext, Repeat: $_currentRepeat+1/$_repeatCount');

    // Reset word highlighting immediately
    _currentHighlightedWordIndex = -1;
    _emitHighlightedWord();

    if (_currentContext == 'quran' && _currentSurah != null) {
      _handleQuranCompletion();
    } else {
      // For non-Quran audio, just mark as complete
      _isPlaying = false;
      _emitPlayingState();
      _isHandlingCompletion = false;
    }
  }

  /// Handle Quran verse completion with repeat and auto-advance logic
  void _handleQuranCompletion() {
    // Increment repeat counter
    _currentRepeat++;
    logger.d('Verse completed, repeat $_currentRepeat of $_repeatCount');

    if (_currentRepeat < _repeatCount) {
      // Repeat current verse
      _scheduleRepeat();
    } else {
      // Reset repeat counter for next verse
      _currentRepeat = 0;

      // Auto-advance if enabled and not at last verse
      if (_autoAdvance &&
          _currentVerseId < (_currentSurah?.ayahs.length ?? 0)) {
        logger.d('Auto-advance enabled, moving to next verse');
        _scheduleAutoAdvance();
      } else {
        // Check if we've reached the end of the current surah
        if (_currentVerseId >= (_currentSurah?.ayahs.length ?? 0)) {
          _surahCompleted = true;
          logger.d('Surah completed at verse $_currentVerseId, checking for next surah');

          // Try to auto-advance to the next surah if available
          _tryAutoAdvanceToNextSurah();
        } else {
          logger.d(
              'Playback finished - no auto-advance (enabled: $_autoAdvance) or at end of surah (verse $_currentVerseId/${_currentSurah?.ayahs.length})');
          // Clear playing state when completely finished
          _isPlaying = false;
          _emitPlayingState();
          _isHandlingCompletion = false;
        }
      }
    }
  }

  /// Schedule verse repeat - optimized for background execution
  void _scheduleRepeat() {
    // Reduce delay for better background execution on iOS
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_isDisposed && _currentSurah != null && _currentContext == 'quran') {
        logger.d(
            'Repeating verse $_currentVerseId (repeat $_currentRepeat/$_repeatCount)');

        // Play the current verse again immediately
        try {
          _loadAndPlayAudio(_currentSurah!, _currentVerseId, _playbackSpeed);
        } catch (e) {
          logger.e('Error repeating verse: $e');
          _isPlaying = false;
          _emitPlayingState();
          _isHandlingCompletion = false;
        }
      } else {
        logger.w(
            'Cannot repeat: disposed=$_isDisposed, surah=${_currentSurah != null}, context=$_currentContext');
        _isHandlingCompletion = false;
      }
    });
  }

  /// Try to auto-advance to the next surah when current surah is completed
  void _tryAutoAdvanceToNextSurah() {
    if (!_autoAdvance || _currentSurah == null) {
      logger.d('Auto-advance disabled or no current surah, stopping playback');
      _isPlaying = false;
      _emitPlayingState();
      _isHandlingCompletion = false;
      return;
    }

    // Check if there's a next surah (Quran has 114 surahs)
    if (_currentSurah!.number < 114) {
      final nextSurahNumber = _currentSurah!.number + 1;
      logger.d('Auto-advancing to next surah: $nextSurahNumber');

      // Load the next surah using QuranService
      final quranService = QuranService();
      if (!quranService.isInitialized) {
        logger.w('QuranService not initialized, cannot auto-advance to next surah');
        _isPlaying = false;
        _emitPlayingState();
        _isHandlingCompletion = false;
        return;
      }

      try {
        final nextSurah = quranService.getSurah(nextSurahNumber);

        // Update current surah and reset to first verse
        _currentSurah = nextSurah;
        _currentVerseId = 1;
        _surahCompleted = false; // Reset completion flag for new surah

        logger.d('Successfully switched to next surah: ${nextSurah.name}, verse 1');
        _emitCurrentVerse();

        // Start playing the first verse of the next surah
        if (!_isDisposed && _currentContext == 'quran') {
          try {
            _loadAndPlayAudio(_currentSurah!, _currentVerseId, _playbackSpeed);
          } catch (e) {
            logger.e('Error playing first verse of next surah: $e');
            _isPlaying = false;
            _emitPlayingState();
            _isHandlingCompletion = false;
          }
        } else {
          _isHandlingCompletion = false;
        }
      } catch (e) {
        logger.e('Error getting next surah $nextSurahNumber: $e');
        _isPlaying = false;
        _emitPlayingState();
        _isHandlingCompletion = false;
      }
    } else {
      // We've reached the end of the Quran (Surah 114 - An-Nas)
      logger.d('Reached end of Quran, stopping playback');
      _isPlaying = false;
      _emitPlayingState();
      _isHandlingCompletion = false;
    }
  }

  /// Schedule auto-advance to next verse - optimized for background execution
  void _scheduleAutoAdvance() {
    // Immediate execution for better background performance on iOS
    Future.delayed(const Duration(milliseconds: 10), () {
      if (!_isDisposed && _currentSurah != null && _currentContext == 'quran') {
        final oldVerse = _currentVerseId;

        // Increment verse number
        _currentVerseId++;

        // Check if we've reached the end of the surah
        if (_currentVerseId > _currentSurah!.ayahs.length) {
          logger.d('Reached end of surah, stopping playback');
          _currentVerseId =
              _currentSurah!.ayahs.length; // Keep it at last verse
          _surahCompleted = true;
          _isPlaying = false;
          _emitPlayingState();
          _isHandlingCompletion = false;
          return;
        }

        logger.d('Auto-advancing from verse $oldVerse to $_currentVerseId');
        _emitCurrentVerse();

        // Start playing the next verse immediately - no additional delay
        if (!_isDisposed &&
            _currentSurah != null &&
            _currentContext == 'quran') {
          try {
            _loadAndPlayAudio(
                _currentSurah!, _currentVerseId, _playbackSpeed);
          } catch (e) {
            logger.e('Error playing next verse after auto-advance: $e');
            _isPlaying = false;
            _emitPlayingState();
            _isHandlingCompletion = false;
          }
        } else {
          _isHandlingCompletion = false;
        }
      } else {
        logger.w(
            'Cannot auto-advance: disposed=$_isDisposed, surah=${_currentSurah != null}, context=$_currentContext');
        _isHandlingCompletion = false;
      }
    });
  }

  /// Handle stream errors by reinitializing if needed
  void _handleStreamError() {
    if (_isDisposed) return;

    logger.w('Stream error detected, attempting recovery...');
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!_isDisposed && !isInitialized) {
        initialize().catchError((e) {
          logger.e('Failed to recover from stream error: $e');
        });
      }
    });
  }

  /// Emit initial state to streams
  void _emitInitialState() {
    _emitPlayingState();
    _emitLoadingState();
    _emitCurrentVerse();
    _emitHighlightedWord();
  }

  /// Emit playing state
  void _emitPlayingState() {
    if (!_isDisposed &&
        _playingStateController != null &&
        !_playingStateController!.isClosed) {
      _playingStateController!.add(_isPlaying);
    }
  }

  /// Emit loading state
  void _emitLoadingState() {
    if (!_isDisposed &&
        _loadingStateController != null &&
        !_loadingStateController!.isClosed) {
      _loadingStateController!.add(_isLoading);
    }
  }

  /// Emit current verse
  void _emitCurrentVerse() {
    if (!_isDisposed &&
        _currentVerseController != null &&
        !_currentVerseController!.isClosed) {
      _currentVerseController!.add(_currentVerseId);
    }
  }

  /// Emit highlighted word
  void _emitHighlightedWord() {
    if (!_isDisposed &&
        _highlightedWordController != null &&
        !_highlightedWordController!.isClosed) {
      _highlightedWordController!.add(_currentHighlightedWordIndex);
    }
  }

  /// Play Quran verse
  Future<void> playQuranVerse({
    required Surah surah,
    required int verseId,
    double playbackSpeed = 1.0,
    bool forceRestart = false,
  }) async {
    if (_isDisposed) {
      throw Exception('SharedAudioService is disposed');
    }

    // Ensure service is initialized
    if (!isInitialized) {
      await initialize();
    }

    // Check if surah is completed and user wants to restart
    if (_surahCompleted &&
        _currentSurah?.number == surah.number &&
        _currentVerseId >= (_currentSurah?.ayahs.length ?? 0)) {
      logger.d('Surah completed, restarting from verse 1');
      verseId = 1;
      _surahCompleted = false;
      forceRestart = true;
    }

    logger.d(
        'Playing Quran verse: ${surah.name} - $verseId (restart: $forceRestart)');

    try {
      _currentContext = 'quran';

      // Reset completion handling flag
      _isHandlingCompletion = false;

      // Check if this is a new verse (different from current)
      final isDifferentVerse =
          _currentSurah?.number != surah.number || _currentVerseId != verseId;

      // Update current verse info - only reset repeat counter for new verses
      if (isDifferentVerse || forceRestart) {
        _currentRepeat = 0;
        _surahCompleted =
            false; // Reset completion flag when starting new verse
      }

      _currentSurah = surah;
      _currentVerseId = verseId;
      _currentHighlightedWordIndex = -1;
      _emitCurrentVerse();
      _emitHighlightedWord();

      // Check if we can resume same verse from same context
      final isSameVerse =
          _lastPlayedSurahId == surah.number && _lastPlayedVerseId == verseId;
      final hasAudioSource = _audioPlayer?.audioSource != null;
      final canResume =
          isSameVerse && !forceRestart && hasAudioSource && !_surahCompleted;

      if (canResume) {
        logger.d('Resuming same verse from pause position');
        await _audioPlayer!.setSpeed(playbackSpeed);
        await _audioPlayer!.play();
        return;
      }

      // Stop current playback if playing different verse or force restart
      if (_audioPlayer?.playing == true || forceRestart) {
        await _stopPlayback();
      }

      // Load and play audio
      await _loadAndPlayAudio(surah, verseId, playbackSpeed);
    } catch (e) {
      logger.e('Error playing Quran verse: $e');
      _isLoading = false;
      _isPlaying = false;
      _emitLoadingState();
      _emitPlayingState();
      rethrow;
    }
  }

  /// Preload audio for a verse to improve subsequent playback speed
  Future<void> preloadVerseAudio({
    required Surah surah,
    required int verseId,
  }) async {
    if (_isDisposed || !isInitialized) return;

    try {
      final ayah = surah.ayahs.firstWhere(
        (a) => a.numberInSurah == verseId,
        orElse: () => surah.ayahs.first,
      );

      // Get the first valid audio URL
      final audioUrls = <String>[];
      if (ayah.audio.isNotEmpty) audioUrls.add(ayah.audio);
      if (ayah.audioSecondary.isNotEmpty) audioUrls.addAll(ayah.audioSecondary);

      final validUrls = audioUrls
          .where((url) => url.isNotEmpty && Uri.tryParse(url) != null)
          .toList();

      if (validUrls.isNotEmpty) {
        final audioSource = AudioSource.uri(Uri.parse(validUrls.first));

        // Preload without playing (faster than setAudioSource)
        await _audioPlayer?.setAudioSource(audioSource, preload: false).timeout(
              const Duration(seconds: 2),
            );

        logger.d('Preloaded audio for verse ${surah.name}:$verseId');
      }
    } catch (e) {
      logger.w('Failed to preload audio for verse ${surah.name}:$verseId: $e');
      // Don't rethrow - preloading is optional
    }
  }

  /// Stop current playback
  Future<void> _stopPlayback() async {
    if (_audioPlayer == null) return;

    try {
      // Reset word highlighting first
      _currentHighlightedWordIndex = -1;
      _emitHighlightedWord();

      await _audioPlayer!.stop();
      _isPlaying = false;
      _isLoading = false;
      _emitPlayingState();
      _emitLoadingState();
    } catch (e) {
      logger.w('Error stopping playback: $e');
    }
  }

  /// Load and play audio for verse with optimizations
  Future<void> _loadAndPlayAudio(
      Surah surah, int verseId, double playbackSpeed) async {
    // Ensure audio session is active for iOS background playback
    await _ensureAudioSessionActive();

    // Get the ayah using find instead of firstWhere to avoid exceptions
    final ayah = surah.ayahs.firstWhere(
      (a) => a.numberInSurah == verseId,
      orElse: () => surah.ayahs.first,
    );

    _isLoading = true;
    _emitLoadingState();

    // Reset completion handling flag since we're starting new playback
    _isHandlingCompletion = false;

    // Reset word highlighting for new verse
    _currentHighlightedWordIndex = -1;
    _emitHighlightedWord();

    // Get audio URLs with smart prioritization
    final audioUrls = <String>[];
    if (ayah.audioSecondary.isNotEmpty) audioUrls.addAll(ayah.audioSecondary);
    if (ayah.audio.isNotEmpty) audioUrls.add(ayah.audio);

    if (audioUrls.isEmpty) {
      _isLoading = false;
      _emitLoadingState();
      throw Exception('No audio URLs available for verse $verseId');
    }

    // Filter out invalid URLs early for faster processing
    final validUrls = audioUrls
        .where((url) => url.isNotEmpty && Uri.tryParse(url) != null)
        .toList();

    if (validUrls.isEmpty) {
      _isLoading = false;
      _emitLoadingState();
      throw Exception('No valid audio URLs found for verse $verseId');
    }

    // Try loading audio from URLs with optimized timeout and early success detection
    bool loaded = false;
    Exception? lastError;

    for (final url in validUrls) {
      try {
        final audioSource = AudioSource.uri(Uri.parse(url));

        // Optimized timeout for faster loading with parallel setup
        await Future.wait([
          _audioPlayer!.setAudioSource(audioSource),
        ]).timeout(
          const Duration(seconds: 15),
        );

        loaded = true;
        logger.d(
            'Audio loaded successfully from: ${url.substring(0, url.length > 50 ? 50 : url.length)}...');
        break;
      } catch (e) {
        lastError = Exception('Failed to load $url: $e');
        logger.w(
            'Audio load failed, trying next URL: ${e.toString().substring(0, 100)}...');
        continue;
      }
    }

    if (!loaded) {
      _isLoading = false;
      _emitLoadingState();
      throw lastError ?? Exception('Failed to load audio from all sources');
    }

    // Update tracking
    _lastPlayedSurahId = surah.number;
    _lastPlayedVerseId = verseId;

    // Set speed and play with optimized configuration
    _playbackSpeed = playbackSpeed;
    await _audioPlayer!.setSpeed(_playbackSpeed);
    await _audioPlayer!.play();

    _isLoading = false;
    _emitLoadingState();
  }

  /// Play prayer guide audio
  Future<void> playPrayerAudio(String audioKey, {String? screen}) async {
    if (_isDisposed) {
      throw Exception('SharedAudioService is disposed');
    }

    if (!isInitialized) {
      await initialize();
    }

    final audioPath = _prayerAudioFiles[audioKey];
    if (audioPath == null) {
      throw Exception('Audio file not found: $audioKey');
    }

    logger.d('Playing prayer audio: $audioKey');

    try {
      _currentContext = 'prayer_guide';
      if (screen != null) _originatingScreen = screen;

      // Reset completion handling flag
      _isHandlingCompletion = false;

      await _stopPlayback();

      _isLoading = true;
      _emitLoadingState();

      final audioSource = AudioSource.asset(audioPath);
      await _audioPlayer!.setAudioSource(audioSource);
      await _audioPlayer!.play();

      _isLoading = false;
      _emitLoadingState();
    } catch (e) {
      logger.e('Error playing prayer audio: $e');
      _isLoading = false;
      _emitLoadingState();
      rethrow;
    }
  }

  /// Toggle play/pause
  Future<void> playPause() async {
    if (_isDisposed) return;

    if (!isInitialized) {
      await initialize();
    }

    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Pause playback
  Future<void> pause() async {
    if (_audioPlayer != null && _isPlaying) {
      // Reset word highlighting when pausing
      _currentHighlightedWordIndex = -1;
      _emitHighlightedWord();

      await _audioPlayer!.pause();
    }
  }

  /// Resume playback
  Future<void> resume() async {
    if (_audioPlayer?.audioSource != null) {
      await _audioPlayer!.play();
    } else if (_currentContext == 'quran' && _currentSurah != null) {
      await playQuranVerse(surah: _currentSurah!, verseId: _currentVerseId);
    }
  }

  /// Stop playback
  Future<void> stop() async {
    // Reset completion handling flag
    _isHandlingCompletion = false;
    await _stopPlayback();
  }

  /// Set Quran context
  void setSurahAndVerse(Surah surah, int verseId, {String? screen}) {
    if (_isDisposed) return;

    logger.d('Setting context: ${surah.name} - $verseId (screen: $screen)');

    // Check if switching verses while playing
    final isDifferentVerse =
        _currentSurah?.number != surah.number || _currentVerseId != verseId;
    
    // Check if switching screens while playing
    final isDifferentScreen = screen != null && _originatingScreen != screen;

    // Stop audio if playing and switching verses or screens
    if (_isPlaying && (isDifferentVerse || isDifferentScreen)) {
      logger.d('Stopping audio due to context switch - verse: $isDifferentVerse, screen: $isDifferentScreen');
      stop();
    }

    // Update the context
    _currentSurah = surah;
    _currentVerseId = verseId;
    _currentContext = 'quran';

    // Always reset word highlighting when setting new verse context
    _currentHighlightedWordIndex = -1;

    // Reset repeat counter and completion flag if switching verses or screens
    if (isDifferentVerse || isDifferentScreen) {
      _currentRepeat = 0;
      _surahCompleted = false; // Reset completion flag when switching context
      // Don't modify _repeatCount here as it should be set by the calling screen
    }

    if (screen != null) {
      _originatingScreen = screen;
    }

    // Always emit the verse change to ensure UI is updated
    _emitCurrentVerse();
    _emitHighlightedWord();
  }

  /// Play current verse
  Future<void> playCurrentVerse() async {
    if (_currentSurah == null) {
      throw Exception('No surah set');
    }

    // Check if surah is completed and restart from verse 1
    int targetVerseId = _currentVerseId;
    bool shouldForceRestart = true;

    if (_surahCompleted && _currentVerseId >= _currentSurah!.ayahs.length) {
      logger.d('Surah completed, restarting from verse 1');
      targetVerseId = 1;
      _surahCompleted = false;
    }

    await playQuranVerse(
      surah: _currentSurah!,
      verseId: targetVerseId,
      playbackSpeed: _playbackSpeed,
      forceRestart: shouldForceRestart,
    );
  }

  /// Move to next verse
  void nextVerse() {
    if (_currentSurah == null) return;

    // Check if current verse is valid
    if (_currentVerseId < _currentSurah!.ayahs.length) {
      // Stop current playback
      if (_isPlaying) {
        stop();
      }

      // Update verse
      _currentVerseId++;
      _currentRepeat = 0;
      _emitCurrentVerse();
      logger.d('Next verse: $_currentVerseId');
    }
  }

  /// Move to previous verse
  void previousVerse() {
    if (_currentSurah == null) return;

    if (_currentVerseId > 1) {
      // Stop current playback
      if (_isPlaying) {
        stop();
      }

      // Update verse
      _currentVerseId--;
      _currentRepeat = 0;
      _emitCurrentVerse();
      logger.d('Previous verse: $_currentVerseId');
    }
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    _playbackSpeed = speed;
    if (_audioPlayer != null && _isPlaying) {
      await _audioPlayer!.setSpeed(speed);
    }
  }

  /// Set repeat count
  void setRepeatCount(int count) {
    if (count < 1) count = 1; // Ensure minimum value
    _repeatCount = count;
    _currentRepeat = 0;
    logger.d('Repeat count set to $count');
  }

  /// Set auto-advance
  void setAutoAdvance(bool autoAdvance) {
    _autoAdvance = autoAdvance;
    logger.d('Auto-advance set to $autoAdvance');
  }

  /// Get current ayah
  Ayah? _getCurrentAyah() {
    if (_currentSurah == null) return null;

    try {
      return _currentSurah!.ayahs.firstWhere(
        (ayah) => ayah.numberInSurah == _currentVerseId,
        orElse: () => _currentSurah!.ayahs.first,
      );
    } catch (e) {
      logger.e('Error getting current ayah: $e');
      return null;
    }
  }

  /// Dispose audio player
  Future<void> _disposeAudioPlayer() async {
    if (_audioPlayer != null) {
      try {
        await _audioPlayer!.stop();
        await _audioPlayer!.dispose();
      } catch (e) {
        logger.w('Error disposing audio player: $e');
      } finally {
        _audioPlayer = null;
      }
    }
  }

  /// Close stream controllers
  Future<void> _closeStreamControllers() async {
    try {
      await _playingStateController?.close();
      await _loadingStateController?.close();
      await _currentVerseController?.close();
      await _highlightedWordController?.close();
    } catch (e) {
      logger.w('Error closing stream controllers: $e');
    }

    _playingStateController = null;
    _loadingStateController = null;
    _currentVerseController = null;
    _highlightedWordController = null;
  }

  /// Cancel subscriptions
  Future<void> _cancelSubscriptions() async {
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();

    _playerStateSubscription = null;
    _positionSubscription = null;
  }

  /// Cleanup all resources
  Future<void> _cleanup() async {
    await _cancelSubscriptions();
    await _disposeAudioPlayer();
    await _closeStreamControllers();
  }

  /// Dispose the service
  Future<void> dispose() async {
    if (_isDisposed) return;

    logger.i('Disposing SharedAudioService...');
    _isDisposed = true;

    await _cleanup();

    // Reset state
    _isPlaying = false;
    _isLoading = false;
    _currentContext = null;
    _currentSurah = null;
    _currentVerseId = 1;
    _currentHighlightedWordIndex = -1;
    _currentRepeat = 0;
    _isHandlingCompletion = false;
    _originatingScreen = null;
    _lastPlayedSurahId = null;
    _lastPlayedVerseId = null;
    _surahCompleted = false;

    logger.i('SharedAudioService disposed');
  }

  /// Preload audio source in background to reduce first-time delay
  /// This only loads the audio source without playing and handles errors silently
  void preloadAudioSource() {
    // Don't await this - let it run in background
    _performPreload().catchError((error) {
      // Handle errors silently - this is background preloading
      logger.d('Audio preload failed (silent): $error');
    });
  }

  /// Internal method to perform the actual preloading
  Future<void> _performPreload() async {
    try {
      // Check if service is disposed or already initialized with audio
      if (_isDisposed) {
        logger.d('Skipping preload - service disposed');
        return;
      }

      // Initialize service if not already done
      if (!isInitialized) {
        await initialize();
      }

      // Skip if already playing something or if audio player is not available
      if (_isPlaying || _audioPlayer == null) {
        logger.d('Skipping preload - audio already active');
        return;
      }

      // Import QuranService to get first surah data
      final QuranService quranService = QuranService();

      // Check if QuranService is initialized
      if (!quranService.isInitialized) {
        logger.d('Skipping preload - QuranService not initialized');
        return;
      }

      // Get Al-Fatiha (first surah) for preloading
      final Surah firstSurah = quranService.getSurah(1);
      if (firstSurah.ayahs.isEmpty) {
        logger.d('Skipping preload - no ayahs in first surah');
        return;
      }

      final Ayah firstAyah = firstSurah.ayahs.first;

      // Get audio URLs with same logic as actual playback
      final audioUrls = <String>[];
      if (firstAyah.audioSecondary.isNotEmpty) {
        audioUrls.addAll(firstAyah.audioSecondary);
      }
      if (firstAyah.audio.isNotEmpty) audioUrls.add(firstAyah.audio);

      if (audioUrls.isEmpty) {
        logger.d('Skipping preload - no audio URLs available');
        return;
      }

      // Filter valid URLs
      final validUrls = audioUrls
          .where((url) => url.isNotEmpty && Uri.tryParse(url) != null)
          .toList();

      if (validUrls.isEmpty) {
        logger.d('Skipping preload - no valid audio URLs');
        return;
      }

      // Try to preload from first valid URL only (don't try all URLs to keep it fast)
      final url = validUrls.first;
      final audioSource = AudioSource.uri(Uri.parse(url));

      // Set audio source with shorter timeout for preloading
      await _audioPlayer!.setAudioSource(audioSource).timeout(
            const Duration(seconds: 15),
          );

      logger.i('Audio source preloaded successfully');
    } catch (e) {
      // This is expected to fail sometimes - that's okay for background preloading
      logger.d('Audio preload completed with error (this is normal): $e');
    }
  }

  /// Reset the service (for testing or recovery)
  static Future<void> reset() async {
    if (_instance != null) {
      await _instance!.dispose();
      _instance = null;
    }
  }
}
