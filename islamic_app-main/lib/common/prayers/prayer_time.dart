import 'package:deenhub/common/calculation/celestial_time_calculation.dart';
import 'package:deenhub/common/calculation/prayer_calculation_parameters.dart';
import 'package:deenhub/common/celestial/celestial_math.dart';
import 'package:deenhub/common/celestial/stellar_moment.dart';
import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/common/enums/prayer_madhab.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/common/models/coordinates.dart';
import 'package:deenhub/common/prayers/prayer_time_calculator.dart';
import 'package:deenhub/common/prayers/prayer_time_converter.dart';
import 'package:deenhub/core/utils/date_time_utils.dart';

import 'package:timezone/timezone.dart' as tz;

/// The [PrayerTimes] class calculates prayer times based on provided coordinates, date, and calculation parameters.
///
/// This class uses the CelestialMath and StellarMoment classes for calculations.
///
/// The calculations are based on established CelestialMath algorithms and formulas.
/// Please refer to authoritative sources for detailed explanations and references for the calculations.
class PrayerTimes {
  /// The geographic coordinates (latitude and longitude) of the location for which prayer times are calculated.
  late Coordinates coordinates;

  /// The date for which the prayer times are being calculated.
  late DateTime date;
  late tz.Location location;

  /// The calculation parameters used to determine the prayer times.
  late PrayerCalculationParameters calcParams;

  /// The time for the Fajr (pre-dawn) prayer's start and end.
  DateTime? fajrStartTime;
  DateTime? fajrEndTime;

  /// The time for the Sehri (pre-dawn meal) corresponding to Fajr.
  DateTime? sehri;

  /// The time for the Sunrise prayer.
  DateTime? sunrise;

  DateTime? duha;

  /// The time for the Dhuhr (noon) prayer's start and end.
  DateTime? dhuhrStartTime;
  DateTime? dhuhrEndTime;

  /// The time for the Asr (afternoon) prayer's start and end.
  DateTime? asrStartTime;
  DateTime? asrEndTime;

  /// The time for the Maghrib (evening) prayer's start and end.
  DateTime? maghribStartTime;
  DateTime? maghribEndTime;

  /// The time for the Isha (night) prayer's start and end.
  DateTime? ishaStartTime;
  DateTime? ishaEndTime;
  DateTime? tahajjudEndTime;
  DateTime? midnight;

  /// Qiyam
  DateTime? qiyamCurrentDay;
  DateTime? qiyamNextDay;
  DateTime? fajrNextDay;

  /// The name of the location for which the prayer times are being calculated.
  final String locationName;

