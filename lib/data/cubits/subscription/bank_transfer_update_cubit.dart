import 'dart:io';

import 'package:eClassify/data/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BankTransferUpdateState {}

class BankTransferUpdateInitial extends BankTransferUpdateState {}

class BankTransferUpdateInProgress extends BankTransferUpdateState {}

class BankTransferUpdateSuccess extends BankTransferUpdateState {
  BankTransferUpdateSuccess(this.message);

  final String message;
}

class BankTransferUpdateFailure extends BankTransferUpdateState {
  BankTransferUpdateFailure(this.error);

  final dynamic error;
}

class BankTransferUpdateCubit extends Cubit<BankTransferUpdateState> {
  BankTransferUpdateCubit() : super(BankTransferUpdateInitial());

  final SubscriptionRepository _repository = SubscriptionRepository();

  Future<void> uploadReceipt({
    required String paymentTransactionId,
    required File receiptFile,
  }) async {
    try {
      emit(BankTransferUpdateInProgress());
      final response = await _repository.updateBankTransfer(
        paymentTransactionId: paymentTransactionId,
        paymentReceipt: receiptFile,
      );
      emit(BankTransferUpdateSuccess(response['message']?.toString() ?? ''));
    } catch (e) {
      emit(BankTransferUpdateFailure(e));
    }
  }
}
