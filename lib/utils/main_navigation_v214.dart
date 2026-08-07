import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/main_activity.dart';
import 'package:eClassify/utils/reel_deep_link_intent.dart';
import 'package:flutter/material.dart';

/// Tab index helpers — legacy 4-tab vs 2.14 5-tab shell.
abstract final class MainNavigationV214 {
  static bool get usesFiveTabs => AppConfig.enableFiveTabNavV214;

  static int get myAdsTabIndex => usesFiveTabs ? 3 : 2;

  static int get chatTabIndex => 1;

  static int get homeTabIndex => 0;

  static void openMyAdsTab() {
    MainActivity.globalKey.currentState?.onItemTapped(myAdsTabIndex);
  }

  static int get videoAdsTabIndex => usesFiveTabs ? 2 : -1;

  static int get profileTabIndex => usesFiveTabs ? 4 : 3;

  static void openHomeTab() {
    MainActivity.globalKey.currentState?.onItemTapped(homeTabIndex);
  }

  static void openReelsTab({int? reelId, int? itemId}) {
    ReelDeepLinkIntent.set(reelId: reelId, itemId: itemId);
    if (usesFiveTabs) {
      MainActivity.globalKey.currentState?.applyReelsDeepLink();
      return;
    }
    final ctx = MainActivity.globalKey.currentContext;
    if (ctx == null) return;
    Navigator.pushNamed(
      ctx,
      Routes.videoAdsScreen,
      arguments: {
        if (reelId != null) 'reel_id': reelId,
        if (itemId != null) 'item_id': itemId,
      },
    );
  }
}
