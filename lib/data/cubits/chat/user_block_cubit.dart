import 'package:eClassify/data/repositories/chat_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserBlockState {}

class UserBlockInitial extends UserBlockState {}

class UserBlockLoading extends UserBlockState {}

class UserBlockSuccess extends UserBlockState {
  UserBlockSuccess({required this.userId, required this.isBlocked});

  final int userId;
  final bool isBlocked;
}

class UserBlockFailure extends UserBlockState {
  UserBlockFailure({required this.message});

  final String message;
}

class UserBlockCubit extends Cubit<UserBlockState> {
  UserBlockCubit() : super(UserBlockInitial());

  Future<void> toggleBlockUser({
    required int userId,
    bool isUserBlocked = false,
  }) async {
    try {
      emit(UserBlockLoading());

      await ChatRepository.instance.toggleBlockUser(
        userId: userId,
        isUserBlocked: isUserBlocked,
      );

      emit(UserBlockSuccess(userId: userId, isBlocked: !isUserBlocked));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(UserBlockFailure(message: e.toString()));
    }
  }
}
