import 'package:deenhub/config/themes/styles.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class NavigationActionButton extends StatelessWidget {
  final Widget icon;
  final String? text;
  final bool usePadding;
  final bool useCircleBackground;
  final Size? size;
  final ButtonStyle? style;
  final Color? backgroundColor;
  final Color? borderColor;
  final String Function(BuildContext context)? getTooltip;
  final VoidCallback? onPressed;

  const NavigationActionButton({
    super.key,
    required this.icon,
    this.text,
    this.usePadding = false,
    this.useCircleBackground = false,
    this.size,
    this.style,
    this.backgroundColor,
    this.borderColor,
    this.getTooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return (useCircleBackground
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor ?? context.onTertiaryColor.withValues(alpha: .20),
                  border: borderColor != null ? Border.all(color: borderColor!) : null,
                ),
                child: _buildIconButton(context),
              )
            : _buildIconButton(context))
        .withPadding(usePadding ? p8 : p0);
  }

  Widget _buildIconButton(BuildContext context) {
    return text != null
        ? TextButton.icon(
            onPressed: onPressed,
            icon: icon,
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(
                context.onTertiaryColor,
              ),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
                  if (states.contains(WidgetState.pressed)) {
                    return context.onTertiaryColor.withValues(alpha: .20); // Splash color on press
                  }
                  return null; // No overlay for other states
                },
              ),
            ),
            label: Text(text!),
          )
        : IconButton(
            constraints: size != null ? BoxConstraints.tight(size!) : null,
            icon: icon,
            style: style,
            tooltip: getTooltip?.call(context),
            onPressed: onPressed,
          );
  }
}
