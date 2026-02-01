// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zakat_faq_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZakatFAQModel _$ZakatFAQModelFromJson(Map<String, dynamic> json) =>
    ZakatFAQModel(
      category: json['category'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      quranReference: json['quranReference'] == null
          ? null
          : QuranReference.fromJson(
              json['quranReference'] as Map<String, dynamic>,
            ),
      hadithReference: json['hadithReference'] == null
          ? null
          : HadithReference.fromJson(
              json['hadithReference'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ZakatFAQModelToJson(ZakatFAQModel instance) =>
    <String, dynamic>{
      'category': instance.category,
      'question': instance.question,
      'answer': instance.answer,
      'quranReference': instance.quranReference,
      'hadithReference': instance.hadithReference,
    };

QuranReference _$QuranReferenceFromJson(Map<String, dynamic> json) =>
    QuranReference(
      surah: json['surah'] as String,
      surahNumber: (json['surahNumber'] as num).toInt(),
      verseNumber: (json['verseNumber'] as num).toInt(),
      quote: json['quote'] as String,
    );

Map<String, dynamic> _$QuranReferenceToJson(QuranReference instance) =>
    <String, dynamic>{
      'surah': instance.surah,
      'surahNumber': instance.surahNumber,
      'verseNumber': instance.verseNumber,
      'quote': instance.quote,
    };

HadithReference _$HadithReferenceFromJson(Map<String, dynamic> json) =>
    HadithReference(
      source: json['source'] as String,
      quote: json['quote'] as String,
    );

Map<String, dynamic> _$HadithReferenceToJson(HadithReference instance) =>
    <String, dynamic>{'source': instance.source, 'quote': instance.quote};
