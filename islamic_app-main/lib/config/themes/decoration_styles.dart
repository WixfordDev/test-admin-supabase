import 'package:flutter/services.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class DecorationStyles {
  static InputBorder get editTextBorder => const OutlineInputBorder(
        borderSide: BorderSide(color: ThemeColors.darkGray),
      );

  static InputBorder get editTextUnderlineBorder => const UnderlineInputBorder(
        borderSide: BorderSide(color: ThemeColors.darkGray),
      );

  static BoxDecoration calendarView(BuildContext context) => BoxDecoration(
        shape: BoxShape.rectangle,
        color: context.surfaceContainerColor,
        // color: context.onSecondaryContainerColor,
      );

  static List<BoxShadow> getBoxShadow(Color color) => [
        BoxShadow(
          color: color.withAlpha(60),
          blurRadius: 16.0,
          spreadRadius: 8.0,
          offset: const Offset(0.0, 16.0),
        ),
      ];

  static SystemUiOverlayStyle appBarSystemUiOverlayStyle({
    BuildContext? context,
    Color? appBarColor,
  }) {
    final baseColor = appBarColor ?? context!.primaryColor;
    final showDarkText = shouldShowDarkText(baseColor);

    // For edge-to-edge mode, we want to match status bar color with app bar color
    // instead of making it completely transparent
    return SystemUiOverlayStyle(
      // Match status bar color with app bar color instead of transparent
      statusBarColor: baseColor,
      statusBarBrightness: showDarkText ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: showDarkText ? Brightness.dark : Brightness.light,
      // Only navigation bar should be transparent for edge-to-edge
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: showDarkText ? Brightness.dark : Brightness.light,
    );
  }

  static bool shouldShowDarkText(Color backgroundColor) {
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5;
  }

  static Color getTextColor(Color backgroundColor) =>
      shouldShowDarkText(backgroundColor) ? ThemeColors.black : ThemeColors.white;
}