  /// Constructs a `PrayerTimes` object and calculates Islamic prayer times based on the provided parameters.
  ///
  /// The calculated prayer times are based on the provided coordinates, date, and calculation parameters.
  ///
  /// @param coordinates The geographic coordinates (latitude and longitude) of the location.
  /// @param calculationParameters The calculation parameters used for determining prayer times.
  /// @param precision Specifies whether to round the calculated times to the nearest minute (default: false).
  /// @param locationName The name of the location for which prayer times are being calculated.
  /// @param dateTime The specific date and time for which to calculate prayer times (default: current date and time).
  PrayerTimes({
    required this.coordinates,
    required this.calcParams,
    bool precision = false,
    required this.locationName,
    DateTime? dateTime,
  }) {
    // tz.initializeTimeZones();
    location = tz.getLocation(locationName);
    DateTime date = tz.TZDateTime.from(dateTime ?? DateTime.now(), location);
    this.date = date;

    // Calculate StellarMoment objects for the current date and adjacent days
    DateTime dateBefore = date.subtract(const Duration(days: 1));
    DateTime dateAfter = date.add(const Duration(days: 1));
    StellarMoment solarTime = StellarMoment(date, coordinates);
    StellarMoment solarTimeBefore = StellarMoment(dateBefore, coordinates);
    StellarMoment solarTimeAfter = StellarMoment(dateAfter, coordinates);

    // Calculate various time components using StellarMoment calculations
    DateTime fajrTime;
    DateTime asrTime;
    DateTime maghribTime;
    DateTime ishaTime;
    DateTime ishabeforeTime;
    DateTime fajrafterTime;
    double? nightFraction;
    DateTime dhuhrTime =
        PrayerTimeConverter(solarTime.transit).utcDate(date.year, date.month, date.day);
    DateTime sunriseTime =
        PrayerTimeConverter(solarTime.sunrise).utcDate(date.year, date.month, date.day);
    DateTime sunsetTime =
        PrayerTimeConverter(solarTime.sunset).utcDate(date.year, date.month, date.day);
    DateTime sunriseafterTime = PrayerTimeConverter(solarTimeAfter.sunrise)
        .utcDate(dateAfter.year, dateAfter.month, dateAfter.day);
    DateTime sunsetbeforeTime = PrayerTimeConverter(solarTimeBefore.sunset)
        .utcDate(dateBefore.year, dateBefore.month, dateBefore.day);

    // Calculate Asr time based on shadow length and madhab
    asrTime = PrayerTimeConverter(
            solarTime.afternoon(PrayerTimeCalculator.shadowLength(calcParams.madhab)))
        .utcDate(date.year, date.month, date.day);

    DateTime tomorrow = CelestialTimeUtils.dateByAddingDays(date, 1);
    var tomorrowStellarMoment = StellarMoment(tomorrow, coordinates);
    DateTime tomorrowSunrise = PrayerTimeConverter(tomorrowStellarMoment.sunrise)
        .utcDate(tomorrow.year, tomorrow.month, tomorrow.day);
    int night = (tomorrowSunrise.difference(sunsetTime)).inSeconds;

    // Calculate Fajr times
    fajrTime = PrayerTimeConverter(solarTime.hourAngle(-1 * calcParams.fajrAngle, false))
        .utcDate(date.year, date.month, date.day);
    fajrafterTime = PrayerTimeConverter(solarTimeAfter.hourAngle(-1 * calcParams.fajrAngle, false))
        .utcDate(dateAfter.year, dateAfter.month, dateAfter.day);

    // Special case for moonsighting committee above latitude 55
    if (calcParams.method == PrayerCalculationMethodType.moonsightingCommittee &&
        coordinates.latitude >= 55) {
      nightFraction = night / 7;
      fajrTime = CelestialTimeUtils.dateByAddingSeconds(sunriseTime, -nightFraction.round());
      fajrafterTime =
          CelestialTimeUtils.dateByAddingSeconds(sunriseafterTime, -nightFraction.round());
    }

    // Calculate safe Fajr time adjustments
    DateTime safeFajr() {
      if (calcParams.method == PrayerCalculationMethodType.moonsightingCommittee) {
        return CelestialMath.seasonAdjustedMorningTwilight(
            coordinates.latitude, CelestialTimeUtils.dayOfYear(date), date.year, sunriseTime);
      } else {
        var portion = calcParams.nightPortions()[PrayerType.fajr];
        nightFraction = (portion ?? 1) * night;
        return CelestialTimeUtils.dateByAddingSeconds(sunriseTime, -nightFraction!.round());
      }
    }

    // // Calculate safe Fajr time adjustments after sunrise
    // DateTime safeFajrAfter() {
    //   if (calculationParameters.method == "MoonsightingCommittee") {
    //     return CelestialMath.seasonAdjustedMorningTwilight(coordinates.latitude, CelestialTimeUtils.dayOfYear(date), date.year, sunriseTime);
    //   } else {
    //     var portion = calculationParameters.nightPortions()[PrayerType.fajr];
    //     nightFraction = (portion ?? 1) * night;
    //     return CelestialTimeUtils.dateByAddingSeconds(sunriseTime, -nightFraction!.round());
    //   }
    // }

    //Apply safe Fajr time adjustments
    if (safeFajr().isAfter(fajrTime)) {
      fajrTime = safeFajr();
    }

    if (safeFajr().isAfter(fajrafterTime)) {
      fajrafterTime = safeFajr();
    }

    // Calculate Isha times based on interval and angle
    if (calcParams.ishaInterval != null && calcParams.ishaInterval! > 0) {
      ishaTime = CelestialTimeUtils.dateByAddingMinutes(sunsetTime, calcParams.ishaInterval ?? 0);
      ishabeforeTime =
          CelestialTimeUtils.dateByAddingMinutes(sunsetbeforeTime, calcParams.ishaInterval ?? 0);
    } else {
      ishaTime = PrayerTimeConverter(solarTime.hourAngle(-1 * calcParams.ishaAngle, true))
          .utcDate(date.year, date.month, date.day);
      ishabeforeTime =
          PrayerTimeConverter(solarTimeBefore.hourAngle(-1 * calcParams.ishaAngle, true))
              .utcDate(dateBefore.year, dateBefore.month, dateBefore.day);

      // Special case for moonsighting committee above latitude 55
      if (calcParams.method == PrayerCalculationMethodType.moonsightingCommittee &&
          coordinates.latitude >= 55) {
        nightFraction = night / 7;
        ishaTime = CelestialTimeUtils.dateByAddingSeconds(sunsetTime, nightFraction!.round());
        ishabeforeTime =
            CelestialTimeUtils.dateByAddingSeconds(sunsetbeforeTime, nightFraction!.round());
      }

      // Calculate safe Isha time adjustments
      DateTime safeIsha() {
        if (calcParams.method == PrayerCalculationMethodType.moonsightingCommittee) {
          return CelestialMath.seasonAdjustedEveningTwilight(
              coordinates.latitude, CelestialTimeUtils.dayOfYear(date), date.year, sunsetTime);
        } else {
          var portion = calcParams.nightPortions()[PrayerType.isha];
          nightFraction = (portion ?? 1) * night;
          return CelestialTimeUtils.dateByAddingSeconds(sunsetTime, nightFraction!.round());
        }
      }

      // Calculate safe Isha time adjustments before sunset
      DateTime safeIshaBefore() {
        if (calcParams.method == PrayerCalculationMethodType.moonsightingCommittee) {
          return CelestialMath.seasonAdjustedEveningTwilight(
              coordinates.latitude, CelestialTimeUtils.dayOfYear(date), date.year, sunsetTime);
        } else {
          var portion = calcParams.nightPortions()[PrayerType.isha];
          nightFraction = (portion ?? 1) * night;
          return CelestialTimeUtils.dateByAddingSeconds(sunsetTime, nightFraction!.round());
        }
      }

      // Apply safe Isha time adjustments
      if (safeIsha().isBefore(ishaTime)) {
        ishaTime = safeIsha();
      }

      if (safeIshaBefore().isBefore(ishabeforeTime)) {
        ishabeforeTime = safeIshaBefore();
      }
    }

    // Calculate Maghrib time based on angle
    maghribTime = sunsetTime;
    if (calcParams.maghribAngle != null) {
      DateTime angleBasedMaghrib =
          PrayerTimeConverter(solarTime.hourAngle(-1 * calcParams.maghribAngle!, true))
              .utcDate(date.year, date.month, date.day);
      if (sunsetTime.isBefore(angleBasedMaghrib) && ishaTime.isAfter(angleBasedMaghrib)) {
        maghribTime = angleBasedMaghrib;
      }
    }

    // Apply adjustments for each prayer time
    int fajrAdjustment = adjustmentTime(PrayerType.fajr, calcParams);
    int sunriseAdjustment = adjustmentTime(PrayerType.sunrise, calcParams);
    int dhuhrAdjustment = adjustmentTime(PrayerType.dhuhr, calcParams);
    int asrAdjustment = adjustmentTime(PrayerType.asr, calcParams);
    int maghribAdjustment = adjustmentTime(PrayerType.maghrib, calcParams);
    int ishaAdjustment = adjustmentTime(PrayerType.isha, calcParams);

    // fajr
    fajrStartTime = _getTime(fajrTime, fajrAdjustment, precision, location);
    ishaEndTime = _getTime(fajrafterTime, fajrAdjustment, precision, location);
    tahajjudEndTime = _getTime(fajrTime, fajrAdjustment, precision, location);
    fajrStartTime = fajrStartTime?.add(Duration(minutes: 2));

    // sunrise
    sunrise = _getTime(sunriseTime, sunriseAdjustment, precision, location);
    // sunrise = sunrise?.add(Duration(minutes: -1));
    fajrEndTime = _getTime(sunriseTime, sunriseAdjustment, precision, location);

    // dhuhr and asr
    dhuhrStartTime = _getTime(dhuhrTime, dhuhrAdjustment, precision, location);
    dhuhrStartTime = dhuhrStartTime?.add(Duration(minutes: 0));

    asrStartTime = _getTime(asrTime, asrAdjustment, precision, location);
    asrStartTime = asrStartTime?.add(Duration(minutes: 1));
    dhuhrEndTime = _getTime(asrTime, asrAdjustment, precision, location);

    // magrid and isha
    maghribStartTime = _getTime(maghribTime, maghribAdjustment, precision, location);
    maghribStartTime = maghribStartTime?.add(Duration(minutes: 1));
    asrEndTime = _getTime(maghribTime, maghribAdjustment, precision, location);
    ishaStartTime = _getTime(ishaTime, ishaAdjustment, precision, location);
    ishaStartTime = ishaStartTime?.add(Duration(minutes: 1));

    //  fajrafter = tz.TZDateTime.from(CelestialTimeUtils.roundedMinute(CelestialTimeUtils.dateByAddingMinutes(fajrafterTime, fajrAdjustment), precision: precision), location);
    // ishabefore = tz.TZDateTime.from(CelestialTimeUtils.roundedMinute(CelestialTimeUtils.dateByAddingMinutes(ishabeforeTime, ishaAdjustment), precision: precision), location);
    maghribEndTime = _getTime(ishaTime, ishaAdjustment, precision, location);

    // final sunnahInsights = SunnahInsights.middleOfTheNight(this);
    // midnight = sunnahInsights.middleOfTheNight;

    Duration nightDuration = (fajrStartTime!.difference(maghribStartTime!));
    midnight = CelestialTimeUtils.roundedMinute(
      CelestialTimeUtils.dateByAddingSeconds(
        maghribStartTime!,
        (nightDuration.inSeconds / 2).floor(),
      ),
      precision: precision,
    );
  }

