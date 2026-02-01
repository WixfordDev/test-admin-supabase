import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_book.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_chapter.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_metadata_service.dart';
import 'package:deenhub/config/routes/routes.dart';

class HadithChaptersScreen extends StatefulWidget {
  final String bookId;

  const HadithChaptersScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<HadithChaptersScreen> createState() => _HadithChaptersScreenState();
}

class _HadithChaptersScreenState extends State<HadithChaptersScreen> {
  bool _isLoading = true;
  HadithBook? _book;
  List<HadithChapter> _chapters = [];
  final HadithMetadataService _metadataService = HadithMetadataService.instance;
  
  @override
  void initState() {
    super.initState();
    _loadBookAndChapters();
  }

  Future<void> _loadBookAndChapters() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bookId = int.parse(widget.bookId);
      
      // Load the book with chapters from metadata service
      final book = await _metadataService.getBook(bookId);
      
      if (book == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _book = book;
        _chapters = book.chapters;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading book chapters: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: _book?.name ?? 'Hadith Chapters',
      useScrollView: true,
      showScrollbar: true,
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          : _book == null
              ? Center(
                  child: Padding(
                    padding: p16,
                    child: Text(
                      'Book not found',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.onSurfaceColor,
                      ),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookHeader(context),
                    gapH16,
                    Padding(
                      padding: px16,
                      child: Text(
                        'Chapters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.onSurfaceColor,
                        ),
                      ),
                    ),
                    gapH8,
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _chapters.length,
                      itemBuilder: (context, index) {
                        return _buildChapterItem(context, _chapters[index], index);
                      },
                    ),
                    gapH16,
                  ],
                ),
    );
  }

  Widget _buildBookHeader(BuildContext context) {
    return Container(
      margin: p16,
      padding: p16,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primaryColor,
            context.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced book icon with gradient
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book,
                  size: 36,
                  color: context.onPrimaryColor,
                ),
              ),
              gapW16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _book!.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.onPrimaryColor,
                      ),
                    ),
                    gapH4,
                    Text(
                      'Author: ${_book!.author}',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.onPrimaryColor.withValues(alpha: 0.9),
                      ),
                    ),
                    gapH4,
                    Text(
                      '${_chapters.length} Chapters',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.onPrimaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          gapH16,
          Text(
            _book!.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: context.onPrimaryColor.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHadithList(HadithChapter chapter) {
    context.pushNamed(
      Routes.hadithList.name,
      queryParameters: {
        'bookId': widget.bookId,
        'chapterId': chapter.id.toString(),
      },
    );
  }

  Widget _buildChapterItem(BuildContext context, HadithChapter chapter, int index) {
    return Container(
      margin: px16.copyWith(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToHadithList(chapter),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _getChapterColor(index).withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Number container with gradient
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getChapterColor(index),
                            _getChapterColor(index).withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getChapterColor(index).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    gapW16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: context.onSurfaceColor,
                            ),
                          ),
                          gapH6,
                          if (chapter.arabic.isNotEmpty)
                            Text(
                              chapter.arabic,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Amiri',
                                color: context.onSurfaceColor.withValues(alpha: 0.7),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          gapH6,
                          // Display hadith count and range
                          if (chapter.length > 0)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getChapterColor(index).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.format_list_numbered,
                                        size: 12,
                                        color: _getChapterColor(index),
                                      ),
                                      gapW4,
                                      Text(
                                        '${chapter.length} Hadiths',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: _getChapterColor(index),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                gapW8,
                                if (chapter.start > 0 && chapter.end > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getChapterColor(index).withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      '#${chapter.start}-${chapter.end}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _getChapterColor(index).withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          gapH6,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getChapterColor(index).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.format_list_numbered,
                                  size: 14,
                                  color: _getChapterColor(index),
                                ),
                                gapW4,
                                Text(
                                  'View Hadiths',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _getChapterColor(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getChapterColor(index).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: _getChapterColor(index),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to get different colors for chapters to add visual variety
  Color _getChapterColor(int index) {
    final colors = [
      context.primaryColor,
      Colors.teal,
      Colors.purple,
      Colors.indigo,
      Colors.orange,
    ];
    
    return colors[index % colors.length];
  }
} 