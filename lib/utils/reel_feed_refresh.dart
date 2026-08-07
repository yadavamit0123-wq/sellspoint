import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/reel_subscription_refresh.dart';
import 'package:flutter/foundation.dart';

/// Reels tab feed reload (repeat tab tap / gate refresh).
abstract final class ReelFeedRefresh {
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static void onReelsTabRepeatTap() {
    if (!AppConfig.enableReelsTabRepeatTapRefreshV214) {
      return;
    }
    ReelSubscriptionRefresh.onReelsTabVisible();
    revision.value++;
  }
}
