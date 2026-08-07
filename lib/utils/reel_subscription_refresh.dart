import 'dart:async';

import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/reel_subscription_access.dart';
import 'package:flutter/foundation.dart';

/// Hooks subscription checkout → reel gate cache refresh.
abstract final class ReelSubscriptionRefresh {
  /// Bumped after checkout; [ActivePlanScreen] refetches active packages.
  static final ValueNotifier<int> activePlansRevision = ValueNotifier(0);

  static void afterPackagePurchase() {
    if (!AppConfig.enableReelSubscriptionRefreshAfterPurchaseV214) {
      return;
    }
    ReelSubscriptionAccess.invalidateCache();
    if (AppConfig.enableReelSubscriptionPrefetchAfterPurchaseV214) {
      unawaited(
        ReelSubscriptionAccess.canUseReelFeatures(forceRefresh: true),
      );
    }
    if (AppConfig.enableActivePlanRefreshAfterPurchaseV214) {
      activePlansRevision.value++;
    }
  }
}
