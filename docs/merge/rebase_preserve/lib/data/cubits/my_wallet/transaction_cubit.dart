// transaction_cubit.dart
import 'package:eClassify/data/model/faq_response.dart';
import 'package:eClassify/data/model/wallet/wallet_transaction_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// States for TransactionBloc
abstract class TransactionListState {}

class TransactionListInitial extends TransactionListState {}

class TransactionListLoading extends TransactionListState {}

class TransactionListSuccess extends TransactionListState {
  final List<WalletTransactionData> transactions;
  TransactionListSuccess(this.transactions);
}

class TransactionListError extends TransactionListState {
  final String errorMessage;
  TransactionListError(this.errorMessage);
}

// TransactionBloc for transaction data
class TransactionBloc extends Cubit<TransactionListState> {
  TransactionBloc() : super(TransactionListInitial());

  Future<void> fetchTransactions() async {

    emit(TransactionListLoading());
    try {
      final response = await Api.get(
        url: "${Api.walletTransHistoryApi}",
      );
      print('wallet res ------ ${response}');
      final data = response['data'] as List<dynamic>;
      final transactions = data.map((e) => WalletTransactionData.fromJson(e)).toList();

      emit(TransactionListSuccess(transactions));
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }
}

// States for TransactionCubit (FAQs)
abstract class TransactionFaqState {}

class TransactionFaqInitial extends TransactionFaqState {}

class TransactionFaqLoading extends TransactionFaqState {}

class TransactionFaqSuccess extends TransactionFaqState {
  final List<FaqData> faqs;
  TransactionFaqSuccess(this.faqs);
}

class TransactionFaqError extends TransactionFaqState {
  final String errorMessage;
  TransactionFaqError(this.errorMessage);
}
List<FaqData>? _cachedFaqs; // local cache

// TransactionCubit for FAQs
class TransactionCubit extends Cubit<TransactionFaqState> {
  TransactionCubit() : super(TransactionFaqInitial());

  Future<void> fetchWalletFaqs() async {
    if (_cachedFaqs != null && _cachedFaqs!.isNotEmpty) {
      emit(TransactionFaqSuccess(_cachedFaqs!));
      return;
    }
    emit(TransactionFaqLoading());
    try {
      final response = await Api.get(
        url: "${Api.walletQuestionApi}",
      );
      final data = response['data'] as List<dynamic>;
      final faqs = data.map((e) => FaqData.fromJson(e)).toList();
      _cachedFaqs = faqs;
      emit(TransactionFaqSuccess(faqs));
    } catch (e) {
      emit(TransactionFaqError(e.toString()));
    }
  }
}