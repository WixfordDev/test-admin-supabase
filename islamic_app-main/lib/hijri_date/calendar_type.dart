import 'package:easy_localization/easy_localization.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';

enum CalendarType {
  hijri,
  gregorian;

  String get label {
    return switch (this) {
      hijri => LocaleKeys.hijri.tr(),
      gregorian => LocaleKeys.gregorian.tr()
    };
  }

  bool get isGregorianType => this == CalendarType.gregorian;
}
