import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/embeddings_service.dart';
import 'package:deenhub/features/hadith/data/repositories/hadith_supabase_service.dart';
import 'package:deenhub/features/hadith/domain/models/hadith.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_chapter.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_content_service.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_metadata_service.dart';
import 'package:deenhub/main.dart';

/// Service responsible for searching hadiths using either local data or Supabase
class HadithSearchService {
  final HadithSupabaseService _supabaseService;
  final HadithMetadataService _metadataService;
  final HadithContentService _contentService;
  final EmbeddingsService _embeddingsService;

  // Constants
  static final Set<int> _fortiesBooks = {15, 16, 17};

  // Singleton instance
  static HadithSearchService? _instance;
  static HadithSearchService get instance {
    _instance ??= HadithSearchService._internal();
    return _instance!;
  }

  HadithSearchService._internal()
      : _supabaseService = getIt<HadithSupabaseService>(),
        _metadataService = HadithMetadataService.instance,
        _contentService = HadithContentService.instance,
        _embeddingsService = EmbeddingsService.instance;

  /// Search for hadiths based on given parameters
  ///
  /// Returns a SearchResult containing the search results and metadata
  Future<SearchResult> search({
    String? query,
    int? bookId,
    int? chapterId,
    int? hadithNumber,
    bool? forceSupabaseSearch = false,
    bool isAdvanced = true,
  }) async {
    try {
      if (forceSupabaseSearch == true) {
        return await _performSupabaseSearch(
          query: query,
          bookId: bookId,
          chapterId: chapterId,
          hadithNumber: hadithNumber,
          isAdvanced: isAdvanced,
        );
      }

      // Determine if we should use local search or API search
      final useLocalSearch = _shouldUseLocalSearch(bookId, chapterId, hadithNumber);

      if (useLocalSearch) {
        // Perform local search
        return await _performLocalSearch(
          query: query,
          bookId: bookId,
          chapterId: chapterId,
          hadithNumber: hadithNumber,
        );
      } else {
        // Perform Supabase search
        return await _performSupabaseSearch(
          query: query,
          bookId: bookId,
          chapterId: chapterId,
          hadithNumber: hadithNumber,
          isAdvanced: isAdvanced,
        );
      }
    } catch (e) {
      logger.e('Error searching for hadiths: $e');
      return SearchResult(
        hadiths: [],
        isSupabaseSearch: false,
        selectedBook: null,
        selectedChapterName: null,
      );
    }
  }

  /// Search for semantically similar hadiths using vector embeddings
  Future<SearchResult> searchWithEmbeddings(String query, {int limit = 3}) async {
    try {
      // Generate embeddings for the query
      logger.i('Generating embeddings for query: $query');
      final embeddings = await _embeddingsService.generateEmbedding(query);
      
      // Search for similar hadiths using the embeddings
      logger.i('Searching for hadiths with embeddings');
      final hadiths = await _supabaseService.searchHadithsWithEmbeddings(
        queryEmbedding: embeddings,
        limit: limit,
      );
      
      logger.i('Found ${hadiths.length} hadiths using vector search | ${hadiths.map((e)=>e.score).toList()}');
      
      return SearchResult(
        hadiths: hadiths,
        isSupabaseSearch: true,
        selectedBook: null,
        selectedChapterName: null,
        isVectorSearch: true,
      );
    } catch (e) {
      logger.e('Error searching for hadiths with embeddings: $e');
      return SearchResult(
        hadiths: [],
        isSupabaseSearch: true,
        selectedBook: null,
        selectedChapterName: null,
        isVectorSearch: true,
      );
    }
  }

  /// Determines if local search should be used based on search parameters
  bool _shouldUseLocalSearch(int? bookId, int? chapterId, int? hadithNumber) {
    // Use local search if:
    // 1. A chapter is selected, or
    // 2. Chapter and hadith number are selected, or
    // 3. Book and hadith number are selected (we can find the chapter), or
    // 4. A "forties" book is selected
    if (chapterId != null) {
      return true; // 1. A chapter is selected
    }

    if (bookId != null) {
      if (hadithNumber != null) {
        return true; // 3. Book and hadith number are selected
      }

      if (_fortiesBooks.contains(bookId)) {
        return true; // 4. A "forties" book is selected
      }
    }

    return false;
  }

