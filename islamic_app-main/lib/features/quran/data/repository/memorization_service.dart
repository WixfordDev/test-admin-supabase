// lib/services/memorization_service.dart
import 'dart:convert';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/database/app_database.dart';
import 'package:deenhub/features/quran/domain/models/memorization_model.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class MemorizationService {
  static const String _progressKey = 'quran_memorization_progress';
  static const String _lastReadSurahKey = 'last_read_surah';
  static const String _lastReadVerseKey = 'last_read_verse';
  
  late MemorizationProgress _progress;
  MemorizationProgress get progress => _progress;
  
  // Singleton pattern
  static final MemorizationService _instance = MemorizationService._internal();
  factory MemorizationService() => _instance;
  MemorizationService._internal();
  
  // Use the drift database
  final AppDatabase _db = getIt<AppDatabase>();
  
  Future<void> initialize() async {
    // Load progress from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);
    
    if (progressJson != null) {
      _progress = MemorizationProgress.fromJson(json.decode(progressJson));
    } else {
      _progress = MemorizationProgress();
    }
  }
  
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, json.encode(_progress.toJson()));
  }
  
  Future<void> updateVerseStatus(int surahId, int verseId, MemorizationStatus status) async {
    _progress.updateVerseStatus(surahId, verseId, status);
    await saveProgress();
  }
  
  Future<void> recordRecentlyRead(int surahId, int verseId, {String source = 'default'}) async {
    // Use the drift database for recently read entries
    await _db.recentlyReadDao.recordRecentlyRead(surahId, verseId, source: source);
    
    // Also keep the cleanup logic to prevent the table from growing too large
    await _db.recentlyReadDao.cleanupOldEntries(20);
  }
  
  Future<List<RecentlyRead>> getRecentlyRead({String? source}) async {
    // Use the drift database to get recently read entries
    final driftEntries = await _db.recentlyReadDao.getRecentlyRead(source: source, limit: 10);
    
    // Convert the drift entries to our domain model
    return driftEntries.map((entry) => RecentlyRead(
      id: entry.id,
      surahId: entry.surahId,
      verseId: entry.verseId,
      timestamp: entry.timestamp,
      source: entry.source,
    )).toList();
  }
  
  /// Clear all memorization data (for logout)
  Future<void> clearAllData() async {
    // Clear in-memory data
    _progress = MemorizationProgress();
    
    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_lastReadSurahKey);
    await prefs.remove(_lastReadVerseKey);
    
    debugPrint('MemorizationService: All memorization data cleared');
  }
  
  /// Reset service to initial state (useful for user switching)
  Future<void> resetToInitialState() async {
    await clearAllData();
    // Reinitialize with empty progress
    await initialize();
    debugPrint('MemorizationService: Reset to initial state completed');
  }
  
  Future<Map<String, int>> getLastReadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final surahId = prefs.getInt(_lastReadSurahKey) ?? 1;
    final verseId = prefs.getInt(_lastReadVerseKey) ?? 1;
    
    return {
      'surahId': surahId,
      'verseId': verseId,
    };
  }
  
  List<Map<String, dynamic>> getRecentlyReadSurahs() {
    // Group by surah and get most recent timestamp for each surah
    final Map<int, DateTime> surahToTimestamp = {};
    
    for (var item in _progress.recentlyRead) {
      final existing = surahToTimestamp[item.surahId];
      if (existing == null || item.timestamp.isAfter(existing)) {
        surahToTimestamp[item.surahId] = item.timestamp;
      }
    }
    
    // Convert to list and sort by timestamp
    final result = surahToTimestamp.entries.map((entry) {
      return {
        'surahId': entry.key,
        'timestamp': entry.value,
      };
    }).toList();
    
    result.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
    return result.take(4).toList(); // Return only top 4
  }
  
  List<Map<String, dynamic>> getMemorizationBySurah() {
    final List<Map<String, dynamic>> result = [];
    final QuranService quranService = QuranService();
    final allSurahs = quranService.getAllSurahs();
    
    // Create a map of surahId to actual verse count
    final Map<int, int> surahVerseCount = {};
    for (var surah in allSurahs) {
      surahVerseCount[surah.number] = surah.ayahs.length;
    }
    
    // For each surah with progress
    for (var surahEntry in _progress.surahProgress.entries) {
      final surahId = surahEntry.key;
      final versesMap = surahEntry.value;
      
      // Count different statuses
      int memorizedCount = 0;
      // Get actual verse count for this surah (default to 0 if not found)
      int totalVerses = surahVerseCount[surahId] ?? 0;
      
      versesMap.forEach((verseId, status) {
        if (status == MemorizationStatus.memorized) {
          memorizedCount++;
        }
      });
      
      result.add({
        'surahId': surahId,
        'memorizedCount': memorizedCount,
        'totalVerses': totalVerses,
        'progress': totalVerses > 0 ? memorizedCount / totalVerses : 0.0,
      });
    }
    
    // Sort by surah number
    result.sort((a, b) => (a['surahId'] as int).compareTo(b['surahId'] as int));
    
    return result;
  }
  
  List<Map<String, dynamic>> getVersesByStatus(String status) {
    final List<Map<String, dynamic>> result = [];
    final QuranService quranService = QuranService();
    
    // Process status parameter - convert to lowercase for case-insensitive comparison
    final String statusLower = status.toLowerCase();
    
    // For each surah with progress
    for (var surahEntry in _progress.surahProgress.entries) {
      final surahId = surahEntry.key;
      final versesMap = surahEntry.value;
      
      // Get surah details
      final surah = quranService.getSurah(surahId);
      if (surah == null) continue;
      
      // For each verse with progress
      versesMap.forEach((verseId, verseStatus) {
        bool shouldInclude = false;
        
        // Check which verses to include based on status parameter
        switch (statusLower) {
          case 'memorized':
            shouldInclude = verseStatus == MemorizationStatus.memorized;
            break;
          case 'reviewing':
            shouldInclude = verseStatus == MemorizationStatus.reviewing;
            break;
          case 'learning':
            shouldInclude = verseStatus == MemorizationStatus.learning;
            break;
          case 'total':
            // Include all verses with any status
            shouldInclude = true;
            break;
          default:
            // Unknown status, don't include anything
            shouldInclude = false;
        }
        
        if (shouldInclude) {
          // Get verse details
          if (verseId >= 1 && verseId <= surah.ayahs.length) {
            final verse = surah.ayahs[verseId - 1];
            result.add({
              'surahId': surahId,
              'surahName': surah.englishName,
              'verseId': verseId,
              'verseText': verse.text,
              'status': verseStatus.toString().split('.').last,
            });
          }
        }
      });
    }
    
    // Sort by surah and verse number
    result.sort((a, b) {
      final surahComparison = (a['surahId'] as int).compareTo(b['surahId'] as int);
      if (surahComparison != 0) return surahComparison;
      return (a['verseId'] as int).compareTo(b['verseId'] as int);
    });
    
    return result;
  }
}