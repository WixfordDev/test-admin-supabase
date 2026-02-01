import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/quran/domain/models/memorization_model.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/settings/models/verse_view_settings.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/widgets/memorization_reading_mode_widgets.dart';
import 'package:flutter/material.dart';

class VerseCardWidget extends StatelessWidget {
  final Ayah ayah;
  final bool isCurrentVerse;
  final MemorizationStatus? verseStatus;
  final bool isResultVerse;
  final bool isMemorizationMode;
  final bool isPlaying;
  final Widget arabicTextWidget;
  final int currentHighlightedWordIndex;
  final Map<int, String> verseExplanations;
  final Map<int, bool> isLoadingExplanation;
  final int repeatCount;
  final double playbackSpeed;
  final String selectedLanguage;
  final VoidCallback onVerseTap;
  final VoidCallback onPlayAudio;
  final VoidCallback onPlayOtherVerse;
  final VoidCallback onGetAIExplanation;
  final VoidCallback onRemoveExplanation;
  final VoidCallback onDecreaseRepeatCount;
  final VoidCallback onIncreaseRepeatCount;
  final Function(double) onChangePlaybackSpeed;
  final Function(MemorizationStatus) onUpdateMemorizationStatus;
  final Function(String) onShowLoginRequiredDialog;
  final Function(int) getStatusColor;
  final Function(int) getStatusIcon;
  final Function(int, String) onReportAIExplanation;
  final VoidCallback? onShowSubscriptionRequiredDialog;
  final VerseViewSettings? verseViewSettings;

