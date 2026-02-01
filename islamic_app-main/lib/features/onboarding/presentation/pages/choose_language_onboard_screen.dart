import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/onboarding/presentation/widgets/onboard_app_bar_scaffold.dart';
import 'package:deenhub/core/widgets/list_view/radio_button_list_view.dart';
import 'package:deenhub/features/settings/domain/utils/language_options.dart';

class ChooseLanguageOnboardScreen extends StatefulWidget {
  const ChooseLanguageOnboardScreen({super.key});

  @override
  State<ChooseLanguageOnboardScreen> createState() => _ChooseLanguageOnboardScreenState();
}

class _ChooseLanguageOnboardScreenState extends State<ChooseLanguageOnboardScreen> {
  LanguageOption _selectedLanguage = LanguageOption.device;

  @override
  Widget build(BuildContext context) {
    return OnboardAppBarScaffold(
      pageTitle: context.tr(LocaleKeys.chooseUrLanguage),
      showBackButton: false,
      showBgAtBottom: true,
      useScrollView: false,
      onNextButtonClick: () {
        context.pushNamed(Routes.getPrayerTimesOnboard.name);
      },
      children: [
        RadioButtonListView<LanguageOption>(
          list: LanguageOption.values,
          groupValue: _selectedLanguage,
          getItemLabel: (item) => item.label,
          onChanged: (value) {
            if (value != null) {
              _selectedLanguage = value;
              getIt<SharedPrefsHelper>().setDeviceLanguage = value;
              context.setLocale(value.localeName.toLocale());
            }
          },
        ).expanded(),
      ],
    );
  }
}
