import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';

class AppNavigatorObserver extends NavigatorObserver {
  final List<String?> routeStack = [];

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeStack.remove(route.settings.name);
    Log.info('Pop route: ${route.settings.name}');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    routeStack.add(route.settings.name);
    Log.info('Push route: ${route.settings.name}');
  }
}
