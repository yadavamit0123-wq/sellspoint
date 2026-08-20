import 'package:eClassify/data/model/custom_field/custom_field_model.dart';
import 'package:eClassify/data/model/user/verification_request.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/log.dart';

class SellerVerificationFieldRepository {
  Future<List<VerificationFieldModel>> getSellerVerificationFields() async {
    try {
      Map<String, dynamic> parameters = {};

      Map<String, dynamic> response = await Api.get(
        url: Api.getVerificationFieldApi,
        queryParameters: parameters,
      );

      List<VerificationFieldModel> modelList = (response['data'] as List)
          .map((e) => VerificationFieldModel.fromMap(e))
          .toList();

      return modelList;
    } catch (e) {
      throw "$e";
    }
  }

  Future<Map> sendVerificationField({
    required Map<String, dynamic> data,
  }) async {
    try {
      Map response = await Api.post(
        url: Api.sendVerificationRequestApi,
        parameter: data,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<VerificationRequest> getVerificationRequest() async {
    try {
      final response = await Api.get(url: Api.getVerificationRequestApi);
      return VerificationRequest.fromJson(response['data']);
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }
}
