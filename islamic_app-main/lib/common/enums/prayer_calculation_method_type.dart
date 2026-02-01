import 'package:easy_localization/easy_localization.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';

enum PrayerCalculationMethodType {
  custom(fajrAngle: 18, ishaAngle: 18),
  egyptian(fajrAngle: 19.5, ishaAngle: 17.5),
  northAmerica(fajrAngle: 15, ishaAngle: 15),
  moonsightingCommittee(
    angleDescription: ", also uses seasonal adjustment values",
    fajrAngle: 18,
    ishaAngle: 18,
  ),
  muslimWorldLeague(fajrAngle: 18, ishaAngle: 17),
  ummAlQura(
      angleDescription: "90 minutes after Maghrib (120 minutes during Ramadan)",
      fajrAngle: 18.5,
      ishaAngle: 0),
  karachi(fajrAngle: 18, ishaAngle: 18),
  malaysia(fajrAngle: 18, ishaAngle: 18),
  singapore(fajrAngle: 20, ishaAngle: 18),
  indonesia(fajrAngle: 20, ishaAngle: 18),
  turkey(fajrAngle: 18, ishaAngle: 17),
  france(fajrAngle: 12, ishaAngle: 12);

  const PrayerCalculationMethodType({
    this.angleDescription,
    required this.fajrAngle,
    required this.ishaAngle,
  });
  final String? angleDescription;

  /// The angle for Fajr (pre-dawn) prayer in degrees.
  final double fajrAngle;

  /// The angle for Isha (nightfall) prayer in degrees.
  final double ishaAngle;

  String get label {
    return switch (this) {
      custom => LocaleKeys.customAngles.tr(),
      egyptian => LocaleKeys.methodEgypt.tr(),
      northAmerica => LocaleKeys.methodIsna.tr(),
      moonsightingCommittee => LocaleKeys.methodMcw.tr(),
      muslimWorldLeague => LocaleKeys.methodMwl.tr(),
      ummAlQura => LocaleKeys.methodMakkah.tr(),
      karachi => LocaleKeys.methodKarachi.tr(),
      malaysia => LocaleKeys.methodJakim.tr(),
      singapore => LocaleKeys.methodMuis.tr(),
      indonesia => LocaleKeys.methodKemenag.tr(),
      turkey => LocaleKeys.methodDiyanet.tr(),
      france => LocaleKeys.methodUoif.tr(),
    };
  }

  String? get description {
    return switch (this) {
      egyptian => LocaleKeys.methodEgyptCountries.tr(),
      northAmerica => LocaleKeys.methodIsnaCountris.tr(),
      moonsightingCommittee => LocaleKeys.methodMcwCountries.tr(),
      muslimWorldLeague => LocaleKeys.methodMwlCountries.tr(),
      ummAlQura => LocaleKeys.methodMakkahCountries.tr(),
      karachi => LocaleKeys.methodKarachiCountries.tr(),
      _ => null,
    };
  }

  String get subtitle {
    String desc = '';
    if (fajrAngle > 0) desc += 'Fajr : $fajrAngle°, Isha : ';
    if (ishaAngle > 0) desc += '$ishaAngle°';
    if (angleDescription != null) desc += angleDescription!;
    return desc;
  }
}

PrayerCalculationMethodType getPrayerCalculationMethod(String? isoCountryCode) {
  if (isoCountryCode == null) {
    return PrayerCalculationMethodType.muslimWorldLeague; // Default fallback
  }

  Map<String, PrayerCalculationMethodType> countryMethodMap = {
    "US": PrayerCalculationMethodType.northAmerica,
    "CA": PrayerCalculationMethodType.northAmerica,
    "EG": PrayerCalculationMethodType.egyptian,
    "PK": PrayerCalculationMethodType.karachi,
    "IN": PrayerCalculationMethodType.karachi,
    "BD": PrayerCalculationMethodType.karachi,
    "ID": PrayerCalculationMethodType.indonesia,
    "MY": PrayerCalculationMethodType.malaysia,
    "SG": PrayerCalculationMethodType.singapore,
    "TR": PrayerCalculationMethodType.turkey,
    "SA": PrayerCalculationMethodType.ummAlQura,
    "AE": PrayerCalculationMethodType.ummAlQura,
    "QA": PrayerCalculationMethodType.ummAlQura,
    "OM": PrayerCalculationMethodType.ummAlQura,
    "KW": PrayerCalculationMethodType.ummAlQura,
    "BH": PrayerCalculationMethodType.ummAlQura,
    "FR": PrayerCalculationMethodType.france,
  };

  return countryMethodMap[isoCountryCode.toUpperCase()] ??
      PrayerCalculationMethodType.muslimWorldLeague;
}
