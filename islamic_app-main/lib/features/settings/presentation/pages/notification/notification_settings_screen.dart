import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/settings/presentation/widgets/settings_item_view.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/features/settings/presentation/pages/notification/memorization_settings_screen.dart';
import 'package:deenhub/features/settings/presentation/pages/notification/sunnah_fasting_settings_screen.dart';
import 'package:deenhub/features/settings/presentation/pages/notification/prayer_notification_settings_screen.dart';
import 'package:deenhub/features/settings/presentation/pages/notification/zakat_reminders_settings_screen.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationSettingsData _currentSettings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _currentSettings = getIt<SharedPrefsHelper>().notificationSettingsData;
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: 'Notification Settings',
      child: ListView(
        children: [
          const SizedBox(height: 16),

          // Prayer Notifications Section
          _buildSectionHeader('Prayer & Worship'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[50],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SettingsItemView(
                  title: "Prayer Notifications",
                  subtitle: "Prayer times, reminders, and Qiyam",
                  icon: Icons.access_time_rounded,
                  onTap: () async {
                    final updatedSettings =
                        await Navigator.push<NotificationSettingsData>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayerNotificationSettingsScreen(
                            settings: _currentSettings),
                      ),
                    );

                    if (updatedSettings != null) {
                      setState(() {
                        _currentSettings = updatedSettings;
                      });
                    }
                    await getIt<NotificationManager>().requestPermissions();
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsItemView(
                  title: "Memorization Reminders",
                  subtitle: "Quran memorization and review reminders",
                  icon: Icons.menu_book_rounded,
                  onTap: () async {
                    final updatedSettings =
                        await Navigator.push<NotificationSettingsData>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemorizationSettingsScreen(
                            settings: _currentSettings),
                      ),
                    );

                    if (updatedSettings != null) {
                      setState(() {
                        _currentSettings = updatedSettings;
                      });
                    }
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsItemView(
                  title: "Sunnah Fasting",
                  subtitle: "Monday & Thursday fasting reminders",
                  icon: Icons.free_breakfast_outlined,
                  onTap: () async {
                    final updatedSettings =
                        await Navigator.push<NotificationSettingsData>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SunnahFastingSettingsScreen(
                            settings: _currentSettings),
                      ),
                    );

                    if (updatedSettings != null) {
                      setState(() {
                        _currentSettings = updatedSettings;
                      });
                    }
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsItemView(
                  title: "Zakat Reminders",
                  subtitle: "Annual Zakat calculation reminders",
                  icon: Icons.volunteer_activism_rounded,
                  onTap: () async {
                    final updatedSettings =
                        await Navigator.push<NotificationSettingsData>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ZakatRemindersSettingsScreen(
                            settings: _currentSettings),
                      ),
                    );

                    if (updatedSettings != null) {
                      setState(() {
                        _currentSettings = updatedSettings;
                      });
                      // Save to SharedPrefs is already handled in ZakatRemindersSettingsScreen
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // // Community & Location Section
          // _buildSectionHeader('Community & Location'),
          // const SizedBox(height: 8),
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(16),
          //     color: Colors.grey[50],
          //   ),
          //   margin: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Column(
          //     children: [
          //       SettingsItemView(
          //         title: "Nearby Mosque Notifications",
          //         subtitle: "Prayer timings and events from nearby mosques",
          //         icon: Icons.mosque_rounded,
          //         onTap: () {
          //           _showComingSoonDialog(context, "Mosque Notifications");
          //         },
          //       ),
          //       const Divider(height: 1, indent: 16, endIndent: 16),
          //       SettingsItemView(
          //         title: "Friday Kahf Reminder",
          //         subtitle: "Weekly reminder to read Surah Al-Kahf",
          //         icon: Icons.calendar_today_rounded,
          //         onTap: () {
          //           _showComingSoonDialog(context, "Friday Kahf Reminder");
          //         },
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(height: 24),

          // // Islamic Calendar Section
          // _buildSectionHeader('Islamic Calendar & Events'),
          // const SizedBox(height: 8),
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(16),
          //     color: Colors.grey[50],
          //   ),
          //   margin: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Column(
          //     children: [
          //       SettingsItemView(
          //         title: "Islamic Events",
          //         subtitle: "Ramadan, Eid, and other Islamic occasions",
          //         icon: Icons.event_note_rounded,
          //         onTap: () {
          //           _showComingSoonDialog(context, "Islamic Events");
          //         },
          //       ),
          //       const Divider(height: 1, indent: 16, endIndent: 16),
          //       SettingsItemView(
          //         title: "Hijri Date Notifications",
          //         subtitle: "Important Islamic dates and milestones",
          //         icon: Icons.date_range_rounded,
          //         onTap: () {
          //           _showComingSoonDialog(context, "Hijri Date Notifications");
          //         },
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(height: 24),

          // // Global Notification Settings
          // _buildSectionHeader('Global Settings'),
          // const SizedBox(height: 8),
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(16),
          //     color: Colors.grey[50],
          //   ),
          //   margin: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Column(
          //     children: [
          //       SettingsItemView(
          //         title: "Do Not Disturb",
          //         subtitle: "Quiet hours and notification scheduling",
          //         icon: Icons.do_not_disturb_rounded,
          //         onTap: () async {
          //           final currentSettings = getIt<SharedPrefsHelper>().notificationSettingsData;

          //           final updatedSettings = await Navigator.push<NotificationSettingsData>(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => DoNotDisturbSettingsScreen(settings: currentSettings),
          //             ),
          //           );

          //           if (updatedSettings != null) {
          //             getIt<SharedPrefsHelper>().setNotificationSettings = updatedSettings;
          //           }
          //         },
          //       ),
          //       const Divider(height: 1, indent: 16, endIndent: 16),
          //       SettingsItemView(
          //         title: "Notification Sounds",
          //         subtitle: "Customize notification tones and volumes",
          //         icon: Icons.volume_up_rounded,
          //         onTap: () async {
          //           final currentSettings = getIt<SharedPrefsHelper>().notificationSettingsData;

          //           final updatedSettings = await Navigator.push<NotificationSettingsData>(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => NotificationSoundsSettingsScreen(settings: currentSettings),
          //             ),
          //           );

          //           if (updatedSettings != null) {
          //             getIt<SharedPrefsHelper>().setNotificationSettings = updatedSettings;
          //           }
          //         },
          //       ),
          //       const Divider(height: 1, indent: 16, endIndent: 16),
          //       SettingsItemView(
          //         title: "Battery Optimization",
          //         subtitle: "Ensure notifications work reliably",
          //         icon: Icons.battery_saver_rounded,
          //         onTap: () {
          //           _showBatteryOptimizationDialog(context);
          //         },
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(height: 32),

          // Info Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.blue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: ThemeColors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Permissions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.blue,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Some features may require additional permissions. Tap on any setting to configure.',
                        style: TextStyle(
                          color: ThemeColors.blue.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
