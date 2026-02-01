import 'package:flutter/material.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';
import 'package:deenhub/config/themes/theme_colors.dart';

class NotificationSoundsSettingsScreen extends StatefulWidget {
  final NotificationSettingsData settings;
  
  const NotificationSoundsSettingsScreen({
    super.key,
    required this.settings,
  });

  @override
  State<NotificationSoundsSettingsScreen> createState() => _NotificationSoundsSettingsScreenState();
}

class _NotificationSoundsSettingsScreenState extends State<NotificationSoundsSettingsScreen> {
  late NotificationSettingsData _settings;
  
  final List<Map<String, String>> _prayerSounds = [
    {'name': 'Default', 'value': 'default'},
    {'name': 'Azan Traditional', 'value': 'azan_traditional'},
    {'name': 'Azan Makkah', 'value': 'azan_makkah'},
    {'name': 'Azan Madinah', 'value': 'azan_madinah'},
    {'name': 'Simple Chime', 'value': 'simple_chime'},
    {'name': 'Soft Bell', 'value': 'soft_bell'},
  ];

  final List<Map<String, String>> _reminderSounds = [
    {'name': 'Default', 'value': 'default'},
    {'name': 'Gentle Ping', 'value': 'gentle_ping'},
    {'name': 'Soft Chime', 'value': 'soft_chime'},
    {'name': 'Islamic Bell', 'value': 'islamic_bell'},
    {'name': 'Peaceful Tone', 'value': 'peaceful_tone'},
  ];
  
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
        pageTitle: 'Notification Sounds',
        child: ListView(
          children: [
            const SizedBox(height: 16),
            
            // Global Sound Settings
            _buildSectionHeader('Global Sound Settings'),
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
                    title: const Text('Enable Custom Sounds'),
                    subtitle: const Text('Use Islamic notification sounds'),
                    value: _settings.useCustomSounds,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(useCustomSounds: value);
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    title: const Text('Notification Volume'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${(_settings.notificationVolume * 100).round()}%'),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                            activeTrackColor: ThemeColors.blue,
                            inactiveTrackColor: Colors.grey[300],
                            thumbColor: ThemeColors.blue,
                            overlayColor: ThemeColors.blue.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: _settings.notificationVolume,
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(notificationVolume: value);
                              });
                            },
                            divisions: 10,
                            min: 0.0,
                            max: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Prayer Notification Sounds
            _buildSectionHeader('Prayer Notification Sounds'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[50],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                title: const Text('Prayer Notification Sound'),
                subtitle: Text(_getSoundDisplayName(_settings.prayerNotificationSound, _prayerSounds)),
                trailing: const Icon(Icons.music_note),
                onTap: () => _showSoundPicker('Prayer Notifications', _prayerSounds, _settings.prayerNotificationSound, (value) {
                  setState(() {
                    _settings = _settings.copyWith(prayerNotificationSound: value);
                  });
                }),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Reminder Notification Sounds
            _buildSectionHeader('Reminder Notification Sounds'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[50],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                title: const Text('Reminder Notification Sound'),
                subtitle: Text(_getSoundDisplayName(_settings.reminderNotificationSound, _reminderSounds)),
                trailing: const Icon(Icons.notifications_active),
                onTap: () => _showSoundPicker('Reminder Notifications', _reminderSounds, _settings.reminderNotificationSound, (value) {
                  setState(() {
                    _settings = _settings.copyWith(reminderNotificationSound: value);
                  });
                }),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sound Test Section
            _buildSectionHeader('Test Sounds'),
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
                    title: const Text('Test Prayer Sound'),
                    subtitle: const Text('Play the current prayer notification sound'),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () => _playTestSound(_settings.prayerNotificationSound),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    title: const Text('Test Reminder Sound'),
                    subtitle: const Text('Play the current reminder notification sound'),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () => _playTestSound(_settings.reminderNotificationSound),
                  ),
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
                    Icons.volume_up,
                    color: ThemeColors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sound Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.blue,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose sounds that will help you focus on your prayers and spiritual practice. Custom sounds may require app restart to take effect.',
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

  String _getSoundDisplayName(String soundValue, List<Map<String, String>> soundList) {
    final sound = soundList.firstWhere(
      (sound) => sound['value'] == soundValue,
      orElse: () => {'name': 'Default', 'value': 'default'},
    );
    return sound['name']!;
  }

  void _showSoundPicker(String title, List<Map<String, String>> sounds, String currentValue, Function(String) onChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sounds.map((sound) {
                final isSelected = currentValue == sound['value'];
                return ListTile(
                  title: Text(sound['name']!),
                  selected: isSelected,
                  onTap: () {
                    onChanged(sound['value']!);
                    Navigator.of(context).pop();
                  },
                  tileColor: isSelected ? ThemeColors.blue.withValues(alpha: 0.1) : null,
                  trailing: isSelected 
                    ? Icon(Icons.check, color: ThemeColors.blue)
                    : IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _playTestSound(sound['value']!),
                      ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _playTestSound(String soundValue) {
    // This would integrate with an audio player to play the test sound
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing test sound: ${_getSoundDisplayName(soundValue, [..._prayerSounds, ..._reminderSounds])}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 