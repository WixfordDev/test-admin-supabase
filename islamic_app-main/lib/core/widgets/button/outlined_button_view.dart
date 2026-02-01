import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class OutlinedButtonView extends StatelessWidget {
  final String text;
  final bool useFixedSize;
  final bool enabled;
  final double fontSize;
  final double? width;
  final double? height;
  final void Function()? onPressed;

  const OutlinedButtonView({
    super.key,
    required this.text,
    this.useFixedSize = true,
    this.enabled = true,
    this.fontSize = 16,
    this.width,
    this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        fixedSize: useFixedSize ? Size(width ?? context.width, height ?? 52) : null,
        foregroundColor: context.primaryColor,
        shape: 48.roundedBorder(),
        side: BorderSide(
          width: 2.0,
          color: context.primaryColor.withValues(alpha: .3),
        ),
        textStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: fontSize,
          color: context.primaryColor,
        ),
        disabledForegroundColor: context.primaryColor.withValues(alpha: .3),
      ),
      onPressed: enabled ? onPressed : null,
      child: Text(text),
    );
  }
}
