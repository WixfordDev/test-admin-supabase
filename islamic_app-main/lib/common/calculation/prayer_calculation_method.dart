import 'package:deenhub/common/calculation/prayer_calculation_parameters.dart';
import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/common/enums/prayer_types.dart';

/// The [PrayerCalculationMethod] class provides predefined calculation methods for determining Islamic prayer times.
///
/// This class offers a collection of well-known calculation methods used by various organizations and regions
/// to calculate prayer times based on different conventions and rules.
class PrayerCalculationMethod {
  /// Load all calculation methods
  static List<PrayerCalculationParameters> loadAllCalculationMethods() => [
    initCustom(),
    initEgyptian(),
    initNorthAmerica(),
    initMoonsightingCommittee(),
    initMuslimWorldLeague(),
    initUmmAlQura(),
    initKarachi(),
    initMalaysia(),
    initSingapore(),
    initIndonesia(),
    initTurkey(),
    initFrance(),
  ];

  /// Init calculation method based on [PrayerCalculationMethodType]
  static PrayerCalculationParameters getCalculationMethod(
    PrayerCalculationMethodType type,
  ) => switch (type) {
    PrayerCalculationMethodType.custom => initCustom(),
    PrayerCalculationMethodType.egyptian => initEgyptian(),
    PrayerCalculationMethodType.northAmerica => initNorthAmerica(),
    PrayerCalculationMethodType.moonsightingCommittee =>
      initMoonsightingCommittee(),
    PrayerCalculationMethodType.muslimWorldLeague => initMuslimWorldLeague(),
    PrayerCalculationMethodType.ummAlQura => initUmmAlQura(),
    PrayerCalculationMethodType.karachi => initKarachi(),
    PrayerCalculationMethodType.malaysia => initMalaysia(),
    PrayerCalculationMethodType.singapore => initSingapore(),
    PrayerCalculationMethodType.indonesia => initIndonesia(),
    PrayerCalculationMethodType.turkey => initTurkey(),
    PrayerCalculationMethodType.france => initFrance(),
  };

  static PrayerCalculationParameters initCustom({
    double? fajrAngle,
    double? ishaAngle,
  }) => PrayerCalculationParameters(
    PrayerCalculationMethodType.custom,
    fajrAngle: fajrAngle,
    ishaAngle: ishaAngle,
  );

  static PrayerCalculationParameters initEgyptian() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.egyptian,
    );
    params.methodAdjustments = {PrayerType.dhuhr: 1};
    return params;
  }

  static PrayerCalculationParameters initNorthAmerica() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.northAmerica,
    );
    params.methodAdjustments = {PrayerType.dhuhr: 1};
    return params;
  }

  static PrayerCalculationParameters initMoonsightingCommittee() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.moonsightingCommittee,
    );
    params.methodAdjustments = {PrayerType.dhuhr: 5, PrayerType.maghrib: 3};
    return params;
  }

  static PrayerCalculationParameters initMuslimWorldLeague() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.muslimWorldLeague,
    );
    params.methodAdjustments = {PrayerType.dhuhr: 1};
    return params;
  }

  static PrayerCalculationParameters initUmmAlQura() {
    return PrayerCalculationParameters(
      PrayerCalculationMethodType.ummAlQura,
      ishaInterval: 90,
    );
  }

  static PrayerCalculationParameters initKarachi() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.karachi,
    );
    params.methodAdjustments = {PrayerType.dhuhr: 1};
    return params;
  }

  static PrayerCalculationParameters initMalaysia() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.malaysia,
    );
    params.methodAdjustments = {PrayerType.dhuhr: 1};
    return params;
  }

  static PrayerCalculationParameters initSingapore() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.singapore,
    );
    params.methodAdjustments = {PrayerType.dhuhr: 1};
    return params;
  }

  static PrayerCalculationParameters initIndonesia() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.indonesia,
    );
    params.methodAdjustments = {PrayerType.dhuhr: 1};
    return params;
  }

  static PrayerCalculationParameters initTurkey() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.turkey,
    );
    params.methodAdjustments = {
      PrayerType.sunrise: -7,
      PrayerType.dhuhr: 5,
      PrayerType.asr: 4,
      PrayerType.maghrib: 7,
    };
    return params;
  }

  static PrayerCalculationParameters initFrance() {
    final params = PrayerCalculationParameters(
      PrayerCalculationMethodType.france,
    );
    params.methodAdjustments = {PrayerType.dhuhr: 1};
    return params;
  }
}
