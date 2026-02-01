import 'package:flutter/material.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/config/themes/theme_colors.dart';

class DoNotDisturbSettingsScreen extends StatefulWidget {
  final NotificationSettingsData settings;
  
  const DoNotDisturbSettingsScreen({
    super.key,
    required this.settings,
  });

  @override
  State<DoNotDisturbSettingsScreen> createState() => _DoNotDisturbSettingsScreenState();
}

class _DoNotDisturbSettingsScreenState extends State<DoNotDisturbSettingsScreen> {
  late NotificationSettingsData _settings;
  
  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          Navigator.of(context).pop(_settings);
        }
      },
      child: AppBarScaffold(
        pageTitle: 'Do Not Disturb',
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
                title: const Text('Enable Do Not Disturb'),
                subtitle: const Text('Set quiet hours for notifications'),
                value: _settings.doNotDisturbEnabled,
                onChanged: (value) {
                  setState(() {
                    _settings = _settings.copyWith(doNotDisturbEnabled: value);
                  });
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (_settings.doNotDisturbEnabled) ...[
              // Time Range Section
              _buildSectionHeader('Quiet Hours'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Start Time'),
                      subtitle: Text(_formatTime(_settings.doNotDisturbStartHour, _settings.doNotDisturbStartMinute)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectStartTime(),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(_formatTime(_settings.doNotDisturbEndHour, _settings.doNotDisturbEndMinute)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectEndTime(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Exceptions Section
              _buildSectionHeader('Exceptions'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[50],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: SwitchListTile(
                  title: const Text('Allow Prayer Notifications'),
                  subtitle: const Text('Prayer times will still notify during quiet hours'),
                  value: _settings.doNotDisturbOnlyNonEssential,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(doNotDisturbOnlyNonEssential: value);
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Summary Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bedtime,
                          color: Colors.purple,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Do Not Disturb Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryItem(
                      'Quiet Hours',
                      '${_formatTime(_settings.doNotDisturbStartHour, _settings.doNotDisturbStartMinute)} - ${_formatTime(_settings.doNotDisturbEndHour, _settings.doNotDisturbEndMinute)}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryItem(
                      'Prayer Notifications',
                      _settings.doNotDisturbOnlyNonEssential ? 'Allowed' : 'Blocked',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryItem(
                      'Other Notifications',
                      'Blocked during quiet hours',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
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
                            'How It Works',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.blue,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'During quiet hours, most notifications will be silenced. You can choose to allow prayer notifications to ensure you never miss prayer times.',
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

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.purple.withValues(alpha: 0.8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings.doNotDisturbStartHour,
        minute: _settings.doNotDisturbStartMinute,
      ),
    );
    
    if (picked != null) {
      setState(() {
        _settings = _settings.copyWith(
          doNotDisturbStartHour: picked.hour,
          doNotDisturbStartMinute: picked.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings.doNotDisturbEndHour,
        minute: _settings.doNotDisturbEndMinute,
      ),
    );
    
    if (picked != null) {
      setState(() {
        _settings = _settings.copyWith(
          doNotDisturbEndHour: picked.hour,
          doNotDisturbEndMinute: picked.minute,
        );
      });
    }
  }
} 