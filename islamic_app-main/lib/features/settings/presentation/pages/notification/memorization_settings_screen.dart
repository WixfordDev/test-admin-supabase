import 'package:flutter/material.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';

class MemorizationSettingsScreen extends StatefulWidget {
  final NotificationSettingsData settings;
  
  const MemorizationSettingsScreen({
    super.key,
    required this.settings,
  });

  @override
  State<MemorizationSettingsScreen> createState() => _MemorizationSettingsScreenState();
}

class _MemorizationSettingsScreenState extends State<MemorizationSettingsScreen> {
  late NotificationSettingsData _settings;
  
  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  /// Save settings and navigate back
  void _saveAndGoBack() {
    // Save settings to SharedPrefs
    getIt<SharedPrefsHelper>().setNotificationSettings = _settings;
    
    // Navigate back with the updated settings
    Navigator.of(context).pop(_settings);
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
        pageTitle: 'Memorization Reminders',
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
                title: const Text('Enable Memorization Reminders'),
                subtitle: const Text('Daily reminders for Quran memorization and review'),
                value: _settings.memorizationReminders,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(memorizationReminders: value);
                  });
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (_settings.memorizationReminders) ...[
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
                  subtitle: Text(_formatTime(_settings.memorizationReminderHour, _settings.memorizationReminderMinute)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Days Selection Section
              _buildSectionHeader('Reminder Days'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select the days you want to receive memorization reminders:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildDaySelectionGrid(),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
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
                      Icons.lightbulb_outline,
                      color: ThemeColors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Memorization Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.blue,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Consistent daily practice is key to successful Quran memorization. These reminders will help you maintain your schedule.',
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

  Widget _buildDaySelectionGrid() {
    final days = [
      {'name': 'Mon', 'value': 1},
      {'name': 'Tue', 'value': 2},
      {'name': 'Wed', 'value': 3},
      {'name': 'Thu', 'value': 4},
      {'name': 'Fri', 'value': 5},
      {'name': 'Sat', 'value': 6},
      {'name': 'Sun', 'value': 7},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        final isSelected = _settings.memorizationReminderDays.contains(day['value']);
        return GestureDetector(
          onTap: () {
            final newDays = List<int>.from(_settings.memorizationReminderDays);
            if (isSelected) {
              newDays.remove(day['value']);
            } else {
              newDays.add(day['value'] as int);
            }
            setState(() {
              _settings = _settings.copyWith(memorizationReminderDays: newDays);
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? ThemeColors.blue : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? ThemeColors.blue : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                day['name'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
        hour: _settings.memorizationReminderHour,
        minute: _settings.memorizationReminderMinute,
      ),
    );
    
    if (picked != null) {
      setState(() {
        _settings = _settings.copyWith(
          memorizationReminderHour: picked.hour,
          memorizationReminderMinute: picked.minute,
        );
      });
    }
  }
} 