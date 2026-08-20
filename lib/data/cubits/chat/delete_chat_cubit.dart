import 'package:eClassify/data/repositories/chat_history_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteChatState {}

class DeleteChatInitial extends DeleteChatState {}

class DeleteChatInProgress extends DeleteChatState {}

class DeleteChatSuccess extends DeleteChatState {
  DeleteChatSuccess({required this.itemOfferIds});

  final List<int> itemOfferIds;
}

class DeleteChatFailure extends DeleteChatState {
  DeleteChatFailure({required this.error, required this.itemOfferIds});

  final dynamic error;
  final List<int> itemOfferIds;
}

class DeleteChatCubit extends Cubit<DeleteChatState> {
  DeleteChatCubit() : super(DeleteChatInitial());

  Future<void> deleteChats({required List<int> itemOfferIds}) async {
    try {
      emit(DeleteChatInProgress());
      await ChatHistoryRepository.instance.deleteChat(
        itemOfferIds: itemOfferIds,
      );
      emit(DeleteChatSuccess(itemOfferIds: itemOfferIds));
    } catch (e) {
      emit(DeleteChatFailure(error: e.toString(), itemOfferIds: itemOfferIds));
    }
  }
}
