import 'dart:io';

import 'package:eClassify/data/model/chat/chat_message.dart';
import 'package:eClassify/data/repositories/chat_repository.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMessageState {
  ChatMessageState({
    required this.messages,
    required this.isLoading,
    required this.error,
  });

  factory ChatMessageState.initial() =>
      ChatMessageState(messages: List.empty(), isLoading: false, error: null);

  final List<ChatMessage> messages;
  final bool isLoading;
  final Object? error;

  bool get hasError => error != null;

  ChatMessageState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    Object? error,
  }) => ChatMessageState(
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );

  @override
  String toString() {
    return 'ChatMessageState{messages: ${messages.length}, isLoading: $isLoading, error: $error}';
  }
}

class ChatMessageCubit extends Cubit<ChatMessageState> {
  ChatMessageCubit(this.chatId) : super(ChatMessageState.initial());
  final int chatId;
  final _repository = ChatRepository.instance;
  int? _senderId;

  int page = 0;
  bool hasMore = true;

  /// Tracks the last emitted progress percentage to throttle UI updates.
  final Map<String, double> _lastEmittedProgress = {};

  Future<void> getMessages() async {
    try {
      emit(state.copyWith(isLoading: true));

      final response = await _repository.getMessages(
        chatId: chatId,
        page: page + 1,
      );

      emit(
        state.copyWith(
          messages: [...state.messages, ...response.modelList],
          isLoading: false,
        ),
      );
      hasMore = response.total > state.messages.length;
      if (hasMore) ++page;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(state.copyWith(error: e, isLoading: false));
    }
  }

  /// Sends a message optimistically and handles status/progress updates.
  Future<void> sendMessage({
    String? text,
    File? audio,
    File? attachment,
  }) async {
    _senderId ??= int.parse(HiveUtils.getUserId()!);

    // 1. Create local message placeholder using the Factory
    final localMessage = ChatMessageFactory.fromLocal(
      chatId: chatId,
      senderId: _senderId!,
      text: text,
      audio: audio,
      attachment: attachment,
    );

    final localId = localMessage.localId!;

    // 2. Optimistic Update: Add to the start of the list
    emit(state.copyWith(messages: [localMessage, ...state.messages]));

    try {
      // 3. Call Repository using the message object directly
      final confirmedMessage = await _repository.sendMessage(
        localMessage,
        onProgress: (progress) {
          if (localMessage is TextChatMessage) return;
          Log.info('$localId $progress');
          _onUploadProgress(localId, progress);
        },
      );

      _updateMessage(localId, confirmedMessage);
      _lastEmittedProgress.remove(localId);
    } on Exception catch (e, st) {
      // 5. Update Failure
      if (e.toString() == 'blocked_by_other_user') {
        _removeMessage(localId);
        emit(state.copyWith(error: e));
      } else {
        final msg = _findMessage(localId);
        if (msg != null) {
          // Handle failure state based on subclass type via copyWith
          final failedMessage = _getFailedMessage(msg);
          _updateMessage(localId, failedMessage);
        }
      }
      _lastEmittedProgress.remove(localId);
      Log.error(e.toString(), e, st);
    }
  }

  /// Retries a previously failed message.
  Future<void> retryMessage(String localId) async {
    final message = _findMessage(localId);
    if (message == null || !message.isFailed) return;

    // Reset status to sending
    _updateMessage(localId, _getSendingMessage(message));

    try {
      final confirmedMessage = await _repository.sendMessage(
        message,
        onProgress: (progress) {
          if (message is TextChatMessage) return;
          _onUploadProgress(localId, progress);
        },
      );
      _updateMessage(localId, confirmedMessage);
      _lastEmittedProgress.remove(localId);
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      _updateMessage(localId, _getFailedMessage(message));
      _lastEmittedProgress.remove(localId);
    }
  }

