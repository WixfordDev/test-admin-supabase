import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/features/nearby_mosques/domain/models/mosque.dart';
import 'package:deenhub/features/nearby_mosques/domain/repositories/mosque_repository.dart';
import 'package:deenhub/features/nearby_mosques/presentation/cubit/nearby_mosque_cubit.dart';
import 'package:deenhub/features/nearby_mosques/presentation/widgets/mosque_list_view.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/main.dart';

class FavoriteMosquesScreen extends StatefulWidget {
  const FavoriteMosquesScreen({super.key});

  @override
  State<FavoriteMosquesScreen> createState() => _FavoriteMosquesScreenState();
}

class _FavoriteMosquesScreenState extends State<FavoriteMosquesScreen> {
  final MosqueRepository _mosqueRepository = getIt<MosqueRepository>();
  List<Mosque> _favoriteMosques = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteMosques();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh favorites when screen comes back into focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteMosques();
    });
  }

  Future<void> _loadFavoriteMosques() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get current location data
      final sharedPrefsHelper = getIt<SharedPrefsHelper>();
      final prayerLocData = sharedPrefsHelper.prayerLocationDataOrNull;

      if (prayerLocData == null) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Location data not available. Please set your location first.';
        });
        return;
      }

      final locationData = prayerLocData.toLocationData();

      logger.d('Loading favorite mosques...');

      final favoriteMosques = await _mosqueRepository.fetchFavoriteMosques(
        locationData,
        prayerLocData,
      );

      logger.i(
        'Successfully loaded ${favoriteMosques.length} favorite mosques',
      );

      setState(() {
        _favoriteMosques = favoriteMosques;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading favorite mosques: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load favorite mosques. Please try again.';
      });
    }
  }

  void _onMosqueUpdated(Mosque updatedMosque, int index) {
    setState(() {
      _favoriteMosques[index] = updatedMosque;
    });
  }

  void _onFavoriteToggled(Mosque updatedMosque, int index) {
    if (!updatedMosque.isFavorite) {
      // If mosque is no longer favorite, remove it from the list
      setState(() {
        _favoriteMosques.removeAt(index);
      });

      // Notify the cubit that favorites have changed so other screens can update
      final cubit = getIt<NearbyMosqueCubit>();
      cubit.refreshFavoriteStatuses();
    } else {
      // Update the mosque in the list
      setState(() {
        _favoriteMosques[index] = updatedMosque;
      });

      // Notify the cubit that favorites have changed so other screens can update
      final cubit = getIt<NearbyMosqueCubit>();
      cubit.refreshFavoriteStatuses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: 'Favorite Mosques',
      child: Column(
        children: [
          // Refresh indicator and list
          Expanded(
            child: MosqueListView(
              mosques: _favoriteMosques,
              isLoading: _isLoading,
              emptyStateMessage: _errorMessage ?? 'No favorite mosques yet',
              loadingMessage: 'Loading favorite mosques...',
              onRefresh: _loadFavoriteMosques,
              onMosqueUpdated: _onMosqueUpdated,
              onFavoriteToggled: _onFavoriteToggled,
            ),
          ),
        ],
      ),
    );
  }
}
