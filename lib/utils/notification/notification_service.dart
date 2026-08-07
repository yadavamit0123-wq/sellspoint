// ignore_for_file: file_names

import 'dart:async';

import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_seller_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chat/send_message.dart';
import 'package:eClassify/utils/notification/notification_deep_link_navigation.dart';
import 'package:eClassify/data/model/chat/chat_message_modal.dart';
import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/ui/screens/chat/chat_audio/widgets/chat_widget.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/notification/awsome_notification.dart';
import 'package:eClassify/utils/notification/chat_message_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String currentlyChatingWith = "";
String currentlyChatItemId = "";

class NotificationService {
  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;

  static LocalAwesomeNotification localNotification =
      LocalAwesomeNotification();

  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;

  static double? getPrice(dynamic price) {
    if (price == null || price.toString().isEmpty) {
      return null;
    }
    if (price is String) {
      return double.tryParse(price);
    }
    if (price is int) {
      return price.toDouble();
    }
    if (price is double) {
      return price;
    }
    return null; // In case of unexpected types
  }

  static void handleNotification(RemoteMessage? message, bool isTerminated,
      [BuildContext? context]) {
    var notificationType = message?.data['type'] ?? "";

    print("@notificaiton data is ${message?.data}****${notificationType}");

    //When the app is terminated, the context will not be available so this will throw an error
    //when notification is received. Hence, isTerminated is used to determine if the app is in
    //background or foreground. If app is background, simply just show the notification without any process.
    if (notificationType == "chat" && !isTerminated) {
      var username = message?.data['user_name'];
      var itemImage = message?.data['item_image'];
      var itemName = message?.data['item_name'];
      var userProfile = message?.data['user_profile'];
      var senderId = message?.data['user_id'];
      var itemId = message?.data['item_id'];
      var date = message?.data['created_at'];
      var itemOfferId = message?.data['item_offer_id'];
      var itemPrice = message?.data['item_price'];
      var itemOfferPrice = message?.data['item_offer_amount'];
      var userType = message?.data['user_type'];

      ///Checking if this is user we are chatting with

      if (senderId == currentlyChatingWith && itemId == currentlyChatItemId) {
        ChatMessageModal chatMessageModel = ChatMessageModal(
            id: int.parse(message?.data['id']),
            updatedAt: message?.data['updated_at'],
            createdAt: message?.data['created_at'],
            itemId: int.parse(message?.data['item_id']),
            audio: message?.data['audio'],
            file: message?.data['file'],
            message: message?.data['message'],
            receiverId: int.parse(HiveUtils.getUserId().toString()),
            senderId: int.parse(message?.data['sender_id']));

        ChatMessageHandler.add(BlocProvider(
          create: (context) => SendMessageCubit(),
          child: ChatMessage(
            key: ValueKey(DateTime.now().toString().toString()),
            message: chatMessageModel.message,
            senderId: chatMessageModel.senderId!,
            createdAt: chatMessageModel.createdAt!,
            isSentNow: false,
            updatedAt: chatMessageModel.updatedAt!,
            audio: chatMessageModel.audio,
            file: chatMessageModel.file,
            itemOfferId: chatMessageModel.id!,
          ),
        ));

        totalMessageCount++;
      } else {
        if (userType == "Buyer") {
          (context as BuildContext)
              .read<GetSellerChatListCubit>()
              .addOrUpdateChat(ChatUser(
                  itemId: itemId is String ? int.parse(itemId) : itemId,
                  amount: getPrice(itemOfferPrice),
                  createdAt: date,
                  userBlocked: false,
                  id: int.parse(itemOfferId),
                  updatedAt: date,
                  item: Item(
                      id: int.parse(itemId),
                      price: getPrice((itemPrice)),
                      name: itemName,
                      image: itemImage),
                  buyerId: int.parse(senderId),
                  buyer: Buyer(
                      name: username,
                      profile: userProfile,
                      id: int.parse(senderId)),
                  unreadCount: 1));
        } else {
          (context as BuildContext)
              .read<GetBuyerChatListCubit>()
              .addOrUpdateChat(ChatUser(
                  itemId: itemId is String ? int.parse(itemId) : itemId,
                  userBlocked: false,
                  amount: getPrice(itemOfferPrice),
                  createdAt: date,
                  id: int.parse(itemOfferId),
                  sellerId: int.parse(senderId),
                  updatedAt: date,
                  item: Item(
                      id: int.parse(itemId),
                      price: getPrice((itemPrice)),
                      name: itemName,
                      image: itemImage),
                  seller: Seller(
                      name: username,
                      profile: userProfile,
                      id: int.parse(senderId)),
                  unreadCount: 1));
        }
        localNotification.createNotification(
          isLocked: false,
          notificationData: message!,
        );
      }
    } else {
      localNotification.createNotification(
        isLocked: false,
        notificationData: message!,
      );
    }
  }

  static void init(context) {
    registerListeners(context);
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('background');
    handleNotification(message, true);
  }

  static Future<void> foregroundNotificationHandler(
      BuildContext context) async {
    foregroundStream =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("foreground notification***${message.toString()}");
      handleNotification(message, false, context);
    });
  }

  static Future<void> terminatedStateNotificationHandler(
      BuildContext context) async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message == null) {
      return;
    }
    Future.delayed(Duration.zero, () {
      final ctx = Constant.navigatorKey.currentContext;
      if (ctx == null) return;
      NotificationDeepLinkNavigation.openFromData(
        ctx,
        Map<String, dynamic>.from(message.data),
      );
    });
  }

  static void onTapNotificationHandler(context) {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) async {
      print("message.data on tap***${message.data.toString()}");
      Future.delayed(Duration.zero, () {
        final ctx = Constant.navigatorKey.currentContext;
        if (ctx == null) return;
        NotificationDeepLinkNavigation.openFromData(
          ctx,
          Map<String, dynamic>.from(message.data),
        );
      });
    });
  }

  static Future<void> registerListeners(context) async {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    await foregroundNotificationHandler(context);
    await terminatedStateNotificationHandler(context);
    onTapNotificationHandler(context);
  }

  static void disposeListeners() {
    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
