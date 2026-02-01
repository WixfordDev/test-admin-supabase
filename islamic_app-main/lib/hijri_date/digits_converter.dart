class DigitsConverter {
  static const List<String> easternArabicNumerals = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩'
  ];

  static String convertWesternNumberToEastern(dynamic easternNumber) {
    assert(
      easternNumber is int || easternNumber is String,
      "The value object must be of type 'int' or 'String'.",
    );

    String englishNumber = easternNumber is int
        ? easternNumber.toString()
        : easternNumber as String;

    StringBuffer stringBuffer = StringBuffer();
    for (var rune in englishNumber.runes) {
      String character = String.fromCharCode(rune);
      stringBuffer.write(easternArabicNumerals[int.parse(character)]);
    }
    return stringBuffer.toString();
  }
}

extension IntExtensions on int {
  /// Converts English numbers to the Arabic numbers format
  ///
  ///
  /// Example:
  /// ```dart
  /// final arabicNumbers = 0123456789.toArabicNumbers;
  /// // result: ٠١٢٣٤٥٦٧٨٩
  /// ```
  String get toArabicNumbers {
    return DigitsConverter.convertWesternNumberToEastern(this);
  }
}

extension StringExtensions on String {
  /// Converts English numbers to the Arabic numbers format
  ///
  ///
  /// Example:
  /// ```dart
  /// final arabicNumbers = '0123456789'.toArabicNumbers;
  /// // result: ٠١٢٣٤٥٦٧٨٩
  /// ```
  String get toArabicNumbers {
    return DigitsConverter.convertWesternNumberToEastern(this);
  }
}
