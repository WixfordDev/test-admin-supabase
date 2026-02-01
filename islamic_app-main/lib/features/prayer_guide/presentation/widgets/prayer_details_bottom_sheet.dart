import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/prayer_guide/domain/model/prayer_step.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/prayer_specific_guide_bottom_sheet.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/common_widgets.dart';

class PrayerDetailsBottomSheet {
  static void show(BuildContext context, DetailedPrayer prayer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
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
                  gradient: LinearGradient(
                    colors: prayer.isSpecial 
                      ? [ThemeColors.green, ThemeColors.green.withValues(alpha: 0.8)]
                      : [context.primaryColor, context.primaryColor.withValues(alpha: 0.8)],
                  ),
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
                      prayer.arabicName,
                      style: const TextStyle(
                        fontFamily: 'ScheherazadeNew',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.white,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    gapH8,
                    Text(
                      "${prayer.name} Prayer",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.white,
                      ),
                    ),
                    if (prayer.isSpecial)
                      const Text(
                        "Special Friday Prayer",
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColors.white,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: ListView(
                  padding: p16,
                  children: [
                    // Prayer Sequence Order
                    CommonWidgets.buildDetailCard(
                      "Prayer Sequence Order",
                      Icons.format_list_numbered,
                      prayer.isSpecial ? ThemeColors.green : context.primaryColor,
                      [
                        _buildPrayerSequenceOrder(context, prayer),
                      ],
                    ),
                    
                    gapH16,
                    
                    // Timing
                    CommonWidgets.buildDetailCard(
                      "Prayer Timing",
                      Icons.schedule,
                      ThemeColors.blue,
                      [
                        Text(
                          prayer.timeDescription,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                    
                    gapH16,
                    
                    // Virtues
                    if (prayer.virtues.isNotEmpty)
                      CommonWidgets.buildDetailCard(
                        "Virtues & Benefits",
                        Icons.favorite,
                        ThemeColors.orange,
                        prayer.virtues.map((virtue) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: ThemeColors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                gapW8,
                                Expanded(
                                  child: Text(
                                    virtue,
                                    style: const TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    
                    if (prayer.isSpecial) ...[
                      gapH16,
                      _buildJummahSpecialGuidance(),
                    ],
                    
                    gapH32,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildPrayerSequenceOrder(BuildContext context, DetailedPrayer prayer) {
    List<Widget> sequenceItems = [];
    int step = 1;
    
    if (prayer.sunnahBefore > 0) {
      sequenceItems.add(_buildSequenceOrderItem(
        context,
        step++, 
        "Sunnah Before", 
        "${prayer.sunnahBefore} Rakats", 
        ThemeColors.orange,
        "Voluntary prayer for extra reward",
        true,
        prayer,
        'sunnah_before'
      ));
      sequenceItems.add(gapH8);
    }
    
    sequenceItems.add(_buildSequenceOrderItem(
      context,
      step++, 
      "Fard (Main Prayer)", 
      "${prayer.fardRakats} Rakats", 
      context.primaryColor,
      "OBLIGATORY - Must be performed",
      false,
      prayer,
      'fard'
    ));
    
    if (prayer.sunnahAfter > 0) {
      sequenceItems.add(gapH8);
      sequenceItems.add(_buildSequenceOrderItem(
        context,
        step++, 
        "Sunnah After", 
        "${prayer.sunnahAfter} Rakats", 
        ThemeColors.orange,
        "Voluntary prayer for extra reward",
        true,
        prayer,
        'sunnah_after'
      ));
    }
    
    if (prayer.witr > 0) {
      sequenceItems.add(gapH8);
      sequenceItems.add(_buildSequenceOrderItem(
        context,
        step++, 
        "Witr Prayer", 
        "${prayer.witr} Rakats", 
        ThemeColors.blue,
        "Recommended odd prayer",
        true,
        prayer,
        'witr'
      ));
    }
    
    return Column(children: sequenceItems);
  }

  static Widget _buildSequenceOrderItem(BuildContext context, int step, String title, String rakats, Color color, String description, bool isOptional, DetailedPrayer prayer, String prayerType) {
    return GestureDetector(
      onTap: () => PrayerSpecificGuideBottomSheet.show(context, prayer, prayerType),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  step.toString(),
                  style: const TextStyle(
                    color: ThemeColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        rakats,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  gapH4,
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: ThemeColors.darkGray.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            gapW8,
            Icon(
              Icons.touch_app,
              color: color.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildJummahSpecialGuidance() {
    return CommonWidgets.buildDetailCard(
      "Jummah Special Guidelines",
      Icons.group,
      ThemeColors.green,
      [
        const Text(
          "• Arrive early and perform Ghusl (full body wash)\n"
          "• Listen attentively to the Khutbah (sermon)\n"
          "• Do not talk during the Khutbah\n"
          "• Recite Surah Al-Kahf on Friday\n"
          "• Make abundant Dua between Asr and Maghrib\n"
          "• Jummah replaces Dhuhr prayer for men\n"
          "• Women can attend but it's not obligatory for them",
          style: TextStyle(fontSize: 13, height: 1.6),
        ),
      ],
    );
  }
} 