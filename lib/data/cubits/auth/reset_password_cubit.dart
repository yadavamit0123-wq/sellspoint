import 'package:eClassify/data/repositories/auth_repository.dart';
import 'package:eClassify/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordInProgress extends ResetPasswordState {}

class ResetPasswordSuccess extends ResetPasswordState {}

class ResetPasswordFailure extends ResetPasswordState {
  ResetPasswordFailure(this.errorMessage);

  final String errorMessage;
}

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit() : super(ResetPasswordInitial());

  final AuthRepository _authRepository = AuthRepository();

  Future<void> resetPassword({
    required String phoneNumber,
    required String countryCode,
    required String newPassword,
    required String jwtToken,
  }) async {
    try {
      emit(ResetPasswordInProgress());
      await _authRepository.resetPassword(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        newPassword: newPassword,
        jwtToken: jwtToken,
      );
      emit(ResetPasswordSuccess());
    } on ApiException catch (e) {
      emit(ResetPasswordFailure(e.errorMessage.toString()));
    } catch (e) {
      emit(ResetPasswordFailure(e.toString()));
    }
  }
}
