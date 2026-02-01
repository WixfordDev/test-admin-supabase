import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/widgets/dropdown_view.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/widgets/quran_search_bottom_sheet_view.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/verse_view_screen.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _verseController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _verseFocusNode = FocusNode();

  String? _selectedVerseNumber;
  final juzValueListenable = ValueNotifier<SearchDropdownItem?>(null);
  final surahValueListenable = ValueNotifier<SearchDropdownItem?>(null);

  final List<SearchDropdownItem> _juzOptions = List.generate(
    30,
    (index) => SearchDropdownItem(id: index + 1, name: 'Juz ${index + 1}'),
  );
  final List<SearchDropdownItem> _surahOptions = QuranService()
      .getAllSurahs()
      .map(
        (surah) =>
            SearchDropdownItem(id: surah.number, name: surah.englishName),
      )
      .toList();

  @override
  void dispose() {
    _searchController.dispose();
    _verseController.dispose();
    _searchFocusNode.dispose();
    _verseFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      config: _buildKeyboardActionsConfig(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 20,
        ), // extra padding for keyboard
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search input field
            Text(
              'Search the Quran',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Find verses by text, surah, juz or verse number',
              style: TextStyle(color: Colors.grey[600]),
            ),
            gapH16,
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: 'Type keywords, phrases...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
            ),
            gapH24,

            // Filter options header
            Text(
              'Filter Results',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            gapH12,

            // Juz, Surah selectors
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Juz'),
                      gapH4,
                      DropdownStatelessView<SearchDropdownItem>(
                        dropdownItems: _juzOptions,
                        valueListenable: juzValueListenable,
                        width: double.infinity,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            juzValueListenable.value = value;
                          });
                        },
                        getItemLabel: (item) => item.name,
                      ),
                    ],
                  ),
                ),
                gapW16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Surah'),
                      gapH4,
                      DropdownStatelessView<SearchDropdownItem>(
                        dropdownItems: _surahOptions,
                        valueListenable: surahValueListenable,
                        width: double.infinity,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            surahValueListenable.value = value;
                          });
                        },
                        getItemLabel: (item) => "${item.id}. ${item.name}",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gapH16,

            // Verse number input with iOS toolbar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Verse Number'),
                gapH4,
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _verseController,
                    focusNode: _verseFocusNode,
                    decoration: InputDecoration(
                      hintText: 'e.g. 1, 42, 123',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      setState(() {
                        _selectedVerseNumber = value.isNotEmpty ? value : null;
                      });
                    },
                  ),
                ),
              ],
            ),
            gapH24,

            // Search button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  KeyboardActionsConfig _buildKeyboardActionsConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      actions: [
        // Search input field -> shows "Next"
        KeyboardActionsItem(
          focusNode: _searchFocusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  node.unfocus();
                  FocusScope.of(context).requestFocus(_verseFocusNode);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ],
        ),
        // Verse input field -> shows "Done"
        KeyboardActionsItem(
          focusNode: _verseFocusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  node.unfocus();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            (node) {
              return GestureDetector(
                onTap: () {
                  node.unfocus();
                  _performSearch();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  void _performSearch() {
    FocusScope.of(context).unfocus();

    // Parse search parameters
    final String? query = _searchController.text.isNotEmpty
        ? _searchController.text.trim()
        : null;
    int? juz = juzValueListenable.value?.id;
    int? surahNumber = surahValueListenable.value?.id;

    // Parse verse number
    final int? verseNumber =
        _selectedVerseNumber != null && _selectedVerseNumber!.isNotEmpty
        ? int.tryParse(_selectedVerseNumber!)
        : null;

    // Show loading indicator
    final isAnyFilterApplied =
        query != null ||
        juz != null ||
        surahNumber != null ||
        verseNumber != null;
    if (!isAnyFilterApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter at least one search parameter'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Perform search
    final results = QuranService().searchAyahs(
      query: query,
      juz: juz,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
    );

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No results found'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // If we have a specific surah/verse result, go directly to that verse
    if (surahNumber != null && verseNumber != null && results.isNotEmpty) {
      // We already checked that surahNumber is not null above
      final Surah surah = QuranService().getSurah(surahNumber);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerseViewScreen(
            surah: surah,
            initialVerseId: verseNumber,
            isResultVerse: true,
          ),
        ),
      );
      return;
    }

    // Create search result items that include both ayah and its corresponding surah
    final searchResults = _createSearchResultItems(results);

    // Show search results
    _showSearchResults(searchResults);
  }

  // Create a list of search result items with corresponding surahs
  List<SearchResultItem> _createSearchResultItems(List<Ayah> ayahs) {
    final List<SearchResultItem> items = [];
    final quranService = QuranService();
    final allSurahs = quranService.getAllSurahs();

    // For each ayah, find which surah it belongs to
    for (var ayah in ayahs) {
      for (var surah in allSurahs) {
        if (surah.ayahs.any((a) => a.number == ayah.number)) {
          items.add(SearchResultItem(ayah: ayah, surah: surah));
          break;
        }
      }
    }

    return items;
  }

  void _showSearchResults(List<SearchResultItem> results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return QuranSearchBottomSheetView(
              results: results,
              scrollController: scrollController,
              onItemClick: (resultItem) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerseViewScreen(
                      surah: resultItem.surah,
                      initialVerseId: resultItem.ayah.numberInSurah,
                      isResultVerse: true,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class SearchDropdownItem {
  final int id;
  final String name;

  SearchDropdownItem({required this.id, required this.name});
}

class SearchResultItem {
  final Ayah ayah;
  final Surah surah;

  SearchResultItem({required this.ayah, required this.surah});
}
