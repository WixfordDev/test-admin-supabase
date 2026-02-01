import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/prayer_guide/domain/model/prayer_step.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/prayer_specific_guide_bottom_sheet.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/prayer_details_bottom_sheet.dart';
import 'package:go_router/go_router.dart';

class PrayerOverviewSection extends StatelessWidget {
  final List<DetailedPrayer> prayers;

  const PrayerOverviewSection({
    super.key,
    required this.prayers,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: p16,
      children: [
        _buildSectionHeader(
          context,
          "The Five Daily Prayers",
          "Muslims pray five times a day at specific times",
          Icons.schedule,
          context.primaryColor,
        ),
        gapH16,

        // Prayer Times Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: prayers.length,
          itemBuilder: (context, index) {
            return _buildEnhancedPrayerCard(context, prayers[index]);
          },
        ),

        gapH24,

        // Quick Actions
        _buildQuickActionsSection(context),

        gapH24,

        // Why Muslims Pray Section
        _buildWhyPraySection(context),

        gapH32,
      ],
    );
  }

  Widget _buildEnhancedPrayerCard(BuildContext context, DetailedPrayer prayer) {
    return GestureDetector(
      onTap: () => PrayerDetailsBottomSheet.show(context, prayer),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeColors.white,
              prayer.isSpecial 
                ? ThemeColors.green.withValues(alpha: 0.1)
                : ThemeColors.lightGray2.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: prayer.isSpecial 
              ? ThemeColors.green.withValues(alpha: 0.4)
              : context.primaryColor.withValues(alpha: 0.3),
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
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prayer.isSpecial)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ThemeColors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "FRIDAY",
                    style: TextStyle(
                      color: ThemeColors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                prayer.arabicName,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: prayer.isSpecial ? ThemeColors.green : context.primaryColor,
                ),
                textDirection: TextDirection.rtl,
              ),
              Text(
                prayer.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.darkGray,
                ),
              ),
              gapH4,
              // Prayer Sequence Display
              _buildPrayerSequenceDisplay(context, prayer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerSequenceDisplay(BuildContext context, DetailedPrayer prayer) {
    List<Widget> sequence = [];
    
    if (prayer.sunnahBefore > 0) {
      sequence.add(_buildSequenceItem(context, "${prayer.sunnahBefore} Sunnah", ThemeColors.orange, "Before", true, prayer, 'sunnah_before'));
      sequence.add(gapH4);
    }
    
    sequence.add(_buildSequenceItem(context, "${prayer.fardRakats} Fard", context.primaryColor, "Main", false, prayer, 'fard'));
    
    if (prayer.sunnahAfter > 0) {
      sequence.add(gapH4);
      sequence.add(_buildSequenceItem(context, "${prayer.sunnahAfter} Sunnah", ThemeColors.orange, "After", true, prayer, 'sunnah_after'));
    }
    
    if (prayer.witr > 0) {
      sequence.add(gapH4);
      sequence.add(_buildSequenceItem(context, "${prayer.witr} Witr", ThemeColors.blue, "Optional", true, prayer, 'witr'));
    }
    
    return Column(children: sequence);
  }

  Widget _buildSequenceItem(BuildContext context, String text, Color color, String type, bool isOptional, DetailedPrayer prayer, String prayerType) {
    return GestureDetector(
      onTap: () => PrayerSpecificGuideBottomSheet.show(context, prayer, prayerType),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOptional ? Icons.add_circle_outline : Icons.star,
              size: 12,
              color: color,
            ),
            gapW4,
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            gapW4,
            Text(
              "($type)",
              style: TextStyle(
                fontSize: 8,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          "Quick Access",
          "Essential tools for prayer",
          Icons.apps,
          ThemeColors.blue,
        ),
        gapH12,
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                "Prayer Times",
                "Today's schedule",
                Icons.schedule,
                ThemeColors.green,
                () {
                  // Navigate to main screen with prayer tab selected
                  context.goNamed(Routes.prayers.name);
                },
              ),
            ),
            gapW12,
            Expanded(
              child: _buildQuickActionCard(
                context,
                "Qibla Direction",
                "Find direction",
                Icons.explore,
                ThemeColors.orange,
                () {
                  // Navigate to qibla screen
                  context.pushNamed(Routes.qibla.name);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            gapH8,
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            gapH4,
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: ThemeColors.darkGray.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyPraySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          "Why Muslims Pray",
          "Understanding the significance of prayer",
          Icons.favorite,
          ThemeColors.orange,
        ),
        gapH12,
        _buildInfoCard(
          "Spiritual Connection",
          "Prayer is a direct link between the worshipper and Allah, providing guidance and peace.",
          Icons.favorite_border,
          ThemeColors.orange,
        ),
        gapH8,
        _buildInfoCard(
          "Daily Discipline",
          "Five daily prayers create structure and remind Muslims of their faith throughout the day.",
          Icons.access_time,
          ThemeColors.blue,
        ),
        gapH8,
        _buildInfoCard(
          "Community Bond",
          "Praying together, especially on Fridays, strengthens the bonds within the Muslim community.",
          Icons.group,
          ThemeColors.green,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      String title, String subtitle, IconData icon, Color color) {
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

  Widget _buildInfoCard(
      String title, String description, IconData icon, Color color) {
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
} 