import 'package:json_annotation/json_annotation.dart';

part 'mosque_adjustment.g.dart';

@JsonSerializable()
class MosqueAdjustment {
  final String mosqueId; // Google Place ID
  final String prayerName; // Name of the prayer (e.g., "fajr", "dhuhr")
  final String timeType; // Type of time: "adhan" or "iqamah"
  final int adjustmentMinutes; // Number of minutes to adjust (positive or negative)
  final DateTime updatedAt; // When this adjustment was last updated
  // REMOVED: final String updatedBy; // No longer tracking user who made updates
  
  MosqueAdjustment({
    required this.mosqueId,
    required this.prayerName,
    required this.timeType,
    required this.adjustmentMinutes,
    required this.updatedAt,
    // REMOVED: required this.updatedBy,
  });

  factory MosqueAdjustment.fromJson(Map<String, dynamic> json) => 
      _$MosqueAdjustmentFromJson(json);
      
  Map<String, dynamic> toJson() => _$MosqueAdjustmentToJson(this);

  // Convert to database map for Supabase
  Map<String, dynamic> toDbMap() {
    return {
      'mosque_id': mosqueId,
      'prayer_name': prayerName,
      'time_type': timeType,
      'adjustment_minutes': adjustmentMinutes,
      'updated_at': updatedAt.toIso8601String(),
      // REMOVED: 'updated_by': updatedBy,
    };
  }
  
  // Create from database map
  factory MosqueAdjustment.fromDbMap(Map<String, dynamic> map) {
    return MosqueAdjustment(
      mosqueId: map['mosque_id'],
      prayerName: map['prayer_name'],
      timeType: map['time_type'] ?? 'adhan', // Default to adhan for backward compatibility
      adjustmentMinutes: map['adjustment_minutes'],
      updatedAt: DateTime.parse(map['updated_at']),
      // REMOVED: updatedBy: map['updated_by'],
    );
  }
} 