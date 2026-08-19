import 'dart:async';

import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/model/chat/item_offer.dart';

enum ChatEventType { read, blocked, reviewed, messageReceived, deleted }

class ChatEvent {
  ChatEvent({required this.type, required this.data});

  final ChatEventType type;
  final Map<String, dynamic> data;

  factory ChatEvent.read(int chatId, {int? itemId}) {
    return ChatEvent(
      type: ChatEventType.read,
      data: {'chat_id': chatId, 'item_id': itemId},
    );
  }

  factory ChatEvent.blocked({
    required int userId,
    bool? isBlockedByMe,
    bool? isBlockedByOther,
  }) {
    return ChatEvent(
      type: ChatEventType.blocked,
      data: {
        'user_id': userId,
        'is_blocked_by_me': isBlockedByMe,
        'is_blocked_by_other': isBlockedByOther,
      },
    );
  }

  factory ChatEvent.reviewed(int itemId) {
    return ChatEvent(type: ChatEventType.reviewed, data: {'item_id': itemId});
  }

  factory ChatEvent.messageReceived({
    required ChatNotificationMessage message,
    ItemOffer? itemOffer,
    Chat? chatUser,
    bool isReceiverSeller = false,
  }) {
    return ChatEvent(
      type: ChatEventType.messageReceived,
      data: {
        'message': message,
        'item_offer': itemOffer,
        'chat_user': chatUser,
        'is_receiver_seller': isReceiverSeller,
      },
    );
  }

  factory ChatEvent.deleted({
    required List<int> itemOfferIds,
    int? itemId,
  }) {
    return ChatEvent(
      type: ChatEventType.deleted,
      data: {
        'item_offer_ids': itemOfferIds,
        'item_id': itemId,
      },
    );
  }
}

class ChatEventBus {
  ChatEventBus._internal();

  static final ChatEventBus _instance = ChatEventBus._internal();

  static ChatEventBus get instance => _instance;

  final StreamController<ChatEvent> _controller =
      StreamController<ChatEvent>.broadcast();

  Stream<ChatEvent> get eventStream => _controller.stream;

  void emit(ChatEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