  const VerseCardWidget({
    super.key,
    required this.ayah,
    required this.isCurrentVerse,
    required this.verseStatus,
    required this.isResultVerse,
    required this.isMemorizationMode,
    required this.isPlaying,
    required this.arabicTextWidget,
    required this.currentHighlightedWordIndex,
    required this.verseExplanations,
    required this.isLoadingExplanation,
    required this.repeatCount,
    required this.playbackSpeed,
    required this.selectedLanguage,
    required this.onVerseTap,
    required this.onPlayAudio,
    required this.onPlayOtherVerse,
    required this.onGetAIExplanation,
    required this.onRemoveExplanation,
    required this.onDecreaseRepeatCount,
    required this.onIncreaseRepeatCount,
    required this.onChangePlaybackSpeed,
    required this.onUpdateMemorizationStatus,
    required this.onShowLoginRequiredDialog,
    required this.getStatusColor,
    required this.getStatusIcon,
    required this.onReportAIExplanation,
    this.onShowSubscriptionRequiredDialog,
    this.verseViewSettings,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onVerseTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentVerse ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isCurrentVerse)
              BoxShadow(
                color: context.primaryColor.withValues(alpha: 0.2),
                blurRadius: 12.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8.0,
                spreadRadius: 0.0,
                offset: const Offset(0, 2),
              ),
          ],
          border: isResultVerse && isCurrentVerse
              ? Border.all(color: Colors.red, width: 2)
              : (verseStatus == MemorizationStatus.memorized && !isCurrentVerse
                  ? Border.all(color: Color(0xFF4CAF50), width: 2)
                  : (isCurrentVerse
                      ? Border.all(color: context.primaryColor, width: 2)
                      : Border.all(
                          color: ThemeColors.darkGray.withValues(alpha: 0.3),
                          width: 1))),
          gradient: isCurrentVerse
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.95),
                  ],
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verse header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrentVerse
                            ? context.primaryColor
                            : context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isCurrentVerse
                            ? [
                                BoxShadow(
                                  color: context.primaryColor
                                      .withValues(alpha: 0.3),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        'Verse ${ayah.numberInSurah}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isCurrentVerse
                              ? Colors.white
                              : context.primaryColor,
                        ),
                      ),
                    ),
                    if (verseStatus != null && !isCurrentVerse) ...[
                      const SizedBox(width: 8),
                      Icon(
                        getStatusIcon(ayah.numberInSurah),
                        size: 16,
                        color: getStatusColor(ayah.numberInSurah),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    if (verseStatus != null && isCurrentVerse) ...[
                      Icon(
                        getStatusIcon(ayah.numberInSurah),
                        size: 20,
                        color: getStatusColor(ayah.numberInSurah),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (isCurrentVerse)
                      Container(
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? Colors.red.shade600
                              : context.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isPlaying
                                      ? Colors.red.shade600
                                      : context.primaryColor)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8.0,
                              spreadRadius: 1.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.stop : Icons.play_arrow,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: onPlayAudio,
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.grey,
                        ),
                        onPressed: onPlayOtherVerse,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Arabic text
            if (ayah.text.isNotEmpty)
              Container(
                width: double.infinity,
                decoration: isCurrentVerse
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.primaryColor.withValues(alpha: 0.08),
                            context.primaryColor.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.primaryColor.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      )
                    : null,
                padding: isCurrentVerse
                    ? const EdgeInsets.all(12)
                    : const EdgeInsets.all(4),
                child: arabicTextWidget,
              ),

            // Transliteration
            if (ayah.transliteration.isNotEmpty && (verseViewSettings?.showTransliteration ?? true))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  ayah.transliteration,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: isCurrentVerse
                        ? Colors.teal.shade700
                        : Colors.teal.shade600,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Translation based on selected language
            if (verseViewSettings?.showTranslation ?? true)
              Builder(
                builder: (context) {
                  final translationText =
                      selectedLanguage == 'bn' ? ayah.textBn : ayah.textEn;
                  if (translationText.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      translationText,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color:
                            isCurrentVerse ? Color(0xFF37474F) : Colors.black87,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
                },
              ),

            // AI Explanation
            if ((verseViewSettings?.showAiExplanation ?? true) && verseExplanations.containsKey(ayah.numberInSurah)) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.teal.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology_alt,
                          size: 16,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "AI Explanation",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.teal,
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.teal.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => onReportAIExplanation(
                                  ayah.numberInSurah,
                                  verseExplanations[ayah.numberInSurah]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.flag_outlined,
                                        size: 14,
                                        color: Colors.teal.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Report',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.teal.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 16,
                                color: isCurrentVerse
                                    ? Colors.white70
                                    : Colors.black45,
                              ),
                              onPressed: onRemoveExplanation,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      verseExplanations[ayah.numberInSurah]!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons
            if (verseViewSettings?.showAiExplanation ?? true) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                  onPressed: onGetAIExplanation,
                  icon: isLoadingExplanation[ayah.numberInSurah] == true
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.teal,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.psychology_alt,
                          size: 16,
                          color: Colors.teal,
                        ),
                  label: Text(
                    verseExplanations.containsKey(ayah.numberInSurah)
                        ? "Hide Explanation"
                        : "AI Explanation",
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal.withValues(alpha: 0.05),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            ],

            // Memorization controls for current verse
            if (isCurrentVerse && isMemorizationMode && (verseViewSettings?.showMemorizationStatus ?? true)) ...[
              gapH16,
              MemorizationControlsWidget(
                repeatCount: repeatCount,
                playbackSpeed: playbackSpeed,
                verseStatus: verseStatus,
                onDecreaseRepeatCount: onDecreaseRepeatCount,
                onIncreaseRepeatCount: onIncreaseRepeatCount,
                onChangePlaybackSpeed: onChangePlaybackSpeed,
                onUpdateMemorizationStatus: onUpdateMemorizationStatus,
                onShowLoginRequiredDialog: onShowLoginRequiredDialog,
                onShowSubscriptionRequiredDialog: onShowSubscriptionRequiredDialog,
                showRepeatButton: verseViewSettings?.showRepeatButton ?? true,
                showSpeedControls: verseViewSettings?.showSpeedControls ?? true,
                showMemorizationStatus: verseViewSettings?.showMemorizationStatus ?? true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SingleVerseNavigationWidget extends StatelessWidget {
  final int currentVerseId;
  final int totalVerses;
  final VoidCallback? onPreviousVerse;
  final VoidCallback? onNextVerse;

  const SingleVerseNavigationWidget({
    super.key,
    required this.currentVerseId,
    required this.totalVerses,
    this.onPreviousVerse,
    this.onNextVerse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                visualDensity: VisualDensity.compact,
                onPressed: currentVerseId > 1 ? onPreviousVerse : null,
                color: currentVerseId > 1 ? Colors.black : Colors.grey,
              ),
              Text(
                'Verse $currentVerseId of $totalVerses',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                visualDensity: VisualDensity.compact,
                onPressed: currentVerseId < totalVerses ? onNextVerse : null,
                color:
                    currentVerseId < totalVerses ? Colors.black : Colors.grey,
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
