import 'package:easy_localization/easy_localization.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';

enum PrayerType {
  fajr,
  sunrise(isMandatory: false),
  dhuhr,
  asr,
  maghrib,
  isha,
  qiyam(isMandatory: false),
  ;

  const PrayerType({this.isMandatory = true});
  final bool isMandatory;

  String get label {
    return switch (this) {
      fajr => LocaleKeys.fajr.tr(),
      sunrise => "Sunrise",
      dhuhr => LocaleKeys.duhr.tr(),
      asr => LocaleKeys.asr.tr(),
      maghrib => LocaleKeys.maghrib.tr(),
      isha => LocaleKeys.isha.tr(),
      qiyam => LocaleKeys.qiyam.tr(),
    };
  }
}

Iterable<PrayerType> getMandatoryPrayersList() => PrayerType.values.where((e) => e.isMandatory);
Iterable<PrayerType> getAdjustmentsList() => PrayerType.values.where((e) => true);
List<int> getDefaultAdjustments() => getAdjustmentsList().map((e) => 0).toList();
