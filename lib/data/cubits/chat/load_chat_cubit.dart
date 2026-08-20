import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/repositories/chat_history_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoadChatState {}

class LoadChatInitial extends LoadChatState {}

class LoadChatInProgress extends LoadChatState {}

class LoadChatSuccess extends LoadChatState {
  LoadChatSuccess({required this.chat});

  final Chat chat;
}

class LoadChatFailure extends LoadChatState {
  LoadChatFailure({required this.error});

  final Object? error;
}

class LoadChatCubit extends Cubit<LoadChatState> {
  LoadChatCubit() : super(LoadChatInitial());

  final _chatHistoryRepository = ChatHistoryRepository.instance;

  Future<void> loadChat({required int itemOfferId}) async {
    emit(LoadChatInProgress());
    try {
      final chat = await _chatHistoryRepository.getChatByItemOfferId(
        itemOfferId: itemOfferId,
      );
      emit(LoadChatSuccess(chat: chat));
    } catch (e) {
      emit(LoadChatFailure(error: e));
    }
  }
}
