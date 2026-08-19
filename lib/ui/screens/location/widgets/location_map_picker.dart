import 'dart:math';

import 'package:eClassify/data/cubits/location/location_search_cubit.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/ui/screens/location/widgets/place_api_search_bar.dart';
import 'package:eClassify/ui/screens/widgets/location_map/location_map_controller.dart';
import 'package:eClassify/ui/screens/widgets/location_map/location_map_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationMapPicker extends StatefulWidget {
  const LocationMapPicker({this.enableSearchBar = true, super.key});

  final bool enableSearchBar;

  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider.value(
        value: args['search_cubit'] as LocationSearchCubit,
        child: LocationMapPicker(
          enableSearchBar: args['enable_search_bar'] as bool? ?? true,
        ),
      ),
    );
  }
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  final minRadius = Constant.systemSettings.minRadius.toDouble();
  final maxRadius = Constant.systemSettings.maxRadius.toDouble();

  final LocationMapController _controller = LocationMapController(
    autoZoom: true,
  );
  final TextEditingController _searchController = TextEditingController();
  late final ValueNotifier<double> _radiusNotifier = ValueNotifier(minRadius);

  bool get _hasValidRadiusRange => minRadius < maxRadius;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // Set the persisted radius from Hive once the controller is ready.
      //
      // If the current radius equals [minRadius], update it with the
      // controller's latest radius value (usually restored from persistence).
      if (_radiusNotifier.value == minRadius) {
        _radiusNotifier.value = max(_controller.radius.toDouble(), minRadius);
      }

      // Update the search bar text with the currently selected location.
      //
      // Triggered when the user taps on the map and the controller is ready.
      // Falls back to displaying "Global" if no location is selected.
      if (_controller.isReady) {
        final location = _controller.data.location;
        _searchController.text = location.isEmpty
            ? 'searchCity'.translate(context)
            : location.localizedPath;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _radiusNotifier.dispose();
    super.dispose();
  }

  Widget _radiusSelector() {
    return ValueListenableBuilder(
      valueListenable: _radiusNotifier,
      builder: (context, value, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  'selectAreaRange'.translate(context),
                  color: context.color.textDefaultColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                CustomText(
                  '${value.toInt()} ${"km".translate(context)}',
                  color: context.color.textDefaultColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            20.vGap,
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 10,
                activeTrackColor: context.color.territoryColor,
                inactiveTrackColor: context.color.territoryColor.withValues(
                  alpha: .2,
                ),
                thumbColor: context.color.territoryColor,
                padding: EdgeInsets.zero,
                showValueIndicator: ShowValueIndicator.never,
              ),
              child: Slider(
                value: value,
                min: minRadius.toDouble(),
                max: maxRadius.toDouble(),
                divisions: (maxRadius - minRadius).toInt(),
                onChanged: (value) =>
                    _radiusNotifier.value = value.roundToDouble(),
                onChangeEnd: _controller.updateRadius,
                label: '${value.toInt()}',
              ),
            ),
            5.vGap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  '${minRadius.toInt()}\t${"km".translate(context)}',
                  color: context.color.textDefaultColor,
                  fontWeight: FontWeight.w500,
                ),
                CustomText(
                  '${maxRadius.toInt()}\t${"km".translate(context)}',
                  color: context.color.textDefaultColor,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: CustomText('nearbyListings'.translate(context)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: PlaceApiSearchBar(
            enabled: widget.enableSearchBar,
            controller: _searchController,
            onLocationSelected: (value) {
              _searchController.text = value.location.localizedPath;
              context.read<LocationSearchCubit>().selectLocation(
                placeId: value.location.placeId!,
                sessionToken: value.sessionToken,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.color.territoryColor,
            ),
            onPressed: () {
              Navigator.of(context).pop(LeafLocation.global());
            },
            child: Text('reset'.translate(context)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: Constant.safeAreaMinimumPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            if (_hasValidRadiusRange) _radiusSelector(),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: Size.fromHeight(48)),
              onPressed: () {
                Navigator.of(context).pop(_controller.data.location);
              },
              child: Text('apply'.translate(context)),
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: LocationMapWidget(controller: _controller)),
          BlocConsumer<LocationSearchCubit, LocationSearchState>(
            listener: (context, state) {
              if (state is LocationSearchSelected) {
                _controller.updateLocation(state.location);
              }
            },
            builder: (context, state) {
              if (state is LocationSearchSelecting) {
                return ColoredBox(
                  color: Colors.black12,
                  child: Center(child: UiUtils.progress()),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