  static List<String> getAsrTimes({
    required coordinates,
    required calculationParameters,
    bool precision = true,
    required locationName,
    DateTime? dateTime,
  }) {
    // tz.initializeTimeZones();
    final location = tz.getLocation(locationName);
    DateTime date = tz.TZDateTime.from(dateTime ?? DateTime.now(), location);

    // Calculate StellarMoment objects for the current date and adjacent days
    StellarMoment solarTime = StellarMoment(date, coordinates);

    // Calculate Asr time based on shadow length and madhab
    DateTime asrTimeShafi = PrayerTimeConverter(
            solarTime.afternoon(PrayerTimeCalculator.shadowLength(PrayerMadhab.shafi)))
        .utcDate(date.year, date.month, date.day);
    DateTime asrTimeHanafi = PrayerTimeConverter(
            solarTime.afternoon(PrayerTimeCalculator.shadowLength(PrayerMadhab.hanafi)))
        .utcDate(date.year, date.month, date.day);

    int asrAdjustment = adjustmentTime(PrayerType.asr, calculationParameters);

    final asrStartTimeShafi = _getTime(asrTimeShafi, asrAdjustment, precision, location);
    final asrStartTimeHanafi = _getTime(asrTimeHanafi, asrAdjustment, precision, location);
    return [
      asrStartTimeShafi?.time() ?? '',
      asrStartTimeHanafi?.time() ?? '',
    ];
  }

