import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';

enum LanguageOption {
  device,
  azerbaijani(locale: 'az'),
  indonesian(locale: 'id', labelOverride: 'Bahasa Indonesia'),
  malay(locale: 'ms', labelOverride: 'Bahasa Melayu'),
  german(locale: 'de', labelOverride: 'Deutsch'),
  english(locale: 'en'),
  french(locale: 'fr', labelOverride: 'Français'),
  italian(locale: 'it', labelOverride: 'Italiano'),
  russian(locale: 'ru', labelOverride: 'Pусский'),
  turkish(locale: 'tr', labelOverride: 'Türkçe'),
  arabic(locale: 'ar', labelOverride: 'العربية (١ ٢ ٣)'),
  arabicEG(locale: 'ar', labelOverride: 'العربية (1 2 3)'),
  urdu(locale: 'ur', labelOverride: 'اردو'),
  bangla(locale: 'bn', labelOverride: 'বাংলা'),
  ;

  const LanguageOption({this.locale, this.labelOverride});
  final String? locale;
  final String? labelOverride;

  String get label {
    if (name == device.name) {
      return LocaleKeys.deviceLanguage.tr();
    }
    return labelOverride ?? name.capitalizeFirstLetter;
  }

  String get localeName {
    if (name == device.name) {
      return Platform.localeName.split('_')[0];
    } else {
      return locale!;
    }
  }
}
