import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/hadith/domain/models/hadith.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_book.dart';
import 'package:deenhub/features/hadith/domain/models/hadith_chapter.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_metadata_service.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_content_service.dart';
import 'package:deenhub/core/services/shared_prefs.dart';
import 'package:deenhub/core/widgets/dialog/report_dialog.dart';
import 'package:deenhub/core/services/report_service.dart';

class HadithDetailScreen extends StatefulWidget {
  final String bookId;
  final String chapterId;
  final String hadithId;

  const HadithDetailScreen({
    super.key,
    required this.bookId,
    required this.chapterId,
    required this.hadithId,
  });

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  final String _bookmarkedHadithsKey = 'bookmarked_hadiths';
  final HadithMetadataService _metadataService = HadithMetadataService.instance;
  final HadithContentService _contentService = HadithContentService.instance;

  bool _isLoading = true;
  HadithBook? _book;
  HadithChapter? _chapter;
  Hadith? _hadith;
  Set<String> _bookmarkedHadiths = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSavedHadiths();
  }

  Future<void> _loadSavedHadiths() async {
    final SharedPrefs prefs = SharedPrefs();
    final bookmarkedList =
        prefs.getData(_bookmarkedHadithsKey) as List<String>? ?? [];

    setState(() {
      _bookmarkedHadiths = Set<String>.from(bookmarkedList);
    });
  }

  Future<void> _saveBookmarkedHadiths() async {
    final SharedPrefs prefs = SharedPrefs();
    prefs.saveData(_bookmarkedHadithsKey, _bookmarkedHadiths.toList());
  }

  // Generate a unique ID for the hadith to use in bookmarks and favorites
  String _generateHadithId(Hadith hadith) {
    return '${_book?.id}_${_chapter?.id}_${hadith.id}';
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookId = int.parse(widget.bookId);
      final chapterId = int.parse(widget.chapterId);
      final hadithId = int.parse(widget.hadithId);

      // Load book data from metadata service
      final book = await _metadataService.getBook(bookId);
      if (book == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get chapter info
      HadithChapter? chapter;

      // Check if this book has chapters
      final hasChapters = _contentService.hasChapters(bookId);

      if (hasChapters) {
        // Get chapter info from the book's chapters
        chapter = book.chapters.firstWhere(
          (c) => c.id == chapterId,
          orElse: () => HadithChapter(
            id: chapterId, // Use the chapter ID from parameters
            bookId: bookId,
            arabic: '',
            english: 'Chapter $chapterId', // Default name if not found
            hadiths: [],
          ),
        );
      } else {
        // For books without chapters (like forties collections)
        // Create a default chapter with the book's name
        chapter = HadithChapter(
          id: chapterId,
          bookId: bookId,
          arabic: book.arabicName,
          english: book.name,
          hadiths: [],
        );
      }

      // Load hadith from content service
      final hadith =
          await _contentService.getHadith(bookId, chapterId, hadithId);

      setState(() {
        _book = book;
        _chapter = chapter;
        _hadith = hadith;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading hadith: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _shareHadith() {
    if (_hadith == null) return;

    final text = '''
Hadith ${_hadith!.number} from ${_book!.name}, ${_chapter!.name}
---
${_hadith!.arabic}
---
${_hadith!.translation}
---
Narrator: ${_hadith!.narrator}
${_hadith!.grade.isNotEmpty ? 'Grade: ${_hadith!.grade}' : ''}
Shared from Islamic App
''';
    Share.share(text);
  }

  void _toggleBookmark() {
    if (_hadith == null) return;

    final hadithId = _generateHadithId(_hadith!);
    setState(() {
      if (_bookmarkedHadiths.contains(hadithId)) {
        _bookmarkedHadiths.remove(hadithId);
      } else {
        _bookmarkedHadiths.add(hadithId);
      }
    });
    _saveBookmarkedHadiths();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_bookmarkedHadiths.contains(hadithId)
            ? 'Hadith bookmarked'
            : 'Bookmark removed'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyHadith() {
    if (_hadith == null) return;

    final text = '''
${_hadith!.arabic}

${_hadith!.translation}

Narrator: ${_hadith!.narrator}
${_hadith!.grade.isNotEmpty ? 'Grade: ${_hadith!.grade}' : ''}
''';
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hadith copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hadithId = _hadith != null ? _generateHadithId(_hadith!) : '';
    final isBookmarked = _bookmarkedHadiths.contains(hadithId);

    return AppBarScaffold(
      pageTitle:
          _hadith != null ? 'Hadith ${_hadith!.idInBook}' : 'Hadith Details',
      bottomNavigationBar:
          _hadith == null ? null : _buildBottomActionBar(context, isBookmarked),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hadith == null
              ? Center(
                  child: Padding(
                    padding: p16,
                    child: Text(
                      'Hadith not found',
                      style: TextStyle(
                          fontSize: 16, color: context.onSurfaceColor),
                    ),
                  ),
                )
              : _buildModernHadithDetails(context, isBookmarked),
    );
  }

  Widget _buildModernHadithDetails(BuildContext context, bool isBookmarked) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with book and chapter info
          _buildHeader(context),

          // Hadith content
          Container(
            margin: p16,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Narrator tag at the top
                if (_hadith!.narratorText.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      _hadith!.narratorText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: context.primaryColor,
                      ),
                    ),
                  ),

                // Arabic text
                Container(
                  width: double.infinity,
                  padding: p16,
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: _hadith!.narratorText.isEmpty
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          )
                        : null,
                  ),
                  child: Text(
                    _hadith!.arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.8,
                      color: context.onSurfaceColor,
                      fontFamily: 'Scheherazade',
                    ),
                  ),
                ),

                // Divider between Arabic and English
                Divider(color: Colors.grey.withValues(alpha: 0.3), height: 1),

                // English translation
                Container(
                  width: double.infinity,
                  padding: p16,
                  child: Text(
                    _hadith!.translationText,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.6,
                      color: context.onSurfaceColor,
                    ),
                  ),
                ),

                // Grade badge at the bottom
                if (_hadith!.grade.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _getGradeColor(_hadith!.grade).withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 18,
                          color: _getGradeColor(_hadith!.grade),
                        ),
                        gapW8,
                        Text(
                          'Grade: ${_hadith!.grade}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _getGradeColor(_hadith!.grade),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Hadith number badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${_hadith!.idInBook}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.onPrimaryColor,
                  ),
                ),
              ),
              gapW16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _book?.name ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.onPrimaryColor,
                      ),
                    ),
                    gapH4,
                    Row(
                      children: [
                        Icon(Icons.menu_book_outlined,
                            size: 14,
                            color:
                                context.onPrimaryColor.withValues(alpha: 0.9)),
                        gapW4,
                        Expanded(
                          child: Text(
                            _chapter?.name ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  context.onPrimaryColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, bool isBookmarked) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.bookmark_outline,
            activeIcon: Icons.bookmark,
            label: isBookmarked ? 'Saved' : 'Save',
            isActive: isBookmarked,
            onTap: _toggleBookmark,
          ),
          _buildActionButton(
            icon: Icons.copy_outlined,
            label: 'Copy',
            onTap: _copyHadith,
          ),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: _shareHadith,
          ),
          _buildActionButton(
            icon: Icons.flag_outlined,
            label: 'Report',
            onTap: _showReportDialog,
            isSpecial: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isSpecial = false,
  }) {
          return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: isSpecial ? BoxDecoration(
              color: const Color(0xFF2A7A8C).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2A7A8C).withValues(alpha: 0.2),
                width: 0.5,
              ),
            ) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? (activeIcon ?? icon) : icon,
                  size: 24,
                  color: isSpecial
                      ? const Color(0xFF2A7A8C)
                      : isActive
                          ? context.primaryColor
                          : context.onSurfaceColor.withValues(alpha: 0.7),
                ),
                gapH4,
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSpecial
                        ? const Color(0xFF2A7A8C)
                        : isActive
                            ? context.primaryColor
                            : context.onSurfaceColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void _showReportDialog() {
    if (_hadith == null) return;

    // Check if user is logged in (you can add your own login check here)
    // For now, we'll allow all users to report

    final hadithData = {
      'arabic': _hadith!.arabic,
      'translation': _hadith!.translationText,
      'narrator': _hadith!.narratorText,
      'grade': _hadith!.grade,
      'book_name': _book?.name ?? '',
      'chapter_name': _chapter?.name ?? '',
      'hadith_number': _hadith!.idInBook,
    };

    ReportDialog.showHadithReport(
      context,
      hadithId: widget.hadithId,
      bookId: widget.bookId,
      hadithData: hadithData,
      additionalContext: {
        'chapter_id': widget.chapterId,
        'book_arabic_name': _book?.arabicName ?? '',
        'chapter_arabic_name': _chapter?.arabic ?? '',
        'total_hadiths_in_chapter': _chapter?.hadiths.length ?? 0,
      },
    );
  }

  // Helper method to get color based on hadith grade
  Color _getGradeColor(String grade) {
    grade = grade.toLowerCase();
    if (grade.contains('sahih')) {
      return Colors.green;
    } else if (grade.contains('hasan')) {
      return Colors.blue;
    } else if (grade.contains('da\'if') ||
        grade.contains('daif') ||
        grade.contains('weak')) {
      return Colors.red;
    } else if (grade.contains('maudu') || grade.contains('fabricated')) {
      return Colors.red;
    } else {
      return Colors.purple; // For other grades
    }
  }
}
