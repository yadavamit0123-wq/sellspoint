import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/data/repositories/item/advertisement_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchUserPackageLimitState {}

class FetchUserPackageLimitInitial extends FetchUserPackageLimitState {}

class FetchUserPackageLimitInProgress extends FetchUserPackageLimitState {}

class FetchUserPackageLimitInSuccess extends FetchUserPackageLimitState {
  final String responseMessage;

  FetchUserPackageLimitInSuccess(this.responseMessage);
}

class FetchUserPackageLimitFailure extends FetchUserPackageLimitState {
  final dynamic error;

  FetchUserPackageLimitFailure(this.error);
}

class FetchUserPackageLimitCubit extends Cubit<FetchUserPackageLimitState> {
  FetchUserPackageLimitCubit() : super(FetchUserPackageLimitInitial());

  void fetchUserPackageLimit({
    required SubscriptionPackageType packageType,
  }) async {
    try {
      emit(FetchUserPackageLimitInProgress());

      final response = await AdvertisementRepository.instance
          .fetchUserPackageLimit(packageType: packageType);

      emit(FetchUserPackageLimitInSuccess(response['message']));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(FetchUserPackageLimitFailure(e.toString()));
    }
  }
}
