import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider {
  static final SupabaseProvider _instance = SupabaseProvider._internal();
  static SupabaseProvider get instance => _instance;
  factory SupabaseProvider() => _instance;
  SupabaseProvider._internal();

  late SupabaseClient client;
  bool _isInitialized = false;

  /// Initialize the Supabase client
  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_isInitialized) return;

    try {
      // Check if session exists in shared preferences before initialization
      final prefs = await SharedPreferences.getInstance();
      final persistSessionKey = "sb-${Uri.parse(url).host.split(".").first}-auth-token";
      final hasSession = prefs.containsKey(persistSessionKey);
      debugPrint('Existing session found: $hasSession');

      // Initialize Supabase with default settings
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: true,
        authOptions: FlutterAuthClientOptions(
          autoRefreshToken: true,
        ),
      );

      client = Supabase.instance.client;
      _isInitialized = true;

      // Log user state after initialization
      final currentUser = client.auth.currentUser;
      debugPrint('Current user after initialization: ${currentUser?.id ?? 'No user found'}');
      debugPrint('Session restored: ${currentUser != null}');

      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }

  /// Get the Supabase client instance
  SupabaseClient get supabase {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return client;
  }
}
