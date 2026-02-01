// lib/widgets/memorization_by_surah_widget.dart
import 'package:flutter/material.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';

class MemorizationBySurahWidget extends StatelessWidget {
  final List<Map<String, dynamic>> memorizationBySurah;
  final QuranService quranService;
  final Function(int) onPracticeTap;
  
  const MemorizationBySurahWidget({
    super.key,
    required this.memorizationBySurah,
    required this.quranService,
    required this.onPracticeTap,
  });

  @override
  Widget build(BuildContext context) {
    // If no memorization data, show all surahs for memorization
    final List<Map<String, dynamic>> dataToShow = memorizationBySurah.isEmpty
        ? quranService.getAllSurahs().take(5).map((surah) {
            return {
              'surahId': surah.number,
              'memorizedCount': 0,
              'totalVerses': surah.ayahs.length,
              'progress': 0.0,
            };
          }).toList()
        : memorizationBySurah;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.school, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Recent Memorized Surahs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Track your progress for each surah'),
        const SizedBox(height: 16),
        
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: dataToShow.length > 3 ? 3 : dataToShow.length,
          itemBuilder: (context, index) {
            final item = dataToShow[index];
            final surah = quranService.getSurah(item['surahId']);
            final progress = item['progress'] as double;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.teal.withValues(alpha: 0.1),
                          foregroundColor: Colors.teal,
                          child: Text('${surah.number}'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    surah.englishName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    surah.name,
                                    style: const TextStyle(
                                      fontFamily: 'ScheherazadeNew',
                                      fontSize: 18,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${item['memorizedCount']} of ${item['totalVerses']} verses',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => onPracticeTap(surah.number),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal,
                            side: const BorderSide(color: Colors.teal),
                          ),
                          child: const Text('Practice'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}