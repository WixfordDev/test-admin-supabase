import 'package:deenhub/main.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_content_service.dart';

enum ReferenceType {
  quran,
  hadith,
  zakat,
  other,
}

/// Response class that holds both processed text and detected references
class AIResponse {
  final String text;
  final List<IslamicReference> references;

  AIResponse({required this.text, required this.references});
}

class IslamicReference {
  final ReferenceType type;
  final Map<String, dynamic> params;
  final String displayText;

  IslamicReference({
    required this.type,
    required this.params,
    required this.displayText,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'params': params,
      'displayText': displayText,
    };
  }

  factory IslamicReference.fromJson(Map<String, dynamic> json) {
    return IslamicReference(
      type: _getReferenceTypeFromString(json['type'] as String),
      params: Map<String, dynamic>.from(json['params'] as Map),
      displayText: json['displayText'] as String,
    );
  }

  static ReferenceType _getReferenceTypeFromString(String typeStr) {
    if (typeStr.contains('quran')) return ReferenceType.quran;
    if (typeStr.contains('hadith')) return ReferenceType.hadith;
    if (typeStr.contains('zakat')) return ReferenceType.zakat;
    return ReferenceType.other;
  }
}

/// Utility class to detect and extract Islamic references from text
class ReferenceDetector {
  // Static list to store detected references
  static final List<IslamicReference> _detectedReferences = [];

  // Instance of HadithContentService
  static final HadithContentService _hadithContentService = HadithContentService.instance;

  /// Process all reference types in a text and return AIResponse with processed text and references
  static Future<AIResponse> processReferences(String text) async {
    try {
      // Clear any previously detected references
      _detectedReferences.clear();

      // Detect references
      // _detectHadithReferences(text);
      _detectQuranReferences(text);
      _detectZakatReferences(text);

      // Return AIResponse with original text and references
      return AIResponse(
        text: text,
        references: List<IslamicReference>.from(_detectedReferences),
      );
    } catch (e) {
      logger.e('Error processing references: $e');
      // Return original text if error occurs
      return AIResponse(
        text: text,
        references: [],
      );
    }
  }

  /// Detect hadith references in the format [HadithBookName] [ChapterNumber]:[HadithNumber]
  static void _detectHadithReferences(String text) {
    try {
      // Use regex pattern with book names from HadithContentService
      RegExp hadithPattern = RegExp(
          "${HadithContentService.getHadithBookNamePattern()} (\\d+):(\\d+)",
          caseSensitive: false);

      final matches = hadithPattern.allMatches(text);

      for (var match in matches) {
        // Safely extract groups with null checking
        final String? bookNameGroup = match.group(1);
        final String? chapterGroup = match.group(2);
        final String? hadithNumberGroup = match.group(3);

        if (bookNameGroup == null || chapterGroup == null || hadithNumberGroup == null) continue;

        final String bookName = bookNameGroup;
        final String chapterId = chapterGroup;
        final String hadithNumber = hadithNumberGroup;
        final int? bookId = _hadithContentService.getBookIdFromName(bookName);

        if (bookId == null) continue;

        // Add reference without making API calls
        _detectedReferences.add(IslamicReference(
          type: ReferenceType.hadith,
          params: {
            'bookId': bookId.toString(),
            'chapterId': chapterId,
            'hadithId': hadithNumber,
            'collection': bookName,
          },
          displayText: '$bookName $chapterId:$hadithNumber',
        ));
      }
    } catch (e) {
      logger.e('Error detecting hadith references: $e');
    }
  }

  /// Detect Quran references in the text
  static void _detectQuranReferences(String text) {
    try {
      // Use simplest regex pattern construction with fewer special characters
      RegExp quranPattern = RegExp("(Quran|Qur'an) (\\d+):(\\d+)", caseSensitive: false);

      final matches = quranPattern.allMatches(text);

      for (var match in matches) {
        // Safe extraction with null checking
        final String? surahGroup = match.group(2);
        final String? verseGroup = match.group(3);

        if (surahGroup == null || verseGroup == null) continue;

        final String surah = surahGroup;
        final String verse = verseGroup;

        _detectedReferences.add(IslamicReference(
          type: ReferenceType.quran,
          params: {
            'surah': surah,
            'verse': verse,
          },
          displayText: 'Quran $surah:$verse',
        ));
      }
    } catch (e) {
      logger.e('Error detecting Quran references: $e');
    }
  }

  /// Detect Zakat references in the text
  static void _detectZakatReferences(String text) {
    try {
      // Simplified regex for zakat references
      RegExp zakatPattern =
          RegExp("zakat calculator|calculate zakat|zakat calculation", caseSensitive: false);

      final matches = zakatPattern.allMatches(text);

      for (var match in matches) {
        if (match.group(0) != null) {
          _detectedReferences.add(IslamicReference(
            type: ReferenceType.zakat,
            params: {},
            displayText: 'Zakat Calculator',
          ));
        }
      }
    } catch (e) {
      logger.e('Error detecting Zakat references: $e');
    }
  }
}
