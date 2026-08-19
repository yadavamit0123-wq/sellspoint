import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';
import 'package:path/path.dart' as path;

class SubscriptionRepository {
  SubscriptionRepository._internal();

  static final _instance = SubscriptionRepository._internal();

  static SubscriptionRepository get instance => _instance;

  Future<List<SubscriptionPackage>> getPackages({
    required SubscriptionPackageType type,
    int? categoryId,
  }) async {
    try {
      final effectiveId = categoryId == null || categoryId <= 0
          ? null
          : categoryId;

      final response = await Api.get(
        url: Api.getPackageApi,
        queryParameters: {Api.type: type.label, Api.categoryId: ?effectiveId},
      );

      return JsonHelper.parseList(
        response['data'] as List?,
        SubscriptionPackage.fromJson,
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<SubscriptionPackage>> getActivePackages({
    SubscriptionPackageType? type,
    int? categoryId,
    AdItemType? adItemType,
  }) async {
    try {
      final response = await Api.get(
        url: Api.getActivePackagesApi,
        queryParameters: {
          'category_id': ?categoryId,
          'type': ?type?.label,
          if (adItemType != null)
            'item_type': adItemType == AdItemType.regularAd ? 'normal' : 'reel',
        },
      );

      return JsonHelper.parseList(
        response['data'] as List?,
        SubscriptionPackage.fromJson,
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future updateBankTransfer({
    required String paymentTransactionId,
    required File paymentReceipt,
  }) async {
    try {
      Map<String, dynamic> parameters = {};
      parameters[Api.paymentTransectionId] = paymentTransactionId;

      MultipartFile image = await MultipartFile.fromFile(
        paymentReceipt.path,
        filename: path.basename(paymentReceipt.path),
      );

      parameters[Api.paymentReceipt] = image;

      var response = await Api.post(
        url: Api.bankTransferUpdateApi,
        parameter: parameters,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
