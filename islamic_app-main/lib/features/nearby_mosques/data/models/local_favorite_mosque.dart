import 'dart:convert';

/// Local favorite mosque model for storing favorites in SharedPreferences
/// This replaces the Supabase-stored favorite mosques
class LocalFavoriteMosque {
  final String mosqueId; // Google Place ID
  final String mosqueName;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime addedAt;
  final bool subscribedToUpdates; // Whether user receives notifications for this mosque
  final DateTime? lastNotificationCheck; // Last time we checked for updates
  
  const LocalFavoriteMosque({
    required this.mosqueId,
    required this.mosqueName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.addedAt,
    this.subscribedToUpdates = true, // Subscribe by default when adding to favorites
    this.lastNotificationCheck,
  });
  
  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'mosqueId': mosqueId,
      'mosqueName': mosqueName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'addedAt': addedAt.toIso8601String(),
      'subscribedToUpdates': subscribedToUpdates,
      'lastNotificationCheck': lastNotificationCheck?.toIso8601String(),
    };
  }
  
  /// Create from JSON from local storage
  factory LocalFavoriteMosque.fromJson(Map<String, dynamic> json) {
    return LocalFavoriteMosque(
      mosqueId: json['mosqueId'] as String,
      mosqueName: json['mosqueName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      subscribedToUpdates: json['subscribedToUpdates'] as bool? ?? true,
      lastNotificationCheck: json['lastNotificationCheck'] != null 
          ? DateTime.parse(json['lastNotificationCheck'] as String)
          : null,
    );
  }
  
  /// Convert list to JSON string for storage
  static String listToJsonString(List<LocalFavoriteMosque> favorites) {
    return jsonEncode(favorites.map((f) => f.toJson()).toList());
  }
  
  /// Create list from JSON string from storage
  static List<LocalFavoriteMosque> listFromJsonString(String jsonString) {
    if (jsonString.isEmpty) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => LocalFavoriteMosque.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Create a copy with updated properties
  LocalFavoriteMosque copyWith({
    String? mosqueId,
    String? mosqueName,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? addedAt,
    bool? subscribedToUpdates,
    DateTime? lastNotificationCheck,
  }) {
    return LocalFavoriteMosque(
      mosqueId: mosqueId ?? this.mosqueId,
      mosqueName: mosqueName ?? this.mosqueName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      addedAt: addedAt ?? this.addedAt,
      subscribedToUpdates: subscribedToUpdates ?? this.subscribedToUpdates,
      lastNotificationCheck: lastNotificationCheck ?? this.lastNotificationCheck,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalFavoriteMosque && other.mosqueId == mosqueId;
  }
  
  @override
  int get hashCode => mosqueId.hashCode;
} 