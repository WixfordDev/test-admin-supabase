import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class FilledBorderButtonWidget extends StatelessWidget {
  final String text;
  final Color? textColor;
  final void Function()? onPressed;

  const FilledBorderButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        fixedSize: Size(context.width, 48),
        foregroundColor: textColor ?? context.onSurfaceColor,
        backgroundColor: context.primaryColor,
        shape: 16.roundedBorder(),
        side: BorderSide(
          width: 2.0,
          color: context.onSurfaceColor.withValues(alpha: .5),
        ),
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: textColor ?? context.onSurfaceColor,
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
