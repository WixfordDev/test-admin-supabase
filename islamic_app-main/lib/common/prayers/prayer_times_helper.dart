import 'dart:collection';

import 'package:deenhub/common/calculation/prayer_calculation_method.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/common/models/coordinates.dart';
import 'package:deenhub/common/prayers/prayer_time.dart';
import 'package:deenhub/common/utils/sunnah_insights.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/hijri_date/calendar_type.dart';
import 'package:deenhub/hijri_date/hijri_date_time.dart';
import 'package:deenhub/hijri_date/hijri_date_utils.dart';

abstract class PrayerTimesHelper {
  static LinkedHashMap<HijriDateTime, List<PrayerItem>> getPrayerTimingsForRange(
    LocationData locData,
    PrayerLocationData prayerLocData,
    Iterable<PrayerType> prayerTypesList,
    HijriDateTime start,
    HijriDateTime end,
  ) {
    final timings = LinkedHashMap<HijriDateTime, List<PrayerItem>>(
      equals: (date1, date2) => isSameDay(CalendarType.hijri, date1, date2),
      hashCode: getHashCode,
    );

    for (HijriDateTime date = start; date.isBefore(end); date = date.add(const Duration(days: 1))) {
      timings[date] = getPrayerTimings(
            locData,
            prayerLocData,
            time: date.toDateTime(),
            prayerTypesList: prayerTypesList,
          ).prayerTimes ??
          [];
    }

    return timings;
  }

  static int getHashCode(HijriDateTime key) {
    return key.hDay * 1000000 + key.hMonth * 10000 + key.hYear;
  }

  static LocationData getPrayerTimings(
    LocationData locData,
    PrayerLocationData prayerLocData, {
    DateTime? time,
    Iterable<PrayerType> prayerTypesList = PrayerType.values,
    bool fetchOnlyMandatory = true,
  }) {
    final currentTime = time ?? DateTime.now();
    final prayerTimes = _getPrayerTimesInstance(currentTime, locData, prayerLocData,
        fetchOnlyMandatory: fetchOnlyMandatory);

    final currentPrayer = prayerTimes.currentPrayer(prayerTypesList, date: currentTime);
    final nextPrayer = prayerTimes.nextPrayer(prayerTypesList, date: currentTime);

    List<PrayerItem> salahItems = [];
    for (var type in prayerTypesList) {
      if (type != PrayerType.qiyam) {
        final prayer = getPrayerItem(type, prayerTimes, currentPrayer, nextPrayer);
        salahItems.add(prayer);
      }
    }

    if (!fetchOnlyMandatory) {
      final qiyamEnabled = prayerTypesList.contains(PrayerType.qiyam);
      if (currentTime.isAfter(prayerTimes.fajrStartTime!)) {
        // Next day Qiyam
        if (qiyamEnabled) {
          final qiyamNextDay = getPrayerItem(
            PrayerType.qiyam,
            prayerTimes,
            currentPrayer,
            nextPrayer,
            time: prayerTimes.qiyamNextDay,
            showDivider: true,
          );
          salahItems.add(qiyamNextDay);
        }

        if (currentTime.isAfter(prayerTimes.maghribStartTime!)) {
          final fajrNextDay = getPrayerItem(
            PrayerType.fajr,
            prayerTimes,
            currentPrayer,
            nextPrayer,
            time: prayerTimes.fajrNextDay,
            showDivider: !qiyamEnabled,
          );
          // salahItems.add(fajrNextDay);
          if (!qiyamEnabled && currentPrayer == PrayerType.isha && nextPrayer == PrayerType.fajr) {
            final fajrIndex = salahItems.indexWhere((e) => e.type == PrayerType.fajr);
            salahItems[fajrIndex] = salahItems[fajrIndex].copyWith(isUpcoming: false);
          }
        }
      } else {
        if (qiyamEnabled) {
          final qiyamCurrentDay =
              getPrayerItem(PrayerType.qiyam, prayerTimes, currentPrayer, nextPrayer);
          salahItems.insert(0, qiyamCurrentDay);
        }
      }
    }
    return locData.copyWith(
      currentTime: prayerTimes.date,
      location: prayerTimes.location,
      prayerTimes: salahItems,
    );
  }

  static PrayerTimes _getPrayerTimesInstance(
    DateTime currentTime,
    LocationData locData,
    PrayerLocationData prayerLocData, {
    bool fetchOnlyMandatory = true,
  }) {
    // logger.d("Fetching prayer times");

    final coordinates = Coordinates(prayerLocData.lat, prayerLocData.lng);
    final params = PrayerCalculationMethod.getCalculationMethod(prayerLocData.calculationMethod)
      ..madhab = prayerLocData.asrMethod
      ..adjustments = locData.adjustments.asMap().map(
            (key, value) => MapEntry(PrayerType.values.elementAt(key), value),
          );
    // logger.d("Adjust: ${locData.adjustments}\n${params.adjustments}");

    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      calcParams: params,
      precision: true,
      locationName: locData.timezone,
      dateTime: currentTime,
    );

    if (!fetchOnlyMandatory) {
      final sunnahInsights = SunnahInsights(prayerTimes);
      prayerTimes.qiyamCurrentDay = sunnahInsights.lastThirdOfTheNightCurrentDay;
      prayerTimes.qiyamNextDay = sunnahInsights.lastThirdOfTheNightNextDay;
      prayerTimes.fajrNextDay = sunnahInsights.fajrNextDay;
    }
    return prayerTimes;
  }
}
