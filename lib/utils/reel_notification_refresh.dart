import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/my_ads_refresh.dart';
import 'package:eClassify/utils/reel_feed_refresh.dart';

/// List refresh hooks for reel-related notifications / uploads.
abstract final class ReelNotificationRefresh {
  static void afterReelDeepLinkHandled() {
    if (!AppConfig.enableReelNotificationRefreshListsV214) {
      return;
    }
    MyAdsRefresh.revision.value++;
    ReelFeedRefresh.revision.value++;
  }
}
