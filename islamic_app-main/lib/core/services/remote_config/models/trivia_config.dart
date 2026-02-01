import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Trivia feature configuration from Firebase Remote Config
/// 
/// This model contains all the feature flags for the trivia game.
/// Parsed from a nested JSON structure in Remote Config.
class TriviaConfig extends Equatable {
  /// Master switch for the entire trivia feature
  final bool featureEnabled;

  /// Whether solo mode is available
  final bool soloModeEnabled;

  /// Whether group/multiplayer mode is available
  final bool groupModeEnabled;

  const TriviaConfig({
    required this.featureEnabled,
    required this.soloModeEnabled,
    required this.groupModeEnabled,
  });

  /// Default configuration (all disabled)
  factory TriviaConfig.defaults() {
    return const TriviaConfig(
      featureEnabled: false,
      soloModeEnabled: false,
      groupModeEnabled: false,
    );
  }

  /// Parse from JSON string from Remote Config
  factory TriviaConfig.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return TriviaConfig(
        featureEnabled: json['feature_enabled'] as bool? ?? false,
        soloModeEnabled: json['solo_mode_enabled'] as bool? ?? false,
        groupModeEnabled: json['group_mode_enabled'] as bool? ?? false,
      );
    } catch (e) {
      // Return defaults if parsing fails
      return TriviaConfig.defaults();
    }
  }

  /// Parse from Map (for direct JSON objects)
  factory TriviaConfig.fromMap(Map<String, dynamic> json) {
    return TriviaConfig(
      featureEnabled: json['feature_enabled'] as bool? ?? false,
      soloModeEnabled: json['solo_mode_enabled'] as bool? ?? false,
      groupModeEnabled: json['group_mode_enabled'] as bool? ?? false,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'feature_enabled': featureEnabled,
      'solo_mode_enabled': soloModeEnabled,
      'group_mode_enabled': groupModeEnabled,
    };
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Check if any trivia mode is available
  bool get hasAnyModeEnabled => soloModeEnabled || groupModeEnabled;

  /// Check if trivia is fully accessible
  bool get isAccessible => featureEnabled && hasAnyModeEnabled;

  TriviaConfig copyWith({
    bool? featureEnabled,
    bool? soloModeEnabled,
    bool? groupModeEnabled,
  }) {
    return TriviaConfig(
      featureEnabled: featureEnabled ?? this.featureEnabled,
      soloModeEnabled: soloModeEnabled ?? this.soloModeEnabled,
      groupModeEnabled: groupModeEnabled ?? this.groupModeEnabled,
    );
  }

  @override
  List<Object?> get props => [
        featureEnabled,
        soloModeEnabled,
        groupModeEnabled,
      ];

  @override
  String toString() {
    return 'TriviaConfig(featureEnabled: $featureEnabled, '
        'soloModeEnabled: $soloModeEnabled, '
        'groupModeEnabled: $groupModeEnabled)';
  }
}

