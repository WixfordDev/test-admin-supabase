// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mosque_adjustment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MosqueAdjustment _$MosqueAdjustmentFromJson(Map<String, dynamic> json) =>
    MosqueAdjustment(
      mosqueId: json['mosqueId'] as String,
      prayerName: json['prayerName'] as String,
      timeType: json['timeType'] as String,
      adjustmentMinutes: (json['adjustmentMinutes'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MosqueAdjustmentToJson(MosqueAdjustment instance) =>
    <String, dynamic>{
      'mosqueId': instance.mosqueId,
      'prayerName': instance.prayerName,
      'timeType': instance.timeType,
      'adjustmentMinutes': instance.adjustmentMinutes,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
