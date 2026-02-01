// lib/widgets/recently_read_widget.dart
import 'package:flutter/material.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/features/quran/data/repository/memorization_service.dart';
import 'package:deenhub/features/quran/domain/models/memorization_model.dart';

class RecentlyReadWidget extends StatefulWidget {
  final QuranService quranService;
  final Function(int, int) onItemTap;
  final MemorizationService memorizationService;

  const RecentlyReadWidget({
    super.key,
    required this.quranService,
    required this.onItemTap,
    required this.memorizationService,
  });

  @override
  State<RecentlyReadWidget> createState() => _RecentlyReadWidgetState();
}

class _RecentlyReadWidgetState extends State<RecentlyReadWidget> {
  List<RecentlyRead> _recentlyReadItems = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadReadingModeEntries();
  }
  
  Future<void> _loadReadingModeEntries() async {
    try {
      // Get only entries with 'reading_mode' source
      final entries = await widget.memorizationService.getRecentlyRead(source: 'reading_mode');
      
      if (mounted) {
        setState(() {
          _recentlyReadItems = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reading mode entries: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_recentlyReadItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Recently Read',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _recentlyReadItems.length > 3 ? 3 : _recentlyReadItems.length,
          itemBuilder: (context, index) {
            final item = _recentlyReadItems[index];
            final surah = widget.quranService.getSurah(item.surahId);
            final ayah = surah.ayahs.firstWhere(
              (a) => a.numberInSurah == item.verseId,
              orElse: () => surah.ayahs.first,
            );

            return Card(
              margin: EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
              child: InkWell(
                onTap: () => widget.onItemTap(surah.number, ayah.numberInSurah),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Surah number
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${surah.number}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Surah info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah.englishName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Verse ${ayah.numberInSurah}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Time info
                      Text(
                        _formatTimestamp(item.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 24) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} mins ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
