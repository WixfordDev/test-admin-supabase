import 'package:flutter/material.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';

class ZakatRemindersSettingsScreen extends StatefulWidget {
  final NotificationSettingsData settings;
  
  const ZakatRemindersSettingsScreen({
    super.key,
    required this.settings,
  });

  @override
  State<ZakatRemindersSettingsScreen> createState() => _ZakatRemindersSettingsScreenState();
}

class _ZakatRemindersSettingsScreenState extends State<ZakatRemindersSettingsScreen> {
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
        pageTitle: 'Zakat Reminders',
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
                title: const Text('Enable Zakat Reminders'),
                subtitle: const Text('Annual Zakat calculation reminders'),
                value: _settings.zakatReminders,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(zakatReminders: value);
                  });
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (_settings.zakatReminders) ...[
              // Zakat Date Section
              _buildSectionHeader('Zakat Calculation Date'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  title: const Text('Annual Zakat Date'),
                  subtitle: Text(_settings.zakatReminderDate != null 
                    ? _formatDate(_settings.zakatReminderDate!)
                    : 'Not set - tap to select'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectZakatDate(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Reminder Settings Section
              _buildSectionHeader('Reminder Settings'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  title: const Text('Remind me'),
                  subtitle: Text('${_settings.zakatReminderDaysBefore} days before Zakat date'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => _showDaysPickerDialog(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Next Reminder Info
              if (_settings.zakatReminderDate != null) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.orange,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Next Reminder',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getNextReminderText(),
                        style: TextStyle(
                          color: Colors.orange.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
              
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About Zakat',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Zakat is one of the Five Pillars of Islam. It is obligatory to pay 2.5% of your wealth annually to those in need. Set your Zakat date to track your lunar year and get timely reminders.',
                      style: TextStyle(
                        color: Colors.green.withValues(alpha: 0.8),
                        fontSize: 12,
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

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getNextReminderText() {
    if (_settings.zakatReminderDate == null) return '';
    
    final reminderDate = _settings.zakatReminderDate!.subtract(
      Duration(days: _settings.zakatReminderDaysBefore),
    );
    
    final now = DateTime.now();
    final daysUntilReminder = reminderDate.difference(now).inDays;
    
    if (daysUntilReminder > 0) {
      return 'You will be reminded in $daysUntilReminder days (${_formatDate(reminderDate)})';
    } else if (daysUntilReminder == 0) {
      return 'Reminder is today!';
    } else {
      // Calculate next year's reminder
      final nextYear = DateTime(_settings.zakatReminderDate!.year + 1, 
          _settings.zakatReminderDate!.month, _settings.zakatReminderDate!.day);
      final nextReminderDate = nextYear.subtract(
        Duration(days: _settings.zakatReminderDaysBefore),
      );
      final daysUntilNextReminder = nextReminderDate.difference(now).inDays;
      return 'Next year\'s reminder in $daysUntilNextReminder days (${_formatDate(nextReminderDate)})';
    }
  }

  Future<void> _selectZakatDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _settings.zakatReminderDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select your annual Zakat calculation date',
    );
    
    if (picked != null) {
      setState(() {
        _settings = _settings.copyWith(zakatReminderDate: picked);
      });
    }
  }

  void _showDaysPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final options = [1, 3, 7, 14, 30];
        return AlertDialog(
          title: const Text('Remind me before'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((days) {
                final isSelected = _settings.zakatReminderDaysBefore == days;
                return ListTile(
                  title: Text('$days ${days == 1 ? 'day' : 'days'} before'),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _settings = _settings.copyWith(zakatReminderDaysBefore: days);
                    });
                    Navigator.of(context).pop();
                  },
                  tileColor: isSelected ? ThemeColors.blue.withValues(alpha: 0.1) : null,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
} 