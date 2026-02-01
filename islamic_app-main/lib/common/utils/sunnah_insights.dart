import 'package:deenhub/common/calculation/celestial_time_calculation.dart';
import 'package:deenhub/common/prayers/prayer_time.dart';

/// The [SunnahInsights] class provides calculations for middle of the night and last third of the night times.
///
/// This class calculates middle of the night and last third of the night times based on provided PrayerTimes.
/// It uses the PrayerTimes and CelestialMath classes for calculations.
///
/// The calculations are based on established CelestialMath algorithms and formulas.
/// Please refer to authoritative sources for detailed explanations and references for the calculations.
class SunnahInsights {
  // /// The time representing the middle of the night.
  DateTime? middleOfTheNight;
  // late DateTime middleOfTheNight;

  /// The time representing the last third of the night.
  DateTime? lastThirdOfTheNightCurrentDay;
  DateTime? lastThirdOfTheNightNextDay;
  DateTime? fajrNextDay;

  // late DateTime lastThirdOfTheNightCurrentDay;
  // late DateTime lastThirdOfTheNightNextDay;
  // late DateTime fajrNextDay;

  /// Constructs a `SunnahInsights` object and calculates middle of the night and last third of the night times.
  ///
  /// The calculated times are based on the provided PrayerTimes.
  ///
  /// @param prayerTimes The PrayerTimes for which Sunnah times are to be calculated.
  /// @param precision Specifies whether to round the calculated times to the nearest minute (default: true).
  SunnahInsights(PrayerTimes prayerTimes, {bool precision = true}) {
    DateTime date = prayerTimes.date;
    DateTime previousDay = CelestialTimeUtils.dateByAddingDays(date, -1);
    DateTime nextDay = CelestialTimeUtils.dateByAddingDays(date, 1);

    PrayerTimes previousDayPrayerTimes = PrayerTimes(
      coordinates: prayerTimes.coordinates,
      calcParams: prayerTimes.calcParams,
      precision: precision,
      locationName: prayerTimes.locationName,
      dateTime: previousDay,
    );
    PrayerTimes nextDayPrayerTimes = PrayerTimes(
      coordinates: prayerTimes.coordinates,
      calcParams: prayerTimes.calcParams,
      precision: precision,
      locationName: prayerTimes.locationName,
      dateTime: nextDay,
    );

    Duration nightDurationForPrevioustDay =
        (prayerTimes.fajrStartTime!.difference(previousDayPrayerTimes.maghribStartTime!));
    Duration nightDurationForNextDay =
        (nextDayPrayerTimes.fajrStartTime!.difference(prayerTimes.maghribStartTime!));

    // middleOfTheNight = CelestialTimeUtils.roundedMinute(
    //     CelestialTimeUtils.dateByAddingSeconds(prayerTimes.maghribStartTime!,
    //         (nightDuration.inSeconds / 2).floor()),
    //     precision: precision);

    fajrNextDay = nextDayPrayerTimes.fajrStartTime!;

    lastThirdOfTheNightNextDay = CelestialTimeUtils.roundedMinute(
        CelestialTimeUtils.dateByAddingSeconds(
            prayerTimes.maghribStartTime!, ((nightDurationForNextDay.inSeconds / 3) * 2).floor()),
        precision: precision);
    lastThirdOfTheNightNextDay = lastThirdOfTheNightNextDay?.add(Duration(minutes: 25));

    lastThirdOfTheNightCurrentDay = CelestialTimeUtils.roundedMinute(
        CelestialTimeUtils.dateByAddingSeconds(previousDayPrayerTimes.maghribStartTime!,
            ((nightDurationForPrevioustDay.inSeconds / 3) * 2).floor()),
        precision: precision);
    lastThirdOfTheNightCurrentDay = lastThirdOfTheNightCurrentDay?.add(Duration(minutes: 25));
  }

  SunnahInsights.middleOfTheNight(PrayerTimes prayerTimes, {bool precision = true}) {
    DateTime date = prayerTimes.date;
    DateTime nextDay = CelestialTimeUtils.dateByAddingDays(date, 1);

    PrayerTimes nextDayPrayerTimes = PrayerTimes(
      coordinates: prayerTimes.coordinates,
      calcParams: prayerTimes.calcParams,
      precision: precision,
      locationName: prayerTimes.locationName,
      dateTime: nextDay,
    );
    Duration nightDuration =
        (nextDayPrayerTimes.fajrStartTime!.difference(prayerTimes.maghribStartTime!));

    middleOfTheNight = CelestialTimeUtils.roundedMinute(
      CelestialTimeUtils.dateByAddingSeconds(
        prayerTimes.maghribStartTime!,
        (nightDuration.inSeconds / 2).floor(),
      ),
      precision: precision,
    );
  }
}
