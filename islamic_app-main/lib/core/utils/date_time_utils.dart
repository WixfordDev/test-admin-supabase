import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:timezone/timezone.dart' as tz;

const String timeFormatPattern = 'EEEE, h:mm a';
const String shortDayTimeFormatPattern = 'EEE h:mm a';
const String dateTimeFormatPattern = 'EEEE, MMMM d, yyyy';
const String dateTimeShortFormatPattern = 'EEE, MMM d, yyyy h:mm a';
const String dayFormatPattern = 'd MMM, yyyy';
const String monthDayFormatPattern = 'MMMM d, yyyy';

extension DateTimeExtension on DateTime {
  /// Return a string representing [date] formatted according to our locale
  String format({
    String pattern = dateTimeFormatPattern,
    String? locale,
  }) {
    String localeValue = locale ?? getIt<SharedPrefsHelper>().deviceLanguage.localeName;

    if (localeValue.isNotEmpty) {
      initializeDateFormatting(localeValue);
    }
    return DateFormat(pattern, localeValue).format(this);
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isTomorrow() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day + 1;
  }

  bool isYesterday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day - 1;
  }

  String timeIn24Hr({String? locale}) => format(pattern: 'H:mm', locale: locale);
  String time({String? locale}) => format(pattern: 'h:mm a', locale: locale);

  String timeWithoutPeriod({String? locale}) => format(pattern: 'h:mm', locale: locale);
  String timeSecondsWithoutPeriod({String? locale}) => format(pattern: 'h:mm:ss', locale: locale);
  String inAmOrPm({String? locale}) => format(pattern: 'a', locale: locale);

  String formatInHourAndMinutes({
    String? locale,
    bool showMinutesMini = true,
    bool useMiniFormat = false,
  }) {
    String localeValue = locale ?? getIt<SharedPrefsHelper>().deviceLanguage.localeName;
    final formatter = NumberFormat.decimalPattern(localeValue);
    final spaceFormat = useMiniFormat ? '' : ' ';

    // Get minutes remaining after whole hours
    if (hour == 0) {
      return "${formatter.format(minute)}$spaceFormat${useMiniFormat ? LocaleKeys.minuteMini.tr() : LocaleKeys.minutes.tr().toLowerCase()}";
    }
    String hoursLabel = useMiniFormat
        ? LocaleKeys.hourMini.tr()
        : hour == 1
            ? LocaleKeys.hour.tr()
            : LocaleKeys.hours.tr();
    return "${formatter.format(hour)}$spaceFormat${hoursLabel.toLowerCase()} ${formatter.format(minute)}$spaceFormat${showMinutesMini ? LocaleKeys.minuteMini.tr() : LocaleKeys.minutes.tr().toLowerCase()}";
  }
}

extension DurationExtension on Duration {
  int get remainingMinutes => inMinutes % 60;

  String formatInHourAndMinutes({
    String? locale,
    bool showMinutesMini = true,
    bool useMiniFormat = false,
  }) {
    String localeValue = locale ?? getIt<SharedPrefsHelper>().deviceLanguage.localeName;
    final formatter = NumberFormat.decimalPattern(localeValue);
    final spaceFormat = useMiniFormat ? '' : ' ';

    // Get minutes remaining after whole hours
    if (inHours == 0) {
      return "${formatter.format(remainingMinutes)}$spaceFormat${useMiniFormat ? LocaleKeys.minuteMini.tr() : LocaleKeys.minutes.tr().toLowerCase()}";
    }
    String hoursLabel = useMiniFormat
        ? LocaleKeys.hourMini.tr()
        : inHours == 1
            ? LocaleKeys.hour.tr()
            : LocaleKeys.hours.tr();
    return "${formatter.format(inHours)}$spaceFormat${hoursLabel.toLowerCase()} ${formatter.format(remainingMinutes)}$spaceFormat${showMinutesMini ? LocaleKeys.minuteMini.tr() : LocaleKeys.minutes.tr().toLowerCase()}";
  }

  String get countdownFormat {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    int hours = inHours;
    int minutes = inMinutes.remainder(60);
    int seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "$minutes:${twoDigits(seconds)}";
    }
  }

  String get gmtFormat {
    final hours = inHours.addLeadingZeroIfNeeded(showPositiveSign: true);
    final remainingMinutes = (inMinutes % 60).addLeadingZeroIfNeeded();
    return "GMT$hours:$remainingMinutes";
  }

  int get inDaysRounded => (inMicroseconds / Duration.microsecondsPerDay).round();
}

extension LocationExtension on tz.Location {
  String get offsetGMT => currentTimeZone.offset.milliseconds.gmtFormat;
}
