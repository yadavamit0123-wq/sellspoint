import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/transaction_model.dart';
import 'package:eClassify/utils/api.dart';

class TransactionRepository {
  Future<DataOutput<TransactionModel>> fetchTransactions({
    required int page,
  }) async {
    Map<String, dynamic> response = await Api.get(
      url: Api.getPaymentDetailsApi,
      queryParameters: {Api.page: page},
    );

    final data = response['data'];
    List<dynamic> rawList;
    int total;

    if (data is List) {
      rawList = data;
      total = rawList.length;
    } else if (data is Map) {
      rawList = data['data'] as List? ?? [];
      total = data['total'] ?? rawList.length;
    } else {
      rawList = [];
      total = 0;
    }

    List<TransactionModel> transactionList = rawList
        .map((e) => TransactionModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();

    return DataOutput<TransactionModel>(
      total: total,
      modelList: transactionList,
    );
  }

  Future<String> getPaymentReceipt({required int transactionId}) async {
    return Api.getRaw(
      url: Api.paymentReceiptApi,
      queryParameters: {Api.paymentTransectionId: transactionId},
    );
  }
}
