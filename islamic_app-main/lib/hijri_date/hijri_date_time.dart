import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/utils/date_time_utils.dart';
import 'package:deenhub/features/settings/domain/utils/language_options.dart';
import 'package:deenhub/hijri_date/digits_converter.dart';
import 'package:deenhub/hijri_date/hijri_date_utils.dart';
import 'hijri_array.dart';

class HijriDateTime {
  late int lengthOfMonth;
  int hDay = 1;
  late int hMonth;
  late int hYear;
  int? wkDay;
  late String longMonthName;
  late String shortMonthName;
  late String dayWeName;
  Map<int, int>? adjustments;

  /// The gregorian date value for [this]
  DateTime? _date;

  final String localeName =
      getIt<SharedPrefsHelper>().deviceLanguage.localeName;

  HijriDateTime(int year, int month, int day) {
    setDate(year, month, day);
  }

  HijriDateTime.fromDate(DateTime date) {
    _date = date;
    gregorianToHijri(date.year, date.month, date.day);
  }

  HijriDateTime.now({bool utc = false}) {
    _now(utc);
  }

  HijriDateTime.addMonth(int year, int month) {
    hYear = year + (month - 1) ~/ 12;
    hMonth = (month - 1) % 12 + 1;
    hDay = 1;

    setDate(hYear, hMonth, hDay);
  }

  setDate(int year, int month, int day) {
    _date = hijriToGregorian(year, month, day);
    wkDay = _date?.weekday;
    hDate(year, month, day);
    lengthOfMonth = getNumberOfDatesInMonth()!;
  }

  DateTime toDateTime() {
    return _date!;
  }

  int get weekday => wkDay ?? weekDay();

  String _now(bool utc) {
    DateTime today = DateTime.now();
    if (utc) {
      DateTime todayUtc = DateTime.utc(today.year, today.month, today.day);
      _date = todayUtc;
    } else {
      _date = today;
    }
    return gregorianToHijri(_date!.year, _date!.month, _date!.day);
  }

  int getDaysInMonth(int year, int month) {
    int i = _getNewMoonMJDNIndex(year, month);
    return _ummalquraDataIndex(i)! - _ummalquraDataIndex(i - 1)!;
  }

  int _gMod(int n, int m) {
    // generalized modulo function (n mod m) also valid for negative values of n
    return ((n % m) + m) % m;
  }

  int _getNewMoonMJDNIndex(int hy, int hm) {
    int cYears = hy - 1, totalMonths = (cYears * 12) + 1 + (hm - 1);
    return totalMonths - 16260;
  }

  int lengthOfYear({int? year = 0}) {
    int total = 0;
    if (year == 0) year = hYear;
    for (int m = 0; m <= 11; m++) {
      total += getDaysInMonth(year!, m);
    }
    return total;
  }

  DateTime hijriToGregorian(int year, int month, int day) {
    int iy = year;
    int im = month;
    int id = day;
    int ii = iy - 1;
    int iln = (ii * 12) + 1 + (im - 1);
    int i = iln - 16260;
    int mcjdn = id + _ummalquraDataIndex(i - 1)! - 1;
    int cjdn = mcjdn + 2400000;
    return julianToGregorian(cjdn);
  }

  DateTime julianToGregorian(julianDate) {
    //source from: http://keith-wood.name/calendars.html
    int z = (julianDate + 0.5).floor();
    int a = ((z - 1867216.25) / 36524.25).floor();
    a = z + 1 + a - (a / 4).floor();
    int b = a + 1524;
    int c = ((b - 122.1) / 365.25).floor();
    int d = (365.25 * c).floor();
    int e = ((b - d) / 30.6001).floor();
    int day = b - d - (e * 30.6001).floor();
    //var wd = _gMod(julianDate + 1, 7) + 1;
    int month = e - (e > 13.5 ? 13 : 1);
    int year = c - (month > 2.5 ? 4716 : 4715);
    if (year <= 0) {
      year--;
    } // No year zero
    return DateTime(year, (month), day);
  }

