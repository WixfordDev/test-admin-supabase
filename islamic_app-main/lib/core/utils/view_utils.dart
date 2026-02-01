import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/text_styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/widgets/loading_view.dart';

extension ContextExt on BuildContext {
  // Size
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  double get aspectRatio => MediaQuery.of(this).size.aspectRatio;
  double get longestSide => MediaQuery.of(this).size.longestSide;
  double get shortestSide => MediaQuery.of(this).size.shortestSide;
  Orientation get orientation => MediaQuery.of(this).orientation;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  // Themes
  bool get isDarkMode =>
      MediaQuery.of(this).platformBrightness == Brightness.dark;
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get onPrimaryColor => Theme.of(this).colorScheme.onPrimary;
  Color get primaryContainerColor =>
      Theme.of(this).colorScheme.primaryContainer;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get onSecondaryColor => Theme.of(this).colorScheme.onSecondary;
  Color get secondaryContainerColor =>
      Theme.of(this).colorScheme.secondaryContainer;
  Color get onSecondaryContainerColor =>
      Theme.of(this).colorScheme.onSecondaryContainer;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  Color get surfaceDimColor => Theme.of(this).colorScheme.surfaceDim;
  Color get surfaceContainerColor =>
      Theme.of(this).colorScheme.surfaceContainer;
  Color get surfaceContainerLowestColor =>
      Theme.of(this).colorScheme.surfaceContainerLowest;
  Color get surfaceVariantColor => Theme.of(this).colorScheme.surfaceVariant;
  Color get tertiaryColor => Theme.of(this).colorScheme.tertiary;
  Color get onTertiaryColor => Theme.of(this).colorScheme.onTertiary;
  Color get tertiaryContainerColor =>
      Theme.of(this).colorScheme.tertiaryContainer;
  Color get onTertiaryContainerColor =>
      Theme.of(this).colorScheme.onTertiaryContainer;
  Color get outlineVariantColor => Theme.of(this).colorScheme.outlineVariant;
  Color get errorColor => Theme.of(this).colorScheme.error;
  // Color get dividerColor => lightGray;

  // Snackbar
  void _showSnackBar(
    String message, {
    Color? backgroundColor,
    SnackBarBehavior? behavior,
    int durationInSeconds = 3,
  }) {
    if (!mounted) return;
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: durationInSeconds),
      backgroundColor: backgroundColor,
      behavior: behavior,
    );
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  void showSnackBar(
    String message, {
    SnackBarBehavior? behavior,
    int durationInSeconds = 3,
  }) {
    _showSnackBar(
      message,
      durationInSeconds: durationInSeconds,
      behavior: behavior,
    );
  }

  void showSuccessSnackBar(
    String message, {
    SnackBarBehavior? behavior,
    int durationInSeconds = 3,
  }) {
    _showSnackBar(
      message,
      backgroundColor: ThemeColors.green,
      durationInSeconds: durationInSeconds,
      behavior: behavior,
    );
  }

  void showErrorSnackBar(
    String message, {
    SnackBarBehavior? behavior,
    int durationInSeconds = 3,
  }) {
    _showSnackBar(
      message,
      backgroundColor: errorColor,
      durationInSeconds: durationInSeconds,
      behavior: behavior,
    );
  }

  void showLoadingDialog() {
    if (!mounted) return;
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingView().center();
      },
    );
  }

  // Dialog
  void displayAlertDialog({
    String? title,
    required String content,
    VoidCallback? onPositivePressed,
    String positiveButtonText = 'OK',
    VoidCallback? onNegativePressed,
    String? negativeButtonText,
  }) {
    if (!mounted) return;
    showDialog(
      context: this,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null
              ? null
              : Text(
                  title,
                  style: TextStyle(
                      color: context.onSurfaceColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
          content: Text(
            content,
            style: TextStyle(
                color: context.onSurfaceColor,
                fontSize: 16,
                fontWeight: FontWeight.normal),
          ),
          contentPadding: const EdgeInsetsDirectional.only(
              start: 24, end: 24, top: 16, bottom: 0),
          actionsPadding: p16,
          actions: <Widget>[
            TextButton(
              onPressed: onNegativePressed ??
                  () {
                    pop();
                  },
              child: Text(negativeButtonText ?? LocaleKeys.cancel.tr()),
            ),
            TextButton(
              onPressed: onPositivePressed ??
                  () {
                    pop();
                  },
              child: Text(positiveButtonText),
            ),
          ],
        );
      },
    );
  }

  Future<T?> showDialogNow<T extends Object?>({
    bool barrierDismissible = true,
    String title = 'Dialog',
    ShapeBorder? shape,
    EdgeInsets? insetPadding,
    required Widget child,
  }) async {
    if (!mounted) return null;
    return await showGeneralDialog<T>(
      context: this,
      barrierLabel: title,
      barrierDismissible: barrierDismissible,
      pageBuilder: (context, animation, secondaryAnimation) => SafeArea(
        child: Dialog(
          shape: shape ?? 16.roundedBorder(),
          insetPadding: insetPadding ??
              const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: child,
        ),
      ),
    );
  }

  Future<T?> showBottomSheetNow<T>({
    bool isScrollControlled = false,
    double topBorderRadius = 40,
    required Widget child,
  }) async {
    if (!mounted) return null;
    return await showModalBottomSheet(
      context: this,
      clipBehavior: Clip.hardEdge,
      // backgroundColor: onTertiaryContainerColor,
      isScrollControlled: isScrollControlled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(topBorderRadius),
          topEnd: Radius.circular(topBorderRadius),
        ),
      ),
      builder: (BuildContext context) => child,
    );
  }

  Future<T?> showPopupMenu<T>({
    required TapDownDetails details,
    required List<PopupMenuEntry<T>> menuItems,
  }) async {
    if (!mounted) return null;
    final offset = details.globalPosition;

    return await showMenu(
      context: this,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        width - offset.dx,
        height - offset.dy,
      ),
      shape: 12.roundedBorder(),
      // color: onTertiaryContainerColor,
      items: menuItems,
    );
  }
}

extension WidgetExt on Widget {
  Expanded expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  Flexible flexible({int flex = 1}) => Flexible(flex: flex, child: this);

  Padding withPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);

  SizedBox box({double? width, double? height}) =>
      SizedBox(width: width, height: height, child: this);

  Center center() => Center(child: this);

  Container container(Color color) => Container(color: color, child: this);
}

PopupMenuItem getMenuItem(
        BuildContext context, String text, void Function()? onTap) =>
    PopupMenuItem(
      value: text,
      height: 40,
      onTap: onTap,
      child: Text(text, style: TextStyles.popupMenuTextStyle(context)),
    );
