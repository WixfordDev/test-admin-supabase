import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_book.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_metadata_service.dart';
import 'package:deenhub/features/hadith/presentation/widgets/hadith_book_card.dart';
import 'package:deenhub/features/hadith/presentation/widgets/hadith_search_widget.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  bool _showSearchWidget = false;
  bool _isLoading = true;
  List<HadithBook> _hadithBooks = [];
  final HadithMetadataService _metadataService = HadithMetadataService.instance;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load books from metadata service
      final books = await _metadataService.getAllBooks();
      
      setState(() {
        _hadithBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading hadith books: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleSearchWidget() {
    setState(() {
      _showSearchWidget = !_showSearchWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: 'Hadith Collections',
      appBarActions: [
        IconButton(
          icon: Icon(_showSearchWidget ? Icons.close : Icons.search),
          onPressed: _toggleSearchWidget,
        ),
      ],
      useScrollView: true,
      showScrollbar: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show advanced search widget if toggle is on
          if (_showSearchWidget) 
            Padding(
              padding: p16,
              child: const HadithSearchWidget(),
            ),
          Padding(
            padding: p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Collections',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                gapH8,
                Text(
                  'Explore the authentic traditions (Hadith) of Prophet Muhammad ﷺ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.onSurfaceColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          gapH8,
          _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _hadithBooks.isEmpty
              ? Center(
                  child: Padding(
                    padding: p16,
                    child: Text(
                      'No hadith collections found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _hadithBooks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: px16.copyWith(bottom: 16),
                      child: HadithBookCard(
                        book: _hadithBooks[index],
                      ),
                    );
                  },
                ),
          gapH16,
        ],
      ),
    );
  }
}
