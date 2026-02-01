import 'package:easy_localization/easy_localization.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';

enum NotificationReminderType {
  sound,
  vibrate,
  soundAndVibrate,
  silent,
  ;

  String get label {
    return switch (this) {
      sound => LocaleKeys.sound.tr(),
      vibrate => LocaleKeys.vibrate.tr(),
      soundAndVibrate => LocaleKeys.soundVibrate.tr(),
      silent => LocaleKeys.silent.tr(),
    };
  }
}
