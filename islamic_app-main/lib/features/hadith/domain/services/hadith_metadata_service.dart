import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_book.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_chapter.dart';
import 'package:deenhub/main.dart';

/// Service responsible for loading and managing hadith metadata
class HadithMetadataService {
  // Singleton instance
  static final HadithMetadataService _instance = HadithMetadataService._internal();
  static HadithMetadataService get instance => _instance;
  factory HadithMetadataService() => _instance;
  HadithMetadataService._internal();

  // Private cache
  final Map<int, HadithBook> _booksCache = {};
  final Map<int, List<HadithChapter>> _chaptersCache = {};
  List<HadithBook>? _allBooksCache;

  // Book collection paths
  static const String _the9BooksPath = 'assets/data/metadata/the_9_books/';
  static const String _otherBooksPath = 'assets/data/metadata/other_books/';
  static const String _fortiesPath = 'assets/data/metadata/forties/';

  // Map of bookId to metadata file path
  final Map<int, String> _bookMetadataPaths = {
    1: '${_the9BooksPath}bukhari_metadata.json',
    2: '${_the9BooksPath}muslim_metadata.json',
    3: '${_the9BooksPath}abudawud_metadata.json',
    4: '${_the9BooksPath}tirmidhi_metadata.json',
    5: '${_the9BooksPath}nasai_metadata.json',
    6: '${_the9BooksPath}ibnmajah_metadata.json',
    7: '${_the9BooksPath}malik_metadata.json',
    8: '${_the9BooksPath}darimi_metadata.json',
    9: '${_the9BooksPath}ahmed_metadata.json',
    10: '${_otherBooksPath}riyad_assalihin_metadata.json',
    11: '${_otherBooksPath}bulugh_almaram_metadata.json',
    12: '${_otherBooksPath}aladab_almufrad_metadata.json',
    13: '${_otherBooksPath}mishkat_almasabih_metadata.json',
    14: '${_otherBooksPath}shamail_muhammadiyah_metadata.json',
    15: '${_fortiesPath}nawawi40_metadata.json',
    16: '${_fortiesPath}qudsi40_metadata.json',
    17: '${_fortiesPath}shahwaliullah40_metadata.json',
  };

  /// Get all books (with basic metadata)
  Future<List<HadithBook>> getAllBooks() async {
    if (_allBooksCache != null) {
      return _allBooksCache!;
    }

    final List<HadithBook> books = [];

    try {
      for (final entry in _bookMetadataPaths.entries) {
        final bookId = entry.key;
        final path = entry.value;
        
        try {
          final jsonString = await rootBundle.loadString(path);
          final jsonData = jsonDecode(jsonString);
          
          final metadata = jsonData['metadata'];
          final totalChapters = jsonData['chapters'].length;
          
          // Create a book without loading all chapters
          final book = HadithBook(
            id: bookId,
            metadata: {
              'english': {
                'title': metadata['english']['title'],
                'author': metadata['english']['author'],
                'introduction': metadata['english']['introduction'] ?? '',
              },
              'arabic': {
                'title': metadata['arabic']['title'],
                'author': metadata['arabic']['author'] ?? '',
                'introduction': metadata['arabic']['introduction'] ?? '',
              },
            },
            chapters: [], // Empty chapters list - chapters will be loaded when needed
          );
          
          // Add total chapters and hadiths count
          book.totalChapters = totalChapters;
          book.totalHadiths = metadata['length'] ?? 0;
          
          books.add(book);
        } catch (e) {
          logger.e('Error loading metadata for book $bookId: $e');
        }
      }
      
      // Sort books by ID
      books.sort((a, b) => a.id.compareTo(b.id));
      
      _allBooksCache = books;
      return books;
    } catch (e) {
      logger.e('Error loading books metadata: $e');
      return [];
    }
  }

