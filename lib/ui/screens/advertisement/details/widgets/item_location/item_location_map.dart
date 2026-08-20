import 'package:eClassify/ui/screens/google_map_screen.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/location_map/location_map_controller.dart';
import 'package:eClassify/ui/screens/widgets/location_map/location_map_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ItemLocationMap extends StatefulWidget {
  const ItemLocationMap({this.latitude, this.longitude, super.key});

  final double? latitude;
  final double? longitude;

  @override
  State<ItemLocationMap> createState() => _ItemLocationMapState();
}

class _ItemLocationMapState extends State<ItemLocationMap> {
  late final _locationController = LocationMapController(
    initialCoordinates: coordinatesAvailable
        ? LatLng(widget.latitude!, widget.longitude!)
        : null,
  );

  final ValueNotifier<bool> _showMap = ValueNotifier(false);

  bool get coordinatesAvailable =>
      widget.latitude != null && widget.longitude != null;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (mounted) {
          _showMap.value = true;
        }
      },
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _showMap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!coordinatesAvailable) return const SizedBox.shrink();
    final shouldShowGoogleMap = Constant.showGoogleMap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text('location'.translate(context), style: context.titleMedium.bold),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ValueListenableBuilder(
                    valueListenable: _showMap,
                    builder: (context, value, child) {
                      return AnimatedSwitcher(
                        switchInCurve: Curves.easeInOutCubic,
                        duration: const Duration(milliseconds: 300),
                        child: value && shouldShowGoogleMap
                            ? LocationMapWidget(
                                key: ValueKey('map'),
                                controller: _locationController,
                                showMyLocationButton: false,
                                showMarker: false,
                                interactive: false,
                              )
                            : CustomImage(
                                key: ValueKey('image'),
                                src: 'assets/map/map.png',
                                fit: BoxFit.cover,
                                size: context.sizeFromAspectRatio(16 / 9),
                              ),
                      );
                    },
                  ),
                ),
                if (!shouldShowGoogleMap)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        'viewMap'.translate(context),
                        style: context.labelMedium.withColor(
                          context.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          barrierDismissible: true,
                          builder: (context) {
                            return GoogleMapScreen(
                              controller: _locationController,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
