import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/settings/models/verse_view_settings.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/settings/widgets/verse_preview_card.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/settings/widgets/verse_settings_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerseViewSettingsScreen extends StatefulWidget {
  const VerseViewSettingsScreen({super.key});

  @override
  State<VerseViewSettingsScreen> createState() =>
      _VerseViewSettingsScreenState();
}

class _VerseViewSettingsScreenState extends State<VerseViewSettingsScreen> {
  late VerseViewSettings _settings;
  late SharedPrefsHelper _prefsHelper;
  bool _settingsChanged = false;

  // Sample verse for preview
  late Ayah _sampleAyah;

  @override
  void initState() {
    super.initState();
    _prefsHelper = getIt<SharedPrefsHelper>();
    _loadSettings();

    // Create a sample ayah for preview
    _sampleAyah = Ayah(
      number: 1,
      audio: '',
      audioSecondary: [],
      text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      numberInSurah: 1,
      juz: 1,
      textEn: 'In the name of Allah, the Gracious, the Merciful',
      textBn: 'পরম করুণাময় অসীম দয়ালু আল্লাহর নামে',
      transliteration: 'Bismillaahir Rahmaanir Raheem',
      wordTiming: null,
    );
  }

  void _loadSettings() {
    final settingsJson = _prefsHelper.getVerseViewSettings();
    setState(() {
      _settings = VerseViewSettings.fromJson(settingsJson ?? {});
    });
  }

  void _saveSettings() {
    _prefsHelper.saveVerseViewSettings(_settings.toJson());
  }

  void _updateSetting(String key, bool value) {
    setState(() {
      switch (key) {
        case 'showTransliteration':
          _settings = _settings.copyWith(showTransliteration: value);
          break;
        case 'showTranslation':
          _settings = _settings.copyWith(showTranslation: value);
          break;
        case 'showRepeatButton':
          _settings = _settings.copyWith(showRepeatButton: value);
          break;
        case 'showSpeedControls':
          _settings = _settings.copyWith(showSpeedControls: value);
          break;
        case 'showMemorizationStatus':
          _settings = _settings.copyWith(showMemorizationStatus: value);
          break;
        case 'showAiExplanation':
          _settings = _settings.copyWith(showAiExplanation: value);
          break;
      }
    });
    _settingsChanged = true;
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          // Return true if settings were changed
          GoRouter.of(context).pop(_settingsChanged);
        }
      },
      child: AppBarScaffold(
        pageTitle: 'Verse View Settings',
        centerTitle: true,
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customize your verse view experience',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            gapH16,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Settings checkboxes
                    VerseSettingsItem(
                      title: 'Show Transliteration',
                      subtitle:
                          'Display Arabic text with English transliteration',
                      value: _settings.showTransliteration,
                      onChanged: (value) =>
                          _updateSetting('showTransliteration', value),
                    ),
                    VerseSettingsItem(
                      title: 'Show Translation',
                      subtitle: 'Display English translation of verses',
                      value: _settings.showTranslation,
                      onChanged: (value) =>
                          _updateSetting('showTranslation', value),
                    ),
                    VerseSettingsItem(
                      title: 'Show Repeat Button',
                      subtitle: 'Allow repeating verses multiple times',
                      value: _settings.showRepeatButton,
                      onChanged: (value) =>
                          _updateSetting('showRepeatButton', value),
                    ),
                    VerseSettingsItem(
                      title: 'Show Speed Controls',
                      subtitle: 'Allow adjusting audio playback speed',
                      value: _settings.showSpeedControls,
                      onChanged: (value) =>
                          _updateSetting('showSpeedControls', value),
                    ),
                    VerseSettingsItem(
                      title: 'Show Memorization Status',
                      subtitle:
                          'Display and allow changing memorization status',
                      value: _settings.showMemorizationStatus,
                      onChanged: (value) =>
                          _updateSetting('showMemorizationStatus', value),
                    ),
                    VerseSettingsItem(
                      title: 'Show AI Explanation',
                      subtitle:
                          'Allow getting AI-powered explanations of verses',
                      value: _settings.showAiExplanation,
                      onChanged: (value) =>
                          _updateSetting('showAiExplanation', value),
                    ),
                    gapH24,

                    // Live preview section
                    Text(
                      'Live Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    gapH12,
                    Text(
                      'Sample Verse (Al-Fatiha 1:1)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    gapH8,
                    // Preview verse card with current settings
                    VersePreviewCard(
                      settings: _settings,
                      sampleAyah: _sampleAyah,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
