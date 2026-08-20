import 'dart:developer';

import 'package:eClassify/data/model/chat/chat_message.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';

class ChatRepository {
  ChatRepository._internal();

  static final ChatRepository _instance = ChatRepository._internal();

  static ChatRepository get instance => _instance;

  /// Fetches messages for a specific chat (item offer).
  Future<DataOutput<ChatMessage>> getMessages({
    required int chatId,
    int page = 1,
  }) async {
    try {
      final response = await Api.get(
        url: Api.chatMessagesApi,
        queryParameters: {Api.itemOfferId: chatId, Api.page: page},
      );

      final messages = JsonHelper.parseList(
        response['data']['data'] as List?,
        ChatMessage.parse,
      );
      final total = response['data']['total'] as int;

      return DataOutput(total: total, modelList: messages);
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'getMessages');
      log('$stack', name: 'getMessages');
      rethrow;
    }
  }

  /// Sends a message to a chat.
  /// This method uses the message's [toJson] implementation to generate API parameters,
  /// allowing for a clean, model-driven interface.
  /// [onProgress] captures multipart upload progress for media messages.
  Future<ChatMessage> sendMessage(
    ChatMessage message, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final response = await Api.post(
        url: Api.sendMessageApi,
        parameter: message.toJson,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
        catchApiError: false,
      );

      Log.debug('$response');

      if (response['error'] == true) {
        if (response['data']?['key'] == 'blocked_by_other_user') {
          throw ApiException('blocked_by_other_user');
        } else {
          throw ApiException(response['message'].toString());
        }
      }
      return ChatMessage.parse(response['data'] as Map<String, dynamic>);
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'sendMessage');
      log('$stack', name: 'sendMessage');
      rethrow;
    }
  }

  /// Toggles blocking/unblocking a user.
  Future<void> toggleBlockUser({
    required int userId,
    bool isUserBlocked = false,
  }) async {
    try {
      final parameters = {Api.blockedUserId: userId};
      final endpoint = isUserBlocked ? Api.unBlockUserApi : Api.blockUserApi;
      await Api.post(url: endpoint, parameter: parameters);
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'toggleBlockUser');
      log('$stack', name: 'toggleBlockUser');
    }
  }

  /// Deletes multiple messages by their IDs.
  Future<void> deleteMessages(int chatId, List<int> ids) async {
    try {
      final parameters = {Api.itemOfferId: chatId, Api.messageIds: ids};
      await Api.post(url: Api.deleteChatMessagesApi, parameter: parameters);
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'deleteMessages');
      log('$stack', name: 'deleteMessages');
      rethrow;
    }
  }
}
