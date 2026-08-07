import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/reel_subscription_access.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

abstract final class ReelFeatureGate {
  static Future<bool> ensureAllowed(BuildContext context) async {
    if (!AppConfig.enableReelSubscriptionGateV214) {
      return true;
    }
    final allowed = await ReelSubscriptionAccess.canUseReelFeatures();
    if (!context.mounted) return false;
    if (!allowed) {
      UiUtils.showSnackBarMessage(
        context,
        'reelNotIncludedInPlan'.translate(context),
      );
      return false;
    }
    return true;
  }
}
