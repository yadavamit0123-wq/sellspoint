import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/reel_subscription_refresh.dart';
import 'package:flutter/foundation.dart';

/// My Ads tab list refetch (repeat tab tap).
abstract final class MyAdsRefresh {
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static void onRepeatTap() {
    if (!AppConfig.enableMyAdsTabRepeatTapRefreshV214) {
      return;
    }
    ReelSubscriptionRefresh.onMyAdsTabVisible();
    revision.value++;
  }
}
