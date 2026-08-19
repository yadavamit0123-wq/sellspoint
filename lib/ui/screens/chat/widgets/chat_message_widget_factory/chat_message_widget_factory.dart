import 'package:eClassify/data/model/chat/chat_message.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_message_widget_factory/audio_message_widget.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_message_widget_factory/file_message_widget.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_message_widget_factory/file_text_message_widget.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_message_widget_factory/text_message_widget.dart';
import 'package:flutter/material.dart';

class ChatMessageWidgetFactory {
  static Widget create(ChatMessage message) {
    return switch (message) {
      final TextChatMessage m => TextMessageWidget(message: m),
      final FileChatMessage m => FileMessageWidget(message: m),
      final FileAndTextMessage m => FileTextMessageWidget(message: m),
      final AudioChatMessage m => AudioMessageWidget(message: m),
      _ => throw UnsupportedError(
        'Unsupported Message Type ${message.runtimeType}',
      ),
    };
  }
}
