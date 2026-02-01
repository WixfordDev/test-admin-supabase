import 'package:deenhub/features/quran/domain/models/memorization_model.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/settings/models/verse_view_settings.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/verse_card_widget.dart';
import 'package:flutter/material.dart';

class VersePreviewCard extends StatelessWidget {
  final VerseViewSettings settings;
  final Ayah sampleAyah;

  const VersePreviewCard({
    super.key,
    required this.settings,
    required this.sampleAyah,
  });

  @override
  Widget build(BuildContext context) {
    // Create preview settings - always show all controls so users can see what they look like
    final previewSettings = VerseViewSettings(
      showTransliteration: settings.showTransliteration,
      showTranslation: settings.showTranslation,
      showRepeatButton: settings.showRepeatButton, // Always show repeat button in preview
      showSpeedControls: settings.showSpeedControls, // Always show speed controls in preview
      showMemorizationStatus: settings.showMemorizationStatus, // Always show memorization status in preview
      showAiExplanation: settings.showAiExplanation,
    );

    return VerseCardWidget(
      ayah: sampleAyah,
      isCurrentVerse: true, // Always show as current for preview
      verseStatus: MemorizationStatus.notStarted, // Default status for preview
      isResultVerse: false,
      isMemorizationMode: true, // Always show memorization controls in preview
      isPlaying: false, // Not playing in preview
      arabicTextWidget: _buildArabicTextPreview(sampleAyah),
      currentHighlightedWordIndex: -1, // No highlighting in preview
      verseExplanations: const {}, // No explanations in preview
      isLoadingExplanation: const {}, // No loading state
      repeatCount: 1, // Default repeat count
      playbackSpeed: 1.0, // Default speed
      selectedLanguage: 'en', // Default language
      onVerseTap: () {}, // No-op for preview
      onPlayAudio: () {}, // No-op for preview
      onPlayOtherVerse: () {}, // No-op for preview
      onGetAIExplanation: () {}, // No-op for preview
      onRemoveExplanation: () {}, // No-op for preview
      onDecreaseRepeatCount: () {}, // No-op for preview
      onIncreaseRepeatCount: () {}, // No-op for preview
      onChangePlaybackSpeed: (speed) {}, // No-op for preview
      onUpdateMemorizationStatus: (status) {}, // No-op for preview
      onShowLoginRequiredDialog: (feature) {}, // No-op for preview
      getStatusColor: (verseId) => Colors.grey, // Default color
      getStatusIcon: (verseId) => Icons.bookmark_border, // Default icon
      onReportAIExplanation: (verseNumber, explanation) {}, // No-op for preview
      onShowSubscriptionRequiredDialog: () {}, // No-op for preview
      verseViewSettings: previewSettings, // Use preview settings that always show memorization status
    );
  }

  Widget _buildArabicTextPreview(Ayah ayah) {
    // Simple Arabic text display for preview (no highlighting needed)
    return RichText(
      text: TextSpan(
        text: ayah.text,
        style: const TextStyle(
          fontSize: 20,
          height: 2.5,
          fontFamily: 'Amiri',
          fontWeight: FontWeight.bold,
          color: Color(0xFF293241),
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }
}
