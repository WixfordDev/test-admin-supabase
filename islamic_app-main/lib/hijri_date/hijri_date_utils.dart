import 'package:deenhub/hijri_date/calendar_type.dart';
import 'package:deenhub/hijri_date/hijri_date_time.dart';

/// Returns the previous month start date for the given date.
dynamic getPreviousMonthDate(dynamic date) {
  if (date is HijriDateTime) {
    return date.hMonth == 1
        ? HijriDateTime(date.hYear - 1, 12, 01)
        : HijriDateTime(date.hYear, date.hMonth - 1, 1);
  }
  return date.month == 1
      ? DateTime(date.year - 1, 12)
      : DateTime(date.year, date.month - 1);
}

/// Returns the next month start date for the given date..
dynamic getNextMonthDate(dynamic date) {
  if (date is HijriDateTime) {
    return date.hMonth == 12
        ? HijriDateTime(date.hYear + 1, 01, 01)
        : HijriDateTime(date.hYear, date.hMonth + 1, 1);
  }
  return date.month == 12
      ? DateTime(date.year + 1)
      : DateTime(date.year, date.month + 1);
}

/// Checks if two DateTime objects are the same day.
/// Returns `false` if either of them is null.
bool isSameDay(CalendarType calendarType, HijriDateTime? a, HijriDateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  if (calendarType.isGregorianType) {
    return a.toDateTime().year == b.toDateTime().year &&
        a.toDateTime().month == b.toDateTime().month &&
        a.toDateTime().day == b.toDateTime().day;
  } else {
    return a.hYear == b.hYear && a.hMonth == b.hMonth && a.hDay == b.hDay;
  }
}