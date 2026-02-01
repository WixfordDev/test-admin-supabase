import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';

class Mosque {
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final double distance; // in kilometers or miles
  final String unit; // km/miles
  List<PrayerItem> prayerTimes; // List of all prayer times
  LocationData? locData;
  final String? placeId; // Google Place ID for unique identification
  final Map<String, int>? timeAdjustments; // Prayer name to minutes adjustment (+ or -)
  final bool isVerified; // Whether the mosque times are verified by a user
  final bool isFavorite; // Whether the mosque is in user's favorites

  Mosque({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.distance,
    required this.unit,
    required this.prayerTimes,
    required this.locData,
    this.placeId,
    this.timeAdjustments,
    this.isVerified = false,
    this.isFavorite = false,
  });

  // Factory method to create a Mosque object from Google Places API response
  factory Mosque.fromJson(
    Map<String, dynamic> json,
    double distance,
    String unit, {
    List<PrayerItem> prayerTimes = const [],
    LocationData? locData,
    Map<String, int>? timeAdjustments,
    bool isVerified = false,
    bool isFavorite = false,
  }) {
    return Mosque(
      name: json['displayName']["text"] ?? 'Unknown Mosque',
      latitude: json['location']['latitude'] ?? 0.0,
      longitude: json['location']['longitude'] ?? 0.0,
      address: json['shortFormattedAddress'] ?? 'No address available',
      distance: distance,
      unit: unit,
      prayerTimes: prayerTimes,
      locData: locData,
      placeId: json['id'], // Google Place ID
      timeAdjustments: timeAdjustments,
      isVerified: isVerified,
      isFavorite: isFavorite,
    );
  }

  // Create a new instance with updated properties
  Mosque copyWith({
    String? name,
    double? latitude,
    double? longitude, 
    String? address,
    double? distance,
    String? unit,
    List<PrayerItem>? prayerTimes,
    LocationData? locData,
    String? placeId,
    Map<String, int>? timeAdjustments,
    bool? isVerified,
    bool? isFavorite,
  }) {
    return Mosque(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      unit: unit ?? this.unit,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      locData: locData ?? this.locData,
      placeId: placeId ?? this.placeId,
      timeAdjustments: timeAdjustments ?? this.timeAdjustments,
      isVerified: isVerified ?? this.isVerified,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
