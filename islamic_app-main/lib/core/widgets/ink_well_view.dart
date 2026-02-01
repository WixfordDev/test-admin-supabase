import 'package:flutter/material.dart';

class InkWellView extends StatelessWidget {
  final ShapeBorder? shapeBorder;
  final void Function()? onTap;
  final void Function(TapDownDetails)? onTapDown;
  final Widget child;

  const InkWellView({
    super.key,
    this.shapeBorder,
    this.onTap,
    this.onTapDown,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: shapeBorder,
        onTap: onTap,
        onTapDown: onTapDown,
        child: child,
      ),
    );
  }
}
