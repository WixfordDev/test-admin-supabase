import 'package:flutter/material.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class VersesByStatusScreen extends StatefulWidget {
  final String status;

  const VersesByStatusScreen({
    super.key,
    required this.status,
  });

  @override
  State<VersesByStatusScreen> createState() => _VersesByStatusScreenState();
}

class _VersesByStatusScreenState extends State<VersesByStatusScreen> {
  final MemorizationService _memorizationService = MemorizationService();
  late Future<void> _initFuture;
  late List<Map<String, dynamic>> _verses;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    await _memorizationService.initialize();
    _verses = _memorizationService.getVersesByStatus(widget.status);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'memorized':
        return Colors.green;
      case 'reviewing':
        return Colors.blue;
      case 'learning':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.status);

    return AppBarScaffold(
      pageTitle: '${widget.status} Verses',
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (_verses.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Summary section
              _buildSummarySection(context, statusColor),

              // Verses list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _verses.length,
                  itemBuilder: (context, index) {
                    final verse = _verses[index];
                    final surahId = verse['surahId'] as int;
                    final surahName = verse['surahName'] as String;
                    final verseId = verse['verseId'] as int;
                    final verseText = verse['verseText'] as String;
                    final status = verse['status'] as String;

                    return _buildVerseCard(
                      context,
                      surahId,
                      surahName,
                      verseId,
                      verseText,
                      status,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, Color statusColor) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(widget.status),
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.status} Verses',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_verses.length} ${_verses.length == 1 ? 'verse' : 'verses'} in total',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(widget.status);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 64,
                color: statusColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${widget.status.toLowerCase()} verses yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mark verses as ${widget.status.toLowerCase()} while reading the Quran to see them here',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(
    BuildContext context,
    int surahId,
    String surahName,
    int verseId,
    String verseText,
    String status,
  ) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => _openVerseForReading(surahId, verseId),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with surah info and status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  // Surah number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      surahId.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Surah name and verse number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Verse $verseId',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Verse text
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                verseText,
                style: TextStyle(
                  fontSize: 22,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            ),

            // Actions row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      final shareText = 'Surah $surahName ($surahId), Verse $verseId:\n$verseText';
                      Share.share(shareText, subject: 'Quran Verse');
                    },
                    icon: Icon(
                      Icons.share_outlined,
                      color: Colors.grey[600],
                    ),
                    tooltip: 'Share',
                  ),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: verseText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verse copied to clipboard!')),
                      );
                    },
                    icon: Icon(
                      Icons.copy_outlined,
                      color: Colors.grey[600],
                    ),
                    tooltip: 'Copy', 
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _openVerseForReading(surahId, verseId),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Read in Quran'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'memorized':
        return Icons.check_circle_outline;
      case 'reviewing':
        return Icons.refresh;
      case 'learning':
        return Icons.school_outlined;
      default:
        return Icons.auto_stories;
    }
  }

  void _openVerseForReading(int surahId, int verseId) {
    context.pushNamed(
      Routes.verseView.name,
      queryParameters: {
        'surahId': surahId.toString(),
        'verseId': verseId.toString(),
        'isMemorizationMode': 'true',
      },
    );
  }
}
