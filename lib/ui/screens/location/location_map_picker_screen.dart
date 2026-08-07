import 'dart:async';

import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 2.14 map picker — pin on map, returns [LeafLocation] / legacy result map.
class LocationMapPickerScreen extends StatefulWidget {
  const LocationMapPickerScreen({super.key, required this.from});

  final String from;

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map? ?? {};
    return BlurredRouter(
      builder: (_) => LocationMapPickerScreen(
        from: args['from']?.toString() ?? 'home',
      ),
    );
  }

  @override
  State<LocationMapPickerScreen> createState() =>
      _LocationMapPickerScreenState();
}

class _LocationMapPickerScreenState extends State<LocationMapPickerScreen> {
  late CameraPosition _cameraPosition;
  final _mapController = Completer<GoogleMapController>();
  LatLng _markerPosition = const LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    final lat = HiveUtils.getLatitude();
    final lng = HiveUtils.getLongitude();
    if (lat != null && lng != null) {
      _markerPosition = LatLng(lat, lng);
    }
    _cameraPosition = CameraPosition(target: _markerPosition, zoom: 14);
  }

  Future<void> _confirm() async {
    final location = LeafLocation(
      latitude: _markerPosition.latitude,
      longitude: _markerPosition.longitude,
      city: HiveUtils.getCityName(),
      state: HiveUtils.getStateName(),
      country: HiveUtils.getCountryName(),
      area: HiveUtils.getAreaName(),
      areaId: HiveUtils.getAreaId(),
    );
    await location.applyToLegacyHive();
    if (!mounted) return;
    context.read<LeafLocationCubit>().syncFromLegacyHive();

    final result = {
      'latitude': _markerPosition.latitude,
      'longitude': _markerPosition.longitude,
      'city': location.city,
      'state': location.state,
      'country': location.country,
      'area': location.area,
      'area_id': location.areaId,
    };

    if (widget.from == 'home') {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'selectLocation'.translate(context),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _cameraPosition,
            onMapCreated: _mapController.complete,
            onCameraMove: (pos) {
              setState(() => _markerPosition = pos.target);
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('pick'),
                position: _markerPosition,
              ),
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: UiUtils.buildButton(
              context,
              height: 48,
              radius: 10,
              buttonTitle: 'comfirmBtnLbl'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}
