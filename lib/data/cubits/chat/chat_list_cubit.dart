import 'dart:async';

import 'package:collection/collection.dart';
import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/chat_history_repository.dart';
import 'package:eClassify/data/services/chat/chat_event_bus.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListSuccess extends ChatListState {
  ChatListSuccess({required this.users})
    : item = users.firstOrNull?.item,
      unreadCount = users.fold(
        0,
        (value, user) => value += (user.unreadCount > 0 ? 1 : 0),
      );
  final List<Chat> users;
  final ItemModel? item;
  final int unreadCount;
}

class ChatListFailure extends ChatListState {
  ChatListFailure({required this.error});

  final Object error;
}

abstract class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit() : super(ChatListInitial()) {
    _eventSubscription = ChatEventBus.instance.eventStream.listen(_onChatEvent);
  }

  bool canProcessEvent(ChatEvent event);

  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<Chat>? _preDeletionUsers;
  List<Chat>? _cachedUsers;
  String? search;
  late final StreamSubscription _eventSubscription;

  void _onChatEvent(ChatEvent event) {
    if (state is! ChatListSuccess) return;
    if (!canProcessEvent(event)) return;
    Log.debug('ChatListCubit._onChatEvent: ${event.type} ${event.data}');

    try {
      switch (event.type) {
        case ChatEventType.read:
          final chatId = event.data['chat_id'] as int?;
          if (chatId != null) {
            removeUnreadCount(chatId);
          }
          break;
        case ChatEventType.blocked:
          final userId = event.data['user_id'] as int?;
          if (userId != null) {
            toggleBlockStatus(
              userId: userId,
              isUserBlocked: event.data['is_blocked_by_me'] as bool?,
              isBlockedByOtherUser: event.data['is_blocked_by_other'] as bool?,
            );
          }
          break;
        case ChatEventType.reviewed:
          final itemId = event.data['item_id'] as int?;
          if (itemId != null) {
            updateReviewStatus(itemId);
          }
          break;
        case ChatEventType.messageReceived:
          final message = event.data['message'] as ChatNotificationMessage?;
          final chatUser = event.data['chat_user'] as Chat?;
          if (message != null) {
            final didUpdate = updateChat(message);
            if (!didUpdate && chatUser != null) {
              addChatUser(chatUser);
            }
          }
          break;
        case ChatEventType.deleted:
          final ids = event.data['item_offer_ids'] as List<dynamic>?;
          if (ids != null) {
            removeChatsLocally(ids.cast<int>());
          }
          break;
      }
    } catch (e, st) {
      Log.error('Error in ChatListCubit._onChatEvent', e, st);
    }
  }

  Future<Json> fetch(int page, {String? search});

  Future<void> getChatUsers({String? search}) async {
    try {
      Log.info('${this.runtimeType}');
      Log.info('search: $search');
      Log.info('this.search: ${this.search}');
      Log.info('cachedUsers: $_cachedUsers');
      this.search = search;
      if (search.isNotNullAndNotEmpty) {
        _cachedUsers ??= (state as ChatListSuccess).users;
        emit(ChatListLoading());
        final response = await fetch(1, search: search);
        final users = response['chats'] as List<Chat>;
        emit(ChatListSuccess(users: users));
      } else {
        if (_cachedUsers.isNotNullAndNotEmpty) {
          emit(ChatListSuccess(users: _cachedUsers!));
          _cachedUsers = null;
        } else {
          emit(ChatListLoading());

          final response = await fetch(page);

          final users = response['chats'] as List<Chat>;
          hasMore = response['has_more'] as bool;
          emit(ChatListSuccess(users: users));
        }
      }
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ChatListFailure(error: e));
    }
  }

  Future<void> getMoreChatUsers() async {
    if (state is! ChatListSuccess ||
        !hasMore ||
        isLoadingMore ||
        (search != null && search!.isNotEmpty))
      return;
    try {
      isLoadingMore = true;
      final response = await fetch(page + 1);

      final users = response['chats'] as List<Chat>;

      emit(
        ChatListSuccess(users: [...(state as ChatListSuccess).users, ...users]),
      );

      hasMore = response['has_more'] as bool;
      if (hasMore) ++page;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ChatListFailure(error: e));
    } finally {
      isLoadingMore = false;
    }
  }

  List<Chat> _getChats() {
    if (state is! ChatListSuccess) return [];
    return (state as ChatListSuccess).users;
  }

  void removeUnreadCount(int chatId) {
    final chats = List<Chat>.from(_getChats());
    final index = chats.indexWhere((element) => element.id == chatId);
    if (index != -1) {
      chats[index] = chats[index].copyWith(unreadCount: 0);
    }
    emit(ChatListSuccess(users: chats));
  }

  bool updateChat(ChatNotificationMessage message) {
    final chats = List<Chat>.from(_getChats());
    final index = chats.indexWhere((element) => element.id == message.id);
    if (index == -1) return false;
    if (index != 0) {
      final newUser = chats[index].fromChatNotification(message);
      chats.removeAt(index);
      emit(ChatListSuccess(users: [newUser, ...chats]));
    } else {
      chats[index] = chats[index].fromChatNotification(message);
      emit(ChatListSuccess(users: chats));
    }
    return true;
  }

  void removeChatsLocally(List<int> ids) {
    final currentChats = _getChats();
    _preDeletionUsers = List.from(currentChats);
    final updatedChats = currentChats
        .where((chat) => !ids.contains(chat.id))
        .toList();
    emit(ChatListSuccess(users: updatedChats));
  }

  void rollbackDeletion() {
    if (_preDeletionUsers != null) {
      emit(ChatListSuccess(users: _preDeletionUsers!));
      _preDeletionUsers = null;
    }
  }

  void commitDeletion() {
    _preDeletionUsers = null;
  }

  // Only for backwards compatibility with existing chat system
  // Remove after refactoring to new chat system
  Chat? getChatFromItemId(int itemId) {
    if (state is! ChatListSuccess) return null;
    return (state as ChatListSuccess).users.firstWhereOrNull((element) {
      return element.item.id == itemId;
    });
  }

  void addChatUser(Chat chat) {
    emit(ChatListSuccess(users: List.from([chat, ..._getChats()])));
  }

  void toggleBlockStatus({
    required int userId,
    bool? isUserBlocked,
    bool? isBlockedByOtherUser,
  }) {
    Log.debug(
      'ChatListCubit.toggleBlockStatus: $userId, $isUserBlocked, $isBlockedByOtherUser',
    );
    final currentChats = _getChats();
    bool updated = false;

    final updatedChats = currentChats.map((chat) {
      if (chat.sellerId == userId || chat.buyerId == userId) {
        updated = true;
        return chat.copyWith(
          isUserBlocked: isUserBlocked,
          isBlockedByOtherUser: isBlockedByOtherUser,
        );
      }
      return chat;
    }).toList();

    if (!updated) {
      Log.debug('ChatListCubit.toggleBlockStatus: No chats found for $userId');
      return;
    }

    emit(ChatListSuccess(users: updatedChats));
  }

  // TODO(I): Temporary fix for Case 2 to update review status in the chat list locally.
  // This avoids re-showing the rating dialog when re-entering a chat.
  void updateReviewStatus(int itemId) {
    final currentChats = _getChats();
    bool updated = false;

    final updatedChats = currentChats.map((chat) {
      if (chat.itemId == itemId) {
        updated = true;
        chat.item.hasReviewed = true;
        return chat;
      }
      return chat;
    }).toList();

    if (updated) {
      emit(ChatListSuccess(users: updatedChats));
    }
  }

  void clear() => emit(ChatListInitial());

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }
}