  /// Search using local hadith data
  Future<SearchResult> _performLocalSearch({
    String? query,
    int? bookId,
    int? chapterId,
    int? hadithNumber,
  }) async {
    List<Hadith> results = [];
    String? selectedChapterName;

    try {
      // Load selected book if book ID is provided
      final selectedBook = bookId != null ? await _metadataService.getBook(bookId) : null;

      // Case 1: Book and chapter are both specified
      if (bookId != null && chapterId != null) {
        // Get all hadiths for the chapter
        final hadiths = await _contentService.getHadithsForChapter(bookId, chapterId);

        // If hadith number is specified, filter by it
        if (hadithNumber != null) {
          results = hadiths.where((h) => h.idInBook == hadithNumber).toList();
        }
        // If query text is provided, filter by it
        else if (query != null && query.isNotEmpty) {
          final queryLower = query.toLowerCase();
          results = hadiths
              .where((h) =>
                  h.translation.toLowerCase().contains(queryLower) ||
                  h.narrator.toLowerCase().contains(queryLower))
              .toList();
        }
        // If no filters, return all hadiths from the chapter
        else {
          results = hadiths;
        }

        // Get chapter name
        if (selectedBook != null) {
          final chapter = selectedBook.chapters.firstWhere(
            (c) => c.id == chapterId,
            orElse: () => selectedBook.chapters.first,
          );
          selectedChapterName = chapter.english;
        }
      }
      // Case 2: Book and hadith number (but no chapter) are specified
      else if (bookId != null && hadithNumber != null && chapterId == null) {
        if (selectedBook != null) {
          // Find the chapter that contains this hadith number
          HadithChapter? targetChapter;
          for (final chapter in selectedBook.chapters) {
            if ((chapter.start <= hadithNumber) && (hadithNumber <= chapter.end)) {
              targetChapter = chapter;
              break;
            }
          }

          if (targetChapter != null) {
            // Get hadiths for the identified chapter
            final hadiths = await _contentService.getHadithsForChapter(bookId, targetChapter.id);

            // Filter by hadith number
            results = hadiths.where((h) => h.idInBook == hadithNumber).toList();

            // Set chapter name
            selectedChapterName = targetChapter.english;
          }
        }
      }
      // Case 3: For forties books (which use all.json), search across the entire book
      else if (bookId != null && _fortiesBooks.contains(bookId)) {
        // For forties collection, chapterId is always 1
        final hadiths = await _contentService.getHadithsForChapter(bookId, 1);

        // Apply filters
        if (hadithNumber != null) {
          results = hadiths.where((h) => h.idInBook == hadithNumber).toList();
        } else if (query != null && query.isNotEmpty) {
          final queryLower = query.toLowerCase();
          results = hadiths
              .where((h) =>
                  h.translation.toLowerCase().contains(queryLower) ||
                  h.narrator.toLowerCase().contains(queryLower))
              .toList();
        } else {
          results = hadiths;
        }
      }

      return SearchResult(
        hadiths: results,
        isSupabaseSearch: false,
        selectedBook: selectedBook,
        selectedChapterName: selectedChapterName,
      );
    } catch (e) {
      logger.e('Error in local search: $e');
      return SearchResult(
        hadiths: [],
        isSupabaseSearch: false,
        selectedBook: null,
        selectedChapterName: null,
      );
    }
  }

  /// Search using the Supabase service
  Future<SearchResult> _performSupabaseSearch({
    String? query,
    int? bookId,
    int? chapterId,
    int? hadithNumber,
    bool isAdvanced = true,
  }) async {
    if (query == null || query.isEmpty) {
      return SearchResult(
        hadiths: [],
        isSupabaseSearch: true,
        selectedBook: null,
        selectedChapterName: null,
      );
    }

    try {
      // Perform the search
      final hadiths = await _supabaseService.searchHadiths(
        query: query,
        bookId: bookId,
        chapterId: chapterId,
        hadithNumber: hadithNumber,
        isAdvanced: isAdvanced,
      );

      logger.i('Supabase search results: ${hadiths.length}');

      return SearchResult(
        hadiths: hadiths,
        isSupabaseSearch: true,
        selectedBook: bookId != null ? await _metadataService.getBook(bookId) : null,
        selectedChapterName: null,
      );
    } catch (e) {
      logger.e('Error in Supabase search: $e');
      return SearchResult(
        hadiths: [],
        isSupabaseSearch: true,
        selectedBook: null,
        selectedChapterName: null,
      );
    }
  }
}

/// Result from a hadith search operation
class SearchResult {
  final List<Hadith> hadiths;
  final bool isSupabaseSearch;
  final dynamic selectedBook;
  final String? selectedChapterName;
  final bool isVectorSearch;

  SearchResult({
    required this.hadiths,
    required this.isSupabaseSearch,
    required this.selectedBook,
    required this.selectedChapterName,
    this.isVectorSearch = false,
  });
}
