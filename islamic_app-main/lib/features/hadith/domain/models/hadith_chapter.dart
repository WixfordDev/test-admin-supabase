import 'package:deenhub/features/hadith/domain/models/hadith.dart';

class HadithChapter {
  final int id;
  final int bookId;
  final String arabic;
  final String english;
  final List<Hadith> hadiths;
  final int length;
  final int start;
  final int end;

  HadithChapter({
    required this.id,
    required this.bookId,
    required this.arabic,
    required this.english,
    required this.hadiths,
    this.length = 0,
    this.start = 0,
    this.end = 0,
  });

  // For backwards compatibility with UI
  String get name => english;

  factory HadithChapter.fromJson(Map<String, dynamic> json) {
    final List<Hadith> hadithsList = [];
    
    if (json['hadiths'] != null) {
      for (var hadith in json['hadiths']) {
        hadithsList.add(Hadith.fromJson(hadith));
      }
    }
    
    return HadithChapter(
      id: json['id'],
      bookId: json['bookId'] ?? json['book_id'] ?? 0,
      arabic: json['arabic'] ?? '',
      english: json['english'] ?? '',
      hadiths: hadithsList,
      length: json['length'] ?? 0,
      start: json['start'] ?? 0,
      end: json['end'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'arabic': arabic,
      'english': english,
      'hadiths': hadiths.map((hadith) => hadith.toJson()).toList(),
      'length': length,
      'start': start,
      'end': end,
    };
  }
} 