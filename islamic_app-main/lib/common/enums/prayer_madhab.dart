import 'package:easy_localization/easy_localization.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';

/// The [PrayerMadhab] class provides predefined madhabs (schools of thought) for Islamic prayer time calculations.
///
/// This class defines constants representing different madhabs that can be used for adjusting prayer times.
enum PrayerMadhab {
  /// The Shafi madhab for Islamic prayer time calculations.
  shafi,

  /// The Hanafi madhab for Islamic prayer time calculations.
  hanafi,
  ;

  String get label {
    return switch (this) {
      shafi => LocaleKeys.asrStandar.tr(),
      hanafi => LocaleKeys.asrHanafi.tr(),
    };
  }

  String get subtitle {
    return switch (this) {
      shafi => LocaleKeys.asrStandarSum.tr(),
      hanafi => LocaleKeys.asrHanafiSum.tr(),
    };
  }
}

PrayerMadhab getPrayerMadhab(double lat, double lng) {
  // South Asian countries (Hanafi)
  if ((lat >= 5 && lat <= 40) && (lng >= 60 && lng <= 100)) {
    return PrayerMadhab.hanafi;
  }

  // Southeast Asia, East Africa, and Yemen (Shafi)
  return PrayerMadhab.shafi;
}
