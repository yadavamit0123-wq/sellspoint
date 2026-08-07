import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:flutter/material.dart';

/// Starts legacy post-ad flow or 2.14 [Routes.adPostingScreen] gateway.
abstract final class AdPostingLauncher {
  static void openCategoryStep(
    BuildContext context, {
    Map<String, dynamic>? arguments,
  }) {
    final args = arguments ?? <String, dynamic>{};
    if (AppConfig.enableAdPostingRouteV214) {
      Navigator.pushNamed(
        context,
        Routes.adPostingScreen,
        arguments: args,
      );
      return;
    }
    Navigator.pushNamed(context, Routes.selectCategoryScreen, arguments: args);
  }

  static void openSuccess(
    BuildContext context, {
    required dynamic model,
    required bool isEdit,
  }) {
    final args = {'model': model, 'isEdit': isEdit};
    if (AppConfig.enableAdPostingRouteV214) {
      Navigator.pushNamed(
        context,
        Routes.adPostingSuccessScreen,
        arguments: args,
      );
      return;
    }
    Navigator.pushNamed(context, Routes.successItemScreen, arguments: args);
  }
}
