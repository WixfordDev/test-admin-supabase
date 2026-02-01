import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/prayer_guide/domain/model/prayer_step.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/prayer_overview_section.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/prayer_steps_section.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/prayer_rules_section.dart';

class PrayerGuideScreen extends StatefulWidget {
  const PrayerGuideScreen({super.key});

  @override
  State<PrayerGuideScreen> createState() => _PrayerGuideScreenState();
}

class _PrayerGuideScreenState extends State<PrayerGuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<DetailedPrayer> prayers = [
    const DetailedPrayer(
      name: "Fajr",
      arabicName: "الفجر",
      description: "The dawn prayer, performed before sunrise",
      fardRakats: 2,
      sunnahBefore: 2,
      sunnahAfter: 0,
      isFard: true,
      timeDescription: "From dawn (true dawn) until sunrise",
      virtues: [
        "Whoever prays the dawn prayer in congregation, it is as if he prayed the entire night.",
        "The two rakats of Fajr are better than this world and everything in it.",
        "No prayer is harder upon the hypocrites than Fajr and Isha prayers."
      ],
    ),
    const DetailedPrayer(
      name: "Dhuhr",
      arabicName: "الظهر",
      description: "The midday prayer, performed after the sun passes its zenith",
      fardRakats: 4,
      sunnahBefore: 4,
      sunnahAfter: 2,
      isFard: true,
      timeDescription: "From when the sun passes its zenith until Asr time",
      virtues: [
        "The middle prayer that Allah mentioned in the Quran.",
        "A time when the gates of heaven are opened."
      ],
    ),
    const DetailedPrayer(
      name: "Asr",
      arabicName: "العصر",
      description: "The afternoon prayer, performed when an object's shadow is twice its length",
      fardRakats: 4,
      sunnahBefore: 4,
      sunnahAfter: 0,
      isFard: true,
      timeDescription: "From when an object's shadow equals its length plus its shadow at zenith until sunset",
      virtues: [
        "Whoever misses the Asr prayer, it is as if he lost his family and property.",
        "The middle prayer that is especially emphasized."
      ],
    ),
    const DetailedPrayer(
      name: "Maghrib",
      arabicName: "المغرب",
      description: "The sunset prayer, performed after sunset",
      fardRakats: 3,
      sunnahBefore: 0,
      sunnahAfter: 2,
      isFard: true,
      timeDescription: "From sunset until the red twilight disappears",
      virtues: [
        "The prayer that breaks the fast during Ramadan.",
        "A blessed time for making dua."
      ],
    ),
    const DetailedPrayer(
      name: "Isha",
      arabicName: "العشاء",
      description: "The night prayer, performed at night",
      fardRakats: 4,
      sunnahBefore: 0,
      sunnahAfter: 2,
      witr: 3,
      isFard: true,
      timeDescription: "From when the red twilight disappears until midnight or dawn",
      virtues: [
        "No prayer is harder upon the hypocrites than Fajr and Isha prayers.",
        "The prayer that ends the day with remembrance of Allah."
      ],
    ),
    const DetailedPrayer(
      name: "Jummah",
      arabicName: "الجمعة",
      description: "The special Friday congregational prayer",
      fardRakats: 2,
      sunnahBefore: 4,
      sunnahAfter: 4,
      isFard: true,
      timeDescription: "Replaces Dhuhr prayer on Fridays, performed in congregation",
      isSpecial: true,
      virtues: [
        "Jummah prayer is obligatory for all Muslim men.",
        "The best day on which the sun rises is Friday.",
        "Whoever leaves three Jummah prayers without excuse, Allah will seal his heart."
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prayer Guide"),
        centerTitle: true,
        backgroundColor: context.primaryColor,
        foregroundColor: ThemeColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'About Prayer Guide',
          ),
        ],
      ),
      body: Column(
        children: [
          // Compact Introduction Header
          _buildCompactHeader(),

          // Tab Navigation
          _buildTabBar(),

          // Main Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                PrayerOverviewSection(prayers: prayers),
                PrayerStepsSection(),
                PrayerRulesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.mosque, color: context.primaryColor),
              gapW8,
              const Text('About Prayer Guide'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This comprehensive prayer guide helps both Muslims and non-Muslims understand Islamic prayer (Salah).',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              gapH16,
              const Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              gapH8,
              ...[
                'Complete step-by-step instructions',
                'Arabic text with pronunciation',
                'Prayer timings and requirements',
                'Sunnah and Fard rakats details',
                'Jummah (Friday) prayer guide',
              ].map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, 
                         color: context.primaryColor, size: 16),
                    gapW8,
                    Expanded(child: Text(feature, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primaryColor,
            context.primaryColor.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.mosque,
                color: ThemeColors.white,
                size: 24,
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Islamic Prayer Guide",
                    style: TextStyle(
                      color: ThemeColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  gapH4,
                  const Text(
                    "Learn how to pray with step-by-step guidance",
                    style: TextStyle(
                      color: ThemeColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    color: ThemeColors.white,
                    size: 12,
                  ),
                  gapW4,
                  const Text(
                    "Authentic",
                    style: TextStyle(
                      color: ThemeColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: ThemeColors.lightGray,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildTabButton("Overview", 0, Icons.info_outline),
          _buildTabButton("How to Pray", 1, Icons.accessibility),
          _buildTabButton("Rules", 2, Icons.rule),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int page, IconData icon) {
    final isSelected = _currentPage == page;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.animateToPage(
            page,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? context.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    isSelected ? ThemeColors.white : ThemeColors.darkGray,
              ),
              gapW4,
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        isSelected ? ThemeColors.white : ThemeColors.darkGray,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
