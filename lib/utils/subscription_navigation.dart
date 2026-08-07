import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:flutter/material.dart';

/// Entry points for 2.14 subscription routes vs legacy package list.
abstract final class SubscriptionNavigation {
  static void openPackageCatalog(BuildContext context) {
    if (AppConfig.enableSubscriptionFlowV214) {
      Navigator.pushNamed(context, Routes.subscriptionCategorySelectionScreen);
      return;
    }
    Navigator.pushNamed(context, Routes.subscriptionPackageListRoute);
  }

  static void openPackagesForCategory(
    BuildContext context, {
    int? categoryId,
    String? categoryName,
  }) {
    Navigator.pushNamed(
      context,
      Routes.subscriptionPackageScreen,
      arguments: {
        'categoryId': categoryId,
        'categoryName': categoryName,
      },
    );
  }

  static void openActivePlans(BuildContext context) {
    Navigator.pushNamed(context, Routes.activePlanScreen);
  }
}
