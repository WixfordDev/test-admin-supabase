import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class LoadingView extends StatelessWidget {
  final Color? color;

  const LoadingView({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator.adaptive(
      valueColor: color == null ? null : AlwaysStoppedAnimation<Color>(color!),
    ).center();
  }
}
