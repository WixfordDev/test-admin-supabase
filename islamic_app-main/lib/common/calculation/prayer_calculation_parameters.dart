import 'package:deenhub/common/enums/high_latitude_rule.dart';
import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/common/enums/prayer_madhab.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';

/// The [PrayerCalculationParameters] class represents parameters used for calculating Islamic prayer times.
///
/// This class provides a convenient way to store various parameters and adjustments
/// required for calculating prayer times based on different methods and rules.
class PrayerCalculationParameters {
  /// The calculation method
  final PrayerCalculationMethodType method;

  /// The angle for Fajr (pre-dawn) prayer in degrees.
  late double fajrAngle;

  /// The angle for Isha (nightfall) prayer in degrees.
  late double ishaAngle;

  /// The interval between sunset and Isha prayer in minutes.
  int? ishaInterval;

  /// The angle for Maghrib (sunset) prayer in degrees.
  double? maghribAngle;

  /// The chosen madhab (school of thought) for the prayer time calculation.
  PrayerMadhab? madhab;

  /// The rule for calculating high latitude prayer times.
  HighLatitudeRule? highLatitudeRule;

  /// Adjustments for various prayer times.
  late Map<PrayerType, int> adjustments;
  // late Map<String, double> adjustments;

  /// Method-specific adjustments for various prayer times.
  late Map<PrayerType, int> methodAdjustments;
  // late Map<String, double> methodAdjustments;

  /// Creates a new `PrayerCalculationParameters` object with the specified parameters.
  ///
  /// - Parameters:
  ///   - method: The calculation method
  ///   - fajrAngle: The angle for Fajr (pre-dawn) prayer in degrees.
  ///   - ishaAngle: The angle for Isha (nightfall) prayer in degrees.
  ///   - ishaInterval: The interval between sunset and Isha prayer in minutes (optional).
  ///   - maghribAngle: The angle for Maghrib (sunset) prayer in degrees (optional).
  PrayerCalculationParameters(
    this.method, {
    double? fajrAngle,
    double? ishaAngle,
    int? ishaInterval,
    this.maghribAngle,
  }) {
    this.fajrAngle = fajrAngle ?? method.fajrAngle;
    this.ishaAngle = ishaAngle ?? method.ishaAngle;
    this.ishaInterval = ishaInterval ?? 0;
    madhab = PrayerMadhab.hanafi;
    highLatitudeRule = getIt<SharedPrefsHelper>().higherLatitudeMethod;
    // highLatitudeRule = HighLatitudeRule.middleOfTheNight;
    adjustments = {
      PrayerType.fajr: 0,
      PrayerType.sunrise: 0,
      PrayerType.dhuhr: 0,
      PrayerType.asr: 0,
      PrayerType.maghrib: 0,
      PrayerType.isha: 0
    };
    methodAdjustments = {
      PrayerType.fajr: 0,
      PrayerType.sunrise: 0,
      PrayerType.dhuhr: 0,
      PrayerType.asr: 0,
      PrayerType.maghrib: 0,
      PrayerType.isha: 0
    };
  }

  /// Determines the portions of the night for Fajr and Isha prayers based on the chosen high latitude rule.
  ///
  /// Returns a map containing the portions of the night allocated for Fajr and Isha prayers.
  Map<PrayerType, double> nightPortions() {
    return switch (highLatitudeRule) {
      HighLatitudeRule.middleOfTheNight => {
          PrayerType.fajr: 1 / 2,
          PrayerType.isha: 1 / 2
        },
      HighLatitudeRule.seventhOfTheNight => {
          PrayerType.fajr: 1 / 7,
          PrayerType.isha: 1 / 7
        },
      HighLatitudeRule.twilightAngle => {
          PrayerType.fajr: fajrAngle / 60,
          PrayerType.isha: ishaAngle / 60
        },
      _ =>
        throw ('Invalid high latitude rule found when attempting to compute night portions: $highLatitudeRule')
    };
  }
}
