class Dua {
  final int id;
  final String title;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String reference;
  final String category;
  final String? subcategory;
  final bool isFavorite;

  Dua({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.reference,
    required this.category,
    this.subcategory,
    this.isFavorite = false,
  });

  Dua copyWith({
    int? id,
    String? title,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? reference,
    String? category,
    String? subcategory,
    bool? isFavorite,
  }) {
    return Dua(
      id: id ?? this.id,
      title: title ?? this.title,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      reference: reference ?? this.reference,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
} 