  String gregorianToHijri(int pYear, int pMonth, int pDay) {
    //This code the modified version of R.H. van Gent Code, it can be found at http://www.staff.science.uu.nl/~gent0113/islam/ummalqura.htm
    // read calendar data

    int day = (pDay);
    int month =
        (pMonth); // -1; // Here we enter the Index of the month (which starts with Zero)
    int year = (pYear);

    int m = month;
    int y = year;

    // append January and February to the previous year (i.e. regard March as
    // the first month of the year in order to simplify leapday corrections)

    if (m < 3) {
      y -= 1;
      m += 12;
    }

    // determine offset between Julian and Gregorian calendar

    int a = (y / 100).floor();
    int jgc = a - (a / 4.0).floor() - 2;

    // compute Chronological Julian Day Number (CJDN)

    int cjdn = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day -
        jgc -
        1524;

    a = ((cjdn - 1867216.25) / 36524.25).floor();
    jgc = a - (a / 4.0).floor() + 1;
    int b = cjdn + jgc + 1524;
    int c = ((b - 122.1) / 365.25).floor();
    int d = (365.25 * c).floor();
    month = ((b - d) / 30.6001).floor();
    day = (b - d) - (30.6001 * month).floor();

    if (month > 13) {
      c += 1;
      month -= 12;
    }

    month -= 1;
    year = c - 4716;

    // compute Modified Chronological Julian Day Number (MCJDN)

    int mcjdn = cjdn - 2400000;

    // the MCJDN's of the start of the lunations in the Umm al-Qura calendar are stored in 'islamcalendar_dat.js'
    int i;
    for (i = 0; i < ummAlquraDateArray.length; i++) {
      if (_ummalquraDataIndex(i)! > mcjdn) break;
    }

    // compute and output the Umm al-Qura calendar date

    int iln = i + 16260;
    int ii = ((iln - 1) / 12).floor();
    int iy = ii + 1;
    int im = iln - 12 * ii;
    int id = mcjdn - _ummalquraDataIndex(i - 1)! + 1;
    int ml = _ummalquraDataIndex(i)! - _ummalquraDataIndex(i - 1)!;
    lengthOfMonth = ml;
    int wd = _gMod(cjdn + 1, 7);

    wkDay = wd == 0 ? 7 : wd;
    return hDate(iy, im, id);
  }

  String hDate(int year, int month, int day) {
    hYear = year;
    hMonth = month;
    longMonthName = month.hijriMonth.monthName;
    dayWeName = wkDay!.weekday.wDayName;
    shortMonthName = month.hijriMonth.monthShortName;
    hDay = day;
    return format(hYear, hMonth, hDay, "dd/mm/yyyy");
  }

  String toFormat({String format = monthDayFormatPattern}) {
    return this.format(hYear, hMonth, hDay, format);
  }

  String format(int year, int month, int day, String format) {
    String newFormat = format;

    String dayString;
    String monthString;
    String yearString;

    if (localeName == LanguageOption.arabic.localeName) {
      dayString = DigitsConverter.convertWesternNumberToEastern(day);
      monthString = DigitsConverter.convertWesternNumberToEastern(month);
      yearString = DigitsConverter.convertWesternNumberToEastern(year);
    } else {
      dayString = day.toString();
      monthString = month.toString();
      yearString = year.toString();
    }

    if (newFormat.contains("dd")) {
      newFormat = newFormat.replaceFirst("dd", dayString);
    } else {
      if (newFormat.contains("d")) {
        newFormat = newFormat.replaceFirst("d", day.toString());
      }
    }

    //=========== Day Name =============//
    // Friday
    if (newFormat.contains("DDDD")) {
      newFormat =
          newFormat.replaceFirst("DDDD", (wkDay ?? weekDay()).weekday.wDayName);

      // Fri
    } else if (newFormat.contains("DD")) {
      newFormat = newFormat.replaceFirst(
          "DD", (wkDay ?? weekDay()).weekday.wDayShortName);
    }

    //============== Month ========================//
    // 1
    if (newFormat.contains("mm")) {
      newFormat = newFormat.replaceFirst("mm", monthString);
    } else {
      newFormat = newFormat.replaceFirst("m", monthString);
    }

    // Muharram
    if (newFormat.contains("MMMM")) {
      newFormat = newFormat.replaceFirst("MMMM", month.hijriMonth.monthName);
    } else {
      if (newFormat.contains("MM")) {
        newFormat =
            newFormat.replaceFirst("MM", month.hijriMonth.monthShortName);
      }
    }

    //================= Year ========================//
    if (newFormat.contains("yyyy")) {
      newFormat = newFormat.replaceFirst("yyyy", yearString);
    } else {
      newFormat = newFormat.replaceFirst("yy", yearString.substring(2, 4));
    }
    return newFormat;
  }

