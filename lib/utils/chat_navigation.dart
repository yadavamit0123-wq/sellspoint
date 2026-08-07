import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/chat/chat_screen_route.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 2.14 chat route entry points — [Routes.chatScreen] / [Routes.sellerItemChatScreen].
abstract final class ChatNavigation {
  static Future<void> openChatUser(
    BuildContext context,
    ChatUser chatUser, {
    bool refreshBuyerChatListOnPop = false,
  }) async {
    if (AppConfig.enableChatRoutesV214) {
      await Navigator.pushNamed(
        context,
        Routes.chatScreen,
        arguments: {'chat_user': chatUser},
      );
    } else {
      await Navigator.push(
        context,
        ChatScreenRoute.routeForChatUser(chatUser),
      );
    }
    _refreshBuyerChatListOnPop(context, refreshBuyerChatListOnPop);
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

  /// Opens buyer chat for a listing from reels / ad details when offer exists.
  ///
  /// Returns `true` if chat was opened; `false` if caller should start
  /// [MakeAnOfferItemCubit.makeAnOfferItem] (no existing thread yet).
  static Future<bool> openBuyerChatForListingItem(
    BuildContext context,
    ItemModel item, {
    bool refreshBuyerChatListOnPop = false,
  }) async {
    final itemId = item.id;
    if (itemId == null) return false;

    ChatUser? existing;
    try {
      existing = context.read<GetBuyerChatListCubit>().getOfferForItem(itemId);
    } catch (_) {}
    if (existing != null) {
      await openChatUser(
        context,
        existing,
        refreshBuyerChatListOnPop: refreshBuyerChatListOnPop,
      );
      return true;
    }

    final offerId = item.itemOfferId;
    if (offerId != null) {
      final seller = item.user;
      await _openLegacy(
        context,
        _legacyParams(
          profilePicture: seller?.profile ?? '',
          userName: seller?.name ?? '',
          itemPicture: item.image ?? '',
          itemName: item.name ?? '',
          itemId: itemId.toString(),
          isBuyerList: true,
          userId: seller?.id?.toString() ?? item.userId?.toString() ?? '',
          date: item.created ?? '',
          itemOfferId: offerId,
          itemPrice: item.price ?? 0,
          status: item.status,
          buyerId: HiveUtils.getUserId(),
          isPurchased: item.isPurchased ?? 0,
          alreadyReview: item.review != null && item.review!.isNotEmpty,
          from: 'reel',
        ),
        refreshBuyerChatListOnPop: refreshBuyerChatListOnPop,
      );
      return true;
    }

    return false;
  }

  static ChatUser chatUserFromMakeOfferPayload(dynamic data) {
    return ChatUser(
      itemId: data['item_id'] is String
          ? int.parse(data['item_id'])
          : data['item_id'] as int?,
      amount: data['amount'] != null
          ? double.tryParse(data['amount'].toString())
          : null,
      buyerId: data['buyer_id'],
      createdAt: data['created_at']?.toString(),
      id: data['id'] is int ? data['id'] as int : int.tryParse('${data['id']}'),
      sellerId: data['seller_id'],
      updatedAt: data['updated_at']?.toString(),
      buyer: data['buyer'] != null ? Buyer.fromJson(data['buyer']) : null,
      item: data['item'] != null ? Item.fromJson(data['item']) : null,
      seller: data['seller'] != null ? Seller.fromJson(data['seller']) : null,
    );
  }

  static void syncBuyerChatListAfterMakeOffer(
    BuildContext context,
    dynamic data,
  ) {
    final chatUser = chatUserFromMakeOfferPayload(data);
    try {
      context.read<GetBuyerChatListCubit>().addOrUpdateChat(chatUser);
    } catch (_) {}
  }

  static Future<void> _openLegacy(
    BuildContext context,
    Map<String, dynamic> legacy, {
    bool refreshBuyerChatListOnPop = false,
  }) async {
    if (legacy['buyerId'] == null || legacy['buyerId'].toString().isEmpty) {
      legacy['buyerId'] = HiveUtils.getUserId();
    }
    if (AppConfig.enableChatRoutesV214) {
      await Navigator.pushNamed(
        context,
        Routes.chatScreen,
        arguments: {'legacy': legacy},
      );
    } else {
      await Navigator.push(
        context,
        ChatScreenRoute.routeForLegacy(legacy),
      );
    }
    _refreshBuyerChatListOnPop(context, refreshBuyerChatListOnPop);
  }

  static void _refreshBuyerChatListOnPop(
    BuildContext context,
    bool requested,
  ) {
    if (!requested || !AppConfig.enableReelFeedBuyerChatReturnRefreshV214) {
      return;
    }
    if (!context.mounted) return;
    try {
      context.read<GetBuyerChatListCubit>().fetch();
    } catch (_) {}
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
