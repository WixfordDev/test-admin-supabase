import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class WuduGuideScreen extends StatefulWidget {
  const WuduGuideScreen({super.key});

  @override
  State<WuduGuideScreen> createState() => _WuduGuideScreenState();
}

class _WuduGuideScreenState extends State<WuduGuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WuduStep> wuduSteps = [
    const WuduStep(
      stepNumber: 1,
      title: "Intention (Niyyah)",
      arabicTitle: "النية",
      description: "Make the intention in your heart",
      details: [
        "Make intention (Niyyah) for Wudu in your heart",
        "The intention is: 'I intend to perform Wudu for prayer'",
        "This intention is made silently in the heart, not spoken aloud",
        "Ensure you are in a clean place",
        "Face the Qibla if possible (but not mandatory for Wudu)",
      ],
      dua: "بِسْمِ اللَّهِ",
      duaTransliteration: "Bismillah",
      duaTranslation: "In the name of Allah",
    ),
    const WuduStep(
      stepNumber: 2,
      title: "Wash Hands",
      arabicTitle: "غسل اليدين",
      description: "Wash both hands up to the wrists",
      details: [
        "Wash your right hand first, then the left",
        "Wash up to the wrists",
        "Wash three times each",
        "Rub between the fingers",
        "Clean under the nails if dirty",
        "Ensure water reaches all parts of both hands",
      ],
      dua: "اللَّهُمَّ اغْفِرْ لِي ذَنْبِي وَوَسِّعْ لِي فِي دَارِي وَبَارِكْ لِي فِي رِزْقِي",
      duaTransliteration: "Allahummaghfir li dhanbi wa wassi' li fi dari wa barik li fi rizqi",
      duaTranslation: "O Allah, forgive my sins, expand my home for me, and bless my sustenance",
    ),
    const WuduStep(
      stepNumber: 3,
      title: "Rinse Mouth",
      arabicTitle: "المضمضة",
      description: "Rinse the mouth with water",
      details: [
        "Take water in your right hand",
        "Put it in your mouth and swirl it around",
        "Rinse thoroughly to clean the mouth",
        "Spit out the water completely",
        "Repeat three times",
        "If fasting, be careful not to swallow water",
      ],
      dua: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
      duaTransliteration: "Allahumma a'inni 'ala dhikrika wa shukrika wa husni 'ibadatik",
      duaTranslation: "O Allah, help me to remember You, thank You, and worship You properly",
    ),
    const WuduStep(
      stepNumber: 4,
      title: "Cleanse Nose",
      arabicTitle: "الاستنشاق",
      description: "Sniff water into nostrils and blow out",
      details: [
        "Take water in your right hand",
        "Gently sniff water into your nostrils",
        "Use your left hand to blow out the water",
        "Clean the inside of the nostrils",
        "Repeat three times",
        "Be gentle if you have a sensitive nose",
      ],
      dua: "اللَّهُمَّ أَرِحْنِي رَائِحَةَ الْجَنَّةِ",
      duaTransliteration: "Allahumma arihni ra'ihatal jannah",
      duaTranslation: "O Allah, let me smell the fragrance of Paradise",
    ),
    const WuduStep(
      stepNumber: 5,
      title: "Wash Face",
      arabicTitle: "غسل الوجه",
      description: "Wash the entire face",
      details: [
        "Wash the face from the forehead to the chin",
        "Wash from ear to ear horizontally",
        "Use both hands to splash water on your face",
        "Ensure water reaches all parts of the face",
        "Wash three times",
        "Men should wash through their beard if it's thin",
      ],
      dua: "اللَّهُمَّ بَيِّضْ وَجْهِي يَوْمَ تَبْيَضُّ وُجُوهٌ وَتَسْوَدُّ وُجُوهٌ",
      duaTransliteration: "Allahumma bayyid wajhi yawma tabyaḍḍu wujuhun wa taswaddu wujuh",
      duaTranslation: "O Allah, make my face bright on the Day when faces will be bright and faces will be dark",
    ),
    const WuduStep(
      stepNumber: 6,
      title: "Wash Arms",
      arabicTitle: "غسل الذراعين",
      description: "Wash both arms up to the elbows",
      details: [
        "Start with the right arm",
        "Wash from fingertips to just above the elbow",
        "Ensure water reaches all parts of the arm",
        "Then wash the left arm in the same manner",
        "Wash three times each",
        "Remove any tight rings or watches if they prevent water flow",
      ],
      dua: "اللَّهُمَّ أَعْطِنِي كِتَابِي بِيَمِينِي",
      duaTransliteration: "Allahumma a'tini kitabi bi yamini",
      duaTranslation: "O Allah, give me my book (of deeds) in my right hand",
    ),
    const WuduStep(
      stepNumber: 7,
      title: "Wipe Head",
      arabicTitle: "مسح الرأس",
      description: "Wipe over the head with wet hands",
      details: [
        "Use wet hands to wipe over your head",
        "Start from the front and move to the back",
        "Then bring hands back to the front",
        "Wipe once (not three times like other parts)",
        "Use all fingers, not just fingertips",
        "If wearing a hijab, you can wipe over the hair that's visible",
      ],
      dua: "اللَّهُمَّ غَشِّنِي بِرَحْمَتِكَ",
      duaTransliteration: "Allahumma ghashshini bi rahmatik",
      duaTranslation: "O Allah, cover me with Your mercy",
    ),
    const WuduStep(
      stepNumber: 8,
      title: "Wipe Ears",
      arabicTitle: "مسح الأذنين",
      description: "Wipe inside and outside of both ears",
      details: [
        "Use your index fingers for the inside of ears",
        "Use your thumbs for the outside/back of ears",
        "Wipe both ears simultaneously",
        "Use the remaining water from wiping the head",
        "Do not use new water for ears",
        "Wipe gently and thoroughly",
      ],
      dua: "اللَّهُمَّ اجْعَلْنِي مِنَ الَّذِينَ يَسْتَمِعُونَ الْقَوْلَ فَيَتَّبِعُونَ أَحْسَنَهُ",
      duaTransliteration: "Allahumma aj'alni minal-ladhina yastami'unal-qawla fa yattabi'una ahsanah",
      duaTranslation: "O Allah, make me among those who listen to the word and follow the best of it",
    ),
    const WuduStep(
      stepNumber: 9,
      title: "Wash Feet",
      arabicTitle: "غسل الرجلين",
      description: "Wash both feet up to the ankles",
      details: [
        "Start with the right foot",
        "Wash from toes to above the ankle",
        "Clean between the toes with your fingers",
        "Ensure water reaches all parts of the foot",
        "Then wash the left foot in the same manner",
        "Wash three times each",
      ],
      dua: "اللَّهُمَّ ثَبِّتْ قَدَمَيَّ عَلَى الصِّرَاطِ",
      duaTransliteration: "Allahumma thabbit qadamayya 'alas-sirat",
      duaTranslation: "O Allah, make my feet firm on the straight path",
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
        title: const Text("Wudu Guide"),
        centerTitle: true,
        backgroundColor: context.primaryColor,
        foregroundColor: ThemeColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'About Wudu',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildOverviewPage(),
                _buildStepsPage(),
                _buildTipsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                Icons.water_drop,
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
                    "Wudu - Ritual Purification",
                    style: TextStyle(
                      color: ThemeColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  gapH4,
                  const Text(
                    "Step-by-step guide to Islamic ablution",
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
          _buildTabButton("Steps", 1, Icons.format_list_numbered),
          _buildTabButton("Tips", 2, Icons.lightbulb_outline),
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
                color: isSelected ? ThemeColors.white : ThemeColors.darkGray,
              ),
              gapW4,
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? ThemeColors.white : ThemeColors.darkGray,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildOverviewPage() {
    return ListView(
      padding: p16,
      children: [
        _buildSectionHeader(
          "What is Wudu?",
          "Understanding ritual purification",
          Icons.help_outline,
          context.primaryColor,
        ),
        gapH16,
        _buildInfoCard(
          "Definition",
          "Wudu is the Islamic ritual of washing certain parts of the body with clean water. It is required before performing prayers, touching the Quran, and other acts of worship.",
          Icons.water_drop,
          context.primaryColor,
        ),
        gapH8,
        _buildInfoCard(
          "Purpose",
          "Wudu purifies the body and soul, preparing a Muslim for standing before Allah in prayer. It symbolizes cleanliness, humility, and spiritual preparation.",
          Icons.clean_hands,
          ThemeColors.blue,
        ),
        gapH8,
        _buildInfoCard(
          "When Required",
          "Wudu is required before the five daily prayers, Friday prayers, touching the Quran, and performing Tawaf around the Kaaba.",
          Icons.schedule,
          ThemeColors.green,
        ),

        gapH24,
        _buildSectionHeader(
          "Conditions for Valid Wudu",
          "Requirements that must be met",
          Icons.check_circle,
          ThemeColors.orange,
        ),
        gapH16,
        _buildRequirementsGrid(),

        gapH24,
        _buildSectionHeader(
          "Things That Break Wudu",
          "Actions that nullify your ablution",
          Icons.cancel,
          ThemeColors.red,
        ),
        gapH12,
        _buildBreakersGrid(),

        gapH32,
      ],
    );
  }

  Widget _buildRequirementsGrid() {
    final requirements = [
      {
        'title': 'Clean Water',
        'description': 'Water must be pure and clean',
        'icon': Icons.opacity,
        'color': ThemeColors.blue,
      },
      {
        'title': 'Correct Intention',
        'description': 'Make intention (Niyyah) in your heart',
        'icon': Icons.favorite,
        'color': ThemeColors.orange,
      },
      {
        'title': 'Proper Order',
        'description': 'Follow the prescribed sequence',
        'icon': Icons.format_list_numbered,
        'color': ThemeColors.green,
      },
      {
        'title': 'No Barriers',
        'description': 'Remove nail polish, makeup, etc.',
        'icon': Icons.block,
        'color': ThemeColors.red,
      },
    ];

    return Column(
      children: requirements.map((req) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (req['color'] as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (req['color'] as Color).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (req['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                req['icon'] as IconData,
                color: req['color'] as Color,
                size: 20,
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: req['color'] as Color,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    req['description'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildBreakersGrid() {
    final breakers = [
      "Using the bathroom",
      "Passing gas",
      "Sleeping",
      "Loss of consciousness",
      "Touching private parts",
      "Heavy bleeding",
      "Vomiting",
      "Menstruation (for women)",
    ];

    return Column(
      children: breakers.map((breaker) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ThemeColors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ThemeColors.red.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: ThemeColors.red, size: 16),
            gapW8,
            Expanded(
              child: Text(
                breaker,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildStepsPage() {
    return ListView(
      padding: p16,
      children: [
        _buildSectionHeader(
          "Wudu Steps",
          "Follow these 9 steps in order",
          Icons.format_list_numbered,
          context.primaryColor,
        ),
        gapH16,
        ...wuduSteps.map((step) => _buildStepCard(step)),
        gapH16,
        _buildFinalDuaCard(),
        gapH32,
      ],
    );
  }

  Widget _buildStepCard(WuduStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.darkGray.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                step.stepNumber.toString(),
                style: const TextStyle(
                  color: ThemeColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.arabicTitle,
                style: const TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.darkGray,
                ),
                textDirection: TextDirection.rtl,
              ),
              Text(
                step.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          subtitle: Text(
            step.description,
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.darkGray.withValues(alpha: 0.7),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Details Section
                  _buildStepSection(
                    "How to perform:",
                    step.details,
                    Icons.check_circle,
                    ThemeColors.green,
                  ),
                  gapH16,

                  // Dua Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: context.primaryColor,
                              size: 16,
                            ),
                            gapW8,
                            Text(
                              "Recommended Dua:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        gapH12,
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ThemeColors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            step.dua,
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
                        gapH8,
                        Text(
                          step.duaTransliteration,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: ThemeColors.blue.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        gapH6,
                        Text(
                          step.duaTranslation,
                          style: TextStyle(
                            fontSize: 11,
                            color: ThemeColors.darkGray.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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

  Widget _buildStepSection(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            gapW8,
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
        gapH8,
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              gapW8,
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildFinalDuaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: ThemeColors.green, size: 20),
              gapW8,
              const Text(
                "After Completing Wudu",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: ThemeColors.green,
                ),
              ),
            ],
          ),
          gapH16,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ، اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ",
              style: TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: 16,
                height: 1.8,
                color: ThemeColors.darkGray,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ),
          gapH12,
          Text(
            "Ash-hadu alla ilaha illallahu wahdahu la shareeka lah, wa ash-hadu anna Muhammadan 'abduhu wa rasuluh. Allahummaj'alni minat-tawwabeena waj'alni minal-mutatahhireen",
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: ThemeColors.blue.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          gapH8,
          Text(
            "I bear witness that there is no deity except Allah, alone without partner, and I bear witness that Muhammad is His servant and messenger. O Allah, make me among those who repent and make me among those who purify themselves.",
            style: TextStyle(
              fontSize: 11,
              color: ThemeColors.darkGray.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsPage() {
    return ListView(
      padding: p16,
      children: [
        _buildSectionHeader(
          "Helpful Tips",
          "Make your Wudu more effective",
          Icons.lightbulb_outline,
          ThemeColors.orange,
        ),
        gapH16,

        _buildTipCard(
          "Water Conservation",
          Icons.water_drop,
          ThemeColors.blue,
          [
            "Use minimal water - the Prophet (PBUH) used very little water",
            "Don't let the tap run continuously",
            "A small cup of water is often sufficient",
            "Avoid wastage as it's discouraged in Islam",
          ],
        ),

        gapH16,

        _buildTipCard(
          "Common Mistakes",
          Icons.warning,
          ThemeColors.orange,
          [
            "Forgetting to wash between fingers and toes",
            "Not washing the entire required area",
            "Using too much or too little water",
            "Breaking the sequence of steps",
            "Talking unnecessarily during Wudu",
          ],
        ),

        gapH16,

        _buildTipCard(
          "Best Practices",
          Icons.star,
          ThemeColors.green,
          [
            "Face the Qibla if possible",
            "Use your right hand to take water",
            "Start each action with 'Bismillah'",
            "Recite the recommended duas",
            "Maintain concentration and mindfulness",
          ],
        ),

        gapH16,

        _buildTipCard(
          "Special Situations",
          Icons.info,
          context.primaryColor,
          [
            "If water is unavailable, perform Tayammum (dry ablution)",
            "If you have wounds, wipe over bandages",
            "Wipe over socks if they were put on in a state of purity",
            "For nail polish, ensure it allows water to reach the nails",
          ],
        ),

        gapH32,
      ],
    );
  }

  Widget _buildTipCard(String title, IconData icon, Color color, List<String> tips) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                gapW12,
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: tips.map((tip) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    gapW12,
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
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

  Widget _buildInfoCard(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                gapH4,
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.darkGray.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
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
              Icon(Icons.water_drop, color: context.primaryColor),
              gapW8,
              const Text('About Wudu'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This comprehensive Wudu guide helps both Muslims and non-Muslims understand Islamic ritual purification.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Step-by-step instructions with Arabic\n'
                   '• Duas for each step\n'
                   '• Conditions and requirements\n'
                   '• Helpful tips and best practices\n'
                   '• Common mistakes to avoid',
                   style: TextStyle(fontSize: 13)),
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
}

// Data Model
class WuduStep {
  final int stepNumber;
  final String title;
  final String arabicTitle;
  final String description;
  final List<String> details;
  final String dua;
  final String duaTransliteration;
  final String duaTranslation;

  const WuduStep({
    required this.stepNumber,
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.details,
    required this.dua,
    required this.duaTransliteration,
    required this.duaTranslation,
  });
} 