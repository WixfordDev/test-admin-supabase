import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/dropdown_view.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_metadata_service.dart';

class HadithSearchWidget extends StatefulWidget {
  const HadithSearchWidget({super.key});

  @override
  State<HadithSearchWidget> createState() => _HadithSearchWidgetState();
}

class _HadithSearchWidgetState extends State<HadithSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  // Value notifiers for the dropdowns
  final bookValueListenable = ValueNotifier<String?>(null);
  final chapterValueListenable = ValueNotifier<ChapterSearchDropdownItem?>(null);
  String? _selectedHadithNumber;

  // Books and chapters from metadata service
  final HadithMetadataService _metadataService = HadithMetadataService.instance;
  List<String> _bookOptions = [];
  List<ChapterSearchDropdownItem> _chapterOptions = [];
  bool _isLoadingBooks = true;
  bool _isLoadingChapters = false;

  // Map to store book name to ID mapping
  Map<String, int> _bookNameToIdMap = {};

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoadingBooks = true;
    });

    try {
      // Load books from metadata service
      final books = await _metadataService.getAllBooks();

      // Map books to options for dropdown
      final bookOptions = books.map((book) => book.name).toList();

      // Create map of book name to ID for lookup
      final bookNameToIdMap = {for (var book in books) book.name: book.id};

      setState(() {
        _bookOptions = bookOptions;
        _bookNameToIdMap = bookNameToIdMap;
        _isLoadingBooks = false;
      });
    } catch (e) {
      logger.e('Error loading hadith books: $e');
      setState(() {
        _isLoadingBooks = false;
      });
    }
  }

  // Update chapters when book selection changes
  Future<void> _updateChapters(String? bookName) async {
    if (bookName == null) return;

    setState(() {
      _isLoadingChapters = true;
      _chapterOptions = [];
    });

    try {
      // Get book ID from name
      final bookId = _bookNameToIdMap[bookName];
      if (bookId == null) {
        setState(() {
          _isLoadingChapters = false;
        });
        return;
      }

      // Load book with chapters
      final book = await _metadataService.getBook(bookId);
      if (book == null) {
        setState(() {
          _isLoadingChapters = false;
        });
        return;
      }

      // Map chapters to options for dropdown
      final chapterOptions = book.chapters
          .map(
            (chapter) => ChapterSearchDropdownItem(
                id: chapter.id,
                name: chapter.name,
                startEndText: '#${chapter.start}-${chapter.end}'),
          )
          .toList();

      setState(() {
        _chapterOptions = chapterOptions;
        _isLoadingChapters = false;
      });
    } catch (e) {
      logger.e('Error loading chapters: $e');
      setState(() {
        _isLoadingChapters = false;
      });
    }

    // Reset chapter selection
    chapterValueListenable.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with improved styling
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                    color: context.primaryColor,
                  ),
                  gapW8,
                  Text(
                    'Search Hadith Collections',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            gapH16,

            // Search input field with improved styling
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by text, narrator or content',
                  hintStyle: TextStyle(
                    color: context.onSurfaceColor.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.primaryColor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            gapH16,

            // Selector headings with improved styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book,
                    size: 18,
                    color: context.primaryColor,
                  ),
                  gapW8,
                  Text(
                    'Select Collection Parameters',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            gapH12,

            // Book and Chapter selectors with improved styling
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  // Book dropdown
                  _isLoadingBooks
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : DropdownStatelessView<String>(
                          label: "Select Book",
                          dropdownItems: _bookOptions,
                          valueListenable: bookValueListenable,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              bookValueListenable.value = value;
                              _updateChapters(value);
                            });
                          },
                          getItemLabel: (item) => item,
                        ),
                  gapH16,

                  // Chapter dropdown with minimum height
                  SizedBox(
                    height: 60, // Minimum height to ensure consistent appearance
                    child: _isLoadingChapters
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : DropdownStatelessView<ChapterSearchDropdownItem>(
                            label: "Select Chapter",
                            showSubtitle: true,
                            dropdownItems: _chapterOptions.isEmpty
                                ? [
                                    ChapterSearchDropdownItem(
                                      id: -1,
                                      name: 'Please select a book first',
                                      startEndText: '',
                                    )
                                  ]
                                : _chapterOptions,
                            valueListenable: chapterValueListenable,
                            onChanged: _chapterOptions.isEmpty
                                ? (value) {}
                                : (value) {
                                    if (value == null) return;
                                    setState(() {
                                      chapterValueListenable.value = value;
                                    });
                                  },
                            getItemLabel: (item) => "Chapter ${item.id}  (${item.startEndText})",
                            getItemDesc: (item) => item.name,
                          ),
                  ),
                  gapH16,

                  // Hadith number field with improved styling
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Hadith Number',
                      labelStyle: TextStyle(
                        color: context.primaryColor,
                      ),
                      hintText: 'e.g. 1, 393, 2341',
                      hintStyle: TextStyle(
                        color: context.onSurfaceColor.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: context.onSurfaceColor.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: context.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.format_list_numbered,
                        color: context.primaryColor,
                        size: 18,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _selectedHadithNumber = value.isNotEmpty ? value : null;
                      });
                    },
                  ),
                ],
              ),
            ),
            gapH16,

            // Add a search button at the bottom
            gapH24,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.onPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Search Hadith',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch() {
    // Build query parameters
    final Map<String, String> queryParams = {};

    // Add search text
    if (_searchController.text.isNotEmpty) {
      queryParams['query'] = _searchController.text;
    }

    // Add book ID if selected
    final bookName = bookValueListenable.value;
    if (bookName != null && _bookNameToIdMap.containsKey(bookName)) {
      queryParams['bookId'] = _bookNameToIdMap[bookName].toString();
    }

    // Add chapter ID if selected
    final chapter = chapterValueListenable.value;
    if (chapter != null) {
      queryParams['chapterId'] = chapter.id.toString();
    }

    // Add hadith number if provided
    if (_selectedHadithNumber != null && _selectedHadithNumber!.isNotEmpty) {
      queryParams['hadithNumber'] = _selectedHadithNumber!;
    }

    // empty or has only hadithNumber parameter
    if (queryParams.isEmpty ||
        (queryParams.length == 1 && queryParams.containsKey('hadithNumber'))) {
      return;
    }

    // Navigate to search results screen with the query parameters
    context.pushNamed(
      Routes.hadithSearch.name,
      queryParameters: queryParams,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    bookValueListenable.dispose();
    chapterValueListenable.dispose();
    super.dispose();
  }
}

class ChapterSearchDropdownItem {
  final int id;
  final String name;
  final String startEndText;

  ChapterSearchDropdownItem({required this.id, required this.name, required this.startEndText});
}
