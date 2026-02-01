import 'dart:async';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';

class SurahListWidget extends StatefulWidget {
  final List<Surah> surahs;
  final bool expanded;
  final Function(Surah) onSurahTap;
  final bool isReadingMode;

  const SurahListWidget({
    super.key,
    required this.surahs,
    required this.onSurahTap,
    this.expanded = false,
    this.isReadingMode = false,
  });

  @override
  State<SurahListWidget> createState() => _SurahListWidgetState();
}

class _SurahListWidgetState extends State<SurahListWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  List<Surah> _filteredSurahs = [];

  @override
  void initState() {
    super.initState();
    _filteredSurahs = List.from(widget.surahs);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(SurahListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surahs != widget.surahs) {
      _updateFilteredSurahs();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Start new timer for debouncing
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          _updateFilteredSurahs();
        });
      }
    });
  }

  void _updateFilteredSurahs() {
    if (_searchQuery.isEmpty) {
      _filteredSurahs = List.from(widget.surahs);
    } else {
      _filteredSurahs = widget.surahs.where((surah) {
        final surahNumber = surah.number.toString();
        final surahName = surah.englishName.toLowerCase();
        final surahArabicName = surah.name.toLowerCase();

        return surahNumber.contains(_searchQuery) ||
               surahName.contains(_searchQuery) ||
               surahArabicName.contains(_searchQuery);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.expanded) gapH16,
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'All Surahs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Text('List View • ${_filteredSurahs.length}${_searchQuery.isNotEmpty ? ' of ${widget.surahs.length}' : ''} Surahs'),
          ],
        ).withPadding((widget.expanded) ? px16 : p0),
        if (!widget.expanded) const SizedBox(height: 16),

        // Search Box
        if (widget.expanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search surahs by number or name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

        // Surah List
        widget.expanded ? allSurahListView().expanded() : allSurahListView(),

        // Show More/Less Button
        if (_filteredSurahs.length > 5 && !widget.expanded)
          Center(
            child: TextButton.icon(
              onPressed: () {
                _openAllSurahListView();
              },
              icon: Icon(widget.expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(widget.expanded ? 'Show Less' : 'Show More'),
            ),
          ),
      ],
    );
  }

  Widget allSurahListView() {
    return ListView.builder(
      physics: (widget.expanded)
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.expanded ? _filteredSurahs.length : (_filteredSurahs.length > 5 ? 5 : _filteredSurahs.length),
      padding: (widget.expanded) ? p16 : p0,
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];

        return GestureDetector(
          onTap: () => widget.onSurahTap(surah),
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Surah Number
                  CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    foregroundColor: Colors.blue,
                    child: Text('${surah.number}'),
                  ),
                  const SizedBox(width: 12),

                  // Surah Names (English & Arabic)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(surah.englishName).expanded(),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              surah.revelationType,
                              style: TextStyle(color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                      gapH2,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                surah.name,
                                style: const TextStyle(fontFamily: 'ScheherazadeNew'),
                                textDirection: TextDirection.rtl,
                              ),
                              gapH4,
                              // Name & Ayah Count
                              Text(
                                '${surah.englishNameTranslation} • ${surah.ayahs.length} verses',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ).expanded(),
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () {
                              // Audio functionality to be implemented
                              widget.onSurahTap(surah);
                            },
                          ),
                        ],
                      ),
                    ],
                  ).expanded(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openAllSurahListView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahListWidget(
          surahs: widget.surahs,
          onSurahTap: widget.onSurahTap,
          expanded: true,
          isReadingMode: widget.isReadingMode,
        ),
      ),
    );
  }
}
