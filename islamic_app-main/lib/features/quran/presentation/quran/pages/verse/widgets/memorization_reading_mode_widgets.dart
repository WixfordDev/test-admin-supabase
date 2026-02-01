import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/features/quran/domain/models/memorization_model.dart';

class ControlButtonsWidget extends StatelessWidget {
  final bool singleVerseMode;
  final String selectedLanguage;
  final Color selectedBgColor;
  final Color unselectedBgColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final VoidCallback onToggleSingleVerseMode;
  final Function(String) onLanguageChanged;

  const ControlButtonsWidget({
    super.key,
    required this.singleVerseMode,
    required this.selectedLanguage,
    required this.selectedBgColor,
    required this.unselectedBgColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.onToggleSingleVerseMode,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: onToggleSingleVerseMode,
          icon: Icon(
            singleVerseMode ? Icons.fullscreen : Icons.view_list,
            color: singleVerseMode ? selectedTextColor : unselectedTextColor,
            size: 18,
          ),
          label: Text(
            singleVerseMode ? 'Focus Mode On' : 'Focus Mode Off',
            style: TextStyle(
              color: singleVerseMode ? selectedTextColor : unselectedTextColor,
              fontSize: 12,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: singleVerseMode
                ? selectedBgColor
                : unselectedBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: selectedBgColor,
            borderRadius: BorderRadius.circular(32),
          ),
          child: DropdownButton<String>(
            value: selectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null) {
                onLanguageChanged(newValue);
              }
            },
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: selectedTextColor),
            style: TextStyle(
              color: selectedTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            items: const [
              DropdownMenuItem<String>(
                value: 'en',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language, size: 16, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('English', style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: 'bn',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language, size: 16, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Bangla', style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MemorizationControlsWidget extends StatelessWidget {
  final int repeatCount;
  final double playbackSpeed;
  final MemorizationStatus? verseStatus;
  final VoidCallback onDecreaseRepeatCount;
  final VoidCallback onIncreaseRepeatCount;
  final Function(double) onChangePlaybackSpeed;
  final Function(MemorizationStatus) onUpdateMemorizationStatus;
  final Function(String) onShowLoginRequiredDialog;
  final VoidCallback? onShowSubscriptionRequiredDialog;
  final bool showRepeatButton;
  final bool showSpeedControls;
  final bool showMemorizationStatus;

  const MemorizationControlsWidget({
    super.key,
    required this.repeatCount,
    required this.playbackSpeed,
    required this.verseStatus,
    required this.onDecreaseRepeatCount,
    required this.onIncreaseRepeatCount,
    required this.onChangePlaybackSpeed,
    required this.onUpdateMemorizationStatus,
    required this.onShowLoginRequiredDialog,
    this.onShowSubscriptionRequiredDialog,
    this.showRepeatButton = true,
    this.showSpeedControls = true,
    this.showMemorizationStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Playback controls
        if (showRepeatButton || showSpeedControls) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Repeat control
                if (showRepeatButton) ...[
                  Row(
                    children: [
                      Icon(Icons.repeat, size: 18, color: context.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Repeat',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.primaryColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: onDecreaseRepeatCount,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  color: context.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '$repeatCount×',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onIncreaseRepeatCount,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  color: context.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).withPadding(px12),
                ],
                if (showRepeatButton && showSpeedControls) gapH12,
                // Playback speed
                if (showSpeedControls) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 18,
                        color: context.primaryColor,
                      ).withPadding(12.startPadding),
                      const SizedBox(width: 8),
                      Text(
                        'Speed',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${playbackSpeed.toStringAsFixed(2)}×',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: context.primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: context.primaryColor,
                            inactiveTrackColor: context.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                              elevation: 2,
                            ),
                            overlayColor: context.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: playbackSpeed,
                            min: 0.25,
                            max: 2.0,
                            divisions: 7,
                            onChanged: onChangePlaybackSpeed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],

        // Only show gap if memorization status will be shown
        if (showMemorizationStatus) gapH12,

        // Memorization status
        if (showMemorizationStatus) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 18,
                        color: context.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Memorization Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MemorizationStatusButton(
                      status: MemorizationStatus.notStarted,
                      icon: Icons.inventory,
                      label: 'New',
                      color: Color(0xFF9E9E9E),
                      lightColor: Color(0xFFEEEEEE),
                      currentStatus: verseStatus,
                      onTap: () => onUpdateMemorizationStatus(
                        MemorizationStatus.notStarted,
                      ),
                      onShowLoginRequiredDialog: onShowLoginRequiredDialog,
                    ).expanded(),
                    const SizedBox(width: 4),
                    MemorizationStatusButton(
                      status: MemorizationStatus.learning,
                      icon: Icons.school,
                      label: 'Learning',
                      color: Color(0xFF2196F3),
                      lightColor: Color(0xFFE3F2FD),
                      currentStatus: verseStatus,
                      onTap: () => onUpdateMemorizationStatus(
                        MemorizationStatus.learning,
                      ),
                      onShowLoginRequiredDialog: onShowLoginRequiredDialog,
                    ).expanded(),
                    const SizedBox(width: 4),
                    MemorizationStatusButton(
                      status: MemorizationStatus.reviewing,
                      icon: Icons.refresh,
                      label: 'Reviewing',
                      color: Color(0xFFFF9800),
                      lightColor: Color(0xFFFFF3E0),
                      currentStatus: verseStatus,
                      onTap: () => onUpdateMemorizationStatus(
                        MemorizationStatus.reviewing,
                      ),
                      onShowLoginRequiredDialog: onShowLoginRequiredDialog,
                    ).expanded(),
                    const SizedBox(width: 4),
                    MemorizationStatusButton(
                      status: MemorizationStatus.memorized,
                      icon: Icons.check_circle,
                      label: 'Memorized',
                      color: Color(0xFF4CAF50),
                      lightColor: Color(0xFFE8F5E9),
                      currentStatus: verseStatus,
                      onTap: () => onUpdateMemorizationStatus(
                        MemorizationStatus.memorized,
                      ),
                      onShowLoginRequiredDialog: onShowLoginRequiredDialog,
                    ).expanded(),
                  ],
                ).withPadding(p8),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class MemorizationStatusButton extends StatelessWidget {
  final MemorizationStatus status;
  final IconData icon;
  final String label;
  final Color color;
  final Color lightColor;
  final MemorizationStatus? currentStatus;
  final VoidCallback onTap;
  final Function(String) onShowLoginRequiredDialog;

  const MemorizationStatusButton({
    super.key,
    required this.status,
    required this.icon,
    required this.label,
    required this.color,
    required this.lightColor,
    required this.currentStatus,
    required this.onTap,
    required this.onShowLoginRequiredDialog,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentStatus == status;
    final prefsHelper = getIt<SharedPrefsHelper>();
    final isLoggedIn = prefsHelper.isLoggedIn;

    return InkWell(
      onTap: () => isLoggedIn
          ? onTap()
          : onShowLoginRequiredDialog('memorization status'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : lightColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
