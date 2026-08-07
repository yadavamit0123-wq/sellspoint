import 'package:eClassify/ui/screens/subscription/packages_list.dart';
import 'package:flutter/material.dart';

/// 2.14 route name; delegates to [SubscriptionPackageListScreen] with category scope.
class SubscriptionPackageScreen {
  static Route route(RouteSettings routeSettings) {
    return SubscriptionPackageListScreen.route(routeSettings);
  }
}
