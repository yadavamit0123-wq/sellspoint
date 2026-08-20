import 'dart:async';
import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/services/chat/audio_service.dart';
import 'package:eClassify/data/services/chat/chat_event_bus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatSessionState {
  ChatSessionState({
    required this.chat,
    required this.isCurrentUserSeller,
    bool? isBlockedByOther,
  }) : isBlockedByOther = isBlockedByOther ?? chat.isBlockedByOtherUser;

  final Chat chat;
  final bool isCurrentUserSeller;
  final bool isBlockedByOther;

  bool get isBlockedByMe => chat.isUserBlocked;

  ChatSessionState copyWith({Chat? chat, bool? isBlockedByOther}) =>
      ChatSessionState(
        chat: chat ?? this.chat,
        isCurrentUserSeller: isCurrentUserSeller,
        isBlockedByOther: isBlockedByOther ?? this.isBlockedByOther,
      );
}

class ChatSessionCubit extends Cubit<ChatSessionState> {
  ChatSessionCubit(this.chat, {bool isCurrentUserSeller = true})
    : audioService = AudioService(),
      super(
        ChatSessionState(chat: chat, isCurrentUserSeller: isCurrentUserSeller),
      ) {
    _eventSubscription = ChatEventBus.instance.eventStream.listen(_onChatEvent);
  }
  final Chat chat;
  final AudioService audioService;
  late final StreamSubscription _eventSubscription;

  void _onChatEvent(ChatEvent event) {
    switch (event.type) {
      case ChatEventType.blocked:
        final userId = event.data['user_id'] as int?;
        final otherId =
            state.isCurrentUserSeller ? chat.buyerId : chat.sellerId;

        if (userId == otherId) {
          final isBlockedByMe = event.data['is_blocked_by_me'] as bool?;
          final isBlockedByOther = event.data['is_blocked_by_other'] as bool?;

          if (isBlockedByMe != null) {
            setBlockedByMeStatus(isBlockedByMe);
          }
          if (isBlockedByOther != null) {
            setBlockedByOtherStatus(isBlockedByOther);
          }
        }
        break;
      case ChatEventType.reviewed:
        final itemId = event.data['item_id'] as int?;
        if (itemId == chat.itemId) {
          markAsReviewed();
        }
        break;
      case ChatEventType.read:
        // Optional: can be used to hide unread indicator locally
        break;
      default:
        break;
    }
  }

  bool get isBlockedByMe {
    return state.isBlockedByMe;
  }

  bool get isBlockedByOther {
    return state.isBlockedByOther;
  }

  // TODO(I): Temporary fix for Case 2 to track review status locally within the session.
  // Refactor this when ItemModel/Chat DTO is improved.
  void markAsReviewed() {
    state.chat.item.hasReviewed = true;
    emit(state.copyWith(chat: state.chat));
  }

  void setBlockedByMeStatus(bool isBlocked) {
    final chat = state.chat.copyWith(isUserBlocked: isBlocked);
    emit(state.copyWith(chat: chat));
  }

  void setBlockedByOtherStatus(bool isBlocked) {
    emit(state.copyWith(isBlockedByOther: isBlocked));
  }

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    audioService.dispose();
    return super.close();
  }
}
