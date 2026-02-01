import 'package:deenhub/common/enums/prayer_madhab.dart';

/// The [PrayerTimeCalculator] class provides utilities for calculating shadow length based on a specified madhab.
///
/// This class contains methods for determining the shadow length used for calculating Asr prayer time
/// based on the chosen madhab (school of thought).
class PrayerTimeCalculator {
  /// Calculates the shadow length for Asr prayer time based on the specified madhab.
  ///
  /// The `madhab` parameter should be a valid madhab constant from the `PrayerMadhab` class.
  ///
  /// Returns the shadow length in terms of times the object's height.
  static double shadowLength(PrayerMadhab? madhab) => switch (madhab) {
        PrayerMadhab.shafi => 1,
        PrayerMadhab.hanafi => 2,
        _ => throw "Invalid Madhab"
      };
}
