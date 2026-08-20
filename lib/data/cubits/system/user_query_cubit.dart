import 'package:eClassify/data/repositories/system_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserQueryState {}

class UserQueryInitial extends UserQueryState {}

class UserQueryLoading extends UserQueryState {}

class UserQuerySuccess extends UserQueryState {}

class UserQueryFailure extends UserQueryState {
  UserQueryFailure({required this.message});

  final String message;
}

class UserQueryCubit extends Cubit<UserQueryState> {
  UserQueryCubit() : super(UserQueryInitial());

  Future<void> sendUserQuery({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      emit(UserQueryLoading());

      await SystemRepository.instance.sendUserQuery(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );

      emit(UserQuerySuccess());
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(UserQueryFailure(message: e.toString()));
    }
  }
}
