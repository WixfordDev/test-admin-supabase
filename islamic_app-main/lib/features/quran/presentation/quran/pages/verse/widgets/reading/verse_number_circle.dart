import 'package:flutter/material.dart';

class VerseNumberCircle extends StatelessWidget {
  final int verseNumber;
  final bool isCurrentVerse;
  final VoidCallback onTap;

  const VerseNumberCircle({
    super.key,
    required this.verseNumber,
    required this.isCurrentVerse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isCurrentVerse
                ? const Color(0xFF2E7D32)
                : const Color(0xFF757575),
            width: 1.5,
          ),
          color: isCurrentVerse
              ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Center(
          child: Text(
            _toArabicNumerals(verseNumber),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCurrentVerse
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF757575),
              fontFamily: 'Amiri',
            ),
          ),
        ),
      ),
    );
  }

  String _toArabicNumerals(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return arabicNumerals[int.parse(digit)];
    }).join('');
  }
}