  /// Get a specific book with all chapters
  Future<HadithBook?> getBook(int bookId) async {
    // Return from cache if available
    if (_booksCache.containsKey(bookId)) {
      return _booksCache[bookId];
    }

    // Check if the book exists in _allBooksCache
    if (_allBooksCache != null) {
      final cachedBook = _allBooksCache!.firstWhere(
        (book) => book.id == bookId, 
        orElse: () => HadithBook(id: -1, metadata: {}, chapters: [])
      );
      
      // If found in _allBooksCache, load just the chapters
      if (cachedBook.id != -1) {
        try {
          // Get the book's metadata path
          final path = _bookMetadataPaths[bookId];
          if (path == null) {
            logger.w('Requested book $bookId does not have metadata path defined');
            return null;
          }
          
          logger.i('Book found in _allBooksCache, loading only chapters for book $bookId');
          
          // Load and parse the JSON file for chapters only
          final jsonString = await rootBundle.loadString(path);
          final jsonData = jsonDecode(jsonString);
          
          // Get the chapters
          final chaptersList = jsonData['chapters'] as List;
          final chapters = chaptersList.map<HadithChapter>((chapterData) {
            return HadithChapter(
              id: chapterData['id'],
              bookId: chapterData['bookId'],
              arabic: chapterData['arabic'],
              english: chapterData['english'],
              hadiths: [], // Hadiths will be loaded on demand in the next screen
              length: chapterData['length'] ?? 0,
              start: chapterData['start'] ?? 0,
              end: chapterData['end'] ?? 0,
            );
          }).toList();
          
          // Create a complete book with metadata from _allBooksCache and chapters from JSON
          final completeBook = HadithBook(
            id: bookId,
            metadata: cachedBook.metadata,
            chapters: chapters,
          );
          
          completeBook.totalChapters = chapters.length;
          completeBook.totalHadiths = cachedBook.totalHadiths;
          
          // Cache the book and chapters
          _booksCache[bookId] = completeBook;
          _chaptersCache[bookId] = chapters;
          
          return completeBook;
        } catch (e) {
          logger.e('Error loading chapters for book $bookId: $e');
          return null;
        }
      }
    }

    try {
      // Get the book's metadata path
      final path = _bookMetadataPaths[bookId];
      if (path == null) {
        logger.w('Requested book $bookId does not have metadata path defined');
        return null;
      }
      
      logger.i('Loading book metadata for book $bookId from $path');

      // Load and parse the JSON file
      final jsonString = await rootBundle.loadString(path);
      final jsonData = jsonDecode(jsonString);
      
      final metadata = jsonData['metadata'];
      
      // Get the chapters
      final chaptersList = jsonData['chapters'] as List;
      final chapters = chaptersList.map<HadithChapter>((chapterData) {
        return HadithChapter(
          id: chapterData['id'],
          bookId: chapterData['bookId'],
          arabic: chapterData['arabic'],
          english: chapterData['english'],
          hadiths: [], // Hadiths will be loaded on demand in the next screen
          length: chapterData['length'] ?? 0,
          start: chapterData['start'] ?? 0,
          end: chapterData['end'] ?? 0,
        );
      }).toList();
      
      // Create the book with chapters
      final book = HadithBook(
        id: bookId,
        metadata: {
          'english': {
            'title': metadata['english']['title'],
            'author': metadata['english']['author'],
            'introduction': metadata['english']['introduction'] ?? '',
          },
          'arabic': {
            'title': metadata['arabic']['title'],
            'author': metadata['arabic']['author'] ?? '',
            'introduction': metadata['arabic']['introduction'] ?? '',
          },
        },
        chapters: chapters,
      );
      
      // Add total chapters and hadiths count
      book.totalChapters = chapters.length;
      book.totalHadiths = metadata['length'] ?? 0;
      
      // Cache the book and chapters
      _booksCache[bookId] = book;
      _chaptersCache[bookId] = chapters;
      
      return book;
    } catch (e) {
      logger.e('Error loading book $bookId: $e');
      return null;
    }
  }

  /// Get chapters for a specific book
  Future<List<HadithChapter>> getChapters(int bookId) async {
    // Return from cache if available
    if (_chaptersCache.containsKey(bookId)) {
      return _chaptersCache[bookId]!;
    }

    try {
      // Get the book with chapters
      final book = await getBook(bookId);
      if (book == null) {
        return [];
      }
      
      // Return the chapters
      return book.chapters;
    } catch (e) {
      logger.e('Error loading chapters for book $bookId: $e');
      return [];
    }
  }

  /// Get a specific chapter
  Future<HadithChapter?> getChapter(int bookId, int chapterId) async {
    // Get all chapters for the book
    final chapters = await getChapters(bookId);
    
    // Find the chapter with the given ID
    try {
      return chapters.firstWhere(
        (chapter) => chapter.id == chapterId,
      );
    } catch (e) {
      logger.w('Chapter $chapterId not found in book $bookId');
      return null;
    }
  }
  
  /// Clear all caches - useful for testing or memory management
  void clearCache() {
    _booksCache.clear();
    _chaptersCache.clear();
    _allBooksCache = null;
    logger.i('Hadith metadata cache cleared');
  }
} 