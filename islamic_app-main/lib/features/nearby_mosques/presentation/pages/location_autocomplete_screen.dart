import 'dart:async';

import 'package:deenhub/map_location_picker/map_location_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/common/enums/prayer_madhab.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/nearby_mosques/domain/models/mosque.dart';
import 'package:deenhub/features/nearby_mosques/domain/repositories/mosque_repository.dart';
import 'package:deenhub/features/nearby_mosques/presentation/widgets/mosque_list_view.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/main.dart';
import 'package:http/http.dart';

class LocationAutocompleteScreen extends StatefulWidget {
  /// API key for the map & places
  final String apiKey;

  /// Top card text field hint text
  final String searchHintText;

  /// Bottom card margin
  final EdgeInsetsGeometry bottomCardMargin;

  /// httpClient is used to make network requests.
  final Client? placesHttpClient;

  /// apiHeader is used to add headers to the request.
  final Map<String, String>? placesApiHeaders;

  /// baseUrl is used to build the url for the request.
  final String? placesBaseUrl;

  /// Session token for Google Places API
  final String? sessionToken;

  /// Offset for pagination of results
  /// offset: int,
  final num? offset;

  /// Origin location for calculating distance from results
  /// origin: Location(lat: -33.852, lng: 151.211),
  final Location? origin;

  /// currentLatLng init location for camera position
  /// currentLatLng: Location(lat: -33.852, lng: 151.211),
  final LatLng? currentLatLng;

  /// Location bounds for restricting results to a radius around a location
  /// location: Location(lat: -33.867, lng: 151.195)
  final Location? location;

  /// Radius for restricting results to a radius around a location
  /// radius: Radius in meters
  final num? radius;

  /// Language code for Places API results
  /// language: 'en',
  final String? language;

  /// Types for restricting results to a set of place types
  final List<String> types;

  /// Components set results to be restricted to a specific area
  /// components: [Component(Component.country, "us")]
  final List<Component> components;

  /// Bounds for restricting results to a set of bounds
  final bool strictbounds;

  /// Region for restricting results to a set of regions
  /// region: "us"
  final String? region;

  /// List of fields to be returned by the Google Maps Places API.
  /// Refer to the Google Documentation here for a list of valid values: https://developers.google.com/maps/documentation/places/web-service/details
  final List<String> fields;

  final BorderRadiusGeometry borderRadius;

  final Iterable<Widget>? viewTrailing;

  final BorderSide? viewSide;

  final OutlinedBorder? viewShape;

  final Widget? viewLeading;

  final String? viewHintText;

  final Color? viewBackgroundColor;

  final Color? dividerColor;

  final BoxConstraints? constraints;

  final Iterable<Widget>? barTrailing;

  final WidgetStateProperty<TextStyle?>? barTextStyle;

  final WidgetStateProperty<BorderSide?>? barSide;

  final WidgetStateProperty<EdgeInsetsGeometry?>? barPadding;

  final WidgetStateProperty<Color?>? barOverlayColor;

  final Widget? barLeading;

  final WidgetStateProperty<TextStyle?>? barHintStyle;

  final WidgetStateProperty<Color?>? barBackgroundColor;

  final WidgetStateProperty<OutlinedBorder?>? barShape;

  final void Function()? onBarTap;

  final bool isFullScreen;

  final WidgetStateProperty<double?>? barElevation;

  final TextStyle? headerHintStyle;

  final TextStyle? headerTextStyle;

  final Widget Function(BuildContext, List<Prediction>?)? listBuilder;

  final BoxConstraints? viewConstraints;

  final void Function(Prediction?)? onSuggestionSelected;
  final void Function(PlacesDetailsResponse?)? onPlacesDetailsResponse;

  final FutureOr<Iterable<Widget>> Function(BuildContext, SearchController)? suggestionsBuilder;

  final double? viewElevation;

  const LocationAutocompleteScreen({
    super.key,
    this.onPlacesDetailsResponse,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.viewTrailing,
    this.viewSide,
    this.viewShape,
    this.viewLeading,
    this.viewHintText,
    this.viewBackgroundColor,
    this.dividerColor,
    this.constraints,
    this.barTrailing,
    this.barTextStyle,
    this.barSide,
    this.barPadding,
    this.barOverlayColor,
    this.barLeading,
    this.barHintStyle,
    this.barBackgroundColor,
    this.barShape,
    this.onBarTap,
    this.isFullScreen = false,
    this.barElevation,
    this.headerHintStyle,
    this.headerTextStyle,
    this.listBuilder,
    this.viewConstraints,
    this.onSuggestionSelected,
    this.suggestionsBuilder,
    this.viewElevation,
    required this.apiKey,
    this.language,
    this.searchHintText = "Start typing to search",
    this.bottomCardMargin = const EdgeInsets.fromLTRB(8, 8, 8, 16),
    this.currentLatLng = const LatLng(28.8993468, 76.6250249),
    this.placesHttpClient,
    this.placesApiHeaders,
    this.placesBaseUrl,
    this.sessionToken,
    this.offset,
    this.origin,
    this.location,
    this.radius,
    this.region,
    this.fields = const [],
    this.types = const [],
    this.components = const [],
    this.strictbounds = false,
  });

  @override
  State<LocationAutocompleteScreen> createState() => _LocationAutocompleteScreenState();
}

class _LocationAutocompleteScreenState extends State<LocationAutocompleteScreen> {
  /// initial latitude & longitude
  late LatLng _initialPosition = const LatLng(28.8993468, 76.6250249);

