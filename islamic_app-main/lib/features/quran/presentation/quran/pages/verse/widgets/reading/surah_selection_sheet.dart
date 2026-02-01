import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/surah_list_widget.dart';
import 'package:flutter/material.dart';

class SurahSelectionSheet extends StatelessWidget {
  final List<Surah> surahs;
  final Function(Surah) onSurahSelected;

  const SurahSelectionSheet({
    super.key,
    required this.surahs,
    required this.onSurahSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF4CAF50),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Surah for Reading',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SurahListWidget(
              surahs: surahs,
              onSurahTap: onSurahSelected,
              expanded: true,
              isReadingMode: true,
            ),
          ),
        ],
      ),
    );
  }
}
