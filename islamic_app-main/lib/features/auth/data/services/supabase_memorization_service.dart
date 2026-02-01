import 'dart:io';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
import 'package:deenhub/features/quran/domain/models/memorization_model.dart';
import 'package:deenhub/features/quran/domain/models/verse_progress_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

/// A service that synchronizes memorization data between local storage and Supabase
class SupabaseMemorizationService {
  final SupabaseProvider _supabaseProvider;
  final MemorizationService _memorizationService;
  String? _deviceId;
  static const String _deviceIdKey = 'deenhub_device_id';
  
  SupabaseMemorizationService(this._supabaseProvider, this._memorizationService);
  
  /// Get a unique device ID for tracking sync across devices
  Future<String> getDeviceId() async {
    // Return cached device ID if already loaded
    if (_deviceId != null) {
      return _deviceId!;
    }
    
    // Try to load from SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    
    // If not found, generate a new one and save it
    if (deviceId == null) {
      deviceId = await _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    
    _deviceId = deviceId;
    return deviceId;
  }
  
  /// Clear device-specific memorization data (for logout)
  Future<void> clearDeviceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      _deviceId = null;
      debugPrint('SupabaseMemorizationService: Device data cleared');
    } catch (e) {
      debugPrint('Error clearing device data: $e');
    }
  }
  
  /// Generate a unique device ID based on device info + random UUID
  Future<String> _generateDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final uuid = const Uuid().v4();
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.model}_${androidInfo.id}_$uuid';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.model}_${iosInfo.identifierForVendor}_$uuid';
      } else {
        return 'unknown_device_$uuid';
      }
    } catch (e) {
      debugPrint('Error generating device ID: $e');
      return 'fallback_device_$uuid';
    }
  }
  
  /// Fetches the overall memorization counts for a user
  Future<Map<String, dynamic>?> fetchMemorizationCounts(String userId) async {
    try {
      final response = await _supabaseProvider.supabase
          .from('user_memorization')
          .select()
          .eq('user_id', userId)
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error fetching memorization counts: $e');
      return null;
    }
  }
  
  /// Updates the overall memorization counts for a user
  Future<void> updateMemorizationCounts(String userId) async {
    try {
      final progress = _memorizationService.progress;
      
      await _supabaseProvider.supabase
          .from('user_memorization')
          .upsert({
            'user_id': userId,
            'memorized_count': progress.memorizedCount,
            'reviewing_count': progress.reviewingCount,
            'learning_count': progress.learningCount,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id');
      
      debugPrint('Memorization counts updated successfully');
    } catch (e) {
      debugPrint('Error updating memorization counts: $e');
      rethrow;
    }
  }
  
  /// Fetch verse progress records for a user
  Future<List<VerseProgressModel>> fetchVerseProgress(String userId) async {
    try {
      final response = await _supabaseProvider.supabase
          .from('verse_progress')
          .select()
          .eq('user_id', userId);
      
      return (response as List)
          .map((json) => VerseProgressModel.fromDbMap(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching verse progress: $e');
      return [];
    }
  }
  
  /// Save or update progress for a single verse
  Future<void> saveVerseProgress(
      String userId, int surahId, int verseId, MemorizationStatus status) async {
    try {
      final progressModel = VerseProgressModel.fromStatus(
        surahId: surahId,
        verseId: verseId,
        status: status,
      );
      
      final deviceId = await getDeviceId();
      
      await _supabaseProvider.supabase
          .from('verse_progress')
          .upsert(
            {
              ...progressModel.toDbMap(userId),
              'device_id': deviceId,
            },
            onConflict: 'user_id,surah_id,verse_id',
          );
      
      debugPrint('Verse progress saved successfully');
    } catch (e) {
      debugPrint('Error saving verse progress: $e');
      // Log but don't rethrow to avoid breaking the UI flow
    }
  }
  
  /// Record a recently read verse
  Future<void> recordRecentlyRead(
      String userId, 
      int surahId, 
      int verseId,
      [String source = 'default']) async {
    try {
      final deviceId = await getDeviceId();
      final timestamp = DateTime.now().toIso8601String();
      
      // Save to recently_read table with proper conflict resolution
      // Use upsert with explicit conflict resolution
      await _supabaseProvider.supabase.from('recently_read').upsert(
        {
          'user_id': userId,
          'surah_id': surahId,
          'verse_id': verseId,
          'timestamp': timestamp,
          'device_id': deviceId,
          'source': source, // Add source field
        },
        onConflict: 'user_id,surah_id,verse_id',
        ignoreDuplicates: false, // This ensures updates happen on conflict
      );
      
      debugPrint('SupabaseMemorizationService: Recently read recorded successfully');
    } catch (e) {
      debugPrint('SupabaseMemorizationService: Error recording recently read: $e');
      rethrow; // Allow caller to handle retry
    }
  }
  
  /// Fetch recently read verses
  Future<List<RecentlyRead>> fetchRecentlyRead(String userId, {int limit = 10}) async {
    try {
      final response = await _supabaseProvider.supabase
          .from('recently_read')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(limit);
      
      return (response as List).map((json) => RecentlyRead(
        surahId: json['surah_id'],
        verseId: json['verse_id'],
        timestamp: DateTime.parse(json['timestamp']),
      )).toList();
    } catch (e) {
      debugPrint('Error fetching recently read verses: $e');
      return [];
    }
  }
  
  /// Synchronize all local memorization data to Supabase
  Future<void> syncToSupabase(String userId) async {
    try {
      // Update memorization counts
      try {
        await updateMemorizationCounts(userId);
      } catch (e) {
        debugPrint('Error updating memorization counts: $e');
        // Check if it's a constraint violation - this means data already exists
        if (e.toString().contains('duplicate key value violates unique constraint') ||
            e.toString().contains('23505')) {
          debugPrint('Memorization counts already exist for user - continuing with sync');
        } else {
          // For other errors, still continue but log the issue
          debugPrint('Failed to update memorization counts, continuing with other sync operations');
        }
      }
      
      // Get all progress from local
      final progress = _memorizationService.progress;
      
      // Sync verse progress
      for (final surahEntry in progress.surahProgress.entries) {
        final surahId = surahEntry.key;
        final versesMap = surahEntry.value;
        
        for (final verseEntry in versesMap.entries) {
          final verseId = verseEntry.key;
          final status = verseEntry.value;
          
          if (status != MemorizationStatus.notStarted) {
            try {
              await saveVerseProgress(userId, surahId, verseId, status);
            } catch (e) {
              // Log the error but continue with the next verse
              debugPrint('Error syncing verse progress for surah $surahId, verse $verseId: $e');
            }
          }
        }
      }
      
      // Sync recently read (just the first 10)
      for (final recent in progress.recentlyRead.take(10)) {
        try {
          await recordRecentlyRead(userId, recent.surahId, recent.verseId);
        } catch (e) {
          // Log the error but continue with the next recently read entry
          debugPrint('Error syncing recently read for surah ${recent.surahId}, verse ${recent.verseId}: $e');
        }
      }
      
      debugPrint('Successfully synced memorization data to Supabase');
    } catch (e) {
      debugPrint('Error syncing to Supabase: $e');
      // Still rethrow this error as it might be a critical one
      rethrow;
    }
  }
  
  /// Synchronize memorization data from Supabase to local storage
  Future<void> syncFromSupabase(String userId) async {
    try {
      // Fetch verse progress
      final verseProgressList = await fetchVerseProgress(userId);
      
      // Update local cache with verse progress
      for (final progress in verseProgressList) {
        await _memorizationService.updateVerseStatus(
          progress.surahId,
          progress.verseId,
          progress.memorizationStatus,
        );
      }
      
      // Fetch recently read
      final recentlyReadList = await fetchRecentlyRead(userId);
      
      // Update local cache with recently read
      for (final recent in recentlyReadList) {
        await _memorizationService.recordRecentlyRead(
          recent.surahId,
          recent.verseId,
        );
      }
      
      debugPrint('Successfully synced memorization data from Supabase');
    } catch (e) {
      debugPrint('Error syncing from Supabase: $e');
    }
  }
} 