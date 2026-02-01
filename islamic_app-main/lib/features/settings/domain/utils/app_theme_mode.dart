import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/themes/theme_colors.dart';

enum AppThemeMode {
  automatic(isLightTheme: null),
  dynamicLight,
  classic,
  white,
  dynamicDark(isLightTheme: false),
  nightBlack(isLightTheme: false),
  pureBlack(isLightTheme: false),
  nightAcent(isLightTheme: false),
  ;

  const AppThemeMode({this.isLightTheme = true});
  final bool? isLightTheme;

  String label(bool inList) {
    return switch (this) {
      automatic => LocaleKeys.automatic.tr(),
      dynamicLight =>
        '${LocaleKeys.dynamicColors.tr()}${inList ? '' : ' (${LocaleKeys.light.tr()})'}',
      classic => LocaleKeys.classic.tr(),
      white => LocaleKeys.white.tr(),
      dynamicDark => '${LocaleKeys.dynamicColors.tr()}${inList ? '' : ' (${LocaleKeys.dark.tr()})'}',
      nightBlack => LocaleKeys.nightBlack.tr(),
      pureBlack => LocaleKeys.pureBlack.tr(),
      nightAcent => LocaleKeys.nightBlue.tr(),
    };
  }

  String? get subtitle {
    return switch (this) {
      dynamicLight => LocaleKeys.dynamicColorsThemeSum.tr(),
      dynamicDark => LocaleKeys.dynamicColorsThemeSum.tr(),
      _ => null,
    };
  }

  bool isDarkTheme(bool isDarkMode) {
    if (isLightTheme == null) {
      return isDarkMode;
    }
    return isLightTheme == false;
  }

  ThemeMode modeValue(bool isDarkMode) {
    return isDarkTheme(isDarkMode) ? ThemeMode.dark : ThemeMode.light;
  }

  String modeValueLabel(bool isDarkMode) {
    return isDarkTheme(isDarkMode) ? LocaleKeys.darkTheme.tr() : LocaleKeys.lightTheme.tr();
  }

  Color surfaceColor(Color primary) {
    return switch (this) {
      automatic => ThemeColors.black,
      dynamicLight => ThemeColors.white,
      classic => ThemeColors.white,
      white => ThemeColors.white,
      dynamicDark => ThemeColors.dynamicBlack,
      nightBlack => ThemeColors.nightBlack,
      pureBlack => ThemeColors.black,
      nightAcent => ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark).surface,
    };
  }

  // Color secondaryColor(bool isDarkMode) {
  //   if (!isDarkMode) return ThemeColors.dividerLight;
  //   if (this == dynamicDark || this == pureBlack) return ThemeColors.nightBlackStatusBar;
  //   return ThemeColors.black;
  // }

  Color secondaryContainerColor(bool isDarkMode) {
    if (!isDarkMode) return ThemeColors.dividerLight;
    if (this == dynamicDark || this == pureBlack) return ThemeColors.nightBlackStatusBar;
    return ThemeColors.black;
  }

  Color statusBarColor(Color primary) {
    return switch (this) {
      automatic => ThemeColors.black,
      dynamicLight => primary,
      classic => primary,
      white => ThemeColors.white,
      dynamicDark => ThemeColors.dynamicBlackStatusBar,
      nightBlack => ThemeColors.nightBlackStatusBar,
      pureBlack => ThemeColors.black,
      nightAcent =>
        ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark).surfaceContainer,
    };
  }

  Color get onStatusBarColor {
    if (this == white) return ThemeColors.black;
    return ThemeColors.white;
  }
}
