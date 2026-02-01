class Hadith {
  final int id;
  final int idInBook;
  final int chapterId;
  final int bookId;
  final String arabic;
  final Map<String, dynamic> english;
  final double? score;

  // Computed properties for easier access
  String get number => idInBook.toString();
  String get arabicText => arabic;
  String get translation => english['text'] ?? '';
  String get narrator => english['narrator'] ?? '';
  String get fullText => '$translation$narrator';

  // Grade extraction logic
  String get grade {
    // For Bukhari (id: 1) and Muslim (id: 2), all hadiths are considered Sahih
    if (bookId == 1 || bookId == 2) {
      return 'Sahih';
    }

    // For other books, check if the translation contains grade information
    final text = translation;
    if (text.contains('(Sahih)')) return 'Sahih';
    if (text.contains('(Hasan)')) return 'Hasan';
    if (text.contains('(Da\'if)') || text.contains('(Daif)') || text.contains('(Weak)')) {
      return 'Da\'if';
    }
    if (text.contains('(Maudu)') || text.contains('(Fabricated)')) return 'Maudu';

    // If no grade information is found, return empty string
    return '';
  }

  // Convenience getters
  String get narratorText => english['narrator'] ?? '';
  String get translationText => english['text'] ?? '';

  const Hadith({
    required this.id,
    required this.idInBook,
    required this.chapterId,
    required this.bookId,
    required this.arabic,
    required this.english,
    this.score,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'],
      idInBook: json['idInBook'],
      chapterId: json['chapterId'],
      bookId: json['bookId'],
      arabic: json['arabic'],
      english: json['english'],
    );
  }

  factory Hadith.fromJsonSupabase(Map<String, dynamic> json) {
    final idInBook = json['idInBook'] ?? json['idinbook'] ?? 0;
    return Hadith(
      id: json['id'] ?? idInBook,
      idInBook: idInBook,
      chapterId: json['chapterId'] ?? json['chapterid'] ?? 0,
      bookId: json['bookId'] ?? json['bookid'] ?? 0,
      arabic: json['arabic'] ?? '',
      english: {
        'narrator': json['english_narrator'] ?? '',
        'text': json['english_text'] ?? '',
      },
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idInBook': idInBook,
      'chapterId': chapterId,
      'bookId': bookId,
      'arabic': arabic,
      'english': english,
    };
  }
}