  /// Adds a message received from a real-time source (e.g. Notification).
  /// Handles deduplication and matching with local optimistic messages.
  void addIncomingMessage(ChatMessage message) {
    // 1. Check if message already exists by server ID
    if (message.id != null && state.messages.any((m) => m.id == message.id)) {
      return;
    }

    // 2. Check if it matches a local optimistic message
    if (message.localId != null) {
      final existing = _findMessage(message.localId!);
      if (existing != null) {
        // Replace the local placeholder with the server-confirmed version
        _updateMessage(message.localId!, message);
        _lastEmittedProgress.remove(message.localId);
        return;
      }
    }

    // 3. New message: prepend to list
    emit(state.copyWith(messages: [message, ...state.messages]));
  }

  /// Throttled progress updates to avoid jank.
  void _onUploadProgress(String localId, double progress) {
    final last = _lastEmittedProgress[localId] ?? 0.0;
    // Emit only if progress increased by > 5% or reached 100%
    if ((progress - last) > 0.05 || progress >= 0.99) {
      _lastEmittedProgress[localId] = progress;
      final message = _findMessage(localId);
      if (message != null) {
        _updateMessage(localId, _getProgressMessage(message, progress));
      }
    }
  }

  /// Helper to replace a message in the state list by localId.
  void _updateMessage(String localId, ChatMessage newMessage) {
    final updatedList = state.messages.map((m) {
      return m.localId == localId ? newMessage : m;
    }).toList();
    emit(state.copyWith(messages: updatedList));
  }

  /// Helper to find a specific message by localId.
  ChatMessage? _findMessage(String localId) {
    return state.messages.where((m) => m.localId == localId).firstOrNull;
  }

  void _removeMessage(String localId) {
    final updatedList = state.messages
        .where((m) => m.localId != localId)
        .toList();
    emit(state.copyWith(messages: updatedList));
  }

  /// Helpers to handle polymorphic copyWith for various states
  ChatMessage _getFailedMessage(ChatMessage m) {
    return switch (m) {
      TextChatMessage m => m.copyWith(
        sendingStatus: MessageSendingStatus.failed,
      ),
      AudioChatMessage m => m.copyWith(
        sendingStatus: MessageSendingStatus.failed,
        uploadProgress: 0,
      ),
      FileChatMessage m => m.copyWith(
        sendingStatus: MessageSendingStatus.failed,
        uploadProgress: 0,
      ),
      FileAndTextMessage m => m.copyWith(
        sendingStatus: MessageSendingStatus.failed,
        uploadProgress: 0,
      ),
      _ => m,
    };
  }

  ChatMessage _getSendingMessage(ChatMessage m) {
    return switch (m) {
      TextChatMessage m => m.copyWith(
        sendingStatus: MessageSendingStatus.sending,
      ),
      AudioChatMessage m => m.copyWith(
        sendingStatus: MessageSendingStatus.sending,
        uploadProgress: 0,
      ),
      FileChatMessage m => m.copyWith(
        sendingStatus: MessageSendingStatus.sending,
        uploadProgress: 0,
      ),
      FileAndTextMessage m => m.copyWith(
        sendingStatus: MessageSendingStatus.sending,
        uploadProgress: 0,
      ),
      _ => m,
    };
  }

  Future<void> deleteMessages(int chatId, List<int> ids) async {
    final originalMessages = List<ChatMessage>.from(state.messages);

    // Optimistic Update
    final updatedList = state.messages
        .where((m) => !ids.contains(m.id))
        .toList();
    emit(state.copyWith(messages: updatedList));

    try {
      await _repository.deleteMessages(chatId, ids);
    } catch (e, st) {
      // Revert if failed
      emit(state.copyWith(messages: originalMessages));
      Log.error('Failed to delete messages', e, st);
    }
  }

  ChatMessage _getProgressMessage(ChatMessage m, double progress) {
    return switch (m) {
      AudioChatMessage m => m.copyWith(uploadProgress: progress),
      FileChatMessage m => m.copyWith(uploadProgress: progress),
      FileAndTextMessage m => m.copyWith(uploadProgress: progress),
      _ => m,
    };
  }
}
