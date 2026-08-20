import 'package:eClassify/data/repositories/subscription/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchReceiptState {}

class FetchReceiptInitial extends FetchReceiptState {}

class FetchReceiptInProgress extends FetchReceiptState {}

class FetchReceiptSuccess extends FetchReceiptState {
  FetchReceiptSuccess({required this.htmlContent});

  final String htmlContent;
}

class FetchReceiptFailure extends FetchReceiptState {
  FetchReceiptFailure({required this.error});

  final Object error;
}

class FetchReceiptCubit extends Cubit<FetchReceiptState> {
  final TransactionRepository _transactionRepository = TransactionRepository();

  FetchReceiptCubit() : super(FetchReceiptInitial());

  Future<void> fetchReceipt(int transactionId) async {
    try {
      emit(FetchReceiptInProgress());
      String response = await _transactionRepository.getPaymentReceipt(
        transactionId: transactionId,
      );
      emit(FetchReceiptSuccess(htmlContent: response));
    } catch (e) {
      emit(FetchReceiptFailure(error: e));
    }
  }
}
