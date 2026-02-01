import "package:flutter/material.dart";
import "package:deenhub/config/themes/theme_colors.dart";
import "package:deenhub/features/settings/domain/utils/app_theme_mode.dart";

abstract class Themes {
  // light
  static ColorScheme lightScheme(int accentColor, AppThemeMode theme) {
    return getScheme(
      false,
      accentColor,
      theme,
      onPrimary: ThemeColors.white,
      onSecondary: ThemeColors.white,
      onSecondaryContainer: ThemeColors.lightGrayCalendar,
      onTertiaryContainer: ThemeColors.white,
      onSurface: ThemeColors.black,
      surfaceTint: ThemeColors.white,
    );
  }

  // Night
  static ColorScheme darkScheme(int accentColor, AppThemeMode theme) {
    return getScheme(
      true,
      accentColor,
      theme,
      onPrimary: ThemeColors.black,
      onSecondary: ThemeColors.black,
      onSecondaryContainer: ThemeColors.darkGrayCalendar,
      onTertiaryContainer: ThemeColors.nightBlackStatusBar,
      onSurface: ThemeColors.white,
      surfaceTint: ThemeColors.black,
    );
  }

  // Color Scheme
  static ColorScheme getScheme(
    bool isDarkTheme,
    int accentColor,
    AppThemeMode theme, {
    required Color onPrimary,
    required Color onSecondary,
    required Color onSecondaryContainer,
    required Color onTertiaryContainer,
    required Color onSurface,
    required Color surfaceTint,
  }) {
    final primaryColor = Color(accentColor);
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      // dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    return scheme;

    // return ColorScheme(
    //   brightness: isDarkTheme ? Brightness.dark : Brightness.light,
    //   primary: primaryColor,
    //   onPrimary: onPrimary,
    //   primaryContainer: isDarkTheme ? ThemeColors.lightBlack : ThemeColors.lightWhite,
    //   onPrimaryContainer: const Color(0xFF00201F),
    //   // secondary: theme.secondaryColor(isDarkTheme),
    //   secondary: ThemeColors.divider,
    //   onSecondary: ThemeColors.black,
    //   secondaryContainer: theme.secondaryContainerColor(isDarkTheme),
    //   onSecondaryContainer: onSecondaryContainer,
    //   tertiary: theme.statusBarColor(primaryColor),
    //   onTertiary: theme.onStatusBarColor,
    //   // tertiaryContainer: darkScheme.,
    //   tertiaryContainer: const Color(0xFF294747),
    //   onTertiaryContainer: onTertiaryContainer,
    //   error: const Color(0xFFFF1A1A),
    //   errorContainer: const Color(0xFFFFDAD6),
    //   onError: ThemeColors.white,
    //   onErrorContainer: const Color(0xFF410002),
    //   surface: theme.surfaceColor(primaryColor),
    //   onSurface: onSurface,
    //   surfaceContainerHighest: const Color(0xFFDAE5E3),
    //   onSurfaceVariant: const Color(0xFF3F4948),
    //   outline: const Color(0xFF6F7978),
    //   onInverseSurface: const Color(0xFFD6F6FF),
    //   inverseSurface: const Color(0xFF00363F),
    //   inversePrimary: ThemeColors.blue,
    //   shadow: ThemeColors.black,
    //   surfaceTint: surfaceTint,
    //   outlineVariant: const Color(0xFFBEC9C7),
    //   scrim: ThemeColors.black,
    // );
  }
}
