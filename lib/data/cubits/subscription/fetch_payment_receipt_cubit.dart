import 'package:eClassify/data/repositories/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchPaymentReceiptState {}

class FetchPaymentReceiptInitial extends FetchPaymentReceiptState {}

class FetchPaymentReceiptInProgress extends FetchPaymentReceiptState {}

class FetchPaymentReceiptSuccess extends FetchPaymentReceiptState {
  FetchPaymentReceiptSuccess(this.receiptHtml);

  final String receiptHtml;
}

class FetchPaymentReceiptFailure extends FetchPaymentReceiptState {
  FetchPaymentReceiptFailure(this.error);

  final dynamic error;
}

class FetchPaymentReceiptCubit extends Cubit<FetchPaymentReceiptState> {
  FetchPaymentReceiptCubit() : super(FetchPaymentReceiptInitial());

  final TransactionRepository _repository = TransactionRepository();

  Future<void> fetch({required int transactionId}) async {
    try {
      emit(FetchPaymentReceiptInProgress());
      final html = await _repository.getPaymentReceipt(
        transactionId: transactionId,
      );
      emit(FetchPaymentReceiptSuccess(html));
    } catch (e) {
      emit(FetchPaymentReceiptFailure(e));
    }
  }
}
