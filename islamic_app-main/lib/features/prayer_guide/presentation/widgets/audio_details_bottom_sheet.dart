import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/widgets/audio_player_button.dart';

class AudioDetailsBottomSheet {
  static void show({
    required BuildContext context,
    required String title,
    required String audioKey,
    required String arabicText,
    required String transliteration,
    required String translation,
    required Color color,
    required IconData icon,
    String? description,
    List<Widget>? additionalContent,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: ThemeColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Header with audio controls
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    gapH16,
                    
                    // Header content
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: ThemeColors.white, size: 28),
                        ),
                        gapW16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              if (description != null) ...[
                                gapH4,
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ThemeColors.darkGray.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        gapW8,
                        AudioPlayerButton(
                          audioKey: audioKey,
                          label: 'Listen',
                          color: color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Audio guidance
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ThemeColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ThemeColors.blue.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ThemeColors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.headphones_rounded,
                                color: ThemeColors.white,
                                size: 20,
                              ),
                            ),
                            gapW12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "🎧 Audio Pronunciation Guide",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeColors.blue,
                                    ),
                                  ),
                                  gapH4,
                                  Text(
                                    "Listen to learn the correct pronunciation • Perfect for beginners",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ThemeColors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      gapH24,
                      
                      // Arabic Text Section
                      _buildTextSection(
                        "Arabic Text",
                        arabicText,
                        Icons.menu_book_rounded,
                        ThemeColors.green,
                        isArabic: true,
                      ),
                      
                      gapH16,
                      
                      // Transliteration Section
                      _buildTextSection(
                        "Transliteration (Pronunciation)",
                        transliteration,
                        Icons.record_voice_over,
                        ThemeColors.blue,
                        isItalic: true,
                      ),
                      
                      gapH16,
                      
                      // Translation Section
                      _buildTextSection(
                        "English Translation",
                        translation,
                        Icons.translate,
                        ThemeColors.orange,
                      ),
                      
                      // Additional content if provided
                      if (additionalContent != null) ...[
                        gapH24,
                        ...additionalContent,
                      ],
                      
                      gapH32,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildTextSection(
    String title,
    String text,
    IconData icon,
    Color color, {
    bool isArabic = false,
    bool isItalic = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                gapW8,
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          
          // Text content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: isArabic ? 'ScheherazadeNew' : null,
                fontSize: isArabic ? 24 : 16,
                height: isArabic ? 2.0 : 1.6,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                color: ThemeColors.darkGray,
                fontWeight: isArabic ? FontWeight.w500 : FontWeight.normal,
              ),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isArabic ? TextAlign.center : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
} 