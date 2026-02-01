import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class HajjGuideScreen extends StatefulWidget {
  const HajjGuideScreen({super.key});

  @override
  State<HajjGuideScreen> createState() => _HajjGuideScreenState();
}

class _HajjGuideScreenState extends State<HajjGuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<HajjStep> hajjSteps = [
    const HajjStep(
      title: "Ihram",
      arabicTitle: "الإحرام",
      description: "The sacred state of purity and intention",
      details: [
        "Enter the state of Ihram before crossing the Miqat (designated boundary)",
        "Perform Ghusl (ritual bath) and wear the prescribed clothing",
        "Men: Two white seamless cloths (Izar and Rida)",
        "Women: Regular modest clothing covering the body",
        "Make the intention (Niyyah) for Hajj or Umrah",
        "Recite the Talbiyah: 'Labbayk Allahumma Labbayk...'"
      ],
      prohibitions: [
        "No cutting of hair or nails",
        "No use of perfumes or scented products",
        "No sexual relations",
        "No hunting or killing animals",
        "Men cannot cover their heads or wear sewn garments",
        "Women cannot cover their faces or hands"
      ],
      dua: "لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ",
      duaTransliteration: "Labbayk Allahumma labbayk, labbayk la shareeka laka labbayk, innal hamda wan-ni'mata laka wal-mulk, la shareeka lak",
      duaTranslation: "Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Indeed all praise, favor and sovereignty belong to You. You have no partner.",
    ),
    const HajjStep(
      title: "Tawaf al-Qudum",
      arabicTitle: "طواف القدوم",
      description: "The arrival circumambulation around the Kaaba",
      details: [
        "Perform Tawaf (7 rounds) around the Kaaba in counter-clockwise direction",
        "Start and end each round at the Black Stone (Hajar al-Aswad)",
        "Kiss the Black Stone if possible, otherwise point to it",
        "Recite prayers and supplications during Tawaf",
        "For men: Perform Raml (quick pace) in first 3 rounds",
        "Keep the Kaaba on your left side throughout"
      ],
      prohibitions: [
        "Maintain the prohibitions of Ihram",
        "Do not push or harm others",
        "Maintain cleanliness and modesty"
      ],
      dua: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      duaTransliteration: "Rabbana atina fi'd-dunya hasanatan wa fi'l-akhirati hasanatan wa qina 'adhab an-nar",
      duaTranslation: "Our Lord, give us good in this world and good in the next world, and save us from the punishment of the Fire.",
    ),
    const HajjStep(
      title: "Sa'i",
      arabicTitle: "السعي",
      description: "Walking between the hills of Safa and Marwah",
      details: [
        "Walk 7 times between the hills of Safa and Marwah",
        "Start at Safa and end at Marwah",
        "Recite prayers and make supplications",
        "Men should jog in the designated green-lit area",
        "Women walk at normal pace throughout",
        "Remember the story of Hajar (Hagar) searching for water"
      ],
      prohibitions: [
        "Continue observing Ihram restrictions",
        "Do not run outside designated areas (for men)",
        "Maintain respect and order"
      ],
      dua: "إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ",
      duaTransliteration: "Inna as-Safa wal-Marwata min sha'a'ir Allah",
      duaTranslation: "Indeed, Safa and Marwah are among the symbols of Allah.",
    ),
    const HajjStep(
      title: "Day of Tarwiyah (Mina)",
      arabicTitle: "يوم التروية",
      description: "8th of Dhul Hijjah - Journey to Mina",
      details: [
        "Travel to Mina on the 8th of Dhul Hijjah",
        "Spend the day and night in Mina",
        "Perform Dhuhr, Asr, Maghrib, Isha, and Fajr prayers",
        "Engage in remembrance of Allah (Dhikr)",
        "Prepare spiritually for Arafat",
        "Rest and conserve energy for the next day"
      ],
      prohibitions: [
        "Continue all Ihram restrictions",
        "Stay focused on worship",
        "Avoid unnecessary activities"
      ],
      dua: "اللَّهُمَّ بَلِّغْنِي عَرَفَةَ",
      duaTransliteration: "Allahumma ballighni 'Arafah",
      duaTranslation: "O Allah, let me reach Arafat.",
    ),
    const HajjStep(
      title: "Day of Arafat",
      arabicTitle: "يوم عرفة",
      description: "9th of Dhul Hijjah - The pinnacle of Hajj",
      details: [
        "Travel to Arafat after Fajr prayer",
        "Stay in Arafat from Dhuhr until sunset",
        "Perform Dhuhr and Asr prayers combined and shortened",
        "Make extensive supplications (this is the essence of Hajj)",
        "Listen to the Khutbah (sermon) at Masjid Namirah",
        "Stand anywhere within the boundaries of Arafat"
      ],
      prohibitions: [
        "Do not leave Arafat before sunset",
        "Maintain Ihram restrictions",
        "Focus on worship and supplication"
      ],
      dua: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
      duaTransliteration: "La ilaha illa Allah, wahdahu la shareeka lah, lahu'l-mulku wa lahu'l-hamd, wa huwa 'ala kulli shay'in qadeer",
      duaTranslation: "There is no god but Allah, alone without partner. To Him belongs the kingdom, to Him belongs all praise, and He has power over everything.",
    ),
    const HajjStep(
      title: "Muzdalifah",
      arabicTitle: "المزدلفة",
      description: "Night between Arafat and Mina",
      details: [
        "Travel to Muzdalifah after sunset from Arafat",
        "Perform Maghrib and Isha prayers combined",
        "Spend the night under the open sky if possible",
        "Collect 70 small pebbles for Jamarat",
        "Pray Fajr early and make supplications until sunrise",
        "Women and elderly may leave after midnight"
      ],
      prohibitions: [
        "Continue Ihram restrictions",
        "Do not leave before Fajr (except for women/elderly)",
        "Maintain spiritual focus"
      ],
      dua: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ",
      duaTransliteration: "Allahumma a'inni 'ala dhikrika wa shukrika wa husni 'ibadatik",
      duaTranslation: "O Allah, help me in remembering You, thanking You, and worshipping You in the best manner.",
    ),
    const HajjStep(
      title: "Rami al-Jamarat",
      arabicTitle: "رمي الجمرات",
      description: "Stoning of the pillars",
      details: [
        "10th Dhul Hijjah: Stone only Jamrat al-Aqaba (large pillar) with 7 pebbles",
        "11th-12th Dhul Hijjah: Stone all three pillars (small, medium, large) with 7 pebbles each",
        "Stone between sunrise and sunset",
        "Say 'Allahu Akbar' with each throw",
        "Throw pebbles individually, not all at once",
        "Stand at a reasonable distance (not too close)"
      ],
      prohibitions: [
        "Do not throw shoes, large stones, or other objects",
        "Do not push or harm others",
        "Do not stone outside the designated times"
      ],
      dua: "اللهُ أَكْبَر",
      duaTransliteration: "Allahu Akbar",
      duaTranslation: "Allah is the Greatest.",
    ),
    const HajjStep(
      title: "Sacrifice (Qurbani)",
      arabicTitle: "الأضحية",
      description: "Animal sacrifice on 10th Dhul Hijjah",
      details: [
        "Perform sacrifice after stoning Jamrat al-Aqaba",
        "Sacrifice a sheep, goat, or share in a cow/camel",
        "Can be done personally or through authorized agents",
        "Eat some of the meat and distribute to the poor",
        "This completes one of the main rituals of Hajj",
        "Can be done until sunset on 13th Dhul Hijjah"
      ],
      prohibitions: [
        "Ensure the animal meets Islamic requirements",
        "Cannot use sick or defective animals",
        "Must be done within the designated area"
      ],
      dua: "بِسْمِ اللَّهِ، اللَّهُمَّ تَقَبَّلْ مِنِّي",
      duaTransliteration: "Bismillah, Allahumma taqabbal minni",
      duaTranslation: "In the name of Allah, O Allah, accept from me.",
    ),
    const HajjStep(
      title: "Halq/Taqsir",
      arabicTitle: "الحلق أو التقصير",
      description: "Shaving or shortening the hair",
      details: [
        "Men: Complete shaving (Halq) is preferred, or shortening (Taqsir)",
        "Women: Cut a fingertip's length from the end of hair",
        "Perform after the sacrifice",
        "This partially exits the state of Ihram",
        "All prohibitions of Ihram are lifted except marital relations",
        "Can now wear regular clothes and use perfume"
      ],
      prohibitions: [
        "Women should not shave their heads",
        "Do not cut more than required for women",
        "Maintain cleanliness and modesty"
      ],
      dua: "اللَّهُمَّ اغْفِرْ لِلْمُحَلِّقِينَ",
      duaTransliteration: "Allahummaghfir lil-muhalliqeen",
      duaTranslation: "O Allah, forgive those who shave their heads.",
    ),
    const HajjStep(
      title: "Tawaf al-Ifadah",
      arabicTitle: "طواف الإفاضة",
      description: "The main Tawaf of Hajj",
      details: [
        "Perform Tawaf (7 rounds) around the Kaaba",
        "This is one of the essential pillars of Hajj",
        "Can be performed on 10th, 11th, or 12th Dhul Hijjah",
        "After this Tawaf, all restrictions of Ihram are lifted",
        "Perform Sa'i if you haven't done it earlier",
        "This completes the major rituals of Hajj"
      ],
      prohibitions: [
        "Maintain cleanliness and Wudu",
        "Show respect and avoid pushing",
        "Complete all 7 rounds properly"
      ],
      dua: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      duaTransliteration: "Rabbana atina fi'd-dunya hasanatan wa fi'l-akhirati hasanatan wa qina 'adhab an-nar",
      duaTranslation: "Our Lord, give us good in this world and good in the next world, and save us from the punishment of the Fire.",
    ),
    const HajjStep(
      title: "Tawaf al-Wida",
      arabicTitle: "طواف الوداع",
      description: "The farewell Tawaf",
      details: [
        "Perform this final Tawaf before leaving Mecca",
        "Seven rounds around the Kaaba",
        "Make final supplications and prayers",
        "This is the last ritual of Hajj",
        "Drink Zamzam water and make dua",
        "Bid farewell to the Holy Kaaba"
      ],
      prohibitions: [
        "Do not delay unnecessarily after this Tawaf",
        "Women in menstruation are excused from this Tawaf",
        "Maintain respect and devotion"
      ],
      dua: "اللَّهُمَّ زِدْ هَذَا الْبَيْتَ تَشْرِيفًا وَتَعْظِيمًا وَتَكْرِيمًا وَمَهَابَةً",
      duaTransliteration: "Allahumma zid hadha'l-bayta tashrife wa ta'ziman wa takriman wa mahabah",
      duaTranslation: "O Allah, increase this House in honor, reverence, respect and awe.",
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
        title: const Text("Hajj Guide"),
        centerTitle: true,
        backgroundColor: context.primaryColor,
        foregroundColor: ThemeColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'About Hajj',
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
                _buildPreparationPage(),
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
                    "Hajj - The Sacred Journey",
                    style: TextStyle(
                      color: ThemeColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  gapH4,
                  const Text(
                    "Complete guide to the pilgrimage of a lifetime",
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
          _buildTabButton("Steps", 1, Icons.list_alt),
          _buildTabButton("Preparation", 2, Icons.checklist),
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
          "What is Hajj?",
          "Understanding the sacred pilgrimage",
          Icons.help_outline,
          context.primaryColor,
        ),
        gapH16,
        _buildInfoCard(
          "The Fifth Pillar of Islam",
          "Hajj is the annual Islamic pilgrimage to Mecca, Saudi Arabia. It is a mandatory religious duty for Muslims who are physically and financially capable of undertaking the journey.",
          Icons.star,
          context.primaryColor,
        ),
        gapH8,
        _buildInfoCard(
          "When is Hajj Performed?",
          "Hajj is performed during the Islamic month of Dhul Hijjah, specifically from the 8th to 12th (or 13th) of the month.",
          Icons.calendar_today,
          ThemeColors.blue,
        ),
        gapH8,
        _buildInfoCard(
          "Who Must Perform Hajj?",
          "Every adult Muslim who is physically able and can financially afford the journey must perform Hajj at least once in their lifetime.",
          Icons.people,
          ThemeColors.green,
        ),

        gapH24,
        _buildSectionHeader(
          "Types of Hajj",
          "Three different ways to perform Hajj",
          Icons.route,
          ThemeColors.orange,
        ),
        gapH16,
        _buildHajjTypesGrid(),

        gapH24,
        _buildSectionHeader(
          "Spiritual Significance",
          "The deeper meaning of Hajj",
          Icons.favorite,
          ThemeColors.orange,
        ),
        gapH12,
        _buildInfoCard(
          "Unity and Equality",
          "Hajj demonstrates the unity of Muslims regardless of race, nationality, or social status. All pilgrims wear simple white garments.",
          Icons.group,
          ThemeColors.orange,
        ),
        gapH8,
        _buildInfoCard(
          "Forgiveness and Purification",
          "The Prophet Muhammad (PBUH) said: 'Whoever performs Hajj and does not commit any obscenity or transgression will return as pure as the day his mother gave birth to him.'",
          Icons.clean_hands,
          ThemeColors.green,
        ),
        gapH8,
        _buildInfoCard(
          "Following Abraham's Footsteps",
          "Many Hajj rituals commemorate the actions of Prophet Abraham (Ibrahim), his wife Hagar (Hajar), and their son Ishmael (Ismail).",
          Icons.history,
          ThemeColors.blue,
        ),

        gapH32,
      ],
    );
  }

  Widget _buildHajjTypesGrid() {
    final types = [
      {
        'title': 'Hajj Tamattu',
        'arabic': 'حج التمتع',
        'description': 'Perform Umrah first, then Hajj',
        'details': 'Exit Ihram after Umrah, re-enter for Hajj',
        'color': ThemeColors.green,
      },
      {
        'title': 'Hajj Qiran',
        'arabic': 'حج القران',
        'description': 'Umrah and Hajj together',
        'details': 'Remain in Ihram throughout both',
        'color': ThemeColors.blue,
      },
      {
        'title': 'Hajj Ifrad',
        'arabic': 'حج الإفراد',
        'description': 'Hajj only',
        'details': 'Intention only for Hajj',
        'color': ThemeColors.orange,
      },
    ];

    return Column(
      children: types.map((type) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (type['color'] as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (type['color'] as Color).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (type['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.route,
                color: type['color'] as Color,
                size: 20,
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type['arabic'] as String,
                    style: TextStyle(
                      fontFamily: 'ScheherazadeNew',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: type['color'] as Color,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    type['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  gapH4,
                  Text(
                    type['description'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    type['details'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: ThemeColors.darkGray.withValues(alpha: 0.7),
                    ),
                  ),
                ],
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
          "Hajj Steps",
          "Complete guide to performing Hajj",
          Icons.list_alt,
          context.primaryColor,
        ),
        gapH16,
        ...hajjSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return _buildStepCard(step, index + 1);
        }),
        gapH32,
      ],
    );
  }

  Widget _buildStepCard(HajjStep step, int stepNumber) {
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
                stepNumber.toString(),
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
                    "What to Do:",
                    step.details,
                    Icons.check_circle,
                    ThemeColors.green,
                  ),
                  gapH16,

                  // Prohibitions Section
                  if (step.prohibitions.isNotEmpty) ...[
                    _buildStepSection(
                      "Important Notes:",
                      step.prohibitions,
                      Icons.warning,
                      ThemeColors.orange,
                    ),
                    gapH16,
                  ],

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

  Widget _buildPreparationPage() {
    return ListView(
      padding: p16,
      children: [
        _buildSectionHeader(
          "Hajj Preparation",
          "Essential preparation for your journey",
          Icons.checklist,
          ThemeColors.blue,
        ),
        gapH16,

        _buildPreparationCard(
          "Before You Go",
          Icons.flight_takeoff,
          ThemeColors.blue,
          [
            "Complete all required vaccinations",
            "Obtain Hajj visa and necessary documents",
            "Learn basic Arabic phrases and prayers",
            "Study the Hajj rituals thoroughly",
            "Arrange for family responsibilities",
            "Set up automatic bill payments",
            "Inform banks of travel plans",
            "Get travel insurance",
          ],
        ),

        gapH16,

        _buildPreparationCard(
          "What to Pack",
          Icons.luggage,
          ThemeColors.green,
          [
            "Ihram clothing (2-3 sets for men)",
            "Comfortable walking shoes",
            "Prayer mat and Quran",
            "Medications and first aid kit",
            "Sunscreen and lip balm",
            "Unscented toiletries",
            "Small bag for pebbles",
            "Copies of important documents",
          ],
        ),

        gapH16,

        _buildPreparationCard(
          "Physical Preparation",
          Icons.fitness_center,
          ThemeColors.orange,
          [
            "Start walking regularly to build stamina",
            "Practice crowd management techniques",
            "Learn to sleep in various conditions",
            "Maintain good hygiene habits",
            "Stay hydrated and eat healthy",
            "Consult doctor for health clearance",
            "Practice patience and self-control",
            "Build mental and spiritual strength",
          ],
        ),

        gapH16,

        _buildPreparationCard(
          "Spiritual Preparation",
          Icons.favorite,
          context.primaryColor,
          [
            "Increase prayers and remembrance of Allah",
            "Seek forgiveness from Allah and people",
            "Learn Hajj-related supplications",
            "Study the life of Prophet Ibrahim",
            "Practice humility and patience",
            "Make a list of people to pray for",
            "Set spiritual goals for Hajj",
            "Purify your intention (Niyyah)",
          ],
        ),

        gapH32,
      ],
    );
  }

  Widget _buildPreparationCard(String title, IconData icon, Color color, List<String> items) {
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
              children: items.map((item) => Container(
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
                        item,
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
              Icon(Icons.mosque, color: context.primaryColor),
              gapW8,
              const Text('About Hajj'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This comprehensive Hajj guide helps both Muslims and non-Muslims understand the sacred pilgrimage to Mecca.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Complete step-by-step instructions\n'
                   '• Arabic text with pronunciation\n'
                   '• Preparation guidelines\n'
                   '• Spiritual significance\n'
                   '• Types of Hajj explained',
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
class HajjStep {
  final String title;
  final String arabicTitle;
  final String description;
  final List<String> details;
  final List<String> prohibitions;
  final String dua;
  final String duaTransliteration;
  final String duaTranslation;

  const HajjStep({
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.details,
    required this.prohibitions,
    required this.dua,
    required this.duaTransliteration,
    required this.duaTranslation,
  });
} 