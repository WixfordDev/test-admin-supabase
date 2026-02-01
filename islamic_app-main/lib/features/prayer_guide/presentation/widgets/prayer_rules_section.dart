import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/prayer_guide/presentation/widgets/common_widgets.dart';

class PrayerRulesSection extends StatelessWidget {
  const PrayerRulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: p16,
      children: [
        _buildSectionHeader(
          "Important Prayer Rules",
          "Essential guidelines for proper prayer",
          Icons.rule,
          context.primaryColor,
        ),
        gapH16,

        // Essential Rules Card
        CommonWidgets.buildDetailCard(
          "Essential Prayer Requirements",
          Icons.star,
          context.primaryColor,
          [
            _buildRule(
              "✓ Must face Qibla (direction of Mecca)",
              "Face the direction of the Ka'bah in Mecca for your prayer to be valid",
              false,
            ),
            _buildRule(
              "✓ Must be in state of purity (Wudu)",
              "Perform ablution before prayer. Without it, prayer is not accepted",
              false,
            ),
            _buildRule(
              "✓ Must cover Awrah (body parts)",
              "Men: navel to knees. Women: entire body except face and hands",
              false,
            ),
            _buildRule(
              "✓ Must pray at correct times",
              "Each prayer has a specific time window. Don't delay unnecessarily",
              false,
            ),
            _buildRule(
              "✓ Must recite Surah Al-Fatiha",
              "Required in every rakat. Without it, the rakat is invalid",
              false,
            ),
          ],
        ),

        gapH16,

        // Forbidden Times Card (with warning color)
        CommonWidgets.buildDetailCard(
          "⚠️ FORBIDDEN Prayer Times",
          Icons.warning,
          Colors.red,
          [
            _buildRule(
              "❌ During Sunrise",
              "From when the sun starts to rise until it's fully risen (about 15-20 minutes)",
              true,
            ),
            _buildRule(
              "❌ During Sunset",
              "From when the sun starts to set until it's completely set (about 15-20 minutes)",
              true,
            ),
            _buildRule(
              "❌ When Sun is at Zenith",
              "About 15 minutes before and during Zuhr time on Fridays",
              true,
            ),
            _buildRule(
              "⚠️ Exception: Missed obligatory (Fard) prayers can be made up at any time",
              "You can pray missed Fard prayers even during forbidden times",
              false,
            ),
          ],
        ),

        gapH16,

        // Prayer Invalidators Card (with warning color)
        CommonWidgets.buildDetailCard(
          "⚠️ Things That Break Prayer",
          Icons.cancel,
          Colors.red.shade700,
          [
            _buildRule(
              "❌ Breaking Wudu",
              "Using bathroom, passing gas, bleeding, vomiting, sleeping",
              true,
            ),
            _buildRule(
              "❌ Eating or Drinking",
              "Any consumption during prayer invalidates it",
              true,
            ),
            _buildRule(
              "❌ Talking",
              "Speaking to someone or making unnecessary sounds",
              true,
            ),
            _buildRule(
              "❌ Excessive Movement",
              "Moving too much or turning away from Qibla",
              true,
            ),
            _buildRule(
              "❌ Laughing Out Loud",
              "Audible laughter breaks the prayer",
              true,
            ),
          ],
        ),

        gapH16,

        // Missed Prayer Rules
        CommonWidgets.buildDetailCard(
          "Missed Prayer (Qada) Rules",
          Icons.access_time,
          ThemeColors.orange,
          [
            _buildRule(
              "✓ Pray immediately when you remember",
              "Don't delay making up missed prayers",
              false,
            ),
            _buildRule(
              "✓ Maintain the original order",
              "Pray missed prayers in the order they were missed",
              false,
            ),
            _buildRule(
              "✓ No limit on how many you can make up",
              "You can pray multiple missed prayers in succession",
              false,
            ),
            _buildRule(
              "⚠️ Intentionally missing prayer is a major sin",
              "Try your best to never miss prayers without valid excuse",
              true,
            ),
          ],
        ),

        gapH16,

        // Travel Prayer Rules
        CommonWidgets.buildDetailCard(
          "Travel Prayer (Qasr) Rules",
          Icons.flight,
          ThemeColors.blue,
          [
            _buildRule(
              "✓ Shorten 4-rakat prayers to 2 rakats",
              "Zuhr, Asr, and Isha become 2 rakats during travel",
              false,
            ),
            _buildRule(
              "✓ Minimum travel distance: ~77km/48 miles",
              "Distance where shortening becomes permissible",
              false,
            ),
            _buildRule(
              "✓ Can combine prayers during travel",
              "Zuhr+Asr together, Maghrib+Isha together",
              false,
            ),
            _buildRule(
              "✓ Fajr and Maghrib remain unchanged",
              "Always pray 2 rakats for Fajr, 3 for Maghrib",
              false,
            ),
          ],
        ),

        gapH16,

        // Women's Prayer Rules
        CommonWidgets.buildDetailCard(
          "Special Considerations for Women",
          Icons.woman,
          ThemeColors.green,
          [
            _buildRule(
              "✓ During menstruation: No prayer required",
              "Women don't pray during monthly cycle, no makeup required",
              false,
            ),
            _buildRule(
              "✓ During postpartum bleeding: No prayer required",
              "Same rule applies during postpartum period",
              false,
            ),
            _buildRule(
              "✓ Can pray at home or mosque",
              "Home prayer is often preferred and rewarded equally",
              false,
            ),
            _buildRule(
              "✓ Modest dress code required",
              "Cover entire body except face and hands",
              false,
            ),
          ],
        ),

        gapH16,

        // Emergency Situations
        CommonWidgets.buildDetailCard(
          "Emergency/Sick Prayer Rules",
          Icons.local_hospital,
          Colors.orange.shade700,
          [
            _buildRule(
              "✓ Can pray sitting if can't stand",
              "Sitting prayer is valid when standing is difficult",
              false,
            ),
            _buildRule(
              "✓ Can pray lying down if necessary",
              "Face direction of Qibla if possible",
              false,
            ),
            _buildRule(
              "✓ Can combine prayers during illness",
              "Join prayers to reduce difficulty",
              false,
            ),
            _buildRule(
              "✓ Tayammum when water unavailable",
              "Dry ablution with clean earth/dust when water absent",
              false,
            ),
            _buildRule(
              "⚠️ Never completely abandon prayer",
              "There's always a way to pray according to your ability",
              true,
            ),
          ],
        ),

        gapH16,

        // Congregation Prayer Rules
        CommonWidgets.buildDetailCard(
          "Congregation (Jamaat) Prayer Rules",
          Icons.group,
          ThemeColors.blue,
          [
            _buildRule(
              "✓ 27 times more reward than individual prayer",
              "Praying in congregation has immense spiritual benefits",
              false,
            ),
            _buildRule(
              "✓ Follow the Imam completely",
              "Don't move before the Imam, follow all movements",
              false,
            ),
            _buildRule(
              "✓ Stand shoulder to shoulder",
              "Fill gaps in rows, stand close together",
              false,
            ),
            _buildRule(
              "✓ If late, join wherever Imam is",
              "Complete missed portions after Imam finishes",
              false,
            ),
            _buildRule(
              "⚠️ Don't talk during prayer",
              "Maintain complete silence and focus",
              true,
            ),
          ],
        ),

        gapH32,
      ],
    );
  }

  Widget _buildSectionHeader(
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

  Widget _buildRule(String title, String description, bool isWarning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.red.shade50
            : ThemeColors.lightGray2.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border:
            isWarning ? Border.all(color: Colors.red.shade200, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isWarning ? Colors.red.shade800 : ThemeColors.darkGray,
            ),
          ),
          gapH4,
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isWarning
                  ? Colors.red.shade700
                  : ThemeColors.darkGray.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
