import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class TextStyles {
  static TextStyle get labelTextStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: ThemeColors.lightTeal,
      );

  static TextStyle titleTextStyle(BuildContext context) => TextStyle(
        fontSize: 16,
        color: context.onSurfaceColor,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle titleTextStyle_18(BuildContext context) => TextStyle(
        fontSize: 18,
        color: context.onSurfaceColor,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle titleTextStyle_14(BuildContext context) => TextStyle(
        fontSize: 14,
        color: context.onSurfaceColor,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle get descriptionTextStyle => const TextStyle(
        fontSize: 12,
        color: ThemeColors.darkGray,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle settingsTitleTextStyle(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: context.primaryColor,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle dropDownTextStyle(BuildContext context) => TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
        color: context.onSurfaceColor,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle popupMenuTextStyle(BuildContext context) => TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: context.onSurfaceColor,
        overflow: TextOverflow.ellipsis,
      );
}

extension TextStyleExtension on TextStyle {
  TextStyle get normal => copyWith(fontWeight: FontWeight.normal);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
}
