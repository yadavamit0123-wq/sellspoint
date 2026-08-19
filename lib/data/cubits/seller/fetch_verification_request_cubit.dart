import 'package:eClassify/data/model/user/verification_request.dart';
import 'package:eClassify/data/repositories/seller/seller_verification_field_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class VerificationRequestState {}

class VerificationRequestInitial extends VerificationRequestState {}

class VerificationRequestLoading extends VerificationRequestState {}

class VerificationRequestSuccess extends VerificationRequestState {
  VerificationRequestSuccess({required this.request});
  final VerificationRequest request;
}

class VerificationRequestFail extends VerificationRequestState {
  VerificationRequestFail({required this.error});
  final Object? error;
}

class VerificationRequestCubit extends Cubit<VerificationRequestState> {
  VerificationRequestCubit() : super(VerificationRequestInitial());
  final SellerVerificationFieldRepository repository =
      SellerVerificationFieldRepository();

  void fetchVerificationRequest() async {
    try {
      emit(VerificationRequestLoading());
      final request = await repository.getVerificationRequest();
      emit(VerificationRequestSuccess(request: request));
    } catch (e) {
      emit(VerificationRequestFail(error: e));
    }
  }
}
