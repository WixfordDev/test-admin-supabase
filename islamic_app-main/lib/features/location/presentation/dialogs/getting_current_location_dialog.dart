import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/onboarding/presentation/blocs/onboard_settings_bloc.dart';

class GettingCurrentLocationDialog extends StatelessWidget {
  final String? title;

  const GettingCurrentLocationDialog({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        gapH16,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator.adaptive(strokeWidth: 3).box(width: 24, height: 24),
            gapW16,
            Text(
              title ?? context.tr(LocaleKeys.gettingCurrentLocation),
              style: TextStyle(
                color: context.onSurfaceColor,
                fontSize: 18,
              ),
            ),
          ],
        ).center(),
        gapH24,
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () {
              getIt<OnboardSettingsBloc>().add(
                const OnboardSettingsEvent.cancelFetchingCurrentLocation(),
              );
            },
            child: Text(context.tr(LocaleKeys.cancel)),
          ),
        ).withPadding(8.endPadding),
        gapH16,
      ],
    );
  }
}
