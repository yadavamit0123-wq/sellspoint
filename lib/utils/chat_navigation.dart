import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/ui/screens/chat/chat_screen_route.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/notification/notification_service.dart';
import 'package:flutter/material.dart';

/// 2.14 chat route entry points — [Routes.chatScreen] / [Routes.sellerItemChatScreen].
abstract final class ChatNavigation {
  static void openChatUser(BuildContext context, ChatUser chatUser) {
    if (AppConfig.enableChatRoutesV214) {
      Navigator.pushNamed(
        context,
        Routes.chatScreen,
        arguments: {'chat_user': chatUser},
      );
      return;
    }
    Navigator.push(context, ChatScreenRoute.routeForChatUser(chatUser));
  }

  static void openFromTile(
    BuildContext context, {
    required String profilePicture,
    required String userName,
    required String itemPicture,
    required String itemName,
    required String itemId,
    required bool isBuyerList,
    required String id,
    required String date,
    required int itemOfferId,
    required double itemPrice,
    double? itemAmount,
    String? status,
    String? buyerId,
    required int isPurchased,
    required bool alreadyReview,
  }) {
    _openLegacy(
      context,
      _legacyParams(
        profilePicture: profilePicture,
        userName: userName,
        itemPicture: itemPicture,
        itemName: itemName,
        itemId: itemId,
        isBuyerList: isBuyerList,
        userId: id,
        date: date,
        itemOfferId: itemOfferId,
        itemPrice: itemPrice,
        itemAmount: itemAmount,
        status: status,
        buyerId: buyerId,
        isPurchased: isPurchased,
        alreadyReview: alreadyReview,
      ),
    );
  }

  static void openFromFirebasePayload(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    _openLegacy(context, _legacyFromFirebase(data));
  }

  static void openFromAwesomePayload(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    _openLegacy(context, _legacyFromAwesome(data));
  }

  static void openSellerItemChats(
    BuildContext context, {
    required int itemId,
    String? itemName,
  }) {
    Navigator.pushNamed(
      context,
      Routes.sellerItemChatScreen,
      arguments: {
        'item_id': itemId,
        if (itemName != null) 'item_name': itemName,
      },
    );
  }

  static void _openLegacy(
    BuildContext context,
    Map<String, dynamic> legacy,
  ) {
    if (legacy['buyerId'] == null || legacy['buyerId'].toString().isEmpty) {
      legacy['buyerId'] = HiveUtils.getUserId();
    }
    if (AppConfig.enableChatRoutesV214) {
      Navigator.pushNamed(
        context,
        Routes.chatScreen,
        arguments: {'legacy': legacy},
      );
      return;
    }
    Navigator.push(context, ChatScreenRoute.routeForLegacy(legacy));
  }

  static Map<String, dynamic> _legacyParams({
    required String profilePicture,
    required String userName,
    required String itemPicture,
    required String itemName,
    required String itemId,
    required bool isBuyerList,
    required String userId,
    required String date,
    required int itemOfferId,
    required double itemPrice,
    double? itemAmount,
    String? status,
    String? buyerId,
    required int isPurchased,
    required bool alreadyReview,
    String? from,
  }) {
    return {
      'profilePicture': profilePicture,
      'userName': userName,
      'itemImage': itemPicture,
      'itemTitle': itemName,
      'userId': userId,
      'itemId': itemId,
      'date': date,
      'itemOfferId': itemOfferId,
      'itemPrice': itemPrice,
      'itemOfferPrice': itemAmount,
      'status': status,
      'buyerId': buyerId,
      'isPurchased': isPurchased,
      'alreadyReview': alreadyReview,
      'isFromBuyerList': isBuyerList,
      if (from != null) 'from': from,
    };
  }

  static Map<String, dynamic> _legacyFromFirebase(Map<String, dynamic> data) {
    final itemOfferIdRaw = data['item_offer_id'];
    final itemOfferId = itemOfferIdRaw is int
        ? itemOfferIdRaw
        : int.tryParse(itemOfferIdRaw?.toString() ?? '') ?? 0;

    return _legacyParams(
      profilePicture: data['user_profile']?.toString() ?? '',
      userName: data['user_name']?.toString() ?? '',
      itemPicture: data['item_title_image']?.toString() ?? '',
      itemName: data['item_title']?.toString() ?? '',
      itemId: data['item_id']?.toString() ?? '',
      isBuyerList: true,
      userId: data['sender_id']?.toString() ?? '',
      date: data['created_at']?.toString() ?? '',
      itemOfferId: itemOfferId,
      itemPrice: NotificationService.getPrice(data['item_price']) ?? 0,
      itemAmount: NotificationService.getPrice(data['item_offer_amount']),
      buyerId: HiveUtils.getUserId(),
      isPurchased: 0,
      alreadyReview: false,
    );
  }

  static Map<String, dynamic> _legacyFromAwesome(Map<String, dynamic> data) {
    final itemOfferIdRaw = data['item_offer_id'];
    final itemOfferId = itemOfferIdRaw is int
        ? itemOfferIdRaw
        : int.tryParse(itemOfferIdRaw?.toString() ?? '') ?? 0;

    return _legacyParams(
      profilePicture: data['user_profile']?.toString() ?? '',
      userName: data['user_name']?.toString() ?? '',
      itemPicture: data['item_image']?.toString() ?? '',
      itemName: data['item_name']?.toString() ?? '',
      itemId: data['item_id']?.toString() ?? '',
      isBuyerList: true,
      userId: data['user_id']?.toString() ?? '',
      date: data['created_at']?.toString() ?? '',
      itemOfferId: itemOfferId,
      itemPrice: NotificationService.getPrice(data['item_price']) ?? 0,
      itemAmount: NotificationService.getPrice(data['item_offer_amount']),
      buyerId: HiveUtils.getUserId(),
      isPurchased: 0,
      alreadyReview: false,
    );
  }
}
