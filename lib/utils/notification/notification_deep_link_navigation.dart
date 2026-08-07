import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/main_activity.dart';
import 'package:eClassify/utils/notification/reel_notification_payload.dart';
import 'package:eClassify/utils/notification/subscription_notification_payload.dart';
import 'package:eClassify/utils/reel_deep_link_intent.dart';
import 'package:eClassify/utils/reel_notification_refresh.dart';
import 'package:eClassify/utils/main_navigation_v214.dart';
import 'package:eClassify/utils/subscription_navigation.dart';
import 'package:eClassify/utils/chat_navigation.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';

/// Central navigation for push notification payloads (FCM + cold start).
///
/// Reel-related `type` values and keys: [ReelNotificationPayload].
abstract final class NotificationDeepLinkNavigation {
  static bool _notificationWantsAdDetails(Map<String, dynamic> data) {
    final nav = data['navigate']?.toString() ?? data['destination']?.toString();
    return nav == 'ad_details' || nav == 'adDetails';
  }

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
      if (AppConfig.enableItemUpdateNotificationRefreshV214) {
        ReelNotificationRefresh.afterReelDeepLinkHandled();
      }
      return;
    }

    if (AppConfig.enableReelUploadFailedNotificationV214 &&
        ReelNotificationPayload.isReelUploadFailedType(type)) {
      await _openReelUploadFailed(context, data);
      ReelNotificationRefresh.afterReelDeepLinkHandled();
      return;
    }

    if (AppConfig.enableReelUploadProgressNotificationV214 &&
        ReelNotificationPayload.isReelUploadProgressType(type)) {
      await _openReelUploadProgress(context, data);
      ReelNotificationRefresh.afterReelDeepLinkHandled();
      return;
    }

    if (AppConfig.enableReelNotificationDestinationAdDetailsV214 &&
        _notificationWantsAdDetails(data) &&
        AppConfig.enableReelNotificationDeepLinkV214 &&
        ReelNotificationPayload.isReelsTabType(type)) {
      await _openOwnerAdDetailsForItemNotification(context, data);
      ReelNotificationRefresh.afterReelDeepLinkHandled();
      return;
    }

    if (AppConfig.enableReelNotificationDeepLinkV214 &&
        ReelNotificationPayload.isReelsTabType(type)) {
      await _openReelsFeed(context, data);
      ReelNotificationRefresh.afterReelDeepLinkHandled();
      return;
    }

    if (AppConfig.enableSubscriptionNotificationDeepLinkV214 &&
        SubscriptionNotificationPayload.isSubscriptionType(type)) {
      if (HiveUtils.isUserAuthenticated()) {
        if (AppConfig.enableSubscriptionExpiredActivePlansDeepLinkV214 &&
            type == 'package-expired') {
          SubscriptionNavigation.openActivePlans(context);
        } else {
          SubscriptionNavigation.openPrimaryAdListingCatalog(context);
        }
      } else {
        HelperUtils.goToNextPage(Routes.notificationPage, context, false);
      }
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
        if (AppConfig.enableSubscriptionFlowV214) {
          SubscriptionNavigation.openPrimaryAdListingCatalog(context);
        } else {
          await Navigator.pushNamed(
            context,
            Routes.subscriptionPackageListRoute,
          );
        }
      } else {
        HelperUtils.goToNextPage(Routes.notificationPage, context, false);
      }
      return;
    }

    if (AppConfig.enablePaymentSuccessActivePlansDeepLinkV214 &&
        type == 'payment-success') {
      if (HiveUtils.isUserAuthenticated()) {
        SubscriptionNavigation.openActivePlans(context);
      } else {
        HelperUtils.goToNextPage(Routes.notificationPage, context, false);
      }
      return;
    }

    HelperUtils.goToNextPage(Routes.notificationPage, context, false);
  }

  static Future<void> _openReelsFeed(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final reelId = int.tryParse(
      data[ReelNotificationPayload.reelIdKey]?.toString() ??
          data[ReelNotificationPayload.reelIdAltKey]?.toString() ??
          '',
    );
    final itemId = int.tryParse(
      data[ReelNotificationPayload.itemIdKey]?.toString() ?? '',
    );

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

  static Future<void> _openReelUploadFailed(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    await _openOwnerAdDetailsForItemNotification(context, data);
  }

  static Future<void> _openReelUploadProgress(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    await _openOwnerAdDetailsForItemNotification(context, data);
  }

  static Future<void> _openOwnerAdDetailsForItemNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    if (!HiveUtils.isUserAuthenticated()) {
      HelperUtils.goToNextPage(Routes.notificationPage, context, false);
      return;
    }

    final itemId = int.tryParse(
      data[ReelNotificationPayload.itemIdKey]?.toString() ?? '',
    );
    if (itemId == null) {
      HelperUtils.goToNextPage(Routes.main, context, false);
      MainNavigationV214.openMyAdsTab();
      return;
    }

    try {
      final item = await ItemRepository().fetchItemFromItemId(itemId);
      if (!context.mounted) return;
      HelperUtils.goToNextPage(Routes.main, context, false);
      await Navigator.pushNamed(
        context,
        Routes.adDetailsScreen,
        arguments: {'model': item.modelList.first},
      );
    } catch (_) {
      if (!context.mounted) return;
      HelperUtils.goToNextPage(Routes.main, context, false);
      MainNavigationV214.openMyAdsTab();
    }
  }
}
