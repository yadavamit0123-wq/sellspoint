import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/repositories/chat_repository.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/log.dart';

/// eClassify 2.14 chat inbox helpers (seller item offers, delete thread).
class ChatHistoryRepository {
  ChatHistoryRepository._internal();

  static final ChatHistoryRepository instance = ChatHistoryRepository._internal();

  final ChatRepository _chatRepository = ChatRepository();

  Future<void> deleteChat({required List<int> itemOfferIds}) =>
      _chatRepository.deleteChats(itemOfferIds: itemOfferIds);

  Future<void> deleteChatMessages({
    required int itemOfferId,
    required List<int> messageIds,
  }) =>
      _chatRepository.deleteChatMessages(
        itemOfferId: itemOfferId,
        messageIds: messageIds,
      );

  Future<DataOutput<ChatUser>> fetchSellerItemOffers({
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await Api.get(
        url: Api.chatItemOffersApi,
        queryParameters: {
          Api.type: 'seller',
          Api.page: page,
          if (search != null && search.isNotEmpty) Api.search: search,
        },
      );
      final data = response['data'] as Map? ?? {};
      final list = (data['data'] as List? ?? [])
          .map((e) => ChatUser.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return DataOutput(total: data['total'] ?? list.length, modelList: list);
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
