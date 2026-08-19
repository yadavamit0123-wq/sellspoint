import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/cubits/item/manage_item_cubit.dart';
import 'package:eClassify/data/cubits/location/location_search_cubit.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/screens/location/widgets/place_api_search_bar.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:eClassify/ui/screens/widgets/location_map/location_map_controller.dart';
import 'package:eClassify/ui/screens/widgets/location_map/location_map_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionStep extends StatefulWidget {
  const LocationSelectionStep({super.key});

  @override
  State<LocationSelectionStep> createState() => _LocationSelectionStepState();
}

class _LocationSelectionStepState extends State<LocationSelectionStep> {
  late LeafLocation _location;

  late final LocationMapController _controller;
  late final TextEditingController? _searchController;

  final bool isPaidApi = Constant.systemSettings.mapProvider != 'free_api';

  @override
  void initState() {
    super.initState();
    final data = context
        .read<AdPostingCubit>()
        .state
        .adPostingData;
    _location =
        data.location ?? AppSession.currentLocation ?? LeafLocation.global();
    _controller = LocationMapController(
      initialLocation: _location,
      shouldFetchInitialLocation: _location.isEmpty,
      initialCoordinates: LatLng(
        _location.latitude ?? AppConfig.defaultLatitude,
        _location.longitude ?? AppConfig.defaultLongitude,
      ),
    );
    _controller.addListener(() {
      _location = _controller.data.location;
      // To store the location in the state to pre-fill when going back and forth
      if (_location.isValid) {
        context.read<AdPostingCubit>().updateData(
              (data) => data.copyWith(location: _location),
        );
      }
    });

    if (isPaidApi) {
      _searchController = TextEditingController();
    } else {
      _searchController = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AdPostingStepController.of(context).register(
      onPrevious: _onPrevious,
      onSubmit: _onSubmit,
    );
  }

  void _onPrevious() {
    context.read<AdPostingCubit>().previousStep();
  }

  void _onSubmit() {
    if (!_location.isValid) {
      HelperUtils.showSnackBarMessage(context, 'Invalid Location');
      return;
    }
    context.read<AdPostingCubit>().updateData(
          (data) => data.copyWith(location: _location),
    );
    final data = context
        .read<AdPostingCubit>()
        .state
        .adPostingData;
    context.read<ManageItemCubit>().createItem(data: data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              LocationMapWidget(controller: _controller, showCircleArea: false),
              if (isPaidApi)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  child: PlaceApiSearchBar(
                    controller: _searchController!,
                    searchOnly: true,
                    onLocationSelected: (value) {
                      context.read<LocationSearchCubit>().selectLocation(
                        placeId: value.location.placeId!,
                        sessionToken: value.sessionToken,
                      );
                    },
                  ),
                ),
              if (isPaidApi)
                Positioned.fill(
                  child: BlocConsumer<LocationSearchCubit, LocationSearchState>(
                    listener: (context, state) {
                      if (state is LocationSearchSelected) {
                        _controller.updateLocation(state.location);
                        _searchController?.clear();
                      }
                    },
                    builder: (context, state) {
                      if (state is LocationSearchSelecting) {
                        return const ColoredBox(
                          color: Colors.black12,
                          child: Center(child: LoadingIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 50),
          child: ColoredBox(
            color: context.colorScheme.secondary,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constant.horizontalPadding,
                vertical: 8,
              ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(AppIcons.mapPin, color: context.colorScheme.primary),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_location.primaryText.isNotNullAndNotEmpty)
                              Text(
                                _location.primaryText!,
                                style: context.labelLarge,
                                maxLines: 1,
                              ),
                            if (_location.secondaryText.isNotNullAndNotEmpty)
                              Text(
                                _location.secondaryText!,
                                style: context.labelSmall.withColor(
                                  context.mutedColor,
                                ),
                                maxLines: 1,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (!isPaidApi)
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colorScheme.primary.withValues(
                          alpha: .1,
                        ),
                        foregroundColor: context.colorScheme.primary,
                      ),
                      onPressed: () async {
                        final location =
                        await Navigator.of(context).pushNamed(
                          Routes.locationScreen,
                          arguments: {'requires_exact_location': true},
                        )
                        as LeafLocation?;
                        if (location == null) return;
                        _controller.updateLocation(location);
                      },
                      child: Text('change'.translate(context)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
