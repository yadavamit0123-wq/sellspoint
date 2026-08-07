import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/main_activity.dart';
import 'package:eClassify/utils/reel_deep_link_intent.dart';
import 'package:eClassify/utils/main_navigation_v214.dart';
import 'package:eClassify/utils/chat_navigation.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';

/// Central navigation for push notification payloads (FCM + cold start).
abstract final class NotificationDeepLinkNavigation {
  static Future<void> openFromData(
    BuildContext context,
    Map<String, dynamic> data, {
    bool awesomePayloadKeys = false,
  }) async {
    final type = data['type']?.toString() ?? '';

    if (type == 'chat') {
      if (awesomePayloadKeys) {
        ChatNavigation.openFromAwesomePayload(context, data);
      } else {
        ChatNavigation.openFromFirebasePayload(context, data);
      }
      return;
    }

    if (type == 'offer') {
      if (!HiveUtils.isUserAuthenticated()) {
        HelperUtils.goToNextPage(Routes.notificationPage, context, false);
        return;
      }
      if (awesomePayloadKeys) {
        ChatNavigation.openFromAwesomePayload(context, data);
      } else {
        ChatNavigation.openFromFirebasePayload(context, data);
      }
      return;
    }

    if (type == 'item-update') {
      HelperUtils.goToNextPage(Routes.main, context, false);
      MainNavigationV214.openMyAdsTab();
      return;
    }

    if (AppConfig.enableReelNotificationDeepLinkV214 &&
        _isReelNotification(type)) {
      await _openReelsFeed(context, data);
      return;
    }

    final itemIdRaw = data['item_id'];
    if (itemIdRaw != null && itemIdRaw.toString().isNotEmpty) {
      final id = int.tryParse(itemIdRaw.toString());
      if (id != null) {
        final item = await ItemRepository().fetchItemFromItemId(id);
        if (!context.mounted) return;
        await Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {'model': item.modelList.first},
        );
        return;
      }
    }

    if (type == 'payment') {
      if (HiveUtils.isUserAuthenticated()) {
        await Navigator.pushNamed(
          context,
          Routes.subscriptionPackageListRoute,
        );
      } else {
        HelperUtils.goToNextPage(Routes.notificationPage, context, false);
      }
      return;
    }

    HelperUtils.goToNextPage(Routes.notificationPage, context, false);
  }

  static bool _isReelNotification(String type) {
    switch (type) {
      case 'reel':
      case 'reel-ready':
      case 'reel-upload':
      case 'reel-uploaded':
      case 'video-reel':
        return true;
      default:
        return false;
    }
  }

  static Future<void> _openReelsFeed(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final reelId = int.tryParse(
      data['reel_id']?.toString() ?? data['reelId']?.toString() ?? '',
    );
    final itemId = int.tryParse(data['item_id']?.toString() ?? '');

    if (MainNavigationV214.usesFiveTabs) {
      ReelDeepLinkIntent.set(reelId: reelId, itemId: itemId);
      HelperUtils.goToNextPage(Routes.main, context, false);
      MainActivity.globalKey.currentState?.applyReelsDeepLink();
      return;
    }

    if (!context.mounted) return;
    await Navigator.pushNamed(
      context,
      Routes.videoAdsScreen,
      arguments: {
        if (reelId != null) 'reel_id': reelId,
        if (itemId != null) 'item_id': itemId,
      },
    );
  }
}
