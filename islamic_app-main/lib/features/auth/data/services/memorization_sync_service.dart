import 'dart:async';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/features/auth/data/services/supabase_memorization_service.dart';
import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
import 'package:deenhub/features/quran/domain/models/memorization_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemorizationSyncService {
  final SupabaseProvider _supabaseProvider;
  final MemorizationService _memorizationService;
  late final SupabaseMemorizationService _supabaseMemorizationService;
  
  // Stream controller to notify UI about data changes
  final _dataChangeController = StreamController<bool>.broadcast();
  Stream<bool> get dataChangeStream => _dataChangeController.stream;
  bool _lastChangeValue = false;
  
  // Retry configuration - reduced for faster auth
  static const int _maxRetries = 2; // Reduced from 3 to 2
  static const Duration _retryDelay = Duration(milliseconds: 500); // Reduced from 2 seconds to 500ms
  
  // Auto-sync settings
  static const Duration _autoSyncInterval = Duration(minutes: 5);
  Timer? _autoSyncTimer;
  final List<RealtimeChannel> _channels = [];
  String? _currentUserId;
  bool _isInitialized = false;
  
  MemorizationSyncService(this._supabaseProvider, this._memorizationService) {
    _supabaseMemorizationService = SupabaseMemorizationService(
      _supabaseProvider, 
      _memorizationService
    );
  }
  
  /// Initialize real-time sync for a user
  Future<void> initializeForUser(String userId) async {
    try {
      if (_currentUserId == userId && _isInitialized) {
        debugPrint('MemorizationSyncService: Already initialized for user $userId');
        return;
      }
      
      _currentUserId = userId;
      
      // Clean up previous subscriptions if any
      _cancelSubscriptions();
      
      debugPrint('MemorizationSyncService: Initializing for user: $userId');
      
      // Perform initial sync in background to not block auth
      // Use shorter timeout to prevent hanging during auth
      _performInitialSync(userId);
      
      // Subscribe to real-time changes
      _subscribeToRealtimeChanges(userId);
      
      // Start auto-sync timer
      _startAutoSync(userId);
      
      _isInitialized = true;
      debugPrint('MemorizationSyncService: Successfully initialized for user: $userId');
    } catch (e) {
      debugPrint('MemorizationSyncService: Failed to initialize for user $userId: $e');
      // Don't rethrow - initialization failure should not block auth
    }
  }
  
  /// Perform initial sync in background without blocking auth
  void _performInitialSync(String userId) async {
    try {
      await downloadMemorizationData(userId).timeout(
        const Duration(seconds: 10), // Reduced from 30 to 10 seconds
        onTimeout: () {
          debugPrint('MemorizationSyncService: Initial sync timeout - continuing in background');
          return false;
        },
      );
    } catch (e) {
      debugPrint('MemorizationSyncService: Initial sync failed, will retry later: $e');
      // Don't rethrow - background sync failures should be silent
    }
  }
  
  /// Subscribe to real-time changes from Supabase
  void _subscribeToRealtimeChanges(String userId) {
    try {
      // Cancel existing subscriptions if any
      _cancelSubscriptions();
      
      // Subscribe to verse_progress table changes
      final verseProgressChannel = _supabaseProvider.supabase
          .channel('verse_progress_changes_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'verse_progress',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) => _handleVerseProgressChange(payload, userId),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'verse_progress',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) => _handleVerseProgressChange(payload, userId),
          )
          .subscribe();
      
      // Subscribe to recently_read table changes
      final recentlyReadChannel = _supabaseProvider.supabase
          .channel('recently_read_changes_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'recently_read',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) => _handleRecentlyReadChange(payload, userId),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'recently_read',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) => _handleRecentlyReadChange(payload, userId),
          )
          .subscribe();
      
      // Store channels to remove them later
      _channels.add(verseProgressChannel);
      _channels.add(recentlyReadChannel);
      
      debugPrint('MemorizationSyncService: Subscribed to real-time changes for user: $userId');
    } catch (e) {
      debugPrint('MemorizationSyncService: Failed to subscribe to real-time changes: $e');
      // Continue without real-time sync - don't block the app
    }
  }
  
  /// Handle verse progress changes from Supabase
  void _handleVerseProgressChange(PostgresChangePayload payload, String userId) async {
    try {
      // Access the new record data
      final Map<String, dynamic> data = payload.newRecord;
      final surahId = data['surah_id'] as int;
      final verseId = data['verse_id'] as int;
      final status = MemorizationStatus.values[data['status'] as int];
      
      // Only update if the change is from another device
      // This is to avoid circular updates
      final String deviceId = data['device_id'] ?? '';
      final String currentDeviceId = await _supabaseMemorizationService.getDeviceId();
      
      if (deviceId != currentDeviceId) {
        debugPrint('MemorizationSyncService: Received verse progress update from another device: $surahId:$verseId');
        await _memorizationService.updateVerseStatus(surahId, verseId, status);
        _notifyDataChanged();
      }
    } catch (e) {
      debugPrint('MemorizationSyncService: Error processing verse progress change: $e');
    }
  }
  
  /// Handle recently read changes from Supabase
  void _handleRecentlyReadChange(PostgresChangePayload payload, String userId) async {
    try {
      // Access the new record data
      final Map<String, dynamic> data = payload.newRecord;
      final surahId = data['surah_id'] as int;
      final verseId = data['verse_id'] as int;
      
      // Only update if the change is from another device
      final String deviceId = data['device_id'] ?? '';
      final String currentDeviceId = await _supabaseMemorizationService.getDeviceId();
      
      if (deviceId != currentDeviceId) {
        debugPrint('MemorizationSyncService: Received recently read update from another device: $surahId:$verseId');
        await _memorizationService.recordRecentlyRead(surahId, verseId);
        _notifyDataChanged();
      }
    } catch (e) {
      debugPrint('MemorizationSyncService: Error processing recently read change: $e');
    }
  }
  
  /// Cancel all active subscriptions
  void _cancelSubscriptions() {
    for (var channel in _channels) {
      try {
        _supabaseProvider.supabase.removeChannel(channel);
      } catch (e) {
        debugPrint('MemorizationSyncService: Error removing channel: $e');
      }
    }
    _channels.clear();
  }
  
  /// Start periodic auto-sync timer
  void _startAutoSync(String userId) {
    // Cancel existing timer if any
    _autoSyncTimer?.cancel();
    
    // Create new timer for periodic sync
    _autoSyncTimer = Timer.periodic(_autoSyncInterval, (timer) {
      if (_currentUserId != null && _isInitialized) {
        debugPrint('MemorizationSyncService: Performing auto-sync for user: $_currentUserId');
        // Run async operations without awaiting to prevent timer blocking
        _performBackgroundSync(_currentUserId!);
      }
    });
  }
  
  /// Perform background sync without blocking
  void _performBackgroundSync(String userId) async {
    try {
      await uploadMemorizationData(userId);
      await downloadMemorizationData(userId);
    } catch (e) {
      debugPrint('MemorizationSyncService: Background sync failed: $e');
      // Don't rethrow - background sync failures should be silent
    }
  }
  
  /// Clean up resources when user logs out
  void dispose() {
    _cancelSubscriptions();
    _autoSyncTimer?.cancel();
    _currentUserId = null;
    _isInitialized = false;
    if (!_dataChangeController.isClosed) {
      _dataChangeController.close();
    }
    
    // Clear device-specific data as well
    _supabaseMemorizationService.clearDeviceData();
    
    debugPrint('MemorizationSyncService: Disposed');
  }
  
  /// Handle user logout - clear all data and notify UI
  Future<void> handleUserLogout() async {
    try {
      debugPrint('MemorizationSyncService: Handling user logout');
      
      // Cancel subscriptions and timers first
      _cancelSubscriptions();
      _autoSyncTimer?.cancel();
      
      // Clear memorization data and reinitialize
      await _memorizationService.clearAllData();
      await _memorizationService.initialize(); // Reinitialize with empty state
      
      // Clear sync service state
      _currentUserId = null;
      _isInitialized = false;
      
      // Clear device-specific data
      _supabaseMemorizationService.clearDeviceData();
      
      // Notify UI of data change
      _notifyDataChanged();
      
      debugPrint('MemorizationSyncService: User logout handled successfully');
    } catch (e) {
      debugPrint('MemorizationSyncService: Error during logout: $e');
    }
  }
  
  /// Handle user login - initialize sync and load data
  Future<void> handleUserLogin(String userId) async {
    try {
      debugPrint('MemorizationSyncService: Handling user login for: $userId');
      
      // If same user, just ensure initialization
      if (_currentUserId == userId && _isInitialized) {
        debugPrint('MemorizationSyncService: Same user already initialized');
        // Still notify UI in case of state changes
        _notifyDataChanged();
        return;
      }
      
      // If different user, clear previous data first
      if (_currentUserId != null && _currentUserId != userId) {
        debugPrint('MemorizationSyncService: Different user detected, clearing previous data');
        await _memorizationService.resetToInitialState();
      }
      
      // Initialize for new user
      await initializeForUser(userId);
      
      // Force a data change notification after initialization
      _notifyDataChanged();
      
      debugPrint('MemorizationSyncService: User login handled successfully');
    } catch (e) {
      debugPrint('MemorizationSyncService: Error during login: $e');
      // Still notify UI even if there's an error
      _notifyDataChanged();
      // Don't rethrow to avoid blocking login flow
    }
  }
  
  /// Upload the local memorization progress to Supabase with retry mechanism
  Future<void> uploadMemorizationData(String userId) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        await _supabaseMemorizationService.syncToSupabase(userId);
        debugPrint('MemorizationSyncService: Data uploaded successfully on attempt ${retryCount + 1}');
        return; // Success, exit the function
      } catch (e) {
        retryCount++;
        debugPrint('MemorizationSyncService: Error uploading data (attempt $retryCount): $e');
        
        // Check if it's a constraint violation error - don't retry these
        if (e.toString().contains('duplicate ke y value violates unique constraint') ||
            e.toString().contains('23505')) {
          debugPrint('MemorizationSyncService: Constraint violation detected - data may already exist, continuing...');
          return; // Don't retry constraint violations
        }
        
        if (retryCount < _maxRetries) {
          // Wait before retrying
          await Future.delayed(_retryDelay * retryCount);
          debugPrint('MemorizationSyncService: Retrying upload...');
        } else {
          // Max retries reached
          debugPrint('MemorizationSyncService: Max retries reached. Upload failed.');
          // Don't rethrow - upload failures should not break the app flow
        }
      }
    }
  }
  
  /// Download and merge memorization progress from Supabase with retry mechanism
  Future<bool> downloadMemorizationData(String userId) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        await _supabaseMemorizationService.syncFromSupabase(userId);
        debugPrint('MemorizationSyncService: Data downloaded successfully on attempt ${retryCount + 1}');
        _notifyDataChanged();
        return true;
      } catch (e) {
        retryCount++;
        debugPrint('MemorizationSyncService: Error downloading data (attempt $retryCount): $e');
        if (retryCount < _maxRetries) {
          // Wait before retrying
          await Future.delayed(_retryDelay * retryCount);
          debugPrint('MemorizationSyncService: Retrying download...');
        } else {
          // Max retries reached
          debugPrint('MemorizationSyncService: Max retries reached. Download failed.');
          return false;
        }
      }
    }
    return false;
  }
  
  /// Save a verse progress and sync to Supabase if user is logged in with retry
  Future<void> saveVerseProgress(
      String? userId, int surahId, int verseId, MemorizationStatus status) async {
    try {
      // Update locally first to ensure local state is always updated
      await _memorizationService.updateVerseStatus(surahId, verseId, status);
      
      // Notify UI of data change
      _notifyDataChanged();
      
      // Then sync to Supabase if user is logged in
      if (userId != null && _isInitialized) {
        // Run sync in background without blocking
        _saveVerseProgressToSupabase(userId, surahId, verseId, status);
      }
    } catch (e) {
      debugPrint('MemorizationSyncService: Error in saveVerseProgress: $e');
      // Don't rethrow to avoid breaking the UI flow
    }
  }
  
  /// Save verse progress to Supabase in background
  void _saveVerseProgressToSupabase(String userId, int surahId, int verseId, MemorizationStatus status) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        await _supabaseMemorizationService.saveVerseProgress(
          userId, surahId, verseId, status);
        debugPrint('MemorizationSyncService: Verse progress saved to Supabase successfully');
        break; // Success, exit the loop
      } catch (e) {
        retryCount++;
        debugPrint('MemorizationSyncService: Error saving verse progress (attempt $retryCount): $e');
        if (retryCount < _maxRetries) {
          // Wait before retrying
          await Future.delayed(_retryDelay * retryCount);
        } else {
          // Log failure but don't throw to preserve user experience
          debugPrint('MemorizationSyncService: Failed to sync verse progress after max retries');
        }
      }
    }
  }
  
  /// Get progress status for a specific verse with improved caching
  Future<MemorizationStatus?> getVerseProgress(
      String? userId, int surahId, int verseId) async {
    try {
      // First check if the status exists in local storage
      final surahMap = _memorizationService.progress.surahProgress[surahId];
      if (surahMap != null && surahMap.containsKey(verseId)) {
        return surahMap[verseId];
      }
      
      // If logged in and not found locally, try fetching from Supabase
      if (userId != null && _isInitialized) {
        return await _getVerseProgressFromSupabase(userId, surahId, verseId);
      }
      
      // Default to not started if nothing found
      return MemorizationStatus.notStarted;
    } catch (e) {
      debugPrint('MemorizationSyncService: Error getting verse progress: $e');
      return MemorizationStatus.notStarted; // Return default for better resilience
    }
  }
  
  /// Get verse progress from Supabase with retry logic
  Future<MemorizationStatus?> _getVerseProgressFromSupabase(
      String userId, int surahId, int verseId) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        final response = await _supabaseProvider.supabase
          .from('verse_progress')
          .select()
          .eq('user_id', userId)
          .eq('surah_id', surahId)
          .eq('verse_id', verseId)
          .maybeSingle();
        
        if (response != null) {
          final status = MemorizationStatus.values[response['status']];
          
          // Update local cache
          await _memorizationService.updateVerseStatus(surahId, verseId, status);
          _notifyDataChanged();
          debugPrint('MemorizationSyncService: Retrieved verse progress from Supabase');
          return status;
        }
        break; // Success or not found, exit the loop
      } catch (e) {
        retryCount++;
        debugPrint('MemorizationSyncService: Error fetching verse progress (attempt $retryCount): $e');
        if (retryCount < _maxRetries) {
          // Wait before retrying
          await Future.delayed(_retryDelay * retryCount);
        } else {
          debugPrint('MemorizationSyncService: Failed to fetch verse progress after max retries');
        }
      }
    }
    return null;
  }
  
  /// Record a recently read verse and sync to Supabase if user is logged in
  Future<void> recordRecentlyRead(String? userId, int surahId, int verseId, {String source = 'default'}) async {
    try {
      // Always update local data regardless of login status
      await _memorizationService.recordRecentlyRead(surahId, verseId, source: source);
      
      // Notify UI of data change
      _notifyDataChanged();
      
      // Then sync to Supabase if user is logged in
      if (userId != null && _isInitialized) {
        // Run sync in background without blocking
        _recordRecentlyReadToSupabase(userId, surahId, verseId, source);
      }
    } catch (e) {
      debugPrint('MemorizationSyncService: Error in recordRecentlyRead: $e');
      // Don't rethrow to avoid breaking the user experience
      // Local storage should still work even if there are sync issues
    }
  }
  
  /// Record recently read to Supabase in background
  void _recordRecentlyReadToSupabase(String userId, int surahId, int verseId, String source) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        await _supabaseMemorizationService.recordRecentlyRead(
          userId, surahId, verseId, source);
        debugPrint('MemorizationSyncService: Recently read recorded to Supabase successfully');
        break; // Success, exit the loop
      } catch (e) {
        // Check if it's a duplicate key error - these are expected and shouldn't be retried
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('duplicate key value violates unique constraint') ||
            errorString.contains('23505') ||
            errorString.contains('conflict')) {
          debugPrint('MemorizationSyncService: Recently read already exists, treating as success');
          break; // Don't retry duplicate key errors
        }
        
        retryCount++;
        debugPrint('MemorizationSyncService: Error recording recently read (attempt $retryCount): $e');
        if (retryCount < _maxRetries) {
          // Wait before retrying
          await Future.delayed(_retryDelay * retryCount);
        } else {
          // Log failure but don't throw to preserve user experience
          debugPrint('MemorizationSyncService: Failed to sync recently read after max retries');
        }
      }
    }
  }
  
  /// Trigger data change notification for UI updates
  void _notifyDataChanged() {
    _lastChangeValue = !_lastChangeValue;
    if (!_dataChangeController.isClosed) {
      _dataChangeController.add(_lastChangeValue);
    }
  }
} 