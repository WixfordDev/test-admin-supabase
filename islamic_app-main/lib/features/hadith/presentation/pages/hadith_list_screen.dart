import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/hadith/domain/models/hadith.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_book.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_chapter.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_metadata_service.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_content_service.dart';
import 'package:deenhub/config/routes/routes.dart';

class HadithListScreen extends StatefulWidget {
  final String bookId;
  final String chapterId;

  const HadithListScreen({
    super.key,
    required this.bookId,
    required this.chapterId,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  bool _isLoading = true;
  HadithBook? _book;
  HadithChapter? _chapter;
  List<Hadith> _hadiths = [];
  
  final HadithMetadataService _metadataService = HadithMetadataService.instance;
  final HadithContentService _contentService = HadithContentService.instance;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bookId = int.parse(widget.bookId);
      final chapterId = int.parse(widget.chapterId);
      
      // Get book info
      final book = await _metadataService.getBook(bookId);
      if (book == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Check if this book has chapters
      final hasChapters = _contentService.hasChapters(bookId);
      HadithChapter? chapter;
      
      if (hasChapters) {
        // Get chapter info from the book's chapters
        chapter = book.chapters.firstWhere(
          (c) => c.id == chapterId,
          orElse: () => HadithChapter(
            id: 0,
            bookId: 0,
            arabic: '',
            english: '',
            hadiths: [],
          ),
        );
        
        if (chapter.id == 0) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else {
        // For books without chapters (like forties collections)
        // Create a default chapter with the book's name
        chapter = HadithChapter(
          id: 0,
          bookId: bookId,
          arabic: book.arabicName,
          english: book.name,
          hadiths: [],
        );
      }
      
      // Load hadiths
      final hadiths = await _contentService.getHadithsForChapter(bookId, chapterId);
      
      setState(() {
        _book = book;
        _chapter = chapter;
        _hadiths = hadiths;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading hadiths: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: _chapter?.english ?? 'Hadiths',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hadiths.isEmpty
              ? Center(
                  child: Padding(
                    padding: p16,
                    child: Text(
                      'No hadiths found in this chapter',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.onSurfaceColor,
                      ),
                    ),
                  ),
                )
              : _buildHadithListView(),
    );
  }

  Widget _buildHadithListView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildChapterHeader(),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  'Hadiths',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.onSurfaceColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_hadiths.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildHadithItem(_hadiths[index], index),
              childCount: _hadiths.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterHeader() {
    final bool isFortyCollection = !_contentService.hasChapters(_book!.id);
    final String headerTitle = isFortyCollection ? _book!.name : _chapter!.english;
    final String subTitle = isFortyCollection ? _book!.author : _book!.name;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primaryColor,
            context.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFortyCollection ? Icons.collections_bookmark : Icons.menu_book_outlined,
                    size: 26,
                    color: context.onPrimaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.onPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subTitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.onPrimaryColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_chapter?.arabic.isNotEmpty ?? false)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                _chapter!.arabic,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Amiri',
                  color: context.onPrimaryColor.withValues(alpha: 0.95),
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHadithItem(Hadith hadith, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to hadith detail screen
            context.pushNamed(
              Routes.hadithDetail.name,
              queryParameters: {
                'bookId': _book!.id.toString(),
                'chapterId': _chapter!.id.toString(),
                'hadithId': hadith.idInBook.toString(),
              },
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with hadith number and grade
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 18,
                      color: context.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hadith ${hadith.number}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    if (hadith.grade.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getGradeColor(hadith.grade).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 14,
                              color: _getGradeColor(hadith.grade),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hadith.grade,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _getGradeColor(hadith.grade),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hadith.narrator.isNotEmpty) ...[
                      Text(
                        hadith.narrator,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.primaryColor.withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      hadith.translation,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.onSurfaceColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: context.primaryColor,
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
  
  // Helper method to get color based on hadith grade
  Color _getGradeColor(String grade) {
    grade = grade.toLowerCase();
    if (grade.contains('sahih')) {
      return Colors.green;
    } else if (grade.contains('hasan')) {
      return Colors.blue;
    } else if (grade.contains('da\'if') || grade.contains('daif') || grade.contains('weak')) {
      return Colors.red;
    } else if (grade.contains('maudu') || grade.contains('fabricated')) {
      return Colors.red;
    } else {
      return Colors.purple; // For other grades
    }
  }
} 