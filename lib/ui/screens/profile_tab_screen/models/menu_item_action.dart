import 'package:eClassify/utils/tap_guard.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class MenuItemAction {
  const MenuItemAction({this.guarded = false});

  final bool guarded;

  Future<void> execute(BuildContext context);

  Future<void> runGuarded(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    if (guarded) {
      UiUtils.checkUser(context: context, onNotGuest: action);
    } else {
      await action();
    }
  }
}

class ScreenPushAction extends MenuItemAction {
  ScreenPushAction({
    required this.route,
    this.args,
    super.guarded,
  });

  final String route;
  final dynamic args;

  @override
  Future<void> execute(BuildContext context) {
    return runGuarded(context, () async {
      await Navigator.pushNamed(context, route, arguments: args);
    });
  }
}

class CustomAction extends MenuItemAction {
  CustomAction({
    required this.onTap,
    super.guarded,
  });

  final AsyncCallback onTap;
  final TapGuard _tapGuard = TapGuard();

  @override
  Future<void> execute(BuildContext context) {
    return runGuarded(context, () => _tapGuard.run(onTap));
  }
}
