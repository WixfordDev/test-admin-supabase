import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/common/enums/prayer_madhab.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/bloc/data_state.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/services/location_update_service.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/button/filled_border_button_widget.dart';
import 'package:deenhub/core/widgets/edit_text/input_edit_text.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/location/presentation/dialogs/getting_current_location_dialog.dart';
import 'package:deenhub/features/onboarding/presentation/blocs/onboard_settings_bloc.dart';
// import 'package:deenhub/features/nearby_mosques/domain/models/mosque.dart';
import 'package:deenhub/features/nearby_mosques/presentation/cubit/nearby_mosque_cubit.dart';
import 'package:deenhub/features/nearby_mosques/presentation/widgets/mosque_list_view.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/main.dart';

class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  PrayerLocationData? prayerLocData;
  LocationData? currentLoc;
  final TextEditingController locationController = TextEditingController();
  final _nearbyMosqueCubit = getIt<NearbyMosqueCubit>();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh favorite statuses when screen comes back into focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nearbyMosqueCubit.refreshFavoriteStatuses();
    });
  }

  Future<void> _initializeData() async {
    final prefs = getIt<SharedPrefsHelper>();
    prayerLocData = prefs.prayerLocationDataOrNull;
    if (prayerLocData != null) {
      currentLoc = prayerLocData!.toLocationData();
      locationController.text = prayerLocData?.locName ?? '';
    }

    // No need to fetch manually - cubit should already have data from splash screen
    // If data is not available or stale, trigger a fetch
    if (prayerLocData != null &&
        (!_nearbyMosqueCubit.state.hasData || !_nearbyMosqueCubit.state.isDataFresh)) {
      await _nearbyMosqueCubit.fetchNearbyMosques();
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardSettingsBloc, Ds<OnboardSettingsState>>(
      bloc: getIt<OnboardSettingsBloc>(),
      listener: _handleListeners,
      child: _buildContentView(context),
    );
  }

  Widget _buildContentView(BuildContext context) {
    return Column(
      children: [
        // Location Search Bar
        _buildLocationSearchBar(),

        // Action Buttons Row
        gapH16,
        Row(
          children: [
            Expanded(
              child: FilledBorderButtonWidget(
                text: "Add Mosque",
                textColor: Colors.white,
                onPressed: () {
                  context.pushNamed(Routes.addMosque.name);
                },
              ),
            ),
            gapW12,
            Expanded(
              child: FilledBorderButtonWidget(
                text: "Favorites",
                textColor: Colors.white,
                onPressed: () {
                  context.pushNamed(Routes.favoriteMosques.name);
                },
              ),
            ),
          ],
        ).withPadding(px16),
        gapH8,

        // Mosque List using cubit or empty-state CTA if location missing
        if (prayerLocData == null)
          _buildEnableLocationCta(context).expanded()
        else
          BlocBuilder<NearbyMosqueCubit, NearbyMosqueState>(
            bloc: _nearbyMosqueCubit,
            builder: (context, state) {
              return MosqueListView(
                mosques: state.mosques,
                isLoading: state.isLoading,
                onRefresh: () async {
                  // Update location first if needed, then refresh mosques
                  await LocationUpdateService.updateLocationIfNeeded();
                  await _nearbyMosqueCubit.refresh();
                },
                onMosqueUpdated: (updatedMosque, index) {
                  _nearbyMosqueCubit.updateMosque(updatedMosque, index);
                },
                onFavoriteToggled: (updatedMosque, index) {
                  _nearbyMosqueCubit.updateMosque(updatedMosque, index);
                  // Also refresh favorite statuses in case other screens need to know
                  _nearbyMosqueCubit.refreshFavoriteStatuses();
                },
              );
            },
          ).expanded(),
      ],
    );
  }

  Widget _buildLocationSearchBar() {
    return Container(
      color: context.primaryColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InputEditText(
            controller: locationController,
            inputType: TextInputType.streetAddress,
            readOnly: true,
            isOutlineBorder: false,
            label: 'Enter location, zipcode, or city',
            isDense: true,
            onTap: () async {
              if (prayerLocData == null) {
                // If missing, take user to onboarding location flow
                context.pushNamed(Routes.getPrayerTimesOnboard.name);
              } else {
                context.pushNamed(
                  Routes.locationPicker.name,
                  queryParameters: {
                    "lat": (prayerLocData?.lat).toString(),
                    "lng": (prayerLocData?.lng).toString(),
                  },
                );
              }
            },
          ).expanded(),
          ImageView(
            imagePath: Icons.my_location_rounded,
            color: context.onTertiaryColor,
            padding: p8,
            onTap: () {
              getIt<OnboardSettingsBloc>().add(const OnboardSettingsEvent.getCurrentLocation());
            },
          ),
        ],
      ).withPadding(
        const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0, start: 16.0, end: 8.0),
      ),
    );
  }

  Widget _buildEnableLocationCta(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            gapH16,
            const Text(
              'Enable location to find nearby mosques',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            gapH8,
            const Text(
              'Grant location access or set your location to view mosques near you.',
              textAlign: TextAlign.center,
            ),
            gapH16,
            FilledBorderButtonWidget(
              text: 'Set up location',
              textColor: Colors.white,
              onPressed: () {
                context.pushNamed(Routes.getPrayerTimesOnboard.name);
              },
            ),
          ],
        ),
      ),
    );
  }

  void saveLocationData(
    double lat,
    double lng,
    String locName,
    String country,
    String localTimezone,
  ) {
    final madhab = getPrayerMadhab(lat, lng);
    final method = getPrayerCalculationMethod(country);
    logger.d('Madhab: $madhab | Method: $method');

    setState(() {
      prayerLocData = PrayerLocationData(
        lat: lat,
        lng: lng,
        locName: locName,
        timezone: localTimezone,
        country: country,
        calculationMethod: method,
        asrMethod: madhab,
      );
      currentLoc = prayerLocData!.toLocationData();
    });

    getIt<SharedPrefsHelper>().setPrayerLocationData = prayerLocData!;
    
    // Clear current mosque data and fetch new data for the updated location
    _nearbyMosqueCubit.clearData();
    _nearbyMosqueCubit.fetchNearbyMosques();
  }

  void _handleListeners(BuildContext context, Ds<OnboardSettingsState> state) => state.whenOrNull(
        loading: () {
          context.showDialogNow(
            barrierDismissible: true,
            child: const GettingCurrentLocationDialog(),
          );
          return null;
        },
        success: (sData) =>
            sData.when(currentLocationFetched: (position, locName, country, localTimezone) {
          context.pop();
          saveLocationData(
            position.latitude,
            position.longitude,
            locName,
            country,
            localTimezone,
          );
          return null;
        }),
        error: (error) {
          return context.showErrorSnackBar(error);
        },
      );
}
