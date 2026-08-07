// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:eClassify/utils/api.dart';
import 'package:eClassify/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteMessageState {}

class DeleteMessageInitial extends DeleteMessageState {}

class DeleteMessageInProgress extends DeleteMessageState {}

class DeleteMessageSuccess extends DeleteMessageState {
  final int id;
  DeleteMessageSuccess({
    required this.id,
  });
}

class DeleteMessageFail extends DeleteMessageState {
  dynamic error;
  DeleteMessageFail({
    required this.error,
  });
}

class DeleteMessageCubit extends Cubit<DeleteMessageState> {
  DeleteMessageCubit() : super(DeleteMessageInitial());

  void delete(int id) async {
    try {
      emit(DeleteMessageInProgress());

      await Api.post(
          url: Api.deleteChatMessageApi,
          parameter: {Api.messageId: id});
      emit(DeleteMessageSuccess(id: id));
    } catch (e) {
      emit(DeleteMessageFail(error: e));
    }
  }

  Future<void> deleteMultiple({
    required int itemOfferId,
    required List<int> messageIds,
  }) async {
    try {
      emit(DeleteMessageInProgress());
      await ChatRepository().deleteChatMessages(
        itemOfferId: itemOfferId,
        messageIds: messageIds,
      );
      emit(DeleteMessageSuccess(id: messageIds.first));
    } catch (e) {
      emit(DeleteMessageFail(error: e));
    }
  }
}