  static int adjustmentTime(PrayerType type, PrayerCalculationParameters calculationParameters) {
    return (calculationParameters.adjustments[type] ?? 0) +
        (calculationParameters.methodAdjustments[type] ?? 0);
  }

  static DateTime? _getTime(
    DateTime prayerTime,
    int prayerAdjustment,
    bool precision,
    tz.Location location,
  ) =>
      tz.TZDateTime.from(
        CelestialTimeUtils.roundedMinute(
          CelestialTimeUtils.dateByAddingMinutes(prayerTime, prayerAdjustment),
          precision: precision,
        ),
        location,
      );

  /// Returns the calculated time for the specified prayer.
  ///
  /// @param prayer The prayer for which to retrieve the time (e.g., Prayer.Fajr).
  /// @return The calculated DateTime for the specified prayer, or null if the prayer is not recognized.
  DateTime? timeForPrayer(PrayerType prayer) {
    return switch (prayer) {
      // PrayerType.imsak => sehri, //
      PrayerType.fajr => fajrStartTime,
      PrayerType.sunrise => sunrise,
      // PrayerType.duha => duha, //
      PrayerType.dhuhr => dhuhrStartTime,
      PrayerType.asr => asrStartTime,
      PrayerType.maghrib => maghribStartTime,
      PrayerType.isha => ishaStartTime,
      // PrayerType.midnight => midnight, //
      PrayerType.qiyam => qiyamCurrentDay,
      // PrayerType.IshaBefore => ishabefore,
      // PrayerType.FajrAfter => fajrafter,
    };
  }