  bool isBeforeValue(int year, int month, int day) {
    return hijriToGregorian(hYear, hMonth, hDay).millisecondsSinceEpoch <
        hijriToGregorian(year, month, day).millisecondsSinceEpoch;
  }

  bool isBefore(HijriDateTime other) {
    return _date!.millisecondsSinceEpoch < other._date!.millisecondsSinceEpoch;
  }

  bool isAfterValue(int year, int month, int day) {
    return hijriToGregorian(hYear, hMonth, hDay).millisecondsSinceEpoch >
        hijriToGregorian(year, month, day).millisecondsSinceEpoch;
  }

  bool isAfter(HijriDateTime other) {
    return _date!.millisecondsSinceEpoch > other._date!.millisecondsSinceEpoch;
  }

  bool isAtSameMomentAsValue(int year, int month, int day) {
    return hijriToGregorian(hYear, hMonth, hDay).millisecondsSinceEpoch ==
        hijriToGregorian(year, month, day).millisecondsSinceEpoch;
  }

  bool isAtSameMomentAs(HijriDateTime other) {
    return _date!.millisecondsSinceEpoch == other._date!.millisecondsSinceEpoch;
  }

  Duration difference(HijriDateTime other) {
    return _date!.toUtc().difference(other._date!);
  }

  /// Returns a new [HijriDateTime] instance with [duration] added to [this].
  HijriDateTime add(Duration duration) {
    return _add(duration);
  }

  /// returns the previous date from the given value.
  HijriDateTime _getPreviousDate(HijriDateTime date, int day) {
    if (day <= 0) {
      // ignore: avoid_as
      date = getPreviousMonthDate(date) as HijriDateTime;
      final int? monthLength = date.getNumberOfDatesInMonth();

      /// Return same date when dates count in month not specified.
      if (monthLength == null) {
        return date;
      }

      day = monthLength + day;
      return _getPreviousDate(date, day);
    }

    return HijriDateTime(date.hYear, date.hMonth, day);
  }

  /// Returns the next possible date from the given value.
  HijriDateTime _getNextDate(int? monthLength, HijriDateTime date, int day) {
    if (monthLength != null && day > monthLength) {
      day -= monthLength;
      // ignore: avoid_as
      date = getNextMonthDate(date) as HijriDateTime;
      monthLength = date.getNumberOfDatesInMonth();

      /// Return same date when dates count in month not specified.
      if (monthLength == null) {
        return date;
      }

      return _getNextDate(monthLength, date, day);
    }

    return HijriDateTime(date.hYear, date.hMonth, day);
  }

  /// Returns new [HijriDateTime] instance by subtracting given [Duration].
  HijriDateTime _add(Duration duration) {
    final int? lengthOfMonth = getNumberOfDatesInMonth();

    /// Return same date when dates count in month not specified.
    if (lengthOfMonth == null) {
      return this;
    }

    this.lengthOfMonth = lengthOfMonth;

    int? newDay;
    HijriDateTime? addedDate;
    newDay = duration.inDays + hDay;
    if (newDay > lengthOfMonth) {
      addedDate = _getNextDate(lengthOfMonth, this, newDay);
    } else if (newDay <= 0) {
      addedDate = _getPreviousDate(this, newDay);
    }

    if (addedDate != null) {
      return addedDate;
    }

    return HijriDateTime(hYear, hMonth, newDay);
  }

