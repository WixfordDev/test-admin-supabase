import 'package:easy_localization/easy_localization.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';

/// The [HighLatitudeRule] class provides predefined rules for handling high latitudes
/// when calculating Islamic prayer times.
///
/// This class defines constants representing different strategies for determining
/// the portions of the night used for calculating prayer times in high-latitude regions.
enum HighLatitudeRule {
  /// Middle of the night rule, where Fajr and Isha are set to half the duration of the night.
  middleOfTheNight,

  /// Seventh of the night rule, where Fajr and Isha are set to one-seventh of the duration of the night.
  seventhOfTheNight,

  /// Twilight angle rule, where Fajr and Isha are determined based on specified twilight angles.
  twilightAngle;

  String get label {
    return switch (this) {
      middleOfTheNight => LocaleKeys.middleOfNight.tr(),
      seventhOfTheNight => LocaleKeys.oneSeventhNight.tr(),
      twilightAngle => LocaleKeys.angleBased.tr(),
    };
  }
}
