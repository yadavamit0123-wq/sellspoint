// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_verification_request_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/model/chat/item_offer.dart';
import 'package:eClassify/data/services/chat/chat_event_bus.dart';
import 'package:eClassify/ui/screens/item/my_items_screen.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String currentlyChattingWith = "";
String currentlyChatItemId = "";

// Todo(I): Needs further improvements and refactoring
abstract class NotificationHandler {
  // These are side effects
  static void handleSideEffects(
    BuildContext context,
    NotificationType type,
    Map<String, dynamic> data,
  ) {
    log('Handle Side Effects: ${data}');
    if (!context.mounted) return;
    if (type == NotificationType.unknown) return;

    if (type case NotificationType.itemUpdate || NotificationType.itemEdit) {
      (context).read<FetchMyItemsCubit>().fetchMyItems(
        getItemsWithStatus: selectItemStatus,
      );
    }

    if (type case NotificationType.verificationStatus) {
      context.read<VerificationRequestCubit>().fetchVerificationRequest();
    }

    if (type case NotificationType.chat) {
      final itemId = int.tryParse(data['item_id'] ?? '');
      final offerId = int.tryParse(data['item_offer_id'] ?? '');
      final message = data['message'] ?? '';
      final time =
          DateTime.tryParse(data['updated_at'] ?? '') ?? DateTime.now();
      final isCurrentChat = AppSession.activeChatId == offerId;

      if (itemId == null || offerId == null) return;

      final chatMessage = ChatNotificationMessage(
        id: offerId,
        itemId: itemId,
        message: message,
        time: time,
        unreadCount: isCurrentChat ? 0 : 1,
      );

      final myUser = HiveUtils.getUserDetails();
      final chatUser = Chat.fromNotification(data, myId: myUser.id!);
      final isReceiverSeller =
          data['user_type'].toString().toLowerCase() == 'buyer';
      if (isReceiverSeller) {
        final itemOffer = ItemOffer.fromNotification(data);

        ChatEventBus.instance.emit(
          ChatEvent.messageReceived(
            message: chatMessage,
            itemOffer: itemOffer,
            chatUser: chatUser,
            isReceiverSeller: true,
          ),
        );
      } else {
        ChatEventBus.instance.emit(
          ChatEvent.messageReceived(
            message: chatMessage,
            chatUser: chatUser,
            isReceiverSeller: false,
          ),
        );
      }
    }

    if (type case NotificationType.offer) {
      final itemOffer = ItemOffer.fromNotification(data);
      context.read<SellerItemOffersCubit>().addOffer(itemOffer);
    }
  }

  static void handleNotification(
    BuildContext context,
    NotificationType type,
    Map<String, dynamic> data,
  ) {
    if (!context.mounted) return;
    print('Handling Notification: ${data}');
    if (type == NotificationType.unknown) return;
    if (type == NotificationType.chat) {
      final itemOfferId = int.parse(data['item_offer_id'].toString());
      final isCurrentChat = AppSession.activeChatId == itemOfferId;

      final myUser = HiveUtils.getUserDetails();
      // This block of code fixes the following bug:
      // When user already on the chat page and receive new messages and
      // tap the notification it opens new new window because of this multiple windows are open.
      // and that msg indicator is also not removed.
      //
      // Note: This bug is only present on iOS right now. On android, the notification
      // will not be shown when the chat is open.
      if (isCurrentChat) {
        ChatEventBus.instance.emit(
          ChatEvent.read(
            itemOfferId,
            itemId: int.tryParse(data['item_id'].toString()),
          ),
        );
        return;
      }

      // To check whether the current user is seller or not
      final bool isSeller =
          data['user_type'].toString().toLowerCase() != 'seller';

      if (isSeller) {
        context.read<SellerItemOffersCubit>().clearOfferUnreadCount(
          int.parse(data['item_id'].toString()),
        );
      }

      final chatUser = Chat.fromNotification(data, myId: myUser.id!);

      Navigator.of(context).pushNamed(
        Routes.chatScreen,
        arguments: {'chat_user': chatUser, 'is_seller': isSeller},
      );
    } else if (type == NotificationType.offer) {
      final itemId = int.parse(data['item_id'].toString());
      final itemOfferId = int.parse(data['item_offer_id'].toString());
      Navigator.of(context).pushNamed(
        Routes.sellerItemChatScreen,
        arguments: {'item_id': itemId, 'item_offer_id': itemOfferId},
      );
    } else if (type == NotificationType.itemUpdate) {
      context.read<BottomNavCubit>().changeTab(BottomTab.myAds);
    } else if (type == NotificationType.itemEdit) {
      var id = int.tryParse(data["item_id"]);
      if (id == null) return;
      Navigator.pushNamed(
        context,
        Routes.adDetailsScreen,
        arguments: {'item_id': id},
      );
    } else if (type == NotificationType.jobApplication) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(
          context,
          Routes.jobApplicationList,
          arguments: {'itemId': int.tryParse(data['item_id'] ?? '') ?? 0},
        );
      });
    } else if (type == NotificationType.applicationStatus) {
      Navigator.pushNamed(
        context,
        Routes.jobApplicationList,
        arguments: {'itemId': 0, 'isMyJobApplications': true},
      );
    } else if (type == NotificationType.payment) {
      if (HiveUtils.isUserAuthenticated()) {
        Navigator.pushNamed(context, Routes.activePlanScreen);
      }
    } else if (type == NotificationType.verificationStatus) {
      context.read<BottomNavCubit>().changeTab(BottomTab.profile);
    } else if (type == NotificationType.itemReview) {
      context.read<BottomNavCubit>().changeTab(BottomTab.profile);
      Navigator.pushNamed(context, Routes.myReviewsScreen);
    } else if (type == NotificationType.blog) {
      final blogId = int.tryParse(data['blog_id'].toString());
      if (blogId == null) return;
      Navigator.pushNamed(context, Routes.blogsScreen, arguments: blogId);
    } else if (data["item_id"] != null && data["item_id"] != '') {
      var id = int.tryParse(data["item_id"]);
      if (id == null) return;
      Navigator.pushNamed(
        context,
        Routes.adDetailsScreen,
        arguments: {'item_id': id},
      );
    } else {
      Navigator.pushNamed(
        context,
        Routes.notificationPage,
        arguments: {'notificationId': data['notification_id'] as String?},
      );
    }
  }
}
