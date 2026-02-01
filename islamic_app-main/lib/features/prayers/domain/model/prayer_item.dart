import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/common/prayers/prayer_time.dart';

class PrayerItem {
  final PrayerType type;
  final DateTime time;
  final DateTime iqamahTime;
  final int adjustment;
  final bool isCurrent;
  final bool isUpcoming;
  final bool? showDivider;
  final String adhanStatus;
  final String iqamahStatus;

  const PrayerItem({
    required this.type,
    required this.time,
    required this.iqamahTime,
    required this.isCurrent,
    required this.isUpcoming,
    this.adjustment = 0,
    this.showDivider,
    this.adhanStatus = "prediction",
    this.iqamahStatus = "prediction",
  });

  PrayerItem copyWith({
    PrayerType? type,
    DateTime? time,
    DateTime? iqamahTime,
    bool? isCurrent,
    bool? isUpcoming,
    bool? showDivider,
    int? adjustment,
    String? adhanStatus,
    String? iqamahStatus,
  }) =>
      PrayerItem(
        type: type ?? this.type,
        time: time ?? this.time,
        iqamahTime: iqamahTime ?? this.iqamahTime,
        isCurrent: isCurrent ?? this.isCurrent,
        isUpcoming: isUpcoming ?? this.isUpcoming,
        showDivider: showDivider ?? this.showDivider,
        adjustment: adjustment ?? this.adjustment,
        adhanStatus: adhanStatus ?? this.adhanStatus,
        iqamahStatus: iqamahStatus ?? this.iqamahStatus,
      );
}

PrayerItem getPrayerItem(
  PrayerType type,
  PrayerTimes prayerTimes,
  PrayerType? currentPrayer,
  PrayerType nextPrayer, {
  DateTime? time,
  DateTime? iqamahTime,
  bool? showDivider,
  int? adjustment = 0,
  String? adhanStatus = "prediction",
  String? iqamahStatus = "prediction",
}) =>
    PrayerItem(
      type: type,
      time: time ?? prayerTimes.timeForPrayer(type)!,
      iqamahTime: iqamahTime ?? prayerTimes.timeForPrayer(type)!.add(Duration(minutes: 15)),
      isCurrent: type == currentPrayer,
      isUpcoming: type == nextPrayer,
      showDivider: showDivider,
      adjustment: adjustment ?? 0,
      adhanStatus: adhanStatus ?? "prediction",
      iqamahStatus: iqamahStatus ?? "prediction",
    );
