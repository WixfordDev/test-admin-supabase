import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/widgets/app_webview.dart';

class LegalWebviewScreen extends StatelessWidget {
  final String title;
  final String url;

  const LegalWebviewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: title,
      child: AppWebview(
        url: url,
        bgColor: ThemeColors.white,
      ),
    );
  }
}
