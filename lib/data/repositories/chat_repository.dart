import 'package:dio/dio.dart';
import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/ui/screens/chat/chat_audio/widgets/chat_widget.dart';
import 'package:eClassify/utils/api.dart';
import 'package:flutter/material.dart';

class ChatRepository {
  Future<DataOutput<ChatUser>> fetchBuyerChatList(int page) async {
    Map<String, dynamic> response = await Api.get(
      url: Api.getChatListApi,
      queryParameters: {Api.type: "buyer", Api.page: page},
    );

    final data = response['data'] as Map? ?? {};
    List<ChatUser> modelList = (data['data'] as List? ?? []).map((e) {
      return ChatUser.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList();

    return DataOutput(
      total: data['total'] ?? modelList.length,
      modelList: modelList,
    );
  }

  Future<DataOutput<ChatUser>> fetchSellerChatList(int page) async {
    Map<String, dynamic> response = await Api.get(
      url: Api.getChatListApi,
      queryParameters: {Api.page: page, Api.type: "seller"},
    );

    final data = response['data'] as Map? ?? {};
    List<ChatUser> modelList = (data['data'] as List? ?? []).map((e) {
      return ChatUser.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList();

    return DataOutput(
      total: data['total'] ?? 0,
      modelList: modelList,
    );
  }

  Future<DataOutput<ChatMessage>> getMessagesApi({
    required int page,
    required int itemOfferId,
  }) async {
    Map<String, dynamic> response = await Api.get(
      url: Api.chatMessagesApi,
      queryParameters: {
        Api.itemOfferId: itemOfferId,
        Api.page: page,
      },
    );

    final data = response['data'] as Map? ?? {};
    List<ChatMessage> modelList = (data['data'] as List? ?? []).map((result) {
      final map = Map<String, dynamic>.from(result as Map);
      return ChatMessage(
        key: ValueKey(map['id']),
        message: map['message']?.toString() ?? '',
        senderId: (map['sender_id'] as num).toInt(),
        createdAt: map['created_at'].toString(),
        file: map['file']?.toString() ?? '',
        audio: map['audio']?.toString() ?? '',
        itemOfferId: (map['item_offer_id'] as num).toInt(),
        updatedAt: map['updated_at']?.toString() ?? map['created_at'].toString(),
        messageType: map['message_type']?.toString(),
        id: (map['id'] as num?)?.toInt(),
      );
    }).toList();

    return DataOutput(
      total: data['total'] ?? modelList.length,
      modelList: modelList,
    );
  }

  Future<Map<String, dynamic>> sendMessageApi({
    required int itemOfferId,
    required String message,
    MultipartFile? audio,
    MultipartFile? attachment,
  }) async {
    Map<String, dynamic> parameters = {
      Api.itemOfferId: itemOfferId,
    };

    if (attachment != null) {
      parameters['file'] = attachment;
    }
    if (audio != null) {
      parameters['audio'] = audio;
    }

    if (message.isNotEmpty) {
      parameters[Api.message] = message;
    }

    Map<String, dynamic> map =
        await Api.post(url: Api.sendMessageApi, parameter: parameters);

    if (map['error'] == true) {
      final key = map['data'] is Map ? map['data']['key']?.toString() : null;
      if (key == 'blocked_by_other_user') {
        throw ApiException('blocked_by_other_user');
      }
      throw ApiException(map['message']?.toString() ?? 'error');
    }

    return map;
  }

  Future<void> deleteChatMessages({
    required int itemOfferId,
    required List<int> messageIds,
  }) async {
    await Api.post(
      url: Api.deleteChatMessagesApi,
      parameter: {
        Api.itemOfferId: itemOfferId,
        Api.messageIds: messageIds,
      },
    );
  }

  Future<void> deleteChats({required List<int> itemOfferIds}) async {
    await Api.post(
      url: Api.deleteChatApi,
      parameter: {Api.itemOfferId: itemOfferIds},
    );
  }

  Future<Map<String, dynamic>> blockUserApi({required int blockUserId}) async {
    Map<String, dynamic> parameters = {
      Api.blockedUserId: blockUserId,
    };

    return Api.post(url: Api.blockUserApi, parameter: parameters);
  }

  Future<Map<String, dynamic>> unBlockUserApi({required int blockUserId}) async {
    Map<String, dynamic> parameters = {
      Api.blockedUserId: blockUserId,
    };

    return Api.post(url: Api.unBlockUserApi, parameter: parameters);
  }

  Future<DataOutput<BlockedUserModel>> blockedUsersListApi() async {
    Map<String, dynamic> response =
        await Api.get(url: Api.blockedUsersListApi, queryParameters: {});

    List<BlockedUserModel> modelList = (response['data'] as List? ?? []).map(
      (e) {
        return BlockedUserModel.fromJson(Map<String, dynamic>.from(e as Map));
      },
    ).toList();

    return DataOutput(modelList: modelList, total: modelList.length);
  }
}
