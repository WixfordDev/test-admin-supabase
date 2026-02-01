import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/utils/date_time_utils.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/core/widgets/ink_well_view.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';

class PrayerItemView extends StatelessWidget {
  const PrayerItemView({
    super.key,
    required this.item,
    required this.currentTime,
    required this.isCountdown,
    required this.reminderOn,
  });

  final PrayerItem item;
  final DateTime currentTime;
  final bool isCountdown;
  final bool reminderOn;

  @override
  Widget build(BuildContext context) {
    final color = item.isUpcoming ? context.primaryColor : context.onSurfaceColor;
    final fontWeight = (item.isCurrent || item.isUpcoming) ? FontWeight.bold : FontWeight.normal;
    final label = item.time.weekday == DateTime.friday && item.type == PrayerType.dhuhr
        ? LocaleKeys.jumaah.tr()
        : item.type.label;

    return InkWellView(
      onTap: () {
      },
      child: Row(
        children: [
          Container(
            padding: 16.endPadding,
            decoration: (item.isUpcoming)
                ? BoxDecoration(
                    borderRadius: const BorderRadiusDirectional.all(Radius.circular(64)),
                    border: Border.all(
                      color: context.primaryColor.withValues(alpha: .5),
                      width: 2,
                    ),
                  )
                : null,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
                  decoration: (item.isCurrent)
                      ? BoxDecoration(
                          color: context.primaryColor.withValues(alpha: .2),
                          borderRadius: const BorderRadiusDirectional.all(Radius.circular(64)),
                        )
                      : null,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: fontWeight,
                    ),
                  ).tr(context: context),
                ),
                const Spacer(),
                ...(isCountdown
                    ? _buildCountdownView(context, color, fontWeight)
                    : _buildHourView(context, color, fontWeight)),
              ],
            ),
          ).expanded(),
          gapW8,
          ImageView(
            imagePath: reminderOn ? Icons.volume_down_outlined : Icons.notifications_off_outlined,
            color: reminderOn ? ThemeColors.darkGray : context.secondaryColor,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCountdownView(BuildContext context, Color color, FontWeight fontWeight) {
    final difference = item.time.difference(currentTime);
    return [
      Text(
        difference.formatInHourAndMinutes(useMiniFormat: true),
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: fontWeight,
        ),
      ).tr(context: context),
    ];
  }

  List<Widget> _buildHourView(BuildContext context, Color color, FontWeight fontWeight) {
    return [
      Text(
        item.time.timeWithoutPeriod(),
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: fontWeight,
        ),
      ).tr(context: context),
      gapW8,
      Text(
        item.time.inAmOrPm(),
        style: TextStyle(
          color: ((item.isUpcoming) ? context.primaryColor : ThemeColors.darkGray).withValues(alpha: .5),
          fontSize: 16,
          fontWeight: fontWeight,
        ),
      ).tr(context: context),
    ];
  }
}
