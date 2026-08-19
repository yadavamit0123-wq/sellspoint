import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';

class AppNavigatorObserver extends NavigatorObserver {
  List<String?> routeStack = [];

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeStack.remove(route.settings.name);
    Log.info(
      'Popping Route: ${route.settings.name} with result ${route.currentResult}',
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    routeStack.add(route.settings.name);
    Log.info(
      'Pushing Route: ${route.settings.name}  with arguments ${route.settings.arguments}',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    routeStack.remove(route.settings.name);
    Log.info('Removing Route: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final index = oldRoute != null
        ? routeStack.indexOf(oldRoute.settings.name)
        : -1;
    if (index != -1 && newRoute != null) {
      routeStack[index] = newRoute.settings.name;
    }
    Log.info('Replacing Route: ${newRoute?.settings.name}');
  }
}
