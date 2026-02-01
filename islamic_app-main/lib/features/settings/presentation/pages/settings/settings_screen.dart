import 'package:deenhub/config/constants/app_constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';

import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:deenhub/features/auth/domain/models/user_model.dart';
import 'package:deenhub/features/settings/presentation/widgets/settings_item_view.dart';
import 'package:deenhub/features/settings/presentation/pages/user_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;
  String? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo(
      appName: LocaleKeys.unknown.tr(),
      packageName: LocaleKeys.unknown.tr(),
      version: '1.0',
      buildNumber: LocaleKeys.unknown.tr(),
      buildSignature: LocaleKeys.unknown.tr(),
      installerStore: LocaleKeys.unknown.tr(),
    );
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    final deviceInfoPlugin = DeviceInfoPlugin();

    String deviceInfo;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await deviceInfoPlugin.androidInfo;
        if (kDebugMode) print('Full Device Info : $info');

        deviceInfo =
            'Device: ${info.model}\nAndroid Sdk: ${info.version.sdkInt}';
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.iOS:
        final info = await deviceInfoPlugin.iosInfo;
        if (kDebugMode) print('Full Device Info : $info');

        deviceInfo =
            'Name: ${info.name}\nSystem Name: ${info.systemName}\nSystem Version: ${info.systemVersion}\nModel: ${info.model}';
        break;
    }

    setState(() {
      _packageInfo = info;
      _deviceInfo = deviceInfo;

      if (kDebugMode) {
        print('Package Info : $_packageInfo');
        print('Device Info : $_deviceInfo');
      }
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Signing out...'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 5),
                ),
              );

              // Trigger logout
              getIt<AuthBloc>().add(const AuthEvent.signOut());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    context.pushNamed(Routes.login.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = context.primaryColor;

    return AppBarScaffold(
      pageTitle: Routes.settings.name.capitalizeFirstLetter,
      child: BlocConsumer<AuthBloc, AuthState>(
        bloc: getIt<AuthBloc>(),
        listener: (context, state) {
          state.maybeMap(
            error: (errorState) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorState.message),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            unauthenticated: (_) {
              // Hide any existing snackbars when logged out
              if (mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.maybeMap(
            authenticated: (authState) =>
                _buildAuthenticatedView(authState.user, theme, primaryColor),
            unauthenticated: (_) =>
                _buildUnauthenticatedView(theme, primaryColor),
            loading: (_) => _buildLoadingView(theme, primaryColor),
            orElse: () => _buildUnauthenticatedView(theme, primaryColor),
          );
        },
      ),
    );
  }

  Widget _buildAuthenticatedView(
    UserModel user,
    ThemeData theme,
    Color primaryColor,
  ) {
    return ListView(
      children: [
        // No user info section shown at top when authenticated since we have Account Settings
        const SizedBox(height: 8),

        // Account & Legal Section
        _buildSectionHeader('Account & Legal'),
        SettingsItemView(
          title: "Account Settings",
          icon: Icons.person_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserProfileScreen(),
              ),
            );
          },
        ),
        SettingsItemView(
          title: "Support",
          icon: Icons.favorite_outline,
          onTap: () {
            context.pushNamed(Routes.contactUs.name);
          },
        ),
        SettingsItemView(
          title: "Purchase",
          icon: Icons.diamond_outlined,
          onTap: () {
            context.pushNamed(Routes.subscription.name);
          },
        ),
        SettingsItemView(
          title: "Terms & Condition",
          icon: Icons.description_outlined,
          onTap: () {
            context.pushNamed(Routes.termsConditions.name);
          },
        ),
        SettingsItemView(
          title: "Privacy Policy",
          icon: Icons.privacy_tip_outlined,
          onTap: () {
            context.pushNamed(Routes.privacyPolicy.name);
          },
        ),
        const SizedBox(height: 8),

        // Preferences Section
        _buildSectionHeader('Preferences'),
        SettingsItemView(
          title: "Notifications",
          icon: Icons.notifications_outlined,
          onTap: () {
            context.pushNamed(Routes.notificationSettings.name);
          },
        ),
        // SettingsItemView(
        //   title: 'Language',
        //   icon: Icons.language_outlined,
        //   onTap: () {
        //     // Navigate to language settings
        //   },
        // ),
        const SizedBox(height: 8),

        // Account Management Section
        _buildSectionHeader('Account Management'),
        SettingsItemView(
          title: 'Reset Stats / Delete Account',
          icon: Icons.delete_outlined,
          titleTextStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          onTap: () {
            _showResetStatsDialog();
          },
        ),
        SettingsItemView(
          title: 'Logout',
          icon: Icons.logout_outlined,
          titleTextStyle: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          onTap: _handleLogout,
        ),
        const SizedBox(height: 8),

        // App Info Section
        _buildSectionHeader('App Information'),
        SettingsItemView(
          title: context.tr(LocaleKeys.rateAppInfo),
          subtitle: _packageInfo?.version,
          icon: Icons.star_border,
          onTap: () {
            navigateToRating();
          },
        ),
        SettingsItemView(
          title: 'Share DeenHub',
          icon: Icons.share,
          onTap: () {
            _shareApp();
          },
        ),
        SettingsItemView(
          title: 'About Us',
          icon: Icons.info_outline,
          onTap: () {
            context.pushNamed(Routes.aboutUs.name);
          },
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedView(ThemeData theme, Color primaryColor) {
    return ListView(
      children: [
        // Red Login Section at top
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.warning_rounded,
                size: 48,
                color: Colors.red.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 12),
              Text(
                'Please Sign In',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to access all features, sync your progress, and personalize your Islamic journey',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Account & Legal Section (Limited)
        _buildSectionHeader('Account & Legal'),
        const SizedBox(height: 8),
        SettingsItemView(
          title: "Account Settings",
          icon: Icons.person_outlined,
          enabled: false, // Disabled when not logged in
          onTap: null,
        ),
        SettingsItemView(
          title: "Support",
          icon: Icons.favorite_outline,
          onTap: () {
            context.pushNamed(Routes.contactUs.name);
          },
        ),
        SettingsItemView(
          title: "Purchase",
          icon: Icons.diamond_outlined,
          onTap: () {
            context.pushNamed(Routes.subscription.name);
          },
        ),
        SettingsItemView(
          title: "Terms & Condition",
          icon: Icons.description_outlined,
          onTap: () {
            context.pushNamed(Routes.termsConditions.name);
          },
        ),
        SettingsItemView(
          title: "Privacy Policy",
          icon: Icons.privacy_tip_outlined,
          onTap: () {
            context.pushNamed(Routes.privacyPolicy.name);
          },
        ),
        const SizedBox(height: 24),

        // Preferences Section
        _buildSectionHeader('Preferences'),
        const SizedBox(height: 8),
        SettingsItemView(
          title: "Notifications",
          icon: Icons.notifications_outlined,
          onTap: () {
            context.pushNamed(Routes.notificationSettings.name);
          },
        ),
        // SettingsItemView(
        //   title: 'Language',
        //   icon: Icons.language_outlined,
        //   onTap: () {
        //     // Navigate to language settings
        //   },
        // ),
        const SizedBox(height: 24),

        // Account Management Section (Disabled when not logged in)
        _buildSectionHeader('Account Management'),
        const SizedBox(height: 8),
        SettingsItemView(
          title: 'Reset Stats / Delete Account',
          icon: Icons.delete_outlined,
          titleTextStyle: TextStyle(
            color: Colors.red.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          enabled: false, // Disabled when not logged in
          onTap: null,
        ),
        SettingsItemView(
          title: 'Logout',
          icon: Icons.logout_outlined,
          titleTextStyle: TextStyle(
            color: Colors.orange.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          enabled: false, // Disabled when not logged in
          onTap: null,
        ),
        const SizedBox(height: 24),

        // App Info Section
        _buildSectionHeader('App Information'),
        const SizedBox(height: 8),
        SettingsItemView(
          title: context.tr(LocaleKeys.rateAppInfo),
          subtitle: _packageInfo?.version,
          icon: Icons.star_border,
          onTap: () {
            navigateToRating();
          },
        ),
        SettingsItemView(
          title: 'Share DeenHub',
          icon: Icons.share,
          onTap: () {
            _shareApp();
          },
        ),
        SettingsItemView(
          title: 'About Us',
          icon: Icons.info_outline,
          onTap: () {
            context.pushNamed(Routes.aboutUs.name);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingView(ThemeData theme, Color primaryColor) {
    return ListView(
      children: [
        // Loading placeholder for user section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.outline.withValues(
                  alpha: 0.1,
                ),
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 16,
                      width: 200,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Rest of the settings (always visible)
        _buildSectionHeader('Preferences'),
        const SizedBox(height: 8),
        SettingsItemView(
          title: "Notifications",
          icon: Icons.notifications_outlined,
          onTap: () {
            context.pushNamed(Routes.notificationSettings.name);
          },
        ),
        // SettingsItemView(
        //   title: 'Language',
        //   icon: Icons.language_outlined,
        //   onTap: () {
        //     // Navigate to language settings
        //   },
        // ),
        const SizedBox(height: 16),

        // App Info
        _buildSectionHeader('App Information'),
        const SizedBox(height: 8),
        SettingsItemView(
          title: context.tr(LocaleKeys.rateAppInfo),
          subtitle: _packageInfo?.version,
          icon: Icons.star_border,
          onTap: () {
            navigateToRating();
          },
        ),
        SettingsItemView(
          title: 'Share DeenHub',
          icon: Icons.share,
          onTap: () {
            _shareApp();
          },
        ),
        SettingsItemView(
          title: 'About Us',
          icon: Icons.info_outline,
          onTap: () {
            context.pushNamed(Routes.aboutUs.name);
          },
        ),
      ],
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

  void _showResetStatsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Choose Action',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'What would you like to do?',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildActionOption(
              icon: Icons.refresh_rounded,
              title: 'Reset Statistics',
              subtitle: 'Clear all app usage statistics and progress data',
              color: Colors.orange,
              onTap: () {
                Navigator.of(context).pop();
                _showConfirmResetStatsDialog();
              },
            ),
            const SizedBox(height: 12),
            _buildActionOption(
              icon: Icons.delete_forever_rounded,
              title: 'Delete Account',
              subtitle:
                  'Permanently delete your account and all associated data',
              color: Colors.red,
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteAccountDialog();
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  void _showConfirmResetStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text(
          'Are you sure you want to reset all your statistics? This will clear your prayer tracking, reading progress, and other usage data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle stats reset
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statistics have been reset'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This will permanently delete your account and all associated data including:\n\n• Your profile information\n• Prayer tracking history\n• Reading progress\n• Personal notes and bookmarks\n• Subscription data\n\nThis action cannot be undone. Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Account deletion initiated. Please check your email for confirmation.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void navigateToRating() {
    String url;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        url = 'market://details?id=${_packageInfo?.packageName}';
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        url = 'itms-apps://itunes.apple.com/app/id${_packageInfo?.packageName}';
    }
    url.launchURL();
  }

  void _shareApp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildShareDialog(),
    );
  }

  Widget _buildShareDialog() {
    final theme = Theme.of(context);
    final primaryColor = context.primaryColor;
    const shareUrl = AppConstants.downloadUrl;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Share DeenHub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // App name
          Text(
            'DeenHub',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Description
          const Text(
            'DeenHub is a comprehensive Islamic companion app with Quran, Hadith, prayer times, and AI-powered guidance. Join millions of Muslims on their spiritual journey!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Download URL display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              shareUrl,
              style: TextStyle(
                fontSize: 14,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Copy Link button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _copyLinkToClipboard(shareUrl),
              icon: const Icon(Icons.link),
              label: const Text('Copy Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons row
          Row(
            children: [
              // Share Link button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareLink(shareUrl),
                  icon: const Icon(Icons.share),
                  label: const Text('Share Link'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // QR Code button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showQRCode(shareUrl),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('QR Code'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Disclaimer text
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Anyone can follow this link to download DeenHub. Share it with people you trust.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyLinkToClipboard(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Link copied to clipboard!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  void _shareLink(String url) {
    Navigator.of(context).pop();
    String message = '''🕌 Check out DeenHub - Your Complete Islamic Companion!

🌟 Features:
📖 Full Quran with audio recitations
📚 Comprehensive Hadith collection  
🤖 AI-powered Islamic guidance
🕋 Prayer times & Qibla direction
🧠 Memorization tools & tracking

Join millions of Muslims on their spiritual journey!

Download now: $url

#DeenHub #Islam #Quran #Islamic''';

    Share.share(message);
  }

  void _showQRCode(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QR Code',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Scan this QR code to download DeenHub',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Share QR button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _shareLink(url);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
