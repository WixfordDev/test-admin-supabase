import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/features/dashboard/presentation/utils/prayer_time_utils.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:easy_localization/easy_localization.dart';

class UpcomingPrayerWidget extends StatefulWidget {
  final PrayerItem upcomingPrayer;
  final String remainingTime;

  const UpcomingPrayerWidget({
    super.key,
    required this.upcomingPrayer,
    required this.remainingTime,
  });

  @override
  State<UpcomingPrayerWidget> createState() => _UpcomingPrayerWidgetState();
}

class _UpcomingPrayerWidgetState extends State<UpcomingPrayerWidget>
    with TickerProviderStateMixin {
  late AnimationController _flickerController;
  late Animation<double> _flickerAnimation;

  @override
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flickerAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flickerController,
      curve: Curves.easeInOut,
    ));

    _checkAndStartFlicker();
  }

  @override
  void didUpdateWidget(UpcomingPrayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingTime != widget.remainingTime) {
      _checkAndStartFlicker();
    }
  }

  void _checkAndStartFlicker() {
    final now = DateTime.now();
    final timeDifference = widget.upcomingPrayer.time.difference(now);
    
    // Check if 30 minutes or less remaining
    if (timeDifference.inMinutes <= 30 && timeDifference.inMinutes > 0) {
      _flickerController.repeat(reverse: true);
    } else {
      _flickerController.stop();
      _flickerController.reset();
    }
  }

  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
  }

  bool get _isUrgent {
    final now = DateTime.now();
    final timeDifference = widget.upcomingPrayer.time.difference(now);
    return timeDifference.inMinutes <= 30 && timeDifference.inMinutes > 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgentColor = Colors.red.shade600;
    final isUrgent = _isUrgent;
    
    return AnimatedBuilder(
      animation: _flickerAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isUrgent 
                ? urgentColor.withValues(alpha: 0.1 * _flickerAnimation.value)
                : theme.primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: isUrgent 
                ? Border.all(
                    color: urgentColor.withValues(alpha: _flickerAnimation.value),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isUrgent 
                    ? urgentColor.withValues(alpha: 0.1 * _flickerAnimation.value)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prayer icon and details
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isUrgent 
                          ? urgentColor.withValues(alpha: 0.18 * _flickerAnimation.value)
                          : theme.primaryColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isUrgent ? Icons.warning_rounded : Icons.access_time_rounded,
                      color: isUrgent ? urgentColor : theme.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Prayer name - Line 1
                      Text(
                        _getPrayerName(widget.upcomingPrayer),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isUrgent ? urgentColor : theme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Prayer time - Line 2
                      Text(
                        PrayerTimeUtils.formatPrayerTime(widget.upcomingPrayer.time),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Status banner and countdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status banner - Line 1
                  Container( 
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isUrgent 
                          ? urgentColor.withValues(alpha: 0.22 * _flickerAnimation.value)
                          : theme.primaryColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isUrgent ? "Hurry Up!" : "Upcoming",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isUrgent ? urgentColor : theme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Countdown - Line 2
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isUrgent 
                          ? urgentColor.withValues(alpha: 0.12 * _flickerAnimation.value)
                          : theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUrgent ? Icons.timer_rounded : Icons.hourglass_bottom_rounded, 
                          color: isUrgent ? urgentColor : theme.primaryColor, 
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.remainingTime,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 11,
                            color: isUrgent ? urgentColor : theme.primaryColor, 
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to get prayer name with Friday Jumaah handling
  String _getPrayerName(PrayerItem prayer) {
    if (prayer.time.weekday == DateTime.friday && prayer.type == PrayerType.dhuhr) {
      return LocaleKeys.jumaah.tr();
    }
    return PrayerTimeUtils.getPrayerName(prayer.type, prayerTime: prayer.time);
  }
}
