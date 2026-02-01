import 'dart:io';

import 'package:intl/intl.dart';
import 'package:deenhub/main.dart';
import 'package:url_launcher/url_launcher_string.dart';

const defaultErrorMessage = 'Something went wrong';
final formatter = NumberFormat.simpleCurrency(decimalDigits: 0, name: '');

// boolean
extension BoolNullableExt on bool? {
  bool get orFalse => this ?? false;
  bool get orTrue => this ?? true;
}

// int
extension IntNullableExt on int? {
  int get orZero => this ?? 0;
  String get formatted => formatter.format(orZero);
}

extension IntExt on int {
  String addLeadingZeroIfNeeded({bool showPositiveSign = false}) {
    if (this > 9) return showPositiveSign ? '+$this' : toString();
    if (this > -1) return showPositiveSign ? '+0$this' : '0$this';
    if (this > -10) return '-0${abs()}';
    return toString();
  }

  String get ordinal {
    String suffix;
    int lastDigit = this % 10;

    // Handle special cases (11, 12, 13) first
    if (this >= 11 && this <= 13) {
      suffix = this == 11 ? "th" : (this % 10 == 1 ? "st" : (this % 10 == 2 ? "nd" : "rd"));
    } else {
      // Handle regular cases (1-9)
      suffix = switch (lastDigit) { 1 => "st", 2 => "nd", 3 => "rd", _ => "th" };
    }

    return "$this$suffix";
  }
}

// double
extension DoubleNullableExt on double? {
  double get orZero => this ?? 0;
}

extension DoubleExt on double {
  /// Converts a double value representing latitude or longitude to a formatted string
  /// in degrees, minutes, seconds with cardinal direction (N/S or E/W).
  ///
  /// @param value: The double value representing latitude or longitude
  /// @param isLatitude: True if the value represents latitude, False for longitude.
  ///
  /// @return A formatted string representing the value.
  String convertDegrees(bool isLatitude) {
    if (isLatitude && (this < -90 || this > 90)) {
      return '???';
      // throw ArgumentError('Latitude must be between -90 and 90 degrees.');
    } else if (!isLatitude && (this < -180 || this > 180)) {
      return '???';
      // throw ArgumentError('Longitude must be between -180 and 180 degrees.');
    }

    final degrees = floor();
    final minutes = ((this % 1) * 60).floor();
    final seconds = ((this % 1 - minutes / 60) * 3600 * 100).round() / 100;

    // Determine cardinal direction
    final cardinalDirection = isLatitude ? (this >= 0 ? 'N' : 'S') : (this >= 0 ? 'E' : 'W');

    return "$degrees°$minutes'${seconds.toStringAsFixed(1)}'' $cardinalDirection";
  }
}

// string
extension StringNullableExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  String get orEmpty => this ?? '';
  String get orError => this ?? defaultErrorMessage;
  int get toInt => int.tryParse(this ?? '0').orZero;
  double get toDouble => double.tryParse(this ?? '0').orZero;
  String append(String other) => '$orEmpty$other';
}

extension StringExt on String {
  String get capitalizeFirstLetter => isNotEmpty ? this[0].toUpperCase() + substring(1) : this;

  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  // Format: yyyy-MM-dd HH:mm:ss
  DateTime toDateTime() => DateTime.parse(this);

  /// Launches a provided URL in a suitable application.
  Future<void> launchURL() async {
    if (await canLaunchUrlString(this)) {
      await launchUrlString(
        this,
        mode: Platform.isAndroid ? LaunchMode.platformDefault : LaunchMode.externalNonBrowserApplication,
      );
    } else {
      logger.e('Could not launch $this');
    }
  }
}

extension IterableExtension<T> on Iterable<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// Extensions on iterables whose elements are also iterables.
extension IterableIterableExtension<T> on Iterable<Iterable<T>> {
  /// The sequential elements of each iterable in this iterable.
  ///
  /// Iterates the elements of this iterable.
  /// For each one, which is itself an iterable,
  /// all the elements of that are emitted
  /// on the returned iterable, before moving on to the next element.
  Iterable<T> get flattened sync* {
    for (var elements in this) {
      yield* elements;
    }
  }
}

extension ListExtensions<E> on List<E> {
  /// Takes an action for each element.
  ///
  /// Calls [action] for each element along with the index in the
  /// iteration order.
  void forEachIndexed(void Function(int index, E element) action) {
    for (var index = 0; index < length; index++) {
      action(index, this[index]);
    }
  }
}

extension EnumByNameExt<T extends Enum> on Iterable<T> {
  T? of(String? name) {
    if (name == null) return null;
    return firstWhereOrNull((e) => e.name == name);
  }
}
