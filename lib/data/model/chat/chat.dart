import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:flutter/foundation.dart';

@immutable
class Chat {
  Chat({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.itemId,
    required this.lastChatMessage,
    required this.unreadCount,
    required this.lastMessageTime,
    required this.formattedAmount,
    required this.seller,
    required this.buyer,
    required this.item,
    this.isUserBlocked = false,
    this.isBlockedByOtherUser = false,
  });

  Chat.fromJson(Json json)
    : id = json['id'] as int,
      sellerId = json['seller_id'] as int,
      buyerId = json['buyer_id'] as int,
      itemId = json['item_id'] as int,
      lastChatMessage = json['last_chat_message'] as String?,
      unreadCount = json['unread_chat_count'] as int? ?? 0,
      lastMessageTime = DateTime.parse(json['last_message_time'] as String),
      formattedAmount = json['formatted_amount'] as String?,
      isUserBlocked = json['user_blocked'] as bool? ?? false,
      isBlockedByOtherUser = json['is_my_user_blocked'] as bool? ?? false,
      seller = ChatUser.fromJson(json['seller'] as Json),
      buyer = ChatUser.fromJson(json['buyer'] as Json),
      item = ItemModel.fromJson(json['item'] as Json);

  final int id;
  final int sellerId;
  final int buyerId;
  final int itemId;
  final String? lastChatMessage;
  final int unreadCount;
  final DateTime lastMessageTime;
  final String? formattedAmount;
  final bool isUserBlocked;
  final bool isBlockedByOtherUser;
  final ChatUser seller;
  final ChatUser buyer;
  final ItemModel item;

  Chat copyWith({
    int? unreadCount,
    String? lastChatMessage,
    DateTime? lastMessageTime,
    bool? isUserBlocked,
    bool? isBlockedByOtherUser,
  }) => Chat(
    id: id,
    sellerId: sellerId,
    buyerId: buyerId,
    itemId: itemId,
    lastChatMessage: lastChatMessage ?? this.lastChatMessage,
    unreadCount: unreadCount ?? this.unreadCount,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    formattedAmount: formattedAmount,
    isUserBlocked: isUserBlocked ?? this.isUserBlocked,
    isBlockedByOtherUser: isBlockedByOtherUser ?? this.isBlockedByOtherUser,
    seller: seller,
    buyer: buyer,
    item: item,
  );

  Chat fromChatNotification(ChatNotificationMessage message) => this.copyWith(
    unreadCount: unreadCount + message.unreadCount,
    lastChatMessage: message.message,
    lastMessageTime: message.time,
  );

  static Chat fromNotification(Map<String, dynamic> data, {required int myId}) {
    final bool isSeller =
        data['user_type'].toString().toLowerCase() != 'seller';

    return Chat(
      id: int.parse(data['item_offer_id'].toString()),
      sellerId: isSeller ? myId : int.parse(data['user_id'].toString()),
      buyerId: isSeller ? int.parse(data['user_id'].toString()) : myId,
      itemId: int.parse(data['item_id'].toString()),
      lastChatMessage: data['message'] as String?,
      unreadCount: int.parse(data['unread_count'].toString()),
      lastMessageTime:
          DateTime.tryParse(data['updated_at'] as String? ?? '') ??
          DateTime.now(),
      formattedAmount: data['item_offer_amount'] as String?,
      seller: ChatUser(
        id: isSeller ? myId : int.parse(data['user_id'].toString()),
        name: isSeller ? data['my_user_name'] as String? ?? "" : data['user_name'] as String,
        profile: isSeller ? data['my_user_profile'] as String? : data['user_profile'] as String?,
      ),
      buyer: ChatUser(
        id: isSeller ? int.parse(data['user_id'].toString()) : myId,
        name: isSeller ? data['user_name'] as String : data['my_user_name'] as String? ?? "",
        profile: isSeller ? data['user_profile'] as String? : data['my_user_profile'] as String?,
      ),
      item: ItemModel.fromJson({
        'id': int.parse(data['item_id'].toString()),
        'name': data['item_name'] as String,
        'image': data['item_image'] as String,
        'price': double.tryParse(data['item_price']?.toString() ?? ''),
      }),
    );
  }
}

class ChatUser {
  ChatUser({required this.id, required this.name, required this.profile});

  ChatUser.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      profile = json['profile'] as String?;

  final int id;
  final String name;
  final String? profile;
}

class ChatNotificationMessage {
  ChatNotificationMessage({
    required this.id,
    required this.itemId,
    required this.message,
    required this.time,
    required this.unreadCount,
  });

  final int id;
  final int itemId;
  final String? message;
  final DateTime? time;
  final int unreadCount;
}
