import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:flutter/material.dart';

class SurahHeaderWidget extends StatelessWidget {
  final Surah surah;

  const SurahHeaderWidget({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          surah.name,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        Text(
          '${surah.englishName} • ${surah.ayahs.length} verses',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade100,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
