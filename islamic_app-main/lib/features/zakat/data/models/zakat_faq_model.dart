import 'package:json_annotation/json_annotation.dart';

part 'zakat_faq_model.g.dart';

@JsonSerializable()
class ZakatFAQModel {
  final String category;
  final String question;
  final String answer;
  final QuranReference? quranReference;
  final HadithReference? hadithReference;

  ZakatFAQModel({
    required this.category,
    required this.question,
    required this.answer,
    this.quranReference,
    this.hadithReference,
  });

  factory ZakatFAQModel.fromJson(Map<String, dynamic> json) => _$ZakatFAQModelFromJson(json);
  Map<String, dynamic> toJson() => _$ZakatFAQModelToJson(this);
}

@JsonSerializable()
class QuranReference {
  final String surah;
  final int surahNumber;
  final int verseNumber;
  final String quote;

  QuranReference({
    required this.surah,
    required this.surahNumber,
    required this.verseNumber,
    required this.quote,
  });

  factory QuranReference.fromJson(Map<String, dynamic> json) => _$QuranReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$QuranReferenceToJson(this);
}

@JsonSerializable()
class HadithReference {
  final String source;
  final String quote;

  HadithReference({
    required this.source,
    required this.quote,
  });

  factory HadithReference.fromJson(Map<String, dynamic> json) => _$HadithReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$HadithReferenceToJson(this);
}
