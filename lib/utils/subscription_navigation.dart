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

  /// Item listing packages; reel-capable plans sorted first when [highlightReelPlans].
  static void openItemListingPackagesForReels(BuildContext context) {
    const args = {'highlightReelPlans': true};
    if (AppConfig.enableSubscriptionFlowV214) {
      Navigator.pushNamed(
        context,
        Routes.subscriptionPackageScreen,
        arguments: args,
      );
      return;
    }
    Navigator.pushNamed(
      context,
      Routes.subscriptionPackageListRoute,
      arguments: args,
    );
  }

  /// Global ad listing packages (all plans, not reel-filtered).
  static void openItemListingPackages(BuildContext context) {
    if (AppConfig.enableSubscriptionFlowV214) {
      Navigator.pushNamed(context, Routes.subscriptionPackageScreen);
      return;
    }
    Navigator.pushNamed(context, Routes.subscriptionPackageListRoute);
  }

  /// Default “browse plans” entry (hub vs direct listing catalog).
  static void openPrimaryAdListingCatalog(BuildContext context) {
    if (AppConfig.enableSubscriptionPrimaryListingCatalogV214) {
      openItemListingPackages(context);
      return;
    }
    openPackageCatalog(context);
  }
}
