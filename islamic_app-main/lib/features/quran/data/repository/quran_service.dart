import 'dart:convert';
import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/features/quran/data/repository/quran_repository.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';

class QuranService {
  late QuranData _quranData;
  QuranData get quranData => _quranData;
  final QuranRepository _quranRepository = getIt<QuranRepository>();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // Map to store word timing data for quick lookup
  Map<String, AyahWordTiming> _wordTimingMap = {};

  // Singleton pattern
  static final QuranService _instance = QuranService._internal();
  factory QuranService() => _instance;
  QuranService._internal();

  Future<void> initialize() async {
    // if (_isInitialized) return;

    try {
      // First try to get data from the database
      final savedData = await _quranRepository.getQuranData();

      if (savedData != null) {
        _quranData = savedData;
        await _loadWordTimingData(); // Load word timing data
        await _mapWordTimingToAyahs(); // Map word timing to ayahs
        _isInitialized = true;
        return;
      }
      logger.e('savedData*2: $savedData ');

      // If no data in database, load from assets and save to database
      final String jsonString = await rootBundle.loadString(Assets.jsonQuran);
      final jsonData = json.decode(jsonString);
      _quranData = QuranData.fromJson(jsonData['data']);
      logger.e('savedData*3: | $_quranData');

      // Load word timing data
      await _loadWordTimingData();
      
      // Map word timing data to ayahs
      await _mapWordTimingToAyahs();

      // Save to database for future use
      await _quranRepository.saveQuranData(_quranData);
      _isInitialized = true;
    } catch (e) {
      logger.e('savedData*4: | $e');
      // Fallback to direct loading if database operations fail
      final String jsonString = await rootBundle.loadString(Assets.jsonQuran);
      final jsonData = json.decode(jsonString);
      _quranData = QuranData.fromJson(jsonData['data']);
      
      // Try to load word timing data even in fallback mode
      try {
        await _loadWordTimingData();
        await _mapWordTimingToAyahs();
      } catch (e) {
        logger.e('Failed to load word timing data in fallback mode: $e');
      }
      
      _isInitialized = true;
    }
  }

  // Load word timing data from Alafasy_128kbps.json
  Future<void> _loadWordTimingData() async {
    try {
      final String jsonString = await rootBundle.loadString(Assets.jsonAlafasy128kbps);
      final List<dynamic> jsonData = json.decode(jsonString);
      
      // Clear existing map
      _wordTimingMap.clear();
      
      // Populate word timing map for quick lookup
      for (var item in jsonData) {
        final wordTiming = AyahWordTiming.fromJson(item);
        // Use surah:ayah as key for quick lookup
        final key = '${wordTiming.surahNumber}:${wordTiming.ayahNumber}';
        _wordTimingMap[key] = wordTiming;
      }
      
      logger.d('Loaded ${_wordTimingMap.length} word timing entries');
    } catch (e) {
      logger.e('Error loading word timing data: $e');
      throw Exception('Failed to load word timing data: $e');
    }
  }

  // Map word timing data to the corresponding ayahs
  Future<void> _mapWordTimingToAyahs() async {
    try {
      // Create a new list of surahs with updated ayahs
      final List<Surah> updatedSurahs = [];
      
      for (var surah in _quranData.surahs) {
        final List<Ayah> updatedAyahs = [];
        
        for (var ayah in surah.ayahs) {
          final key = '${surah.number}:${ayah.numberInSurah}';
          final wordTiming = _wordTimingMap[key];
          
          if (wordTiming != null) {
            // Create a new ayah with word timing data
            updatedAyahs.add(ayah.copyWithWordTiming(wordTiming));
          } else {
            // Keep the original ayah if no word timing data found
            updatedAyahs.add(ayah);
          }
        }
        
        // Create a new surah with updated ayahs
        final updatedSurah = Surah(
          number: surah.number,
          name: surah.name,
          englishName: surah.englishName,
          englishNameTranslation: surah.englishNameTranslation,
          revelationType: surah.revelationType,
          ayahs: updatedAyahs,
        );
        
        updatedSurahs.add(updatedSurah);
      }
      
      // Create a new QuranData with updated surahs
      _quranData = QuranData(
        surahs: updatedSurahs,
        edition: _quranData.edition,
      );
          } catch (e) {
      throw Exception('Failed to map word timing data to ayahs: $e');
    }
  }

  // Get a specific surah by number
  Surah getSurah(int number) {
    if (!_isInitialized) {
      throw Exception("QuranService not initialized. Call initialize() first.");
    }
    return _quranData.surahs.firstWhere((surah) => surah.number == number);
  }

  // Get all surahs
  List<Surah> getAllSurahs() {
    if (!_isInitialized) {
      throw Exception("QuranService not initialized. Call initialize() first.");
    }
    return _quranData.surahs;
  }

  // Search functionality
  List<Ayah> searchAyahs({String? query, int? juz, int? surahNumber, int? verseNumber}) {
    if (!_isInitialized) {
      throw Exception("QuranService not initialized. Call initialize() first.");
    }

    List<Ayah> results = [];

    // Return empty list if no search criteria provided
    if (query == null && juz == null && surahNumber == null && verseNumber == null) {
      return results;
    }

    // Normalize query for case-insensitive search
    final normalizedQuery = query?.toLowerCase().trim();
    
    for (var surah in _quranData.surahs) {
      // Skip if specific surah is requested and this is not it
      if (surahNumber != null && surah.number != surahNumber) {
        continue;
      }

      for (var ayah in surah.ayahs) {
        // Skip if specific juz is requested and this is not it
        if (juz != null && ayah.juz != juz) {
          continue;
        }

        // Skip if specific verse number is requested and this is not it
        if (verseNumber != null && ayah.numberInSurah != verseNumber) {
          continue;
        }

        // Skip if query is provided and ayah doesn't contain it in:
        // 1. Arabic text
        // 2. English text
        // 3. Transliteration
        if (normalizedQuery != null && 
            !ayah.text.contains(normalizedQuery) && 
            !ayah.textEn.toLowerCase().contains(normalizedQuery) &&
            !ayah.transliteration.toLowerCase().contains(normalizedQuery)) {
          continue;
        }

        results.add(ayah);
      }
    }

    return results;
  }
  
  // Get word timing data for specific ayah
  AyahWordTiming? getWordTimingForAyah(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    return _wordTimingMap[key];
  }
}
