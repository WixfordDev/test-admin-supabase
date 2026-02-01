import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/main.dart';

class AppUpdateConfig {
  final String minVersion;
  final String recVersion;

  const AppUpdateConfig({required this.minVersion, required this.recVersion});

  bool isBelowMin(String currentVersion) =>
      _compareVersions(currentVersion, minVersion) < 0;

  bool isBelowRec(String currentVersion) =>
      _compareVersions(currentVersion, recVersion) < 0;

  static int _compareVersions(String a, String b) {
    List<int> parse(String v) {
      return v
          .split('.')
          .map((s) {
            final cleaned = s.trim();
            final parsed = int.tryParse(cleaned);
            return parsed ?? 0;
          })
          .toList(growable: false);
    }

    final pa = parse(a);
    final pb = parse(b);
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (int i = 0; i < len; i++) {
      final ai = i < pa.length ? pa[i] : 0;
      final bi = i < pb.length ? pb[i] : 0;
      if (ai != bi) return ai.compareTo(bi);
    }
    return 0;
  }
}

class AppUpdateService {
  static const String _table = 'app_update_config';

  Future<AppUpdateConfig?> fetchConfigForCurrentPlatform() async {
    try {
      final supabase = getIt<SupabaseProvider>().client;
      final platform = _platformString();

      final response = await supabase
          .from(_table)
          .select('min_version, rec_version')
          .eq('platform', platform)
          .maybeSingle();

      if (response == null) {
        logger.w('No app update config found for platform: $platform');
        return null;
      }

      final config = AppUpdateConfig(
        minVersion: (response['min_version'] as String?)?.trim() ?? '0.0.0',
        recVersion: (response['rec_version'] as String?)?.trim() ?? '0.0.0',
      );
      logger.i('AppUpdateConfig fetched: platform=$platform, min=${config.minVersion}, rec=${config.recVersion}');
      return config;
    } catch (e) {
      logger.e('Error fetching app update config: $e');
      return null;
    }
  }

  String _platformString() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return 'android';
    }
  }

  String? getLastRecommendedPromptVersion(SharedPrefsHelper prefs) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return prefs.lastRecPromptVersionAndroid;
      case TargetPlatform.iOS:
        return prefs.lastRecPromptVersionIos;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return prefs.lastRecPromptVersionAndroid;
    }
  }

  void setLastRecommendedPromptVersion(
      SharedPrefsHelper prefs, String version) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        prefs.setLastRecPromptVersionAndroid = version;
        return;
      case TargetPlatform.iOS:
        prefs.setLastRecPromptVersionIos = version;
        return;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        prefs.setLastRecPromptVersionAndroid = version;
        return;
    }
  }

  Future<String> getCurrentAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}






