import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/subscription/transaction_model.dart';
import 'package:eClassify/utils/api.dart';

class TransactionRepository {
  Future<DataOutput<TransactionModel>> fetchTransactions({
    required int page,
  }) async {
    Map<String, dynamic> parameters = {Api.page: page};

    Map<String, dynamic> response = await Api.get(
      url: Api.getPaymentDetailsApi,
      queryParameters: parameters,
    );

    List<TransactionModel> transactionList = (response['data']['data'] as List)
        .map((e) => TransactionModel.fromJson(e))
        .toList();

    return DataOutput<TransactionModel>(
      total: response['data']['total'] ?? 0,
      modelList: transactionList,
    );
  }

  Future<String> getPaymentReceipt({required int transactionId}) async {
    String response = await Api.getRaw(
      url: Api.paymentReceiptApi,
      queryParameters: {'payment_transaction_id': transactionId},
    );

    return response;
  }
}
