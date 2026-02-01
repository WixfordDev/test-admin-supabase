import 'package:deenhub/features/quran/domain/models/memorization_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verse_progress_model.g.dart';

@JsonSerializable()
class VerseProgressModel {
  final int surahId;
  final int verseId;
  final int status; // Using int instead of enum for easier database storage
  final DateTime lastUpdated;
  
  VerseProgressModel({
    required this.surahId,
    required this.verseId,
    required this.status,
    required this.lastUpdated,
  });
  
  // Convert from MemorizationStatus enum
  factory VerseProgressModel.fromStatus({
    required int surahId,
    required int verseId,
    required MemorizationStatus status,
  }) {
    return VerseProgressModel(
      surahId: surahId,
      verseId: verseId,
      status: status.index,
      lastUpdated: DateTime.now(),
    );
  }
  
  // Convert to MemorizationStatus enum
  MemorizationStatus get memorizationStatus => 
      MemorizationStatus.values[status];
  
  // JSON serialization
  factory VerseProgressModel.fromJson(Map<String, dynamic> json) => 
      _$VerseProgressModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$VerseProgressModelToJson(this);
  
  // Convert to database map
  Map<String, dynamic> toDbMap(String userId) {
    return {
      'user_id': userId,
      'surah_id': surahId,
      'verse_id': verseId,
      'status': status,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
  
  // Create from database map
  factory VerseProgressModel.fromDbMap(Map<String, dynamic> map) {
    return VerseProgressModel(
      surahId: map['surah_id'],
      verseId: map['verse_id'],
      status: map['status'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }
} 