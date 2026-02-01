import 'package:flutter/material.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/notification/services/sunnah_fasting_notification_service.dart';

class SunnahFastingSettingsScreen extends StatefulWidget {
  final NotificationSettingsData settings;
  
  const SunnahFastingSettingsScreen({
    super.key,
    required this.settings,
  });

  @override
  State<SunnahFastingSettingsScreen> createState() => _SunnahFastingSettingsScreenState();
}

class _SunnahFastingSettingsScreenState extends State<SunnahFastingSettingsScreen> {
  late NotificationSettingsData _settings;
  
  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  /// Save settings and navigate back
  void _saveAndGoBack() async {
    // Save settings to SharedPrefs
    getIt<SharedPrefsHelper>().setNotificationSettings = _settings;

    // Reschedule sunnah fasting notifications with new settings
    try {
      await getIt<SunnahFastingNotificationService>().updateNotifications();
    } catch (e) {
      // Service might not be registered yet, ignore
    }

    // Navigate back with the updated settings
    if (mounted) {
      Navigator.of(context).pop(_settings);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          // Save settings when user navigates back
          getIt<SharedPrefsHelper>().setNotificationSettings = _settings;
        }
      },
      child: AppBarScaffold(
        pageTitle: 'Sunnah Fasting',
        appBarActions: [
          // Save button in app bar
          TextButton(
            onPressed: _saveAndGoBack,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        child: ListView(
          children: [
            const SizedBox(height: 16),
            
            // Master Switch
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[50],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: SwitchListTile(
                title: const Text('Enable Sunnah Fasting Reminders'),
                subtitle: const Text('Reminders for Monday & Thursday fasting'),
                value: _settings.sunnahFastingReminders,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(sunnahFastingReminders: value);
                  });
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (_settings.sunnahFastingReminders) ...[
              // Fasting Days Section
              _buildSectionHeader('Fasting Days'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Monday Fasting'),
                      subtitle: const Text('Remind me to fast on Mondays'),
                      value: _settings.mondayFasting,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(mondayFasting: value);
                        });
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: const Text('Thursday Fasting'),
                      subtitle: const Text('Remind me to fast on Thursdays'),
                      value: _settings.thursdayFasting,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(thursdayFasting: value);
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Reminder Time Section
              _buildSectionHeader('Reminder Time'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text(
                    '${_formatTime(_settings.sunnahFastingReminderHour, _settings.sunnahFastingReminderMinute)} (night before)',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.eco,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sunnah Fasting Benefits',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The Prophet ﷺ used to fast on Mondays and Thursdays. Fasting these days brings spiritual purification and draws you closer to Allah.',
                            style: TextStyle(
                              color: Colors.green.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Hadith Section
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote,
                          color: ThemeColors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hadith',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"Actions are presented on Mondays and Thursdays, and I love for my actions to be presented while I am fasting."',
                      style: TextStyle(
                        color: ThemeColors.blue.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '- Prophet Muhammad ﷺ (Tirmidhi)',
                      style: TextStyle(
                        color: ThemeColors.blue.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
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

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings.sunnahFastingReminderHour,
        minute: _settings.sunnahFastingReminderMinute,
      ),
    );
    
    if (picked != null) {
      setState(() {
        _settings = _settings.copyWith(
          sunnahFastingReminderHour: picked.hour,
          sunnahFastingReminderMinute: picked.minute,
        );
      });
    }
  }
} 