  /// Returns a new [HijriDateTime] instance with [duration] subtracted to
  /// [this].
  HijriDateTime subtract(Duration duration) {
    return _add(-duration);
  }

  /// returns the number of dates in the month
  int? getNumberOfDatesInMonth() {
    final int totalYear = hYear - 1;
    final int totalMonths = (totalYear * 12) + 1 + (hMonth - 1);
    final int i = totalMonths - 16260;
    return _ummalquraDataIndex(i)! - _ummalquraDataIndex(i - 1)!;
  }

  void setAdjustments(Map<int, int> adj) {
    adjustments = adj;
  }

  int? _ummalquraDataIndex(int index) {
    if (index < 0 || index >= ummAlquraDateArray.length) {
      throw ArgumentError(
          "Valid date should be between 1356 AH (14 March 1937 CE) to 1500 AH (16 November 2077 CE)");
    }

    if (adjustments != null && adjustments!.containsKey(index + 16260)) {
      return adjustments![index + 16260];
    }

    return ummAlquraDateArray[index];
  }

  int weekDay() {
    DateTime wkDay = hijriToGregorian(hYear, hMonth, hDay);
    return wkDay.weekday;
  }

  String get keyValue => _date!.millisecondsSinceEpoch.toString();

  @override
  String toString() {
    String dateFormat;
    if (localeName == LanguageOption.arabic.name ||
        localeName == LanguageOption.arabicEG.name ||
        localeName == LanguageOption.urdu.name) {
      dateFormat = "yyyy/mm/dd";
    } else {
      dateFormat = "dd/mm/yyyy";
    }

    final formatted = format(hYear, hMonth, hDay, dateFormat);
    return '$formatted; ${_date.toString()}';
  }

  List<int?> toList() => [hYear, hMonth, hDay];

  String fullDate() {
    return format(hYear, hMonth, hDay, "DDDD, MMMM dd, yyyy");
  }

  bool isValid() {
    if (validateHijri(hYear, hMonth, hDay)) {
      if (hDay <= getDaysInMonth(hYear, hMonth)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool validateHijri(int year, int month, int day) {
    if (month < 1 || month > 12) return false;

    if (day < 1 || day > 30) return false;
    return true;
  }

  String getLongMonthName() {
    return hMonth.hijriMonth.monthName;
  }

  String getShortMonthName() {
    return hMonth.hijriMonth.monthShortName;
  }

  String getDayName() {
    return wkDay!.weekday.wDayName;
  }

  // // to get all month names in long format
  // Map<int, String> getMonths() {
  //   // return
  //   return _local[language]!['long']!;
  // }

  // to get specific month days on map of date and day name
  Map<int, String> getMonthDays(int month, int year) {
    Map<int, String> calender = {};
    int d = hijriToGregorian(year, month, 1).weekday;
    int daysInMonth = getDaysInMonth(year, month);
    for (int i = 1; i <= daysInMonth; i++) {
      calender.putIfAbsent(i, () => d.weekday.wDayName);
      d = d < 7 ? d + 1 : 1;
    }
    return calender;
  }
}

extension DateTimeExtension on DateTime {
  /// Return a string representing [date] formatted according to our locale
  HijriDateTime toHijriDate() => HijriDateTime.fromDate(this);
}

extension HijriCalendarExtension on HijriDateTime {
  DateTime convertToDateTime() => hijriToGregorian(hYear, hMonth, hDay);

  HijriDateTime copyWith({
    int? year,
    int? month,
    int? day,
  }) {
    return HijriDateTime(
      year ?? hYear,
      month ?? hMonth,
      day ?? hDay,
    );
  }
}
