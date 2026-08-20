part of '../../model/chat/chat_message.dart';

/// Factory class to dynamically generate [ChatMessage] instances.
/// Centralizes instantiation logic for local, server, and notification messages.
class ChatMessageFactory {
  /// Generates a [ChatMessage] instance with a unique [localId] (UUID).
  /// Used for optimistic local placeholders.
  static ChatMessage fromLocal({
    required int chatId,
    required int senderId,
    String? text,
    File? audio,
    File? attachment,
  }) {
    final localId = const Uuid().v4();
    final now = DateTime.now();

    if (audio != null) {
      return AudioChatMessage._(
        audio: audio.path,
        senderId: senderId,
        chatId: chatId,
        dateTime: now,
        localId: localId,
        sendingStatus: MessageSendingStatus.sending,
        uploadProgress: 0,
      );
    } else if (attachment != null) {
      if (text != null && text.trim().isNotEmpty) {
        return FileAndTextMessage._(
          file: attachment.path,
          message: text,
          senderId: senderId,
          chatId: chatId,
          dateTime: now,
          localId: localId,
          sendingStatus: MessageSendingStatus.sending,
          uploadProgress: 0,
        );
      }
      return FileChatMessage._(
        file: attachment.path,
        senderId: senderId,
        chatId: chatId,
        dateTime: now,
        localId: localId,
        sendingStatus: MessageSendingStatus.sending,
        uploadProgress: 0,
      );
    } else {
      return TextChatMessage._(
        message: text ?? '',
        senderId: senderId,
        chatId: chatId,
        dateTime: now,
        localId: localId,
        sendingStatus: MessageSendingStatus.sending,
      );
    }
  }

  /// Parses a [ChatMessage] from server-side JSON logic.
  static ChatMessage fromServerJson(Json json) {
    final typeStr = json['message_type']?.toString();
    if (typeStr == null) {
      throw FormatException('message_type is missing in JSON: $json');
    }
    final type = ChatMessageType.parse(typeStr);
    return switch (type) {
      ChatMessageType.audio => AudioChatMessage._fromJson(json),
      ChatMessageType.file => FileChatMessage._fromJson(json),
      ChatMessageType.fileAndText => FileAndTextMessage._fromJson(json),
      ChatMessageType.text => TextChatMessage._fromJson(json),
    };
  }

  /// Parses a [ChatMessage] from a notification payload.
  /// Handles re-mapping of specific notification keys like 'message_type_temp'.
  static ChatMessage fromNotification(Json payload) {
    // Re-map keys that differ from the standard server response
    final mappedJson = Map<String, dynamic>.from(payload);

    // Map message_type
    if (payload.containsKey('message_type_temp')) {
      mappedJson['message_type'] = payload['message_type_temp'];
    }

    // Firebase data values are strings; coerce them to proper types for models
    void _coerce(String key) {
      final value = mappedJson[key];
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) mappedJson[key] = parsed;
      }
    }

    _coerce('id');
    _coerce('sender_id');
    _coerce('item_offer_id');
    _coerce('is_read');

    return fromServerJson(mappedJson);
  }
}
