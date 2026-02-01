import 'package:deenhub/features/hadith/domain/models/hadith_chapter.dart';

class HadithBook {
  final int id;
  final Map<String, dynamic> metadata;
  final List<HadithChapter> chapters;
  int totalChapters = 0;
  int totalHadiths = 0;

  HadithBook({
    required this.id,
    required this.metadata,
    required this.chapters,
  });

  // Computed properties for backward compatibility with UI
  String get name => metadata['english']['title'] ?? '';
  String get arabicName => metadata['arabic']['title'] ?? '';
  String get author => metadata['english']['author'] ?? '';
  String get arabicAuthor => metadata['arabic']['author'] ?? '';
  String get description => metadata['english']['introduction'] ?? '';
  String get arabicDescription => metadata['arabic']['introduction'] ?? '';

  factory HadithBook.fromJson(Map<String, dynamic> json) {
    return HadithBook(
      id: json['id'],
      metadata: json['metadata'] ?? {},
      chapters: (json['chapters'] as List? ?? [])
          .map((chapter) => HadithChapter.fromJson(chapter))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metadata': metadata,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    };
  }
} 