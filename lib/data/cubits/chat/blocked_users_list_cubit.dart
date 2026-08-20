import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/repositories/chat_history_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlockedUserListState {}

class BlockedUserListInitial extends BlockedUserListState {}

class BlockedUserListLoading extends BlockedUserListState {}

class BlockedUserListSuccess extends BlockedUserListState {
  BlockedUserListSuccess({required this.users});

  final List<ChatUser> users;
}

class BlockedUserListFailure extends BlockedUserListState {
  BlockedUserListFailure({required this.error});

  final Object? error;
}

class BlockedUserListCubit extends Cubit<BlockedUserListState> {
  BlockedUserListCubit() : super(BlockedUserListInitial());

  Future<void> getBlockedUsers() async {
    try {
      emit(BlockedUserListLoading());

      final users = await ChatHistoryRepository.instance.getBlockedUsers();

      emit(BlockedUserListSuccess(users: users));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(BlockedUserListFailure(error: e));
    }
  }

  void removeUser(int userId) {
    if (state is! BlockedUserListSuccess) return;
    final success = this.state as BlockedUserListSuccess;
    if (success.users.isNotEmpty) {
      final updatedList = success.users
          .where((user) => user.id != userId)
          .toList();
      emit(BlockedUserListSuccess(users: updatedList));
    }
  }
}
