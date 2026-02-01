// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseProgressModel _$VerseProgressModelFromJson(Map<String, dynamic> json) =>
    VerseProgressModel(
      surahId: (json['surahId'] as num).toInt(),
      verseId: (json['verseId'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$VerseProgressModelToJson(VerseProgressModel instance) =>
    <String, dynamic>{
      'surahId': instance.surahId,
      'verseId': instance.verseId,
      'status': instance.status,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
