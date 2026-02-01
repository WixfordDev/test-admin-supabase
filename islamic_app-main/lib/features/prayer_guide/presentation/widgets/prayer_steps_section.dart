import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';

class PrayerStepsSection extends StatelessWidget {
  const PrayerStepsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: p16,
      children: [
        _buildSectionHeader(
          context,
          "Step-by-Step Prayer Guide",
          "Learn how to pray with detailed instructions",
          Icons.accessibility,
          context.primaryColor,
        ),
        gapH16,

        // Prerequisites Card
        _buildStepsCard(
          "Prerequisites",
          "Essential requirements before prayer",
          Icons.check_circle_outline,
          ThemeColors.blue,
          [
            _buildPrerequisiteStep("Purification (Wudu)",
                "Perform ablution before prayer", Icons.water_drop),
            _buildPrerequisiteStep("Clean Place",
                "Choose a clean area for prayer", Icons.cleaning_services),
            _buildPrerequisiteStep(
                "Face Qibla", "Direction towards Mecca", Icons.explore),
            _buildPrerequisiteStep("Make Intention",
                "Silent intention in your heart", Icons.favorite),
          ],
        ),

        gapH16,

        // Prayer Steps Card
        _buildStepsCard(
          "Prayer Movements",
          "Follow these steps for each Rakat",
          Icons.accessibility_new,
          context.primaryColor,
          [
            _buildPrayerMovementStep(context, 1, "Standing & Opening (Takbir)",
                "اللّٰهُ أَكْبَر", "Allahu Akbar", "Allah is the Greatest"),
            _buildRecitationExpandableStep(context),
            _buildPrayerMovementStep(
                context,
                3,
                "Bowing (Ruku)",
                "سُبْحَانَ رَبِّيَ الْعَظِيمِ",
                "Subhana Rabbiyal Adheem",
                "Glory to my Lord, the Most Great"),
            _buildPrayerMovementStep(
                context,
                4,
                "Standing from Ruku",
                "سَمِعَ اللّٰهُ لِمَنْ حَمِدَهُ، رَبَّنَا وَلَكَ الْحَمْدُ",
                "Sami Allahu liman hamidah, Rabbana wa lakal hamd",
                "Allah hears those who praise Him. Our Lord, and to You is the praise"),
            _buildPrayerMovementStep(
                context,
                5,
                "First Prostration (Sujud)",
                "سُبْحَانَ رَبِّيَ الْأَعْلَى",
                "Subhana Rabbiyal A'la",
                "Glory to my Lord, the Most High"),
            _buildPrayerMovementStep(
                context,
                6,
                "Sitting Between Prostrations",
                "رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي",
                "Rabbi ghfir li, Rabbi ghfir li",
                "My Lord, forgive me. My Lord, forgive me"),
            _buildPrayerMovementStep(
                context,
                7,
                "Second Prostration",
                "سُبْحَانَ رَبِّيَ الْأَعْلَى",
                "Subhana Rabbiyal A'la",
                "Glory to my Lord, the Most High"),
            _buildTashahhudExpandableStep(),
            _buildPrayerMovementStep(
                context,
                9,
                "Final Salutation (Tasleem)",
                "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ",
                "As-salamu alaykum wa rahmatullah",
                "Peace be upon you and Allah's mercy"),
          ],
        ),

        gapH32,
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeColors.darkGray.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepsCard(String title, String subtitle, IconData icon,
      Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.darkGray.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: p16,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeColors.darkGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrerequisiteStep(
      String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.lightGray2.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ThemeColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: ThemeColors.blue, size: 16),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                gapH4,
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.darkGray.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerMovementStep(BuildContext context, int stepNumber,
      String title, String arabic, String transliteration, String translation) {
    // Map step titles to audio keys and icons
    String? audioKey;
    IconData stepIcon;
    Color stepColor;

    switch (title) {
      case "Standing & Opening (Takbir)":
        audioKey = 'takbir';
        stepIcon = Icons.accessibility_new;
        stepColor = ThemeColors.blue;
        break;
      case "Bowing (Ruku)":
        audioKey = 'ruku';
        stepIcon = Icons.keyboard_arrow_down;
        stepColor = ThemeColors.orange;
        break;
      case "Standing from Ruku":
        audioKey = 'standing_from_ruku';
        stepIcon = Icons.accessibility;
        stepColor = ThemeColors.blue;
        break;
      case "First Prostration (Sujud)":
      case "Second Prostration":
        audioKey = 'sujud';
        stepIcon = Icons.keyboard_double_arrow_down;
        stepColor = ThemeColors.green;
        break;
      case "Sitting Between Prostrations":
        audioKey = 'between_sujud';
        stepIcon = Icons.chair;
        stepColor = ThemeColors.orange;
        break;
      case "Final Salutation (Tasleem)":
        audioKey = 'tasleem';
        stepIcon = Icons.waving_hand;
        stepColor = ThemeColors.blue;
        break;
      default:
        stepIcon = Icons.info;
        stepColor = ThemeColors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: stepColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stepColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: stepColor.withValues(alpha: 0.1),
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
                  colors: [stepColor, stepColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: stepColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      stepIcon,
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
                            color: stepColor,
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
                      color: stepColor,
                    ),
                  ),
                  gapH6,
                  Text(
                    arabic,
                    style: const TextStyle(
                      fontFamily: 'ScheherazadeNew',
                      fontSize: 16,
                      height: 1.6,
                      color: ThemeColors.darkGray,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            gapW12,

            // Audio details button
            if (audioKey != null)
              CommonWidgets.buildAudioDetailsButton(
                context: context,
                title: title,
                audioKey: audioKey,
                arabicText: arabic,
                transliteration: transliteration,
                translation: translation,
                color: stepColor,
                icon: stepIcon,
                isCompact: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecitationExpandableStep(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeColors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ThemeColors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "2",
                style: TextStyle(
                  color: ThemeColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: const Text(
            "Recitation (Qira'at)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: ThemeColors.darkGray,
            ),
          ),
          subtitle: const Text(
            "Recite Surah Al-Fatiha and another Surah",
            style: TextStyle(fontSize: 12),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Surah Fatiha Section
                  _buildSurahFatihaSection(context),
                  gapH16,
                  // Additional Surah Section
                  _buildAdditionalSurahSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahFatihaSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
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
          Row(
            children: [
              // Container(
              //   padding: const EdgeInsets.all(10),
              //   decoration: BoxDecoration(
              //     color: ThemeColors.green,
              //     borderRadius: BorderRadius.circular(12),
              //     boxShadow: [
              //       BoxShadow(
              //         color: ThemeColors.green.withValues(alpha: 0.3),
              //         blurRadius: 8,
              //         offset: const Offset(0, 2),
              //       ),
              //     ],
              //   ),
              //   child: const Icon(
              //     Icons.menu_book_rounded,
              //     color: ThemeColors.white,
              //     size: 24,
              //   ),
              // ),
              // const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Surah Al-Fatiha",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ThemeColors.green,
                      ),
                    ),
                    Text(
                      "Mandatory in every rakat",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColors.darkGray.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Row(
              //   children: [
              //     AudioPlayerButton(
              //       audioKey: 'fatiha',
              //       label: 'Listen',
              //       color: ThemeColors.green,
              //     ),
              gapW4,
              ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed(
                    Routes.quranReadingMode.name,
                    queryParameters: {
                      'surahId': '1',
                      'verseId': '1',
                    },
                  );
                },
                icon: const Icon(Icons.menu_book, size: 14),
                label: const Text("Read", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.green.withValues(alpha: 0.8),
                  foregroundColor: ThemeColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  minimumSize: Size.zero,
                  elevation: 2,
                ),
              ),
              // ],
              // ),
            ],
          ),

          gapH8,

          // Help Section for Beginners
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: ThemeColors.blue.withValues(alpha: 0.2)),
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
                    Icons.headphones_rounded,
                    color: ThemeColors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "🎧 Listen to learn pronunciation • Perfect for beginners and non-Muslims",
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
          CommonWidgets.buildCompactArabicText(
            "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
            "Bismillahir Rahmanir Raheem\nAlhamdu lillahi rabbil alameen\nAr-Rahmanir Raheem\nMaliki yawmiddin\nIyyaka na'budu wa iyyaka nasta'een\nIhdinas siratal mustaqeem\nSiratal lazeena an'amta alayhim ghayril maghdoobi alayhim wa lad dalleen",
            "In the name of Allah, the Most Gracious, the Most Merciful\nPraise be to Allah, Lord of all the worlds\nThe Most Gracious, the Most Merciful\nMaster of the Day of Judgment\nYou alone we worship and You alone we ask for help\nGuide us to the straight path\nThe path of those You have blessed, not of those who have incurred Your wrath, nor of those who have gone astray",
            audioKey: 'fatiha',
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSurahSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Additional Surah (Any Surah)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          gapH8,
          const Text(
            "Recite any Surah after Al-Fatiha. Short Surahs are recommended for beginners.",
            style: TextStyle(fontSize: 12),
          ),
          gapH12,
          ElevatedButton.icon(
            onPressed: () => _showSurahSelectionDialog(context),
            icon: const Icon(Icons.list, size: 14),
            label: const Text("Browse Surahs", style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.orange,
              foregroundColor: ThemeColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTashahhudExpandableStep() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeColors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ThemeColors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "8",
                style: TextStyle(
                  color: ThemeColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: const Text(
            "Tashahhud (Testimony)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: ThemeColors.darkGray,
            ),
          ),
          subtitle: const Text(
            "Recite in final sitting",
            style: TextStyle(fontSize: 12),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Tashahhud
                  CommonWidgets.buildTashahhudSection(isLast: false),
                  gapH12,
                  // Final Tashahhud
                  CommonWidgets.buildTashahhudSection(isLast: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSurahSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
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
                  color: Colors.blue.shade50,
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    gapH16,
                    Text(
                      "Choose a Surah to Recite",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    gapH8,
                    Text(
                      "Select from recommended short Surahs for prayer",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: p16,
                  children: [
                    _buildSurahOption(
                      context,
                      "Surah Al-Ikhlas (Sincerity)",
                      "Chapter 112 • 4 verses • Recommended",
                      () {
                        Navigator.pop(context);
                        context.pushNamed(
                          Routes.quranReadingMode.name,
                          queryParameters: {
                            'surahId': '112',
                            'verseId': '1',
                          },
                        );
                      },
                    ),
                    _buildSurahOption(
                      context,
                      "Surah Al-Falaq (The Daybreak)",
                      "Chapter 113 • 5 verses • Protection",
                      () {
                        Navigator.pop(context);
                        context.pushNamed(
                          Routes.quranReadingMode.name,
                          queryParameters: {
                            'surahId': '113',
                            'verseId': '1',
                          },
                        );
                      },
                    ),
                    _buildSurahOption(
                      context,
                      "Surah An-Nas (Mankind)",
                      "Chapter 114 • 6 verses • Protection",
                      () {
                        Navigator.pop(context);
                        context.pushNamed(
                          Routes.quranReadingMode.name,
                          queryParameters: {
                            'surahId': '114',
                            'verseId': '1',
                          },
                        );
                      },
                    ),
                    _buildSurahOption(
                      context,
                      "Surah Al-Kawthar (Abundance)",
                      "Chapter 108 • 3 verses • Short & Beautiful",
                      () {
                        Navigator.pop(context);
                        context.pushNamed(
                          Routes.quranReadingMode.name,
                          queryParameters: {
                            'surahId': '108',
                            'verseId': '1',
                          },
                        );
                      },
                    ),
                    _buildSurahOption(
                      context,
                      "Surah Al-Asr (The Time)",
                      "Chapter 103 • 3 verses • Very Short",
                      () {
                        Navigator.pop(context);
                        context.pushNamed(
                          Routes.quranReadingMode.name,
                          queryParameters: {
                            'surahId': '103',
                            'verseId': '1',
                          },
                        );
                      },
                    ),
                    gapH16,
                    // Browse all surahs button
                    Container(
                      width: double.infinity,
                      padding: p16,
                      decoration: BoxDecoration(
                        color: ThemeColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: ThemeColors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.menu_book,
                              color: ThemeColors.blue, size: 32),
                          gapH8,
                          Text(
                            "Browse All Surahs",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.blue,
                            ),
                          ),
                          gapH4,
                          Text(
                            "Explore the complete Quran",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          gapH12,
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to Quran main page
                              context.pushNamed(Routes.quran.name);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Open Quran"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSurahOption(
      BuildContext context, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.menu_book, color: Colors.green),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
