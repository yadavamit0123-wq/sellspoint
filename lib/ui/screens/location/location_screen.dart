import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 2.14 location gateway — legacy country/state/city/nearby flows until map picker lands.
class LocationScreen extends StatefulWidget {
  const LocationScreen({
    super.key,
    required this.from,
    required this.requiresExactLocation,
  });

  final String from;
  final bool requiresExactLocation;

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => LocationScreen(
        from: args?['from']?.toString() ?? 'home',
        requiresExactLocation:
            args?['requires_exact_location'] as bool? ?? false,
      ),
    );
  }

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeafLocationCubit>().syncFromLegacyHive();
  }

  Future<void> _openLegacyListPicker() async {
    final value = await Navigator.pushNamed(
      context,
      Routes.countriesScreen,
      arguments: {'from': widget.from},
    );
    if (!mounted) return;
    context.read<LeafLocationCubit>().syncFromLegacyHive();
    if (value != null) {
      Navigator.pop(context, value);
    }
  }

  Future<void> _openNearbyPicker() async {
    final value = await Navigator.pushNamed(
      context,
      Routes.nearbyLocationScreen,
      arguments: {'from': widget.from},
    );
    if (!mounted) return;
    context.read<LeafLocationCubit>().syncFromLegacyHive();
    if (value != null) {
      Navigator.pop(context, value);
    }
  }

  Future<void> _openMapPicker() async {
    final value = await Navigator.pushNamed(
      context,
      Routes.locationMapPicker,
      arguments: {'from': widget.from},
    );
    if (!mounted) return;
    context.read<LeafLocationCubit>().syncFromLegacyHive();
    if (value != null) {
      Navigator.pop(context, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.secondaryColor,
      ),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: 'selectLocation'.translate(context),
        ),
        body: BlocBuilder<LeafLocationCubit, LeafLocation>(
          builder: (context, location) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _CurrentLocationCard(location: location),
                if (widget.requiresExactLocation) ...[
                  const SizedBox(height: 8),
                  CustomText(
                    'selectLocationWarning'.translate(context),
                    fontSize: context.font.small,
                    color: context.color.textLightColor,
                  ),
                ],
                const SizedBox(height: 20),
                _LocationActionTile(
                  icon: AppIcons.location,
                  title: 'chooseLocation'.translate(context),
                  subtitle: 'enterManually'.translate(context),
                  onTap: _openLegacyListPicker,
                ),
                const SizedBox(height: 12),
                _LocationActionTile(
                  icon: AppIcons.location,
                  title: 'useCurrentLocation'.translate(context),
                  subtitle: 'chooseNearbyPlaces'.translate(context),
                  onTap: _openNearbyPicker,
                ),
                if (AppConfig.enableLocationMapPickerV214) ...[
                  const SizedBox(height: 12),
                  _LocationActionTile(
                    icon: AppIcons.location,
                    title: 'pickOnMap'.translate(context),
                    subtitle: 'selectLocation'.translate(context),
                    onTap: _openMapPicker,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({required this.location});

  final LeafLocation location;

  @override
  Widget build(BuildContext context) {
    final primary = location.displayLabel.isNotEmpty
        ? location.displayLabel
        : '------';
    final secondary = location.secondaryText ??
        [
          location.area,
          location.city,
          location.state,
          location.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.color.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'locationLbl'.translate(context),
            fontSize: context.font.small,
            color: context.color.textLightColor,
          ),
          const SizedBox(height: 6),
          CustomText(
            primary,
            fontWeight: FontWeight.w600,
            fontSize: context.font.large,
            color: context.color.textDefaultColor,
          ),
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 4),
            CustomText(
              secondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              fontSize: context.font.small,
              color: context.color.textLightColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationActionTile extends StatelessWidget {
  const _LocationActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.secondaryColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.color.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: UiUtils.getSvg(
                    icon,
                    color: context.color.territoryColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      fontWeight: FontWeight.w600,
                      color: context.color.textDefaultColor,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      fontSize: context.font.small,
                      color: context.color.textLightColor,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.color.textLightColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
