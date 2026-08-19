import 'package:eClassify/ui/screens/widgets/app_dialog.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/color_mappers/primary_color_mapper.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required LocationPermission permission,
    required bool isLocationServiceEnabled,
  }) async {
    LoadingOverlay.hide();

    if (permission == LocationPermission.denied) {
      _showPermissionDeniedMessage(context);
    } else if (permission == LocationPermission.deniedForever) {
      return await _showPermissionDeniedForeverDialog(context);
    } else if (!isLocationServiceEnabled) {
      return await _showLocationServiceDisabledDialog(context);
    }

    return null;
  }

  static Future<bool?> _showPermissionDeniedForeverDialog(
    BuildContext context,
  ) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          icon: CustomImage(
            src: AppAssets.illustrators.locationDenied,
            svgColorMapper: PrimaryColorMapper(context.colorScheme.primary),
          ),
          title: Text(
            'locationPermissionDenied'.translate(context),
            style: context.titleLarge,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'weNeedLocationAvailableLbl'.translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          positiveButtonLabel: 'settingsLbl'.translate(context),
          onPositiveTapped: () async {
            Geolocator.openAppSettings();
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }

  static void _showPermissionDeniedMessage(BuildContext context) {
    HelperUtils.showSnackBarMessage(
      context,
      'locationPermissionDenied'.translate(context),
    );
  }

  static Future<bool?> _showLocationServiceDisabledDialog(
    BuildContext context,
  ) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          icon: CustomImage(
            src: AppAssets.illustrators.locationDenied,
            svgColorMapper: PrimaryColorMapper(context.colorScheme.primary),
          ),
          title: Text(
            'locationServiceDisabled'.translate(context),
            style: context.titleLarge,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'pleaseEnableLocationServicesManually'.translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          positiveButtonLabel: 'settingsLbl'.translate(context),
          onPositiveTapped: () async {
            Geolocator.openLocationSettings();
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }
}
