import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_keys.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/location_picker_launcher.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  static String _locationLine(LeafLocation location) {
    final parts = [
      location.area,
      location.city,
      location.state,
      location.country,
    ].where((e) => e != null && e.isNotEmpty).map((e) => e!);
    if (parts.isEmpty) return '------';
    return parts.join(', ');
  }

  static String _legacyHiveLine() {
    final parts = [
      HiveUtils.getAreaName(),
      HiveUtils.getCityName(),
      HiveUtils.getStateName(),
      HiveUtils.getCountryName(),
    ].where((e) => e != null && e.isNotEmpty).map((e) => e!);
    if (parts.isEmpty) return '------';
    return parts.join(', ');
  }

  Widget _locationTexts(BuildContext context, String line) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'locationLbl'.translate(context),
          color: context.color.textColorDark,
          fontSize: context.font.small,
        ),
        CustomText(
          line,
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          color: context.color.textColorDark,
          fontSize: context.font.small,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.none,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => LocationPickerLauncher.open(context, from: 'home'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: UiUtils.getSvg(
                AppIcons.location,
                fit: BoxFit.none,
                color: context.color.territoryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (AppConfig.enableLocationScreenV214)
            BlocBuilder<LeafLocationCubit, LeafLocation>(
              builder: (context, location) =>
                  _locationTexts(context, _locationLine(location)),
            )
          else
            ValueListenableBuilder(
              valueListenable:
                  Hive.box(HiveKeys.userDetailsBox).listenable(),
              builder: (context, value, child) =>
                  _locationTexts(context, _legacyHiveLine()),
            ),
        ],
      ),
    );
  }
}
