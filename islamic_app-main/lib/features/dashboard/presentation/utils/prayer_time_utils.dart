import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:easy_localization/easy_localization.dart';

class PrayerTimeUtils {
  /// Get prayer name from prayer type, handling Friday Jumaah
  static String getPrayerName(PrayerType type, {DateTime? prayerTime}) {
    // Handle Friday Jumaah case
    if (prayerTime != null &&
        prayerTime.weekday == DateTime.friday &&
        type == PrayerType.dhuhr) {
      return LocaleKeys.jumaah.tr();
    }
    return type.label;
  }

  /// Format prayer time to display in UI
  static String formatPrayerTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// Calculate remaining time until the prayer
  static String getRemainingTime(DateTime prayerTime) {
    final now = DateTime.now();
    // Use copyWith(second: 0) to match prayers_app_bar.dart calculation
    final difference = prayerTime.copyWith(second: 0).difference(now);

    if (difference.isNegative || difference.inSeconds == 0) {
      return "0m 0s";
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m ${seconds}s";
    } else if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  /// Find the next upcoming prayer from the prayer items list
  static int getUpcomingPrayerIndex(List<PrayerItem> prayerItems) {
    final now = DateTime.now();

    // First check if any prayer is marked as upcoming
    for (int i = 0; i < prayerItems.length; i++) {
      if (prayerItems[i].isUpcoming) {
        return i;
      }
    }

    // If none is marked as upcoming, find the next prayer based on time
    for (int i = 0; i < prayerItems.length; i++) {
      if (prayerItems[i].time.isAfter(now)) {
        return i;
      }
    }

    // If no prayer is upcoming today, return Fajr (first prayer)
    return 0;
  }
}
