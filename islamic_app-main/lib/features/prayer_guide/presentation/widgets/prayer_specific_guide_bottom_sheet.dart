import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/prayer_guide/domain/model/prayer_step.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/common_widgets.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/audio_details_bottom_sheet.dart';
import 'package:go_router/go_router.dart';

class PrayerSpecificGuideBottomSheet {
  static void show(
      BuildContext context, DetailedPrayer prayer, String prayerType) {
    String title = "";
    String description = "";
    int rakats = 0;
    Color color = context.primaryColor;

    switch (prayerType) {
      case 'sunnah_before':
        title = "Sunnah Before ${prayer.name}";
        description = "Voluntary prayer performed before the main Fard prayer";
        rakats = prayer.sunnahBefore;
        color = ThemeColors.orange;
        break;
      case 'fard':
        title = "Fard ${prayer.name}";
        description = "Obligatory prayer that must be performed";
        rakats = prayer.fardRakats;
        color = context.primaryColor;
        break;
      case 'sunnah_after':
        title = "Sunnah After ${prayer.name}";
        description = "Voluntary prayer performed after the main Fard prayer";
        rakats = prayer.sunnahAfter;
        color = ThemeColors.orange;
        break;
      case 'witr':
        title = "Witr Prayer";
        description =
            "Recommended odd-numbered prayer, typically performed after Isha";
        rakats = prayer.witr;
        color = ThemeColors.blue;
        break;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: ThemeColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: p16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ThemeColors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    gapH16,
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.white,
                      ),
                    ),
                    gapH8,
                    Text(
                      "$rakats Rakats • $description",
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: p16,
                  children: [
                    _buildSpecificPrayerInstructions(
                        context, rakats, prayerType, color),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSpecificPrayerInstructions(
      BuildContext context, int rakats, String prayerType, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prayer Overview
        CommonWidgets.buildDetailCard(
          "Prayer Overview",
          Icons.info_outline,
          color,
          [
            Text(
              "This prayer consists of $rakats rakat${rakats > 1 ? 's' : ''}.",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (prayerType == 'fard') ...[
              gapH8,
              const Text(
                "This is OBLIGATORY and must be performed. Missing it without valid excuse is a sin.",
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w500),
              ),
            ] else ...[
              gapH8,
              const Text(
                "This is VOLUNTARY but highly recommended for extra spiritual reward.",
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),

        gapH16,

        // Complete Step-by-Step Guide Header
        CommonWidgets.buildDetailCard(
          "Complete Step-by-Step Guide",
          Icons.format_list_numbered,
          color,
          [
            const Text(
              "Follow these instructions for each rakat. Tap on any section for detailed guidance:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            gapH8,
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app, size: 16, color: ThemeColors.blue),
                  SizedBox(width: 8),
                  Text(
                    "💡 Tip: Tap on Arabic text, Takbir, Tashahhud sections for full details",
                    style: TextStyle(fontSize: 11, color: ThemeColors.blue),
                  ).expanded(),
                ],
              ),
            ),
          ],
        ),

        gapH16,

        // Step by step for each rakat with expandable sections
        ...List.generate(
            rakats,
            (index) => _buildEnhancedRakatInstructions(
                context, index + 1, rakats, color, prayerType)),

        // Witr Special Instructions
        if (prayerType == 'witr') ...[
          gapH16,
          CommonWidgets.buildDuaQunootSection(),
          gapH16,
          CommonWidgets.buildDetailCard(
            "Witr Special Instructions",
            Icons.star,
            ThemeColors.blue,
            [
              const Text(
                "• Witr is prayed with odd number of rakats (1, 3, 5, 7, 9, or 11)\n"
                "• It's the last prayer of the night\n"
                "• Can be prayed after Isha until Fajr time\n"
                "• Dua Qunoot is recited in the last rakat after Ruku and before Sujud\n"
                "• Highly recommended but not obligatory",
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ],

        // Sunnah Prayer Benefits
        if (prayerType.contains('sunnah')) ...[
          gapH16,
          CommonWidgets.buildDetailCard(
            "Sunnah Prayer Benefits",
            Icons.favorite,
            ThemeColors.orange,
            [
              const Text(
                "• Compensates for any deficiencies in Fard prayers\n"
                "• Brings you closer to Allah\n"
                "• Increases spiritual reward and rank\n"
                "• Protects from sins and builds good habits\n"
                "• Shows extra devotion beyond obligations\n"
                "• Prophet Muhammad (PBUH) never abandoned these prayers",
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ],

        gapH32,
      ],
    );
  }

  static Widget _buildEnhancedRakatInstructions(BuildContext context,
      int rakatNumber, int totalRakats, Color color, String prayerType) {
    bool isLastRakat = rakatNumber == totalRakats;
    bool needsTashahhud = (rakatNumber == 2 && totalRakats > 2) || isLastRakat;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rakat Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      rakatNumber.toString(),
                      style: const TextStyle(
                        color: ThemeColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                gapW12,
                Text(
                  "Rakat $rakatNumber of $totalRakats",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Rakat Steps
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Step Cards with Audio Details
                _buildCompactStepCard(
                  context,
                  1,
                  "Opening Takbir",
                  "اللّٰهُ أَكْبَر",
                  "Allahu Akbar",
                  "Allah is the Greatest",
                  Icons.accessibility_new,
                  ThemeColors.blue,
                  'takbir',
                ),

                gapH12,

                _buildCompactStepCard(
                  context,
                  2,
                  "Surah Al-Fatiha",
                  "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
                  "Bismillahir Rahmanir Raheem\nAlhamdu lillahi rabbil alameen\nAr-Rahmanir Raheem\nMaliki yawmid deen\nIyyaka na'budu wa iyyaka nasta'een\nIhdinas siratal mustaqeem\nSiratal lazeena an'amta alayhim ghayril maghdoobi alayhim wa lad dalleen",
                  "In the name of Allah, the Most Gracious, the Most Merciful\nPraise be to Allah, Lord of all the worlds\nThe Most Gracious, the Most Merciful\nMaster of the Day of Judgment\nYou alone we worship, and You alone we ask for help\nGuide us to the straight path\nThe path of those You have blessed, not of those who have incurred Your wrath, nor of those who have gone astray",
                  Icons.menu_book_rounded,
                  ThemeColors.green,
                  'fatiha',
                ),

                gapH12,

                if (rakatNumber <= 2) ...[
                  _buildCompactStepCard(
                    context,
                    3,
                    "Additional Surah",
                    "أي سورة قصيرة",
                    "Any short Surah",
                    "Choose any Surah you know after Al-Fatiha",
                    Icons.add_circle_outline,
                    ThemeColors.orange,
                    null, // No specific audio for this
                  ),
                  gapH12,
                ],

                _buildCompactStepCard(
                  context,
                  rakatNumber <= 2 ? 4 : 3,
                  "Ruku (Bowing)",
                  "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
                  "Subhana Rabbiyal Adheem",
                  "Glory to my Lord, the Most Great (3x minimum)",
                  Icons.keyboard_arrow_down,
                  ThemeColors.orange,
                  'ruku',
                ),

                gapH12,

                _buildCompactStepCard(
                  context,
                  rakatNumber <= 2 ? 5 : 4,
                  "Standing from Ruku",
                  "سَمِعَ اللّٰهُ لِمَنْ حَمِدَهُ، رَبَّنَا وَلَكَ الْحَمْدُ",
                  "Sami Allahu liman hamidah, Rabbana wa lakal hamd",
                  "Allah hears those who praise Him. Our Lord, and to You is the praise",
                  Icons.accessibility,
                  ThemeColors.blue,
                  'standing_from_ruku',
                ),

                gapH12,

                _buildCompactStepCard(
                  context,
                  rakatNumber <= 2 ? 6 : 5,
                  "First Sujud (Prostration)",
                  "سُبْحَانَ رَبِّيَ الْأَعْلَى",
                  "Subhana Rabbiyal A'la",
                  "Glory to my Lord, the Most High (3x minimum)",
                  Icons.keyboard_double_arrow_down,
                  ThemeColors.green,
                  'sujud',
                ),

                gapH12,

                _buildCompactStepCard(
                  context,
                  rakatNumber <= 2 ? 7 : 6,
                  "Sitting Between Sujud",
                  "رَبِّ اغْفِرْ لِي",
                  "Rabbi ghfir li",
                  "My Lord, forgive me",
                  Icons.chair,
                  ThemeColors.orange,
                  'between_sujud',
                ),

                gapH12,

                _buildCompactStepCard(
                  context,
                  rakatNumber <= 2 ? 8 : 7,
                  "Second Sujud",
                  "سُبْحَانَ رَبِّيَ الْأَعْلَى",
                  "Subhana Rabbiyal A'la",
                  "Glory to my Lord, the Most High (3x minimum)",
                  Icons.keyboard_double_arrow_down,
                  ThemeColors.green,
                  'sujud',
                ),

                // Tashahhud (if needed)
                if (needsTashahhud) ...[
                  gapH12,
                  _buildCompactStepCard(
                    context,
                    rakatNumber <= 2 ? 9 : 8,
                    isLastRakat ? "Tashahhud (At-Tahiyyat)" : "First Tashahhud",
                    "التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ",
                    "At-tahiyyatu lillahi was-salawatu wat-tayyibat. As-salamu alayka ayyuhan-nabiyyu wa rahmatullahi wa barakatuh. As-salamu alayna wa ala ibadillahis-salihin. Ash-hadu alla ilaha illallahu wa ash-hadu anna Muhammadan abduhu wa rasuluh",
                    "All compliments, prayers and pure words are due to Allah. Peace be upon you, O Prophet, and Allah's mercy and blessings. Peace be upon us and upon all righteous servants of Allah. I bear witness that there is no deity except Allah, and I bear witness that Muhammad is His servant and messenger",
                    Icons.record_voice_over,
                    ThemeColors.blue,
                    'tashahhud',
                  ),
                  if (isLastRakat) ...[
                    gapH12,
                    _buildCompactStepCard(
                      context,
                      rakatNumber <= 2 ? 10 : 9,
                      "Durood Ibrahim",
                      "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ",
                      "Allahumma salli ala Muhammadin wa ala ali Muhammad, kama sallayta ala Ibrahim wa ala ali Ibrahim, innaka hamidun majid. Allahumma barik ala Muhammadin wa ala ali Muhammad, kama barakta ala Ibrahim wa ala ali Ibrahim, innaka hamidun majid",
                      "O Allah, send prayers upon Muhammad and the family of Muhammad, as You sent prayers upon Ibrahim and the family of Ibrahim. Indeed, You are Praiseworthy and Glorious. O Allah, send blessings upon Muhammad and the family of Muhammad, as You sent blessings upon Ibrahim and the family of Ibrahim. Indeed, You are Praiseworthy and Glorious",
                      Icons.favorite,
                      ThemeColors.green,
                      'durood',
                    ),
                    gapH12,
                    _buildCompactStepCard(
                      context,
                      rakatNumber <= 2 ? 11 : 10,
                      "Final Tasleem",
                      "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ",
                      "As-salamu alaykum wa rahmatullah",
                      "Peace be upon you and Allah's mercy (to right and left)",
                      Icons.waving_hand,
                      ThemeColors.green,
                      'tasleem',
                    ),
                  ],
                ] else if (!isLastRakat) ...[
                  gapH12,
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward, color: color, size: 16),
                        gapW8,
                        Text(
                          "Say 'Allahu Akbar' and stand for next rakat",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: color,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCompactStepCard(
    BuildContext context,
    int stepNumber,
    String title,
    String arabicText,
    String transliteration,
    String translation,
    IconData icon,
    Color color,
    String? audioKey,
  ) {
    return GestureDetector(
      onTap: () {
        if (audioKey != null) {
          // Open audio details bottom sheet when tapping anywhere on the card
          AudioDetailsBottomSheet.show(
            context: context,
            title: title,
            audioKey: audioKey,
            arabicText: arabicText,
            transliteration: transliteration,
            translation: translation,
            color: color,
            icon: icon,
          );
        }
      },
      child: Container(
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
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Step number and icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        icon,
                        color: ThemeColors.white,
                        size: 20,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: ThemeColors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            stepNumber.toString(),
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              gapW16,

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    gapH6,
                    Text(
                      title == "Surah Al-Fatiha"
                          ? arabicText.split('\n').take(2).join('\n') +
                              (arabicText.split('\n').length > 2 ? '...' : '')
                          : (arabicText.length > 50
                              ? arabicText.substring(0, 50) + '...'
                              : arabicText),
                      style: const TextStyle(
                        fontFamily: 'ScheherazadeNew',
                        fontSize: 16,
                        height: 1.6,
                        color: ThemeColors.darkGray,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: title == "Surah Al-Fatiha" ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              gapW12,

              // Visual indicator for clickable areas
              if (audioKey != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        color: ThemeColors.white,
                        size: 20,
                      ),
                      gapH2,
                      Text(
                        "Tap",
                        style: TextStyle(
                          color: ThemeColors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: color,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
