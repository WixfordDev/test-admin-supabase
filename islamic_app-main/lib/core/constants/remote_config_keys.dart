/// Remote Config Keys
/// 
/// This file contains all the keys used for Firebase Remote Config.
/// Each feature has a single config key with nested JSON structure.
class RemoteConfigKeys {
  RemoteConfigKeys._();

  // ==================== FEATURE CONFIGURATIONS ====================
  
  /// Trivia feature configuration
  /// Type: JSON String
  /// Structure: {
  ///   "feature_enabled": bool,
  ///   "solo_mode_enabled": bool,
  ///   "group_mode_enabled": bool
  /// }
  static const String triviaConfig = 'trivia_config';

  // ==================== FUTURE FEATURE CONFIGS ====================
  // Add more feature configs here following the same pattern
  
  /// Example: AI Chatbot configuration
  /// static const String aiChatbotConfig = 'ai_chatbot_config';
  /// Structure: {
  ///   "feature_enabled": bool,
  ///   "premium_only": bool,
  ///   "daily_limit": int
  /// }
}

