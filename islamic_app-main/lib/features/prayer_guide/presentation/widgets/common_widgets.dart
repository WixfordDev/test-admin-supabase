import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/widgets/audio_player_button.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/audio_details_bottom_sheet.dart';

class CommonWidgets {
  
  /// Compact button that shows audio details in a bottom sheet
  static Widget buildAudioDetailsButton({
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
    bool isCompact = true,
  }) {
    return GestureDetector(
      onTap: () {
        AudioDetailsBottomSheet.show(
          context: context,
          title: title,
          audioKey: audioKey,
          arabicText: arabicText,
          transliteration: transliteration,
          translation: translation,
          color: color,
          icon: icon,
          description: description,
          additionalContent: additionalContent,
        );
      },
      child: Container(
        padding: EdgeInsets.all(isCompact ? 8 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.volume_up_rounded,
              color: ThemeColors.white,
              size: isCompact ? 16 : 18,
            ),
            if (!isCompact) ...[
              SizedBox(width: 6),
              Text(
                "Details",
                style: TextStyle(
                  color: ThemeColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  static Widget buildDetailCard(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: p16,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                gapW8,
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildCompactArabicText(
      String arabic, String transliteration, String translation, {String? audioKey}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeColors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Arabic text with optional audio button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      arabic,
                      style: const TextStyle(
                        fontFamily: 'ScheherazadeNew',
                        fontSize: 16,
                        height: 1.8,
                        color: ThemeColors.darkGray,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (audioKey != null) ...[
                    // gapW8,
                    CompactAudioButton(
                      audioKey: audioKey,
                      color: ThemeColors.green,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        gapH6,
        Text(
          transliteration,
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: ThemeColors.blue.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        gapH4,
        Text(
          translation,
          style: TextStyle(
            fontSize: 11,
            color: ThemeColors.darkGray.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget buildSurahFatihaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.green.withValues(alpha: 0.08),
            ThemeColors.green.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.green.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.green.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.green.withValues(alpha: 0.15),
                  ThemeColors.green.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeColors.green,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: ThemeColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Surah Al-Fatiha",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: ThemeColors.green,
                        ),
                      ),
                      Text(
                        "Must be recited in every rakat",
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeColors.darkGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                AudioPlayerButton(
                  audioKey: 'fatiha',
                  label: 'Listen',
                  color: ThemeColors.green,
                ),
              ],
            ),
          ),
          
          gapH16,
          
          // Help Section for Beginners
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ThemeColors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: ThemeColors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "🎧 Perfect for beginners! Listen to learn the correct pronunciation",
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          gapH16,
          
          // Arabic Text Section
          buildCompactArabicText(
            "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
            "Bismillahir Rahmanir Raheem\nAlhamdu lillahi rabbil alameen\nAr-Rahmanir Raheem\nMaliki yawmiddin\nIyyaka na'budu wa iyyaka nasta'een\nIhdinas siratal mustaqeem\nSiratal lazeena an'amta alayhim ghayril maghdoobi alayhim wa lad dalleen",
            "In the name of Allah, the Most Gracious, the Most Merciful\nPraise be to Allah, Lord of all the worlds\nThe Most Gracious, the Most Merciful\nMaster of the Day of Judgment\nYou alone we worship and You alone we ask for help\nGuide us to the straight path\nThe path of those You have blessed, not of those who have incurred Your wrath, nor of those who have gone astray",
            audioKey: 'fatiha',
          ),
        ],
      ),
    );
  }

  static Widget buildTakbirSection() {
    return AudioSection(
      title: "Opening Takbir",
      audioKey: 'takbir',
      color: ThemeColors.blue,
      icon: Icons.play_arrow_rounded,
      description: "Say 'Allahu Akbar' to begin prayer",
    );
  }

  static Widget buildRukuSection() {
    return AudioSection(
      title: "Ruku (Bowing)",
      audioKey: 'ruku',
      color: ThemeColors.orange,
      icon: Icons.keyboard_arrow_down_rounded,
      description: "Glory to my Lord, the Most Great",
    );
  }

  static Widget buildSujudSection() {
    return AudioSection(
      title: "Sujud (Prostration)",
      audioKey: 'sujud',
      color: ThemeColors.green,
      icon: Icons.keyboard_arrow_down_rounded,
      description: "Glory to my Lord, the Most High",
    );
  }

  static Widget buildTashahhudSection({bool isLast = false}) {
    return buildDetailCard(
      isLast ? "Final Tashahhud" : "First Tashahhud",
      Icons.record_voice_over,
      ThemeColors.blue,
      [
        Row(
          children: [
            Expanded(
              child: Text(
                "At-Tahiyyat:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            AudioPlayerButton(
              audioKey: 'tashahhud',
              label: 'Listen',
              color: ThemeColors.blue,
              size: 20,
            ),
          ],
        ),
        gapH8,
        buildCompactArabicText(
          "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
          "At-tahiyyatu lillahi was-salawatu wat-tayyibat. As-salamu alayka ayyuhan-nabiyyu wa rahmatullahi wa barakatuh. As-salamu alayna wa ala ibadillahis-salihin. Ash-hadu alla ilaha illallahu wa ash-hadu anna Muhammadan abduhu wa rasuluh",
          "All compliments, prayers and pure words are due to Allah. Peace be upon you, O Prophet, and Allah's mercy and blessings. Peace be upon us and upon all righteous servants of Allah. I bear witness that there is no deity except Allah, and I bear witness that Muhammad is His servant and messenger",
          audioKey: 'tashahhud',
        ),
        if (isLast) ...[
          gapH16,
          Row(
            children: [
              Expanded(
                child: Text(
                  "Durood Ibrahim:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              AudioPlayerButton(
                audioKey: 'durood',
                label: 'Listen',
                color: ThemeColors.green,
                size: 20,
              ),
            ],
          ),
          gapH8,
          buildCompactArabicText(
            "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
            "Allahumma salli ala Muhammadin wa ala ali Muhammad, kama sallayta ala Ibrahim wa ala ali Ibrahim, innaka hamidun majid. Allahumma barik ala Muhammadin wa ala ali Muhammad, kama barakta ala Ibrahim wa ala ali Ibrahim, innaka hamidun majid",
            "O Allah, send prayers upon Muhammad and the family of Muhammad, as You sent prayers upon Ibrahim and the family of Ibrahim. Indeed, You are Praiseworthy and Glorious. O Allah, send blessings upon Muhammad and the family of Muhammad, as You sent blessings upon Ibrahim and the family of Ibrahim. Indeed, You are Praiseworthy and Glorious",
            audioKey: 'durood',
          ),
        ],
      ],
    );
  }

  static Widget buildTasleemSection() {
    return buildDetailCard(
      "Tasleem (Ending Prayer)",
      Icons.waving_hand,
      ThemeColors.green,
      [
        buildCompactArabicText(
          "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ",
          "As-salamu alaykum wa rahmatullah",
          "Peace be upon you and Allah's mercy",
          audioKey: 'tasleem',
        ),
        gapH8,
        const Text(
          "• Turn head to the right and say the above\n• Turn head to the left and repeat\n• This ends the prayer\n• 🎧 Listen to learn proper pronunciation",
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  static Widget buildDuaQunootSection() {
    return buildDetailCard(
      "Dua Qunoot (For Witr Prayer)",
      Icons.favorite,
      ThemeColors.blue,
      [
        Row(
          children: [
            Expanded(
              child: Text(
                "Special prayer for Witr:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            AudioPlayerButton(
              audioKey: 'qunoot',
              label: 'Listen',
              color: ThemeColors.blue,
              size: 20,
            ),
          ],
        ),
        gapH8,
        buildCompactArabicText(
          "اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ، وَبَارِكْ لِي فِيمَا أَعْطَيْتَ، وَقِنِي شَرَّ مَا قَضَيْتَ، فَإِنَّكَ تَقْضِي وَلَا يُقْضَى عَلَيْكَ، إِنَّهُ لَا يَذِلُّ مَنْ وَالَيْتَ، وَلَا يَعِزُّ مَنْ عَادَيْتَ، تَبَارَكْتَ رَبَّنَا وَتَعَالَيْتَ",
          "Allahumma hdini fiman hadayt, wa afini fiman afayt, wa tawallani fiman tawallayt, wa barik li fima a'tayt, wa qini sharra ma qadayt, fa innaka taqdi wa la yuqda alayk, innahu la yadhillu man walayt, wa la ya'izzu man adayt, tabarakta rabbana wa ta'alayt",
          "O Allah, guide me among those You have guided, grant me security among those You have granted security, take me into Your charge among those You have taken into Your charge, bless me in what You have given me, protect me from the evil You have decreed, for You decree and none can decree against You, none can humiliate whom You have befriended, and none can honor whom You have taken as an enemy, blessed are You our Lord and Exalted",
          audioKey: 'qunoot',
        ),
        gapH8,
        const Text(
          "• Recited in the last rakat of Witr prayer\n• After rising from Ruku, before Sujud\n• Can also make personal duas\n• 🎧 Audio helps with memorization",
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  // New helper method to build audio-enabled Arabic text with additional context
  static Widget buildAudioEnabledPrayerText({
    required String title,
    required String arabic,
    required String transliteration,
    required String translation,
    required String audioKey,
    required Color color,
    List<String>? instructions,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
              AudioPlayerButton(
                audioKey: audioKey,
                label: 'Listen',
                color: color,
                size: 20,
              ),
            ],
          ),
          gapH8,
          buildCompactArabicText(
            arabic,
            transliteration,
            translation,
            audioKey: audioKey,
          ),
          if (instructions != null) ...[
            gapH8,
            ...instructions.map((instruction) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                "• $instruction",
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            )),
          ],
        ],
      ),
    );
  }
} 