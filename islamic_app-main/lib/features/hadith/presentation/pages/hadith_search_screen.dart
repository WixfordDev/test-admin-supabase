import 'package:deenhub/features/hadith/domain/services/hadith_search_service.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/hadith/domain/models/hadith.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_book.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_metadata_service.dart';

class HadithSearchScreen extends StatefulWidget {
  final Map<String, String> queryParams;

  const HadithSearchScreen({
    super.key,
    required this.queryParams,
  });

  @override
  State<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends State<HadithSearchScreen> {
  bool _isLoading = true;
  final HadithMetadataService _metadataService = HadithMetadataService.instance;
  final HadithSearchService _hadithSearchService = HadithSearchService.instance;

  // Search results state
  List<Hadith> _searchResults = [];

  // Cache for search results metadata
  final Map<String, String> _chapterNamesCache = {}; // key: "bookId:chapterId"
  final Map<int, String> _bookTitlesCache = {}; // key: bookId, value: book title

  // Book, chapter info
  HadithBook? _selectedBook;
  String? _selectedChapterName;

  // Search parameters
  String? _query;
  int? _bookId;
  int? _chapterId;
  String? _hadithNumber;

  // Flag to track search type
  bool _isSupabaseSearch = false;

  @override
  void initState() {
    super.initState();
    _extractSearchParams();
    _performSearch();
  }

  void _extractSearchParams() {
    // Extract search parameter from query parameters
    _query = widget.queryParams['query'];

    // Extract book, chapter, and hadith number if provided
    if (widget.queryParams.containsKey('bookId')) {
      _bookId = int.tryParse(widget.queryParams['bookId']!);
    }

    if (widget.queryParams.containsKey('chapterId')) {
      _chapterId = int.tryParse(widget.queryParams['chapterId']!);
    }

    _hadithNumber = widget.queryParams['hadithNumber'];
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the new search service
      final searchResult = await _hadithSearchService.search(
        query: _query,
        bookId: _bookId,
        chapterId: _chapterId,
        hadithNumber: int.tryParse(_hadithNumber ?? ''),
      );

      // Update state with search results
      _searchResults = searchResult.hadiths;
      _isSupabaseSearch = searchResult.isSupabaseSearch;
      _selectedBook = searchResult.selectedBook;
      _selectedChapterName = searchResult.selectedChapterName;

      // For Supabase search, we need to preload metadata for results
      if (_isSupabaseSearch) {
        await _loadMetadataForResults();
      }

      // Cache book title if available
      if (_selectedBook != null && _bookId != null) {
        _bookTitlesCache[_bookId!] = _selectedBook!.metadata['english']?['title'] ?? 'Hadith';
      }
    } catch (e) {
      logger.e('Error performing search: $e');
      _searchResults = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Load book and chapter metadata for search results using the metadata service
  Future<void> _loadMetadataForResults() async {
    // Get unique book IDs from search results
    final Set<int> bookIds = _searchResults.map((hadith) => hadith.bookId).toSet();

    // Load books using the metadata service (which is now optimized to check cache first)
    for (final bookId in bookIds) {
      final book = await _metadataService.getBook(bookId);
      if (book != null) {
        // Cache book title
        _bookTitlesCache[bookId] = book.metadata['english']?['title'] ?? 'Hadith';

        // Cache chapter names for this book
        for (final hadith in _searchResults.where((h) => h.bookId == bookId)) {
          final cacheKey = '${hadith.bookId}:${hadith.chapterId}';
          if (!_chapterNamesCache.containsKey(cacheKey)) {
            final chapter = book.chapters.firstWhere(
              (c) => c.id == hadith.chapterId,
              orElse: () => book.chapters.first,
            );
            _chapterNamesCache[cacheKey] = chapter.english;
          }
        }
      }
    }
  }

  // Build search description text
  String _buildSearchDescription() {
    List<String> descriptionParts = [];

    // Add query text if present
    if (_query != null && _query!.isNotEmpty) {
      descriptionParts.add('"$_query"');
    }

    // Add book name if present
    if (_selectedBook != null) {
      final bookTitle = _selectedBook!.metadata['english']?['title'] ?? 'Unknown Book';
      descriptionParts.add(bookTitle);
    }

    // Add chapter name if present
    if (_selectedChapterName != null) {
      descriptionParts.add(_selectedChapterName!);
    }

    // Add hadith number if present
    if (_hadithNumber != null && _hadithNumber!.isNotEmpty) {
      descriptionParts.add('Hadith #$_hadithNumber');
    }

    if (descriptionParts.isNotEmpty) {
      return 'Results for ${descriptionParts.join(', ')}';
    } else {
      return 'Search Results';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: 'Search Results',
      useScrollView: true,
      showScrollbar: true,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: p16,
                  child: Text(
                    _buildSearchDescription(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.onSurfaceColor,
                    ),
                  ),
                ),
                gapH8,
                // Show search results
                _buildSearchResults(context),
                gapH16,
              ],
            ),
    );
  }

  // Unified method to build search results
  Widget _buildSearchResults(BuildContext context) {
    if (_searchResults.isEmpty) {
      return _buildNoResultsView(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: px16,
          child: Text(
            '${_searchResults.length} results found',
            style: TextStyle(
              fontSize: 14,
              color: context.onSurfaceColor.withValues(alpha: 0.7),
            ),
          ),
        ),
        gapH8,
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final hadith = _searchResults[index];
            return _buildHadithResultItem(context, hadith);
          },
        ),
      ],
    );
  }

  // Unified method to build hadith result items
  Widget _buildHadithResultItem(BuildContext context, Hadith hadith) {
    String bookName;
    String chapterName;

    if (_isSupabaseSearch) {
      // Get book title from cache
      bookName = _bookTitlesCache[hadith.bookId] ?? 'Hadith';

      // Get chapter name from cache
      final cacheKey = '${hadith.bookId}:${hadith.chapterId}';
      chapterName = _chapterNamesCache[cacheKey] ?? '';
    } else {
      // For local search, use the selected book and chapter
      bookName = _bookTitlesCache[_bookId] ?? 'Hadith';
      chapterName = _selectedChapterName ?? '';
    }

    return _buildHadithItem(
      context: context,
      hadithNumber: hadith.number,
      bookName: bookName,
      chapterName: chapterName,
      grade: hadith.grade,
      arabicText: hadith.arabicText,
      bodyText: hadith.translation,
      narrator: hadith.narrator,
      onTap: () {
        // Navigate to hadith detail
        context.pushNamed(
          Routes.hadithDetail.name,
          queryParameters: {
            'bookId': hadith.bookId.toString(),
            'chapterId': hadith.chapterId.toString(),
            'hadithId': hadith.idInBook.toString(),
          },
        );
      },
      hasArabicText: hadith.arabicText.isNotEmpty,
    );
  }

  // Build UI for no results
  Widget _buildNoResultsView(BuildContext context) {
    return Center(
      child: Padding(
        padding: p16,
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: context.onSurfaceColor.withValues(alpha: 0.5),
            ),
            gapH16,
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                color: context.onSurfaceColor,
              ),
              textAlign: TextAlign.center,
            ),
            gapH8,
            Text(
              'Try using different search criteria',
              style: TextStyle(
                fontSize: 14,
                color: context.onSurfaceColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget for both API and local hadith items
  Widget _buildHadithItem({
    required BuildContext context,
    required String hadithNumber,
    required String bookName,
    required String chapterName,
    required String grade,
    required String? arabicText,
    required String bodyText,
    required String narrator,
    required VoidCallback onTap,
    required bool hasArabicText,
  }) {
    return Container(
      margin: px16.copyWith(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: context.primaryColor,
                      child: Text(
                        hadithNumber,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: context.onPrimaryColor,
                        ),
                      ),
                    ),
                    gapW8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                            ),
                          ),
                          Text(
                            chapterName,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.onSurfaceColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: p8,
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        grade,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                gapH12,
                // Show Arabic text if available
                if (hasArabicText && arabicText != null && arabicText.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        arabicText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Amiri',
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      gapH8,
                    ],
                  ),
                Text(
                  bodyText,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: context.onSurfaceColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                gapH8,
                Text(
                  'Narrator: $narrator',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: context.onSurfaceColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
