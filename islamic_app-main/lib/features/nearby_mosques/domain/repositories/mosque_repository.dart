import 'dart:convert';

import 'package:deenhub/common/prayers/prayer_times_helper.dart';
import 'package:deenhub/config/constants/app_constants.dart';
import 'package:deenhub/core/firebase/mosque_notification_service.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/nearby_mosques/data/models/local_favorite_mosque.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/features/nearby_mosques/data/models/mosque_facility.dart';
import 'package:deenhub/features/nearby_mosques/data/models/mosque_adjustment.dart';
import 'package:deenhub/features/nearby_mosques/data/services/supabase_mosque_service.dart';
import 'package:deenhub/features/nearby_mosques/domain/models/mosque.dart';
import 'package:deenhub/features/nearby_mosques/domain/utils/utils.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MosqueRepository {
  final SupabaseMosqueService _mosqueService;
  final MosqueNotificationService _notificationService;
  final SharedPrefsHelper _sharedPrefsHelper;

  // Add caching for mosque adjustments to avoid repeated database calls
  final Map<String, Map<String, int>> _adjustmentCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 30);

  MosqueRepository({
    required SupabaseProvider supabaseProvider,
    required MosqueNotificationService notificationService,
    required SharedPrefsHelper sharedPrefsHelper,
  }) : _mosqueService = SupabaseMosqueService(supabaseProvider),
       _notificationService = notificationService,
       _sharedPrefsHelper = sharedPrefsHelper;

  /// Fetches nearby mosques from a given latitude and longitude with optimizations
  /// Returns a list of [Mosque] objects
  Future<List<Mosque>> fetchNearbyMosques(
    double latitude,
    double longitude,
    LocationData currentLoc,
    PrayerLocationData prayerLocData,
  ) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': AppConstants.mapsApiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.shortFormattedAddress,places.location',
      };

      final Map<String, dynamic> data = {
        "includedPrimaryTypes": ["mosque"],
        "maxResultCount":
            10, // Increased to get more options but limit processing
        "rankPreference": "DISTANCE",
        "locationRestriction": {
          "circle": {
            "center": {"latitude": latitude, "longitude": longitude},
            "radius": 50000.0,
          },
        },
      };

      final url = Uri.parse(
        'https://places.googleapis.com/v1/places:searchNearby',
      );

      // Add timeout to prevent hanging
      final response = await http
          .post(url, headers: headers, body: jsonEncode(data))
          .timeout(
            const Duration(seconds: 10), // Add 10 second timeout
            onTimeout: () {
              logger.w('Google Places API timeout');
              return http.Response('{"error": "timeout"}', 408);
            },
          );

      if (response.statusCode != 200) {
        logger.e(
          'Google Places API error: ${response.statusCode} - ${response.body}',
        );
        return [];
      }

      final json = jsonDecode(response.body);
      logger.d('Response: ${json['places']?.length ?? 0} mosques found');

      if (json['places'] != null) {
        // Get prayer times for the location (calculate once)
        final updatedLoc = PrayerTimesHelper.getPrayerTimings(
          currentLoc,
          prayerLocData,
          time: DateTime.now(),
        );

        bool showMiles = Utils.usesMiles(prayerLocData.country);
        String unit = showMiles ? "miles" : "km";

        // Convert places to mosque objects first (fast operation)
        final mosques = (json['places'] as List).take(10).map((place) {
          // Limit to 10 for better performance
          final lat = place['location']['latitude'];
          final lng = place['location']['longitude'];

          final distanceInKm =
              (Geolocator.distanceBetween(latitude, longitude, lat, lng) /
              1000);

          double distance;
          if (showMiles) {
            distance = distanceInKm * 0.621371;
          } else {
            distance = distanceInKm;
          }

          return Mosque.fromJson(
            place,
            distance,
            unit,
            prayerTimes: updatedLoc.prayerTimes ?? [],
            locData: updatedLoc,
          );
        }).toList();

        // Optimize: Process mosques in parallel instead of sequentially
        logger.d('Processing ${mosques.length} mosques in parallel...');

        // Pre-load all adjustments in a single batch call to reduce database round trips
        await _preloadAdjustments(
          mosques
              .map((m) => m.placeId)
              .where((id) => id != null)
              .cast<String>()
              .toList(),
        );

        // Process mosques in parallel with limited concurrency to avoid overwhelming the system
        final enrichedMosques = await _processMosquesInParallel(
          mosques,
          concurrency: 5,
        );

        logger.i('Successfully processed ${enrichedMosques.length} mosques');
        return enrichedMosques;
      }

      return [];
    } catch (e) {
      logger.e('Error fetching nearby mosques: $e');
      return [];
    }
  }

  /// Pre-load adjustments for multiple mosques using parallel calls
  Future<void> _preloadAdjustments(List<String> mosqueIds) async {
    try {
      if (mosqueIds.isEmpty) return;

      // Check if cache is still valid
      if (_lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration) {
        logger.d('Using cached adjustments');
        return;
      }

      logger.d(
        'Preloading adjustments for ${mosqueIds.length} mosques in parallel...',
      );

      // Make parallel calls to get adjustments for all mosques
      final adjustmentFutures = mosqueIds
          .map(
            (mosqueId) => _mosqueService
                .getMosqueAdjustments(mosqueId)
                .then(
                  (adjustments) => {
                    'mosqueId': mosqueId,
                    'adjustments': adjustments,
                  },
                )
                .catchError((error) {
                  logger.w(
                    'Failed to get adjustments for mosque $mosqueId: $error',
                  );
                  return {
                    'mosqueId': mosqueId,
                    'adjustments': <MosqueAdjustment>[],
                  };
                }),
          )
          .toList();

      // Wait for all calls to complete with timeout
      final results = await Future.wait(adjustmentFutures).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.w('Timeout loading mosque adjustments');
          return mosqueIds
              .map(
                (id) => {'mosqueId': id, 'adjustments': <MosqueAdjustment>[]},
              )
              .toList();
        },
      );

      // Organize by mosque ID for fast lookup
      _adjustmentCache.clear();
      int totalAdjustments = 0;

      for (var result in results) {
        final mosqueId = result['mosqueId'] as String;
        final adjustments = result['adjustments'] as List<MosqueAdjustment>;

        if (adjustments.isNotEmpty) {
          _adjustmentCache[mosqueId] = {};

          for (var adjustment in adjustments) {
            final prayerName = adjustment.prayerName.toLowerCase();
            if (adjustment.timeType == 'iqamah') {
              _adjustmentCache[mosqueId]!['${prayerName}_iqamah'] =
                  adjustment.adjustmentMinutes;
            } else {
              _adjustmentCache[mosqueId]![prayerName] =
                  adjustment.adjustmentMinutes;
            }
            totalAdjustments++;
          }
        }
      }

      _lastCacheUpdate = DateTime.now();
      logger.d(
        'Preloaded $totalAdjustments adjustments for ${_adjustmentCache.length} mosques',
      );
    } catch (e) {
      logger.e('Error preloading adjustments: $e');
      // Continue without cache - individual calls will still work
    }
  }

  /// Process mosques in parallel with controlled concurrency
  Future<List<Mosque>> _processMosquesInParallel(
    List<Mosque> mosques, {
    int concurrency = 5,
  }) async {
    final results = <Mosque>[];

    // Process in batches to control memory usage and API load
    for (int i = 0; i < mosques.length; i += concurrency) {
      final batch = mosques.skip(i).take(concurrency).toList();

      final batchResults = await Future.wait(
        batch.map(
          (mosque) => mosque.placeId != null
              ? _enrichMosqueWithCachedData(mosque)
              : Future.value(mosque),
        ),
        eagerError: false, // Continue processing even if some fail
      );

      results.addAll(batchResults);

      // Small delay between batches to prevent overwhelming the system
      if (i + concurrency < mosques.length) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    return results;
  }

  /// Enhanced version that uses cached data for better performance
  Future<Mosque> _enrichMosqueWithCachedData(Mosque mosque) async {
    try {
      if (mosque.placeId == null) {
        return mosque;
      }

      // Check if mosque is in local favorites (fast local operation)
      bool isFavorite = _sharedPrefsHelper.isMosqueFavorite(mosque.placeId!);

      // Use cached adjustments if available, otherwise fetch from Supabase
      var cachedAdjustments = _adjustmentCache[mosque.placeId!];

      // If not in cache, fetch from Supabase directly
      if (cachedAdjustments == null) {
        try {
          final adjustments = await _mosqueService.getMosqueAdjustments(
            mosque.placeId!,
          );
          if (adjustments.isNotEmpty) {
            cachedAdjustments = {};
            for (var adjustment in adjustments) {
              final prayerName = adjustment.prayerName.toLowerCase();
              if (adjustment.timeType == 'iqamah') {
                cachedAdjustments!['${prayerName}_iqamah'] =
                    adjustment.adjustmentMinutes;
              } else {
                cachedAdjustments![prayerName] = adjustment.adjustmentMinutes;
              }
            }
            // Store in cache for future use
            _adjustmentCache[mosque.placeId!] = cachedAdjustments;
            logger.d(
              'Fetched and cached ${adjustments.length} adjustments for ${mosque.name}',
            );
          }
        } catch (e) {
          logger.w(
            'Failed to fetch adjustments for mosque ${mosque.placeId}: $e',
          );
        }
      }
      Map<String, int> adjustmentMap = {};
      bool isVerified = false;
      List<PrayerItem> updatedPrayerTimes = mosque.prayerTimes;
      LocationData? updatedLocData = mosque.locData;

      if (cachedAdjustments != null && cachedAdjustments.isNotEmpty) {
        logger.d('Using cached adjustments for ${mosque.name}');

        // Separate adjustments by prayer and time type
        Map<String, int> adhanAdjustments = {};
        Map<String, int> iqamahAdjustments = {};

        for (var entry in cachedAdjustments.entries) {
          if (entry.key.endsWith('_iqamah')) {
            final prayerName = entry.key.replaceAll('_iqamah', '');
            iqamahAdjustments[prayerName] = entry.value;
          } else {
            adhanAdjustments[entry.key] = entry.value;
          }
        }

        isVerified = true;

        // Apply adjustments to prayer times
        updatedPrayerTimes = [];

        for (var prayer in mosque.prayerTimes) {
          final prayerName = prayer.type.name.toLowerCase();

          DateTime adjustedAdhanTime = prayer.time;
          DateTime? adjustedIqamahTime = prayer.iqamahTime;

          // Apply adhan adjustment if it exists
          if (adhanAdjustments.containsKey(prayerName)) {
            adjustedAdhanTime = prayer.time.add(
              Duration(minutes: adhanAdjustments[prayerName]!),
            );
          }

          // Apply iqamah adjustment if it exists
          if (iqamahAdjustments.containsKey(prayerName)) {
            adjustedIqamahTime = prayer.time.add(
              Duration(minutes: iqamahAdjustments[prayerName]!),
            );
          }

          final hasAdhanAdjustment = adhanAdjustments.containsKey(prayerName);
          final hasIqamahAdjustment = iqamahAdjustments.containsKey(prayerName);

          updatedPrayerTimes.add(
            prayer.copyWith(
              time: adjustedAdhanTime,
              iqamahTime: adjustedIqamahTime,
              adhanStatus: hasAdhanAdjustment
                  ? "verified"
                  : (prayer.adhanStatus.isEmpty
                        ? "prediction"
                        : prayer.adhanStatus),
              iqamahStatus: hasIqamahAdjustment
                  ? "verified"
                  : (prayer.iqamahStatus.isEmpty
                        ? "prediction"
                        : prayer.iqamahStatus),
              adjustment: adhanAdjustments[prayerName] ?? 0,
            ),
          );
        }

        // Update location data with adjustments
        if (mosque.locData != null) {
          final adjustmentsList = <int>[];
          for (var prayer in updatedPrayerTimes) {
            final prayerName = prayer.type.name.toLowerCase();
            adjustmentsList.add(adhanAdjustments[prayerName] ?? 0);
          }

          updatedLocData = mosque.locData!.copyWith(
            adjustments: adjustmentsList,
            prayerTimes: updatedPrayerTimes,
          );
        }

        adjustmentMap = adhanAdjustments;
      } else {
        // No cached adjustments - use predictions
        updatedPrayerTimes = mosque.prayerTimes
            .map(
              (prayer) => prayer.copyWith(
                adhanStatus: prayer.adhanStatus.isEmpty
                    ? "prediction"
                    : prayer.adhanStatus,
              ),
            )
            .toList();
      }

      // Return enriched mosque
      return mosque.copyWith(
        prayerTimes: updatedPrayerTimes,
        locData: updatedLocData,
        timeAdjustments: adjustmentMap.isNotEmpty ? adjustmentMap : null,
        isVerified: isVerified,
        isFavorite: isFavorite,
      );
    } catch (e) {
      logger.e('Error enriching mosque ${mosque.name}: $e');
      return mosque; // Return original mosque if enrichment fails
    }
  }

  /// Legacy method - now uses cached data for better performance
  Future<Mosque> enrichMosqueWithAllData(Mosque mosque) async {
    return await _enrichMosqueWithCachedData(mosque);
  }

  /// Clear the adjustment cache
  void clearAdjustmentCache() {
    _adjustmentCache.clear();
    _lastCacheUpdate = null;
    logger.d('Adjustment cache cleared');
  }

  /// Clear cache for a specific mosque to ensure fresh data is loaded
  void clearCacheForMosque(String mosqueId) {
    _adjustmentCache.remove(mosqueId);
    logger.d('Cache cleared for mosque: $mosqueId');
  }

  /// Fetch user's favorite mosques from local storage
  Future<List<Mosque>> fetchFavoriteMosques(
    LocationData currentLoc,
    PrayerLocationData prayerLocData,
  ) async {
    try {
      // Get user's favorite mosque IDs from local storage
      final favorites = _sharedPrefsHelper.favoriteMosques;

      if (favorites.isEmpty) {
        return [];
      }

      // Fetch detailed information for each mosque using Google Places API
      List<Mosque> mosques = [];

      for (var favorite in favorites) {
        final mosque = await fetchMosqueDetails(
          favorite.mosqueId,
          currentLoc,
          prayerLocData,
        );

        if (mosque != null) {
          // The mosque will already have isFavorite = true from enrichMosqueWithAllData
          mosques.add(mosque);
        }
      }

      return mosques;
    } catch (e) {
      logger.e('Error fetching favorite mosques: $e');
      return [];
    }
  }

  /// Fetch details for a specific mosque by its place ID
  Future<Mosque?> fetchMosqueDetails(
    String placeId,
    LocationData currentLoc,
    PrayerLocationData prayerLocData,
  ) async {
    try {
      final headers = {
        'X-Goog-Api-Key': AppConstants.mapsApiKey,
        'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
      };

      final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // Get prayer times for the location
        final updatedLoc = PrayerTimesHelper.getPrayerTimings(
          currentLoc,
          prayerLocData,
          time: DateTime.now(),
        );

        bool showMiles = Utils.usesMiles(prayerLocData.country);
        String unit = showMiles ? "miles" : "km";

        // Calculate distance
        final lat = json['location']['latitude'];
        final lng = json['location']['longitude'];

        final distanceInKm =
            (Geolocator.distanceBetween(
              prayerLocData.lat,
              prayerLocData.lng,
              lat,
              lng,
            ) /
            1000);

        double distance;
        if (showMiles) {
          distance = distanceInKm * 0.621371;
        } else {
          distance = distanceInKm;
        }

        // Convert to short format for display
        final shortAddress = json['formattedAddress'] ?? 'No address available';

        // Handle different displayName formats from different API endpoints
        String displayName;
        if (json['displayName'] is Map) {
          displayName = json['displayName']['text'] ?? 'Unknown Mosque';
        } else if (json['displayName'] is String) {
          displayName = json['displayName'];
        } else {
          displayName = 'Unknown Mosque';
        }

        final placeJson = {
          'id': placeId,
          'displayName': {'text': displayName},
          'shortFormattedAddress': shortAddress,
          'location': json['location'],
        };

        final mosque = Mosque.fromJson(
          placeJson,
          distance,
          unit,
          prayerTimes: updatedLoc.prayerTimes ?? [],
          locData: updatedLoc,
        );

        // Enrich with adjustment data and favorite status
        final enrichedMosque = await enrichMosqueWithAllData(mosque);

        return enrichedMosque;
      }

      return null;
    } catch (e) {
      logger.e('Error fetching mosque details: $e');
      return null;
    }
  }

  /// Add mosque to local favorites (no authentication required)
  Future<void> addToFavorites(Mosque mosque) async {
    try {
      if (mosque.placeId == null) {
        throw Exception('Mosque has no place ID');
      }

      // Create local favorite object
      final favorite = LocalFavoriteMosque(
        mosqueId: mosque.placeId!,
        mosqueName: mosque.name,
        latitude: mosque.latitude,
        longitude: mosque.longitude,
        address: mosque.address,
        addedAt: DateTime.now(),
        subscribedToUpdates: true, // Subscribe by default
      );

      // Save to local storage
      _sharedPrefsHelper.addFavoriteMosque(favorite);

      // Subscribe to FCM topic for this mosque
      await _notificationService.subscribeToPrayerTimeUpdates(mosque.placeId!);

      logger.i('Mosque added to favorites: ${mosque.name}');
    } catch (e) {
      logger.e('Error adding mosque to favorites: $e');
      rethrow;
    }
  }

  /// Remove mosque from local favorites (no authentication required)
  Future<void> removeFromFavorites(Mosque mosque) async {
    try {
      if (mosque.placeId == null) {
        throw Exception('Mosque has no place ID');
      }

      // Remove from local storage
      _sharedPrefsHelper.removeFavoriteMosque(mosque.placeId!);

      // Unsubscribe from FCM topic
      await _notificationService.unsubscribeFromPrayerTimeUpdates(
        mosque.placeId!,
      );

      logger.i('Mosque removed from favorites: ${mosque.name}');
    } catch (e) {
      logger.e('Error removing mosque from favorites: $e');
      rethrow;
    }
  }

  /// Update subscription status for mosque in local storage
  Future<void> updateSubscriptionStatus(Mosque mosque, bool subscribed) async {
    try {
      if (mosque.placeId == null) {
        throw Exception('Mosque has no place ID');
      }

      // Update in local storage
      _sharedPrefsHelper.updateFavoriteMosqueSubscription(
        mosque.placeId!,
        subscribed,
      );

      // Update FCM subscription
      if (subscribed) {
        await _notificationService.subscribeToPrayerTimeUpdates(
          mosque.placeId!,
        );
      } else {
        await _notificationService.unsubscribeFromPrayerTimeUpdates(
          mosque.placeId!,
        );
      }

      logger.i('Mosque subscription updated: ${mosque.name} - $subscribed');
    } catch (e) {
      logger.e('Error updating mosque subscription: $e');
      rethrow;
    }
  }

  /// Check if a mosque is in local favorites
  bool isMosqueFavorite(String placeId) {
    return _sharedPrefsHelper.isMosqueFavorite(placeId);
  }

  /// Check for mosque time changes and notify about favorite mosques
  Future<void> checkForMosqueTimeChanges() async {
    try {
      final favorites = _sharedPrefsHelper.favoriteMosques;
      if (favorites.isEmpty) return;

      // Get recent time changes
      final timeChanges = await _mosqueService.getRecentSignificantTimeChanges(
        hoursBack: 24,
      );

      for (var change in timeChanges) {
        final mosqueId = change['mosque_id'] as String;

        // Check if this mosque is in user's favorites
        final isFavorite = favorites.any((f) => f.mosqueId == mosqueId);

        if (isFavorite) {
          // Log the time change for favorite mosque
          logger.i(
            'Prayer time changed for favorite mosque: ${change['mosque_name']} - ${change['prayer_name']}',
          );

          // Update last notification check timestamp
          _sharedPrefsHelper.updateFavoriteMosqueNotificationCheck(
            mosqueId,
            DateTime.now(),
          );
        }
      }
    } catch (e) {
      logger.e('Error checking for mosque time changes: $e');
    }
  }

  // ============================================================================
  // MOSQUE FACILITIES METHODS
  // ============================================================================

  /// Get facilities for a specific mosque
  Future<List<MosqueFacility>> getMosqueFacilities(String mosqueId) async {
    try {
      return await _mosqueService.getMosqueFacilities(mosqueId);
    } catch (e) {
      logger.e('Error fetching mosque facilities: $e');
      return [];
    }
  }

  /// Get facilities organized by category
  Future<Map<String, List<MosqueFacility>>> getMosqueFacilitiesByCategory(
    String mosqueId,
  ) async {
    try {
      return await _mosqueService.getMosqueFacilitiesByCategory(mosqueId);
    } catch (e) {
      logger.e('Error fetching categorized mosque facilities: $e');
      return {'General': [], 'For Women': [], 'Accessibility': []};
    }
  }

  /// Save mosque facility
  Future<void> saveMosqueFacility(
    MosqueFacility facility, {
    String? updatedBy,
    String? mosqueName,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      // Ensure mosque metadata exists before saving facility
      await _ensureMosqueMetadataExists(
        mosqueId: facility.mosqueId,
        mosqueName: mosqueName,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      await _mosqueService.saveMosqueFacility(facility, updatedBy: updatedBy);
      logger.i(
        'Mosque facility saved: ${facility.facilityType.displayName} for ${facility.mosqueId}',
      );
    } catch (e) {
      logger.e('Error saving mosque facility: $e');
      rethrow;
    }
  }

  /// Save multiple facilities at once
  Future<void> saveMosqueFacilities(
    List<MosqueFacility> facilities, {
    String? updatedBy,
    String? mosqueName,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      // Ensure mosque metadata exists before saving facilities
      if (facilities.isNotEmpty) {
        final mosqueId = facilities.first.mosqueId;
        await _ensureMosqueMetadataExists(
          mosqueId: mosqueId,
          mosqueName: mosqueName,
          latitude: latitude,
          longitude: longitude,
          address: address,
        );
      }

      await _mosqueService.saveMosqueFacilities(
        facilities,
        updatedBy: updatedBy,
      );
      logger.i('Multiple mosque facilities saved successfully');
    } catch (e) {
      logger.e('Error saving mosque facilities: $e');
      rethrow;
    }
  }

  /// Delete a mosque facility
  Future<void> deleteMosqueFacility(
    String mosqueId,
    FacilityType facilityType,
  ) async {
    try {
      await _mosqueService.deleteMosqueFacility(mosqueId, facilityType);
      logger.i(
        'Mosque facility deleted: ${facilityType.displayName} for $mosqueId',
      );
    } catch (e) {
      logger.e('Error deleting mosque facility: $e');
      rethrow;
    }
  }

  /// Helper method to ensure mosque metadata exists before saving facilities
  Future<void> _ensureMosqueMetadataExists({
    required String mosqueId,
    String? mosqueName,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      // Always try to save/update mosque metadata to ensure it exists
      // This will create the record if it doesn't exist, or update if it does
      await _mosqueService.saveMosqueMetadata(
        mosqueId: mosqueId,
        name: mosqueName ?? 'Unknown Mosque',
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        address: address,
      );
      logger.d('Mosque metadata ensured for ID: $mosqueId');
    } catch (e) {
      logger.w('Warning: Could not ensure mosque metadata exists: $e');
      // Continue anyway - the user might still be able to save facilities
      // if the mosque metadata was created by another process
    }
  }
}
