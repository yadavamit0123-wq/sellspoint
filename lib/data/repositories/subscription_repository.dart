import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/subscription_pacakage_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:path/path.dart' as path;

class SubscriptionRepository {
  Future<DataOutput<SubscriptionPackageModel>> getSubscriptionPacakges({
    required String type,
    int? categoryId,
  }) async {
    Map<String, dynamic> response = await Api.get(
      url: Api.getPackageApi,
      queryParameters: {
        if (Platform.isIOS) "platform": "ios",
        Api.type: type,
        if (categoryId != null && categoryId > 0) Api.categoryId: categoryId,
      },
    );

    List<SubscriptionPackageModel> modelList =
        (response['data'] as List? ?? [])
            .map((element) => SubscriptionPackageModel.fromJson(
                Map<String, dynamic>.from(element as Map)))
            .toList();
    final activeModelList =
        modelList.where((item) => item.isActive == true).toList();
    final inactiveModelList =
        modelList.where((item) => item.isActive == false).toList();
    final combineList = [...activeModelList, ...inactiveModelList];

    return DataOutput(total: combineList.length, modelList: combineList);
  }

  Future<List<SubscriptionPackageModel>> getActiveUserPackages({
    String? type,
    int? categoryId,
    String? itemType,
  }) async {
    final response = await Api.get(
      url: Api.getActivePackagesApi,
      queryParameters: {
        if (categoryId != null && categoryId > 0) Api.categoryId: categoryId,
        if (type != null && type.isNotEmpty) Api.type: type,
        if (itemType != null && itemType.isNotEmpty) 'item_type': itemType,
      },
    );

    return (response['data'] as List? ?? [])
        .map((e) => SubscriptionPackageModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> subscribeToPackage(
    int packageId,
    bool isPackageAvailable,
  ) async {
    await Api.post(
      url: Api.userPurchasePackageApi,
      parameter: {
        Api.packageId: packageId,
        if (isPackageAvailable) 'flag': 1,
      },
    );
  }

  Future<Map<String, dynamic>> updateBankTransfer({
    required String paymentTransactionId,
    required File paymentReceipt,
  }) async {
    final image = await MultipartFile.fromFile(
      paymentReceipt.path,
      filename: path.basename(paymentReceipt.path),
    );

    return Api.post(
      url: Api.bankTransferUpdateApi,
      parameter: {
        Api.paymentTransectionId: paymentTransactionId,
        Api.paymentReceipt: image,
      },
    );
  }
}
