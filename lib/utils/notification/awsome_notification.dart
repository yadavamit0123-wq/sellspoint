// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eClassify/utils/notification/notification_deep_link_navigation.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/notification/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class LocalAwesomeNotification {
  AwesomeNotifications notification = AwesomeNotifications();

  void init(BuildContext context) {
    requestPermission();

    notification.initialize(
        'resource://mipmap/notification',
        [
          NotificationChannel(
              channelKey: Constant.notificationChannel,
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel',
              importance: NotificationImportance.Max,
              ledColor: Colors.grey),
          NotificationChannel(
              channelKey: "Chat Notification",
              channelName: 'Chat Notifications',
              channelDescription: 'Chat Notifications',
              importance: NotificationImportance.Max,
              ledColor: Colors.grey)
        ],
        channelGroups: [],
        debug: true);
    listenTap(context);
  }

  void listenTap(BuildContext context) {
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    );
  }

  void createNotification({
    required RemoteMessage notificationData,
    required bool isLocked,
  }) async {
    try {
      bool isChat = notificationData.data["type"] == "chat";
      bool hasImage = notificationData.data["image"] != null ||
          notificationData.data["image"] != "";

      if (isChat) {
        int chatId = int.parse(notificationData.data['sender_id']) +
            int.parse(notificationData.data['item_id']);

        if (Platform.isAndroid) {
          await notification.createNotification(
            content: NotificationContent(
              id: isChat ? chatId : Random().nextInt(5000),
              title: notificationData.data["title"],
              // icon: AppIcons.aboutUs,
              hideLargeIconOnExpand: true,
              summary: "${notificationData.data['user_name']}",
              locked: isLocked,
              payload: Map.from(notificationData.data),
              autoDismissible: true,

              body: notificationData.data["body"],
              wakeUpScreen: true,

              notificationLayout: NotificationLayout.MessagingGroup,
              groupKey: notificationData.data["id"],
              channelKey: "Chat Notification",
            ),
          );
        }
      } else {
        if (hasImage) {
          String? imageUrl = notificationData.data["image"];

          if (Platform.isAndroid) {
            await notification.createNotification(
              content: NotificationContent(
                id: Random().nextInt(5000),
                title: notificationData.data["title"],
                bigPicture: imageUrl,
                hideLargeIconOnExpand: true,
                summary: null,
                locked: isLocked,
                payload: Map.from(notificationData.data),
                autoDismissible: true,
                body: notificationData.data["body"],
                wakeUpScreen: true,
                notificationLayout: NotificationLayout.BigPicture,
                groupKey: notificationData.data["item_id"],
                channelKey: Constant.notificationChannel,
              ),
            );
          }
        } else {
          if (Platform.isAndroid) {
            await notification.createNotification(
              content: NotificationContent(
                id: Random().nextInt(5000),
                title: notificationData.data["title"],
                hideLargeIconOnExpand: true,
                summary: null,
                locked: isLocked,
                payload: Map.from(notificationData.data),
                autoDismissible: true,
                body: notificationData.data["body"],
                wakeUpScreen: true,
                notificationLayout: NotificationLayout.Default,
                groupKey: notificationData.data["item_id"],
                channelKey: Constant.notificationChannel,
              ),
            );
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPermission() async {
    final notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      final newSettings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (newSettings.authorizationStatus == AuthorizationStatus.authorized ||
          newSettings.authorizationStatus == AuthorizationStatus.provisional) {
        // Permission granted, handle notification setup here.
      } else if (newSettings.authorizationStatus ==
          AuthorizationStatus.denied) {
        // Permission denied, do nothing.
        return;
      }
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      // Permission was already denied, do nothing.
      return;
    }

    // If the permission is already granted, you can proceed with setting up notifications here.
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    Map<String, String?>? payload = receivedAction.payload;

    print('payload receive click***${payload.toString()}');
    Future.delayed(Duration.zero, () {
      final ctx = Constant.navigatorKey.currentContext;
      if (ctx == null) return;
      NotificationDeepLinkNavigation.openFromData(
        ctx,
        Map<String, dynamic>.from(payload ?? {}),
        awesomePayloadKeys: true,
      );
    });
  }
}
