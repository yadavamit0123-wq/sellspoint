library chat_message;

import 'dart:io';

import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:uuid/uuid.dart';

part '../../factories/chat/chat_message_factory.dart';

enum ChatMessageType {
  audio('audio'),
  file('file'),
  fileAndText('file_and_text'),
  text('text');

  const ChatMessageType(this.value);

  final String value;

  static ChatMessageType parse(String value) {
    return ChatMessageType.values.firstWhere((type) => type.value == value);
  }
}

enum MessageSendingStatus { sending, sent, failed }

base class ChatMessage {
  ChatMessage._({
    this.id,
    required this.senderId,
    required this.chatId,
    required this.dateTime,
    this.localId,
    this.sendingStatus = MessageSendingStatus.sent,
    this.uploadProgress,
  });

  factory ChatMessage.parse(Json json) {
    return ChatMessageFactory.fromServerJson(json);
  }

  ChatMessage._fromJson(Json json)
    : id = json['id'] as int?,
      senderId = json['sender_id'] as int,
      chatId = int.parse(json['item_offer_id'].toString()),
      dateTime = DateTime.parse(json['created_at'] as String).toLocal(),
      localId = json['client_id'] as String?,
      sendingStatus = MessageSendingStatus.sent,
      uploadProgress = null;

  final int? id;
  final int senderId;
  final int chatId;
  final DateTime dateTime;

  /// Unique identifier for local tracking before the message is assigned a server ID.
  /// This is sent as 'client_id' to the server and echoed back.
  final String? localId;

  /// Current status of the message sending process.
  final MessageSendingStatus sendingStatus;

  /// Progress of media upload (0.0 to 1.0). Null for text messages or sent messages.
  final double? uploadProgress;

  bool get isLocal => localId != null && id == null;

  bool get isSent => sendingStatus == MessageSendingStatus.sent;

  bool get isFailed => sendingStatus == MessageSendingStatus.failed;

  bool get isSending => sendingStatus == MessageSendingStatus.sending;

  @override
  String toString() {
    return 'ChatMessageV2{id: $id, localId: $localId, status: $sendingStatus, sender: $senderId, chatId: $chatId, dateTime: $dateTime}';
  }

  /// Maps internal fields to API parameter keys.
  /// Subclasses should override and call super.toJson() to append their specific data.
  Json get toJson => {
    Api.itemOfferId: chatId,
    if (localId != null) Api.clientId: localId,
  };
}

final class TextChatMessage extends ChatMessage {
  TextChatMessage._fromJson(Json json)
    : message = json['message'] as String,
      super._fromJson(json);

  final String message;

  @override
  String toString() {
    return 'TextChatMessage{message: $message, ${super.toString()}';
  }

  TextChatMessage._({
    required this.message,
    super.id,
    required super.senderId,
    required super.chatId,
    required super.dateTime,
    super.localId,
    super.sendingStatus = MessageSendingStatus.sent,
    super.uploadProgress,
  }) : super._();

  TextChatMessage copyWith({
    int? id,
    int? senderId,
    int? chatId,
    DateTime? dateTime,
    String? localId,
    MessageSendingStatus? sendingStatus,
    double? uploadProgress,
    String? message,
  }) {
    return TextChatMessage._(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      chatId: chatId ?? this.chatId,
      dateTime: dateTime ?? this.dateTime,
      localId: localId ?? this.localId,
      sendingStatus: sendingStatus ?? this.sendingStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      message: message ?? this.message,
    );
  }

  @override
  Json get toJson => {...super.toJson, Api.message: message};
}

final class FileChatMessage extends ChatMessage {
  FileChatMessage._fromJson(Json json)
    : file = json['file'] as String,
      super._fromJson(json);

  final String file;

  @override
  String toString() {
    return 'FileChatMessage{file: $file, ${super.toString()}';
  }

  FileChatMessage._({
    required this.file,
    super.id,
    required super.senderId,
    required super.chatId,
    required super.dateTime,
    super.localId,
    super.sendingStatus = MessageSendingStatus.sent,
    super.uploadProgress,
  }) : super._();

  FileChatMessage copyWith({
    int? id,
    int? senderId,
    int? chatId,
    DateTime? dateTime,
    String? localId,
    MessageSendingStatus? sendingStatus,
    double? uploadProgress,
    String? file,
  }) {
    return FileChatMessage._(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      chatId: chatId ?? this.chatId,
      dateTime: dateTime ?? this.dateTime,
      localId: localId ?? this.localId,
      sendingStatus: sendingStatus ?? this.sendingStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      file: file ?? this.file,
    );
  }

  @override
  Json get toJson => {
    ...super.toJson,
    // If it's a local file, we send the File object,
    // otherwise we might just be sending the URL
    // (though usually we only toJson for new messages)
    Api.file: File(file),
  };
}

final class AudioChatMessage extends ChatMessage {
  AudioChatMessage._fromJson(Json json)
    : audio = json['audio'] as String,
      super._fromJson(json);

  final String audio;

  @override
  String toString() {
    return 'AudioChatMessage{audio: $audio, ${super.toString()}';
  }

  AudioChatMessage._({
    required this.audio,
    super.id,
    required super.senderId,
    required super.chatId,
    required super.dateTime,
    super.localId,
    super.sendingStatus = MessageSendingStatus.sent,
    super.uploadProgress,
  }) : super._();

  AudioChatMessage copyWith({
    int? id,
    int? senderId,
    int? chatId,
    DateTime? dateTime,
    bool? isRead,
    String? localId,
    MessageSendingStatus? sendingStatus,
    double? uploadProgress,
    String? audio,
  }) {
    return AudioChatMessage._(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      chatId: chatId ?? this.chatId,
      dateTime: dateTime ?? this.dateTime,
      localId: localId ?? this.localId,
      sendingStatus: sendingStatus ?? this.sendingStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      audio: audio ?? this.audio,
    );
  }

  @override
  Json get toJson => {...super.toJson, Api.audio: File(audio)};
}

final class FileAndTextMessage extends ChatMessage {
  FileAndTextMessage._fromJson(Json json)
    : file = json['file'] as String,
      message = json['message'] as String,
      super._fromJson(json);

  final String file;
  final String message;

  @override
  String toString() {
    return 'FileAndTextMessage{file: $file, message: $message, ${super.toString()}';
  }

  FileAndTextMessage._({
    required this.file,
    required this.message,
    super.id,
    required super.senderId,
    required super.chatId,
    required super.dateTime,
    super.localId,
    super.sendingStatus = MessageSendingStatus.sent,
    super.uploadProgress,
  }) : super._();

  FileAndTextMessage copyWith({
    int? id,
    int? senderId,
    int? chatId,
    DateTime? dateTime,
    bool? isRead,
    String? localId,
    MessageSendingStatus? sendingStatus,
    double? uploadProgress,
    String? file,
    String? message,
  }) {
    return FileAndTextMessage._(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      chatId: chatId ?? this.chatId,
      dateTime: dateTime ?? this.dateTime,
      localId: localId ?? this.localId,
      sendingStatus: sendingStatus ?? this.sendingStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      file: file ?? this.file,
      message: message ?? this.message,
    );
  }

  @override
  Json get toJson => {
    ...super.toJson,
    Api.file: File(file),
    Api.message: message,
  };
}
