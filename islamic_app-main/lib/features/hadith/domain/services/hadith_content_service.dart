import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:deenhub/features/hadith/domain/models/hadith.dart';
import 'package:deenhub/main.dart';

/// Service responsible for loading and managing hadith content data
class HadithContentService {
  // Singleton instance
  static final HadithContentService _instance = HadithContentService._internal();
  static HadithContentService get instance => _instance;
  factory HadithContentService() => _instance;
  HadithContentService._internal();

  // Cache for loaded hadiths by chapter
  final Map<String, List<Hadith>> _hadithsByChapterCache = {};

  // Map book IDs to their folder names in assets
  final Map<int, String> _bookFolders = {
    1: 'bukhari',
    2: 'muslim',
    3: 'abudawud',
    4: 'tirmidhi',
    5: 'nasai',
    6: 'ibnmajah',
    7: 'malik',
    8: 'darimi',
    9: 'ahmed',
    10: 'riyad_assalihin',
    11: 'bulugh_almaram',
    12: 'aladab_almufrad',
    13: 'mishkat_almasabih',
    14: 'shamail_muhammadiyah',
    15: 'nawawi40',
    16: 'qudsi40',
    17: 'shahwaliullah40',
  };
  
  // Map of book IDs to their display names
  final Map<int, String> _bookDisplayNames = {
    1: 'Bukhari',
    2: 'Muslim',
    3: 'Abu Dawood',
    4: 'Tirmidhi',
    5: 'Nasai',
    6: 'Ibn Majah',
    7: 'Malik',
    8: 'Ahmad',
    9: 'Darimi',
    10: 'Riyad as-Salihin',
    11: 'Bulugh al-Maram',
    12: "Al-Adab Al-Mufrad",
    13: "Mishkat al-Masabih",
    14: "Shamail Muhammadiyah",
    15: "40 Hadith Nawawi",
    16: "40 Hadith Qudsi",
    17: "40 Hadith Shah Waliullah",
  };

  // Books that use all.json format (forties collection)
  final Set<int> _allJsonFormatBooks = {15, 16, 17};

  /// Get book display name from ID
  String getBookName(int bookId) {
    return _bookDisplayNames[bookId] ?? 'Unknown';
  }
  
  /// Get book ID from display name (case insensitive)
  int? getBookIdFromName(String bookName) {
    final normName = bookName.toLowerCase();
    
    // First try exact match with display names
    for (final entry in _bookDisplayNames.entries) {
      if (entry.value.toLowerCase() == normName) {
        return entry.key;
      }
    }
    
    // Then try pattern matching for common variations
    if (normName.contains('bukhari')) return 1;
    if (normName.contains('muslim')) return 2;
    if ((normName.contains('abu') && (normName.contains('dawud') || normName.contains('dawood')))) return 3;
    if (normName.contains('tirmidhi')) return 4;
    if (normName.contains('nasai')) return 5;
    if ((normName.contains('ibn') && normName.contains('majah'))) return 6;
    if (normName.contains('malik')) return 7;
    if (normName.contains('ahmad')) return 8;
    if (normName.contains('darimi')) return 9;
    if ((normName.contains('riyad') && normName.contains('salihin'))) return 10;
    if ((normName.contains('bulugh') && normName.contains('maram'))) return 11;
    if ((normName.contains('adab') && normName.contains('mufrad'))) return 12;
    if ((normName.contains('mishkat') && normName.contains('masabih'))) return 13;
    if ((normName.contains('shamail'))) return 14;
    if ((normName.contains('nawawi') && normName.contains('40'))) return 15;
    if ((normName.contains('qudsi') && normName.contains('40'))) return 16;
    if ((normName.contains('waliullah') && normName.contains('40'))) return 17;
    
    // Default to Bukhari if no match
    return 1;
  }
  
  /// Get regex pattern for matching hadith book names
  static String getHadithBookNamePattern() {
    return '(Bukhari|Muslim|Abu Dawood|Tirmidhi|Nasai|Ibn Majah|Malik|Ahmad|Darimi|Riyad as-Salihin|Bulugh al-Maram|Al-Adab Al-Mufrad|Mishkat al-Masabih|Shamail Muhammadiyah|40 Hadith Nawawi|40 Hadith Qudsi|40 Hadith Shah Waliullah)';
  }

  /// Get asset path for hadith chapter
  String getAssetPath(int bookId, int chapterId) {
    final String collection = _getCollectionPath(bookId);
    final String bookFolder = _bookFolders[bookId] ?? 'bukhari';

    // For forties collection, use all.json regardless of chapter ID
    if (_allJsonFormatBooks.contains(bookId)) {
      return '$collection/$bookFolder/all.json';
    }

    return '$collection/$bookFolder/$chapterId.json';
  }

  /// Get the collection path based on book ID
  String _getCollectionPath(int bookId) {
    if (bookId >= 1 && bookId <= 9) {
      return 'assets/data/the_9_books';
    } else if (bookId >= 10 && bookId <= 14) {
      return 'assets/data/other_books';
    } else {
      return 'assets/data/forties';
    }
  }

  /// Check if a book has chapters or uses direct hadith list
  bool hasChapters(int bookId) {
    return !_allJsonFormatBooks.contains(bookId);
  }

  /// Get all hadiths for a specific chapter
  Future<List<Hadith>> getHadithsForChapter(int bookId, int chapterId) async {
    final cacheKey = '${bookId}_$chapterId';

    // Return from cache if available
    if (_hadithsByChapterCache.containsKey(cacheKey)) {
      return _hadithsByChapterCache[cacheKey]!;
    }

    try {
      // Load the JSON file from assets
      final assetPath = getAssetPath(bookId, chapterId);
      final jsonData = await rootBundle.loadString(assetPath);
      final data = json.decode(jsonData);

      // Parse hadiths from the JSON
      final List<Hadith> hadiths = [];

      // Handle updated JSON schema that includes chapter metadata
      if (data.containsKey('hadiths')) {
        final hadithsList = data['hadiths'] as List;

        hadiths.addAll(hadithsList.map((item) {
          return Hadith(
            id: item['id'],
            idInBook: item['idInBook'] ?? item['id'],
            chapterId: chapterId,
            bookId: bookId,
            arabic: item['arabic'] ?? '',
            english: {
              'text': item['english']?['text'] ?? '',
              'narrator': item['english']?['narrator'] ?? '',
              'grade': item['english']?['grade'] ?? '',
            },
          );
        }));
      }

      // Cache the results
      _hadithsByChapterCache[cacheKey] = hadiths;

      return hadiths;
    } catch (e) {
      logger.e('Error loading hadiths from chapter $chapterId of book $bookId: $e');
      return [];
    }
  }

  /// Get a specific hadith by its ID
  Future<Hadith?> getHadith(int bookId, int chapterId, int hadithId) async {
    // Load all hadiths for the chapter
    final hadiths = await getHadithsForChapter(bookId, chapterId);

    // Find the hadith with the given ID
    try {
      return hadiths.firstWhere(
        (hadith) => hadith.idInBook == hadithId,
      );
    } catch (e) {
      logger.e('Hadith with ID $hadithId not found in chapter $chapterId of book $bookId');
      return null;
    }
  }
  
  /// Clear the hadith cache for testing or memory management
  void clearCache() {
    _hadithsByChapterCache.clear();
  }
}
