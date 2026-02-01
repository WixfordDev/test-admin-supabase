import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deenhub/features/nearby_mosques/domain/models/mosque.dart';
import 'package:deenhub/features/nearby_mosques/domain/repositories/mosque_repository.dart';
// import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/main.dart';

enum NearbyMosqueStatus {
  initial,
  loading,
  loaded,
  error,
}

class NearbyMosqueState {
  final NearbyMosqueStatus status;
  final List<Mosque> mosques;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const NearbyMosqueState({
    this.status = NearbyMosqueStatus.initial,
    this.mosques = const [],
    this.errorMessage,
    this.lastUpdated,
  });

  NearbyMosqueState copyWith({
    NearbyMosqueStatus? status,
    List<Mosque>? mosques,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return NearbyMosqueState(
      status: status ?? this.status,
      mosques: mosques ?? this.mosques,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get isLoading => status == NearbyMosqueStatus.loading;
  bool get hasData => mosques.isNotEmpty;
  bool get hasError => status == NearbyMosqueStatus.error;
  
  // Check if data is fresh (less than 15 minutes old)
  bool get isDataFresh {
    if (lastUpdated == null) return false;
    return DateTime.now().difference(lastUpdated!) < const Duration(minutes: 15);
  }
}

class NearbyMosqueCubit extends Cubit<NearbyMosqueState> {
  final MosqueRepository _mosqueRepository;
  final SharedPrefsHelper _sharedPrefsHelper;

  NearbyMosqueCubit({
    required MosqueRepository mosqueRepository,
    required SharedPrefsHelper sharedPrefsHelper,
  })  : _mosqueRepository = mosqueRepository,
        _sharedPrefsHelper = sharedPrefsHelper,
        super(const NearbyMosqueState());

  /// Fetch nearby mosques based on current location
  Future<void> fetchNearbyMosques({bool forceRefresh = false}) async {
    try {
      // Skip if we have fresh data and not forcing refresh
      if (!forceRefresh && state.isDataFresh && state.hasData) {
        logger.d('NearbyMosqueCubit: Using cached data, skipping fetch');
        return;
      }

      // Get current location data
      final prayerLocationData = _sharedPrefsHelper.prayerLocationDataOrNull;
      if (prayerLocationData == null) {
        logger.w('NearbyMosqueCubit: No location data available');
        emit(state.copyWith(
          status: NearbyMosqueStatus.error,
          errorMessage: 'Location data not available',
        ));
        return;
      }

      // Only emit loading if we don't have any data yet
      if (!state.hasData) {
        emit(state.copyWith(status: NearbyMosqueStatus.loading));
      }

      logger.d('NearbyMosqueCubit: Fetching nearby mosques...');

      final locationData = prayerLocationData.toLocationData();
      
      final mosques = await _mosqueRepository.fetchNearbyMosques(
        prayerLocationData.lat,
        prayerLocationData.lng,
        locationData,
        prayerLocationData,
      );

      logger.i('NearbyMosqueCubit: Successfully fetched ${mosques.length} mosques');

      emit(state.copyWith(
        status: NearbyMosqueStatus.loaded,
        mosques: mosques,
        errorMessage: null,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      logger.e('NearbyMosqueCubit: Error fetching nearby mosques: $e');
      
      emit(state.copyWith(
        status: NearbyMosqueStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Refresh nearby mosques data
  Future<void> refresh() async {
    await fetchNearbyMosques(forceRefresh: true);
  }

  /// Update a specific mosque (e.g., after user modifies it)
  void updateMosque(Mosque updatedMosque, int index) {
    if (index >= 0 && index < state.mosques.length) {
      final updatedMosques = List<Mosque>.from(state.mosques);
      updatedMosques[index] = updatedMosque;

      emit(state.copyWith(mosques: updatedMosques));
      logger.d('NearbyMosqueCubit: Updated mosque at index $index');
    }
  }

  /// Refresh favorite status for all mosques based on current favorites
  Future<void> refreshFavoriteStatuses() async {
    if (!state.hasData) return;

    try {
      final updatedMosques = state.mosques.map((mosque) {
        if (mosque.placeId != null) {
          final isCurrentlyFavorite = _sharedPrefsHelper.isMosqueFavorite(mosque.placeId!);
          if (mosque.isFavorite != isCurrentlyFavorite) {
            return mosque.copyWith(isFavorite: isCurrentlyFavorite);
          }
        }
        return mosque;
      }).toList();

      // Only emit if there are actual changes
      final hasChanges = !state.mosques.every((mosque) =>
          updatedMosques.any((updated) =>
              updated.placeId == mosque.placeId && updated.isFavorite == mosque.isFavorite));

      if (hasChanges) {
        emit(state.copyWith(mosques: updatedMosques));
        logger.d('NearbyMosqueCubit: Refreshed favorite statuses for ${updatedMosques.length} mosques');
      }
    } catch (e) {
      logger.e('NearbyMosqueCubit: Error refreshing favorite statuses: $e');
    }
  }

  /// Clear current data (useful when location changes significantly)
  void clearData() {
    emit(const NearbyMosqueState());
    logger.d('NearbyMosqueCubit: Cleared mosque data');
  }

  /// Get the first nearby mosque (for home screen display)
  Mosque? get firstMosque {
    return state.hasData ? state.mosques.first : null;
  }
} 