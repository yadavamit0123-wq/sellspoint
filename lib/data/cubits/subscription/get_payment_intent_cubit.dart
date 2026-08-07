import 'package:eClassify/data/repositories/advertisement_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GetPaymentIntentState {}

class GetPaymentIntentInitial extends GetPaymentIntentState {}

class GetPaymentIntentInProgress extends GetPaymentIntentState {}

class GetPaymentIntentInSuccess extends GetPaymentIntentState {
  final dynamic paymentIntent;

  GetPaymentIntentInSuccess(this.paymentIntent);
}

class GetPaymentIntentFailure extends GetPaymentIntentState {
  final dynamic error;

  GetPaymentIntentFailure(this.error);
}

class GetPaymentIntentCubit extends Cubit<GetPaymentIntentState> {
  GetPaymentIntentCubit() : super(GetPaymentIntentInitial());
  AdvertisementRepository repository = AdvertisementRepository();

  Future<void> getPaymentIntent({
    required int packageId,
    required String paymentMethod,
  }) async {
    try {
      emit(GetPaymentIntentInProgress());

      final value = await repository.getPaymentIntent(
        packageId: packageId,
        paymentMethod: paymentMethod,
      );

      final data = value['data'];
      dynamic intent;
      if (data is Map) {
        intent = data['payment_intent'];
      }
      emit(GetPaymentIntentInSuccess(intent ?? data ?? {}));
    } catch (e) {
      emit(GetPaymentIntentFailure(e));
    }
  }
}
