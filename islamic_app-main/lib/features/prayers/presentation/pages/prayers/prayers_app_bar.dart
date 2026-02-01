import 'package:easy_localization/easy_localization.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/date_time_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/widgets/ink_well_view.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';

class PrayersAppBar extends StatelessWidget {
  const PrayersAppBar({
    super.key,
    required this.currentLoc,
    required this.upcomingPrayer,
  });

  final LocationData currentLoc;
  final PrayerItem upcomingPrayer;

  String _formatTimeDifference(Duration difference) {
    if (difference.isNegative || difference.inSeconds == 0) {
      return "0m 0s";
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m ${seconds}s";
    } else if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  // Helper method to get prayer label (handles Friday Jumaah)
  String _getPrayerLabel(PrayerItem prayer) {
    if (prayer.time.weekday == DateTime.friday && prayer.type == PrayerType.dhuhr) {
      return LocaleKeys.jumaah.tr();
    }
    return prayer.type.label;
  }

  @override
  Widget build(BuildContext context) {
    // Use real-time current time for accurate countdown
    final currentTime = DateTime.now();
    final difference = upcomingPrayer.time.copyWith(second: 0).difference(currentTime);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWellView(
              onTap: () {
                // context.pushNamed(Routes.locations.name);
              },
              child: Row(
                children: [
                  Text(
                    currentLoc.locName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: context.onTertiaryColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ).flexible(),
                  ImageView(
                    imagePath: Icons.keyboard_arrow_down_rounded,
                    color: context.outlineVariantColor,
                  ),
                ],
              ),
            ).expanded(),
            ImageView(
              imagePath: Icons.my_location_rounded,
              color: context.onTertiaryColor,
              padding: p8,
              onTap: () {
                // getIt<OnboardSettingsBloc>().add(const OnboardSettingsEvent.getCurrentLocation());
              },
            ),
          ],
        ),
        gapH8,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ImageView(
                  imagePath: Icons.double_arrow_rounded,
                  color: context.outlineVariantColor,
                  height: 24,
                  width: 24,
                ),
                gapW8,
                              Text(
                _getPrayerLabel(upcomingPrayer).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: context.onTertiaryColor,
                ),
              ).tr(context: context),
              ],
            ),
            gapH4,
            Row(
              children: [
                Text(
                  upcomingPrayer.time.timeWithoutPeriod(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: context.onTertiaryColor,
                  ),
                ).tr(context: context),
                gapW16,
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadiusDirectional.all(Radius.circular(16)),
                    border: Border.all(
                      color: context.outlineVariantColor,
                      // color: ThemeColors.teal,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _formatTimeDifference(difference),
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      color: context.onTertiaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ).withPadding(
      const EdgeInsetsDirectional.only(
          top: 16.0, bottom: 16.0, start: 16.0, end: 8.0),
    );
  }
}
