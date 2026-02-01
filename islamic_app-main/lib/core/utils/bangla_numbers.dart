class _BanglaNumbers {
  static String convert(Object value) {
    assert(
      value is int || value is String,
      "The value object must be of type 'int' or 'String'.",
    );

    if (value is int) {
      return _toBanglaNumbers(value.toString());
    } else {
      return _toBanglaNumbers(value as String);
    }
  }

  static String _toBanglaNumbers(String value) {
    return value
        .replaceAll('0', '০')
        .replaceAll('1', '১')
        .replaceAll('2', '২')
        .replaceAll('3', '৩')
        .replaceAll('4', '৪')
        .replaceAll('5', '৫')
        .replaceAll('6', '৬')
        .replaceAll('7', '৭')
        .replaceAll('8', '৮')
        .replaceAll('9', '৯');
  }
}

extension IntExtensions on int {
  /// Converts English numbers to the Bangla numbers format
  ///
  ///
  /// Example:
  /// ```dart
  /// final BanglaNumbers = 0123456789.toBanglaNumbers;
  /// // result: ٠١٢٣٤٥٦٧٨٩
  /// ```
  String get toBanglaNumbers {
    return _BanglaNumbers.convert(this);
  }
}

extension StringExtensions on String {
  /// Converts English numbers to the Bangla numbers format
  ///
  ///
  /// Example:
  /// ```dart
  /// final BanglaNumbers = '0123456789'.toBanglaNumbers;
  /// // result: ٠١٢٣٤٥٦٧٨٩
  /// ```
  String get toBanglaNumbers {
    return _BanglaNumbers.convert(this);
  }
}