final class SellerChatListCubit extends ChatListCubit {
  SellerChatListCubit(this.itemId) : super();
  final int itemId;

  @override
  bool canProcessEvent(ChatEvent event) {
    if (event.type == ChatEventType.messageReceived) {
      final isReceiverSeller =
          event.data['is_receiver_seller'] as bool? ?? false;
      if (!isReceiverSeller) return false;

      final message = event.data['message'] as ChatNotificationMessage?;
      return message?.itemId == itemId;
    }

    if (event.type == ChatEventType.read) {
      final eventItemId = event.data['item_id'] as int?;
      return eventItemId == itemId;
    }

    return true;
  }

  @override
  Future<Json> fetch(int page, {String? search}) => ChatHistoryRepository
      .instance
      .getSellerItemChats(itemId: itemId, page: page, search: search);
}

final class BuyingChatListCubit extends ChatListCubit {
  @override
  bool canProcessEvent(ChatEvent event) {
    if (event.type == ChatEventType.messageReceived) {
      final isReceiverSeller =
          event.data['is_receiver_seller'] as bool? ?? false;
      return !isReceiverSeller;
    }
    return true;
  }

  @override
  Future<Json> fetch(int page, {String? search}) => ChatHistoryRepository
      .instance
      .getBuyerItemChats(page: page, search: search);
}
