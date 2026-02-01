import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/onboarding/presentation/widgets/wavy_circle_clipper.dart';

class OnboardAppBarScaffold extends StatelessWidget {
  final String pageTitle;
  final String nextButtonLabel;
  final bool useScrollView;
  final bool showBackButton;
  final bool showNextButton;
  final bool showBgAtBottom;
  final bool? resizeToAvoidBottomInset;
  final void Function()? onNextButtonClick;
  final List<Widget> children;

  const OnboardAppBarScaffold({
    super.key,
    required this.pageTitle,
    this.nextButtonLabel = LocaleKeys.next,
    this.showBackButton = true,
    this.showNextButton = true,
    this.showBgAtBottom = false,
    this.useScrollView = true,
    this.resizeToAvoidBottomInset,
    this.onNextButtonClick,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final width = context.width;
    final horizontalInset = -(width * 0.4);
    final verticalInset = -(width * 0.3);
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: Stack(
          children: [
            PositionedDirectional(
              end: showBgAtBottom ? null : horizontalInset,
              top: showBgAtBottom ? null : verticalInset,
              start: showBgAtBottom ? horizontalInset : null,
              bottom: showBgAtBottom ? verticalInset : null,
              child: _buildWavyCircleView(context),
            ),
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (useScrollView) const Spacer(),
                  useScrollView
                      ? _buildScrollView(context).box(width: width)
                      : _buildScrollView(context).box(width: width).expanded(),
                  if (useScrollView) const Spacer(),
                  if (showBackButton || showNextButton)
                    Row(
                      children: [
                        if (showBackButton)
                          TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: Text(
                              context.tr(LocaleKeys.back),
                              style: TextStyle(
                                color: context.primaryColor,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (showNextButton) ...[
                          const Spacer(),
                          TextButton(
                            onPressed: onNextButtonClick,
                            child: Text(
                              context.tr(nextButtonLabel),
                              style: TextStyle(
                                color: context.primaryColor,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ).withPadding(p24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollView(BuildContext context) {
    return useScrollView
        ? SingleChildScrollView(
            padding: p24,
            child: _buildContent(context),
          )
        : _buildContent(context).withPadding(p24);
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        gapH24,
        Text(
          pageTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.primaryColor,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        gapH24,
        ...children,
        gapH16,
      ],
    );
  }

  Widget _buildWavyCircleView(BuildContext context) {
    final width = context.width;
    return ClipPath(
      clipper: WavyCircleClipper(20),
      child: Container(
        width: width,
        height: width,
        color: context.primaryColor.withValues(alpha: .1),
      ),
    );
  }
}
