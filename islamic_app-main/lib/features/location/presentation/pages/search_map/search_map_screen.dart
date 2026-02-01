import 'dart:async';

import 'package:deenhub/features/settings/presentation/pages/settings/select_time_zone_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/bloc/data_state.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/location/presentation/bloc/location_bloc.dart';
import 'package:deenhub/features/location/presentation/dialogs/getting_current_location_dialog.dart';
import 'package:deenhub/features/onboarding/presentation/blocs/onboard_settings_bloc.dart';
import 'package:deenhub/features/onboarding/presentation/pages/location_details_onboard_screen.dart';

class SearchMapScreen extends StatefulWidget {
  final Map<String, String> queryParams;

  const SearchMapScreen({super.key, required this.queryParams});

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  final locMarker = const MarkerId('Marker');
  late LatLng position;
  String? asrMethod;
  bool fetchOnly = false;

  final Completer<GoogleMapController> _controller = Completer();
  final _positionStream = StreamController<LatLng>.broadcast();

  @override
  void initState() {
    super.initState();
    // Location
    final locLat = widget.queryParams[LocationDetailsOnboardScreen.argLocLat].toDouble;
    final locLng = widget.queryParams[LocationDetailsOnboardScreen.argLocLng].toDouble;
    if (widget.queryParams.containsKey(LocationDetailsOnboardScreen.argAsrMethod)) {
      asrMethod = widget.queryParams[LocationDetailsOnboardScreen.argAsrMethod].orEmpty;
    }
    if (widget.queryParams.containsKey(LocationDetailsOnboardScreen.argFetchOnly)) {
      fetchOnly = widget.queryParams[LocationDetailsOnboardScreen.argFetchOnly].orEmpty == 'true';
    }

    position = LatLng(locLat, locLng);
  }

  @override
  void dispose() {
    _positionStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: context.tr(LocaleKeys.selectLocation),
      child: BlocListener<OnboardSettingsBloc, Ds<OnboardSettingsState>>(
        bloc: getIt<OnboardSettingsBloc>(),
        listener: _handleListeners,
        child: _buildMapView(context),
      ),
    );
  }

  Widget _buildMapView(BuildContext context) {
    return StreamBuilder<LatLng>(
        stream: _positionStream.stream,
        builder: (context, snapshot) => GoogleMap(
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              compassEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              initialCameraPosition: CameraPosition(
                target: position,
                zoom: 11,
              ),
              markers: <Marker>{
                Marker(
                  draggable: true,
                  markerId: locMarker,
                  position: position,
                  icon: BitmapDescriptor.defaultMarker,
                  // onTap: _updateCamera,
                  infoWindow: InfoWindow(
                    title: context.tr(LocaleKeys.tapHere),
                    onTap: () {
                      getIt<OnboardSettingsBloc>().add(
                        OnboardSettingsEvent.getCurrentLocation(
                          position: position,
                        ),
                      );
                    },
                  ),
                  onDragEnd: (LatLng value) {
                    position = value;
                    _positionStream.sink.add(value);
                  },
                  zIndex: 5,
                ),
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                _showInfoWindow();
              },
            ));
  }

  // void _updateCamera() async {
  //   final controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newLatLngZoom(position, 20));
  // }

  void _showInfoWindow() async {
    final controller = await _controller.future;
    controller.showMarkerInfoWindow(locMarker);
  }

  void _handleListeners(BuildContext context, Ds<OnboardSettingsState> state) => state.whenOrNull(
        loading: () {
          context.showDialogNow(
            barrierDismissible: true,
            child: GettingCurrentLocationDialog(
              title: context.tr(LocaleKeys.pleaseWaitEllip),
            ),
          );
          return null;
        },
        success: (sData) =>
            sData.when(currentLocationFetched: (position, locName, country, localTimezone) {
          context.pop();

          if (fetchOnly) {
            context.pop();
            getIt<LocationBloc>().add(
              LocationEvent.setCurrentLocation(
                getIt<LocationBloc>().currentLoc!.copyWith(
                      lat: position.latitude,
                      lng: position.longitude,
                      locName: locName,
                      timezone: localTimezone,
                    ),
              ),
            );
            return;
          }

          final queryParameters = {
            LocationDetailsOnboardScreen.argLocLat: position.latitude.toString(),
            LocationDetailsOnboardScreen.argLocLng: position.longitude.toString(),
            LocationDetailsOnboardScreen.argLocName: locName,
            SelectTimezoneScreen.argDeviceTimezone: localTimezone,
            LocationDetailsOnboardScreen.argAsrMethod: asrMethod,
          };

          final String route = Routes.locationDetailsOnboard.name;
          context.pushReplacementNamed(route, queryParameters: queryParameters);

          return null;
        }),
        error: (error) {
          return context.showErrorSnackBar(error);
        },
      );
}