  /// Returns the current prayer based on the provided date.
  ///
  /// @param date The DateTime for which to determine the current prayer.
  /// @return The current prayer (e.g., Prayer.Fajr, Prayer.Sunrise), or Prayer.IshaBefore if none of the prayers match.
  PrayerType? currentPrayer(Iterable<PrayerType> prayerTypesList, {DateTime? date}) {
    date ??= DateTime.now();
    if (date.isAfter(ishaStartTime!)) {
      return PrayerType.isha;
    } else if (date.isAfter(maghribStartTime!)) {
      return PrayerType.maghrib;
    } else if (date.isAfter(asrStartTime!)) {
      return PrayerType.asr;
    } else if (date.isAfter(dhuhrStartTime!)) {
      return PrayerType.dhuhr;
    } else if (date.isAfter(sunrise!)) {
      return null;
      // return PrayerType.shuruq;
    } else if (date.isAfter(fajrStartTime!)) {
      return PrayerType.fajr;
    } else {
      if (prayerTypesList.contains(PrayerType.qiyam)) {
        return PrayerType.qiyam;
      } else {
        return PrayerType.fajr;
      }
      // return PrayerType.ishaBefore;
    }
  }

  /// Returns the next prayer based on the provided date.
  ///
  /// @param date The DateTime for which to determine the next prayer.
  /// @return The next prayer (e.g., Prayer.FajrAfter, Prayer.Isha), or Prayer.Fajr if none of the prayers match.
  PrayerType nextPrayer(Iterable<PrayerType> prayerTypesList, {DateTime? date}) {
    date ??= DateTime.now();
    if (date.isAfter(ishaStartTime!)) {
      if (prayerTypesList.contains(PrayerType.qiyam)) {
        return PrayerType.qiyam;
      } else {
        return PrayerType.fajr;
      }
    } else if (date.isAfter(maghribStartTime!)) {
      return PrayerType.isha;
    } else if (date.isAfter(asrStartTime!)) {
      return PrayerType.maghrib;
    } else if (date.isAfter(dhuhrStartTime!)) {
      return PrayerType.asr;
    } else if (date.isAfter(sunrise!)) {
      return PrayerType.dhuhr;
    } else if (date.isAfter(fajrStartTime!)) {
      if (prayerTypesList.contains(PrayerType.sunrise)) {
        return PrayerType.sunrise;
      } else {
        return PrayerType.dhuhr;
      }
    } else if (qiyamCurrentDay != null && date.isAfter(qiyamCurrentDay!)) {
      return PrayerType.fajr;
    } else {
      if (prayerTypesList.contains(PrayerType.qiyam)) {
        return PrayerType.qiyam;
      } else {
        return PrayerType.fajr;
      }
    }
  }
}