  final SearchController searchController = SearchController();

  @override
  void initState() {
    _initialPosition = widget.currentLatLng ?? _initialPosition;
    super.initState();
  }

  List<Mosque>? _mosqueList;
  bool _isLoadingMosques = false;
  final _mosqueRepository = getIt<MosqueRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar with dropdown
          Container(
            margin: widget.bottomCardMargin,
            child: PlacesAutocomplete(
              apiKey: widget.apiKey,
              searchController: searchController,
              borderRadius: widget.borderRadius,
              offset: widget.offset,
              radius: widget.radius,
              components: widget.components,
              fields: widget.fields,
              language: widget.language,
              location: widget.location,
              origin: widget.origin,
              placesApiHeaders: widget.placesApiHeaders,
              placesBaseUrl: widget.placesBaseUrl,
              placesHttpClient: widget.placesHttpClient,
              region: widget.region,
              searchHintText: widget.searchHintText,
              sessionToken: widget.sessionToken,
              strictbounds: widget.strictbounds,
              types: widget.types,
              viewTrailing: widget.viewTrailing,
              viewSide: widget.viewSide,
              viewShape: widget.viewShape,
              viewLeading: widget.viewLeading,
              viewHintText: widget.viewHintText,
              viewBackgroundColor: widget.viewBackgroundColor,
              dividerColor: widget.dividerColor,
              constraints: widget.constraints,
              barTrailing: widget.barTrailing,
              barTextStyle: widget.barTextStyle,
              barSide: widget.barSide,
              barPadding: widget.barPadding,
              barOverlayColor: widget.barOverlayColor,
              barLeading: widget.barLeading,
              barHintStyle: widget.barHintStyle,
              barBackgroundColor: widget.barBackgroundColor,
              onTap: widget.onBarTap,
              barShape: widget.barShape,
              isFullScreen: widget.isFullScreen,
              barElevation: widget.barElevation,
              headerHintStyle: widget.headerHintStyle,
              headerTextStyle: widget.headerTextStyle,
              listBuilder: widget.listBuilder,
              onSuggestionSelected: widget.onSuggestionSelected,
              suggestionsBuilder: widget.suggestionsBuilder,
              viewConstraints: widget.viewConstraints,
              viewElevation: widget.viewElevation,
              onPlacesDetailsResponse: (placesDetails) async {
                if (placesDetails == null) {
                  logger.e("placesDetails is null");
                  return;
                }
                _initialPosition = LatLng(
                  placesDetails.result.geometry?.location.lat ?? 0,
                  placesDetails.result.geometry?.location.lng ?? 0,
                );

                widget.onPlacesDetailsResponse?.call(placesDetails);
                _showNearbyMosques(placesDetails.result);
              },
            ),
            // )
            // .expanded(),
            // ],
          ),

          // Mosque list or loading indicator
          if (_mosqueList != null) _buildMainContent().expanded(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_mosqueList != null) {
      return MosqueListView(
        mosques: _mosqueList!,
        isLoading: _isLoadingMosques,
        emptyStateMessage: 'No mosques found in this area',
        loadingMessage: 'Finding mosques...',
        showFavoriteButton: false,
        onMosqueUpdated: (updatedMosque, index) {
          // Update only the specific mosque in the list
          setState(() {
            // Create a new list to trigger proper UI refresh
            final updatedList = List<Mosque>.from(_mosqueList!);
            updatedList[index] = updatedMosque;
            _mosqueList = updatedList;
          });
        },
      );
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_searching,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Search for a location to find nearby mosques',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNearbyMosques(PlaceDetails place) async {
    if (place.geometry?.location == null) {
      context.showSnackBar('Location coordinates not available');
      return;
    }

    setState(() {
      _isLoadingMosques = true;
    });

    final lat = place.geometry!.location.lat;
    final lng = place.geometry!.location.lng;

    try {
      String countryCode = _getCountryCode(place.addressComponents) ?? '';
      String locationName = place.formattedAddress ?? place.name;
      final madhab = getPrayerMadhab(lat, lng);
      final method = getPrayerCalculationMethod(countryCode);
      logger.d('Madhab: $madhab | Method: $method');
      final prayerLocData = getIt<SharedPrefsHelper>().prayerLocationData;

      // Create temporary location data for this search
      final tempLocData = PrayerLocationData(
        lat: lat,
        lng: lng,
        locName: locationName,
        timezone: prayerLocData.timezone,
        country: countryCode,
        calculationMethod: method,
        asrMethod: madhab,
      );

      final tempCurrentLoc = tempLocData.toLocationData();

      // Fetch nearby mosques using the repository
      final mosques = await _mosqueRepository.fetchNearbyMosques(
        lat,
        lng,
        tempCurrentLoc,
        tempLocData,
      );

      setState(() {
        _mosqueList = mosques;
        _isLoadingMosques = false;
      });
    } catch (e) {
      logger.e('Error fetching nearby mosques: $e');
      setState(() {
        _mosqueList = [];
        _isLoadingMosques = false;
      });
      if (context.mounted) {
        context.showSnackBar('Error fetching nearby mosques');
      }
    }
  }

  String? _getCountryCode(List<AddressComponent> addressComponents) {
    for (var component in addressComponents) {
      if (component.types.contains('country')) {
        return component.shortName; // ISO country code
      }
    }
    return null;
  }
}
