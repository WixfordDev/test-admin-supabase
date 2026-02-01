import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:flutter/material.dart';

class QuranPageWidget extends StatelessWidget {
  final Surah surah;
  final double textSize;
  final Widget continuousText;
  final ScrollController? scrollController; // Add this parameter

  const QuranPageWidget({
    super.key,
    required this.surah,
    required this.textSize,
    required this.continuousText,
    this.scrollController, // Add this to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFFDE7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController, // Use the scroll controller here
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BismillahWidget(surah: surah, textSize: textSize),
                  continuousText,
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BismillahWidget extends StatelessWidget {
  final Surah surah;
  final double textSize;

  const BismillahWidget({
    super.key,
    required this.surah,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    if (surah.number == 1) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: textSize + 2,
              height: 2.0,
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (surah.number == 9) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Center(
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: textSize + 2,
                height: 2.0,
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF2E7D32).withValues(alpha: 0.4),
                  const Color(0xFF2E7D32).withValues(alpha: 0.6),
                  const Color(0xFF2E7D32).withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// import 'package:deenhub/features/quran/domain/models/quran_model.dart';
// import 'package:flutter/material.dart';
// class QuranPageWidget extends StatelessWidget {
//   final Surah surah;
//   final double textSize;
//   final Widget continuousText;

//   const QuranPageWidget({
//     super.key,
//     required this.surah,
//     required this.textSize,
//     required this.continuousText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFFFFF8E1),
//             Color(0xFFFFFDE7),
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   BismillahWidget(surah: surah, textSize: textSize),
//                   continuousText,
//                   const SizedBox(height: 100),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class BismillahWidget extends StatelessWidget {
//   final Surah surah;
//   final double textSize;

//   const BismillahWidget({
//     super.key,
//     required this.surah,
//     required this.textSize,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (surah.number == 1) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 24),
//         child: Center(
//           child: Text(
//             'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
//             style: TextStyle(
//               fontFamily: 'Amiri',
//               fontSize: textSize + 2,
//               height: 2.0,
//               color: const Color(0xFF2E7D32),
//               fontWeight: FontWeight.w600,
//             ),
//             textDirection: TextDirection.rtl,
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }

//     if (surah.number == 9) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Column(
//         children: [
//           Center(
//             child: Text(
//               'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
//               style: TextStyle(
//                 fontFamily: 'Amiri',
//                 fontSize: textSize + 2,
//                 height: 2.0,
//                 color: const Color(0xFF2E7D32),
//                 fontWeight: FontWeight.w600,
//               ),
//               textDirection: TextDirection.rtl,
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             width: double.infinity,
//             height: 2,
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.transparent,
//                   const Color(0xFF2E7D32).withValues(alpha: 0.4),
//                   const Color(0xFF2E7D32).withValues(alpha: 0.6),
//                   const Color(0xFF2E7D32).withValues(alpha: 0.4),
//                   Colors.transparent,
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(1),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }
