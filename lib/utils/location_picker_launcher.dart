import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens the location picker (2.14 [Routes.locationScreen] or legacy countries list).
abstract final class LocationPickerLauncher {
  static Future<Object?> open(
    BuildContext context, {
    String from = 'home',
    bool requiresExactLocation = false,
  }) async {
    final Object? result;
    if (AppConfig.enableLocationScreenV214) {
      result = await Navigator.pushNamed(
        context,
        Routes.locationScreen,
        arguments: {
          'from': from,
          'requires_exact_location': requiresExactLocation,
        },
      );
    } else {
      result = await Navigator.pushNamed(
        context,
        Routes.countriesScreen,
        arguments: {'from': from},
      );
    }
    if (!context.mounted) return result;
    context.read<LeafLocationCubit>().syncFromLegacyHive();
    return result;
  }
}
