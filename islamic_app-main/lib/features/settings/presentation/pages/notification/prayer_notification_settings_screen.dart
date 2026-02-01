import 'package:flutter/material.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/widgets/common_widgets.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/settings/data/entity/notification_settings_data.dart';

class PrayerNotificationSettingsScreen extends StatefulWidget {
  final NotificationSettingsData settings;
  
  const PrayerNotificationSettingsScreen({
    super.key,
    required this.settings,
  });

  @override
  State<PrayerNotificationSettingsScreen> createState() => _PrayerNotificationSettingsScreenState();
}

class _PrayerNotificationSettingsScreenState extends State<PrayerNotificationSettingsScreen> {
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
        pageTitle: 'Prayer Notifications',
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
            _buildMasterSwitchTile(),
            const AppDivider(),
            _buildPrayerTimesSection(),
            const AppDivider(),
            _buildNotificationTimingSection(),
            const AppDivider(),
            _buildAdditionalSettingsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMasterSwitchTile() {
    return SwitchListTile(
      title: const Text('Enable Prayer Notifications'),
      subtitle: const Text('Turn on/off all prayer notifications'),
      value: _settings.masterSwitch,
      onChanged: (value) {
        setState(() {
          _settings = _settings.copyWith(masterSwitch: value);
        });
      },
    );
  }
  
  Widget _buildPrayerTimesSection() {
    // Get all mandatory prayers plus Qiyam
    final prayers = getMandatoryPrayersList().toList();
    if (!prayers.contains(PrayerType.qiyam)) {
      prayers.add(PrayerType.qiyam);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Prayer Times',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        ...prayers.map((prayer) {
          final isEnabled = _settings.prayerNotifications[prayer.name] ?? true;
          return SwitchListTile(
            title: Text(prayer.label),
            value: isEnabled,
            onChanged: _settings.masterSwitch ? (bool value) {
              final updatedMap = Map<String, bool>.from(_settings.prayerNotifications);
              updatedMap[prayer.name] = value;
              setState(() {
                _settings = _settings.copyWith(prayerNotifications: updatedMap);
              });
            } : null,
          );
        }),
      ],
    );
  }

  Widget _buildNotificationTimingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Notification Timing',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Notify at Prayer Time'),
          subtitle: const Text('Notify when prayer time starts'),
          value: _settings.notifyOnPrayerTime,
          onChanged: _settings.masterSwitch ? (value) {
            setState(() {
              _settings = _settings.copyWith(notifyOnPrayerTime: value);
            });
          } : null,
        ),
        SwitchListTile(
          title: const Text('Notify Before Prayer Time'),
          subtitle: Text('Notify ${_settings.beforePrayerMinutes} minutes before prayer'),
          value: _settings.notifyBeforePrayer,
          onChanged: _settings.masterSwitch ? (value) {
            setState(() {
              _settings = _settings.copyWith(notifyBeforePrayer: value);
            });
          } : null,
        ),
        if (_settings.notifyBeforePrayer && _settings.masterSwitch)
          ListTile(
            title: const Text('Minutes Before Prayer'),
            subtitle: Text('${_settings.beforePrayerMinutes} minutes'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => _showMinutesPickerDialog(),
          ),
      ],
    );
  }

  Widget _buildAdditionalSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Additional Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Play Sound'),
          value: _settings.playSound,
          onChanged: _settings.masterSwitch ? (value) {
            setState(() {
              _settings = _settings.copyWith(playSound: value);
            });
          } : null,
        ),
        SwitchListTile(
          title: const Text('Vibrate'),
          value: _settings.vibrate,
          onChanged: _settings.masterSwitch ? (value) {
            setState(() {
              _settings = _settings.copyWith(vibrate: value);
            });
          } : null,
        ),
        // SwitchListTile(
        //   title: const Text('Lock Notification'),
        //   subtitle: const Text('Prevent notification from being dismissed'),
        //   value: _settings.lockNotification,
        //   onChanged: _settings.masterSwitch ? (value) {
        //     setState(() {
        //       _settings = _settings.copyWith(lockNotification: value);
        //     });
        //   } : null,
        // ),
        SwitchListTile(
          title: const Text('Auto-clear Notification'),
          value: _settings.autoClearNotification,
          onChanged: _settings.masterSwitch ? (value) {
            setState(() {
              _settings = _settings.copyWith(autoClearNotification: value);
            });
          } : null,
        ),
        if (_settings.autoClearNotification && _settings.masterSwitch)
          ListTile(
            title: const Text('Auto-clear After'),
            subtitle: Text('${_settings.autoClearMinutes} minutes'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => _showAutoClearMinutesPickerDialog(),
          ),
      ],
    );
  }
  
  void _showMinutesPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final options = [5, 10, 15, 20, 30, 45, 60];
        return AlertDialog(
          title: const Text('Minutes Before Prayer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((minutes) {
                final isSelected = _settings.beforePrayerMinutes == minutes;
                return ListTile(
                  title: Text('$minutes minutes'),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _settings = _settings.copyWith(beforePrayerMinutes: minutes);
                    });
                    Navigator.of(context).pop();
                  },
                  tileColor: isSelected ? ThemeColors.lightGray2 : null,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
  
  void _showAutoClearMinutesPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final options = [1, 5, 10, 15, 30, 60];
        return AlertDialog(
          title: const Text('Auto-clear After'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((minutes) {
                final isSelected = _settings.autoClearMinutes == minutes;
                return ListTile(
                  title: Text('$minutes minutes'),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _settings = _settings.copyWith(autoClearMinutes: minutes);
                    });
                    Navigator.of(context).pop();
                  },
                  tileColor: isSelected ? ThemeColors.lightGray2 : null,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
} 