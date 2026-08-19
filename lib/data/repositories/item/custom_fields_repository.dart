import 'package:eClassify/data/model/custom_field/custom_field_model.dart';
import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';

class CustomFieldRepository {
  // Backwards Compatibility
  factory CustomFieldRepository() => _instance;

  CustomFieldRepository._internal();

  static final CustomFieldRepository _instance =
      CustomFieldRepository._internal();

  static CustomFieldRepository get instance => _instance;

  Future<List<CustomFieldModel>> getCustomFields(
    int categoryId, {
    bool isForFilter = false,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        Api.categoryId: categoryId,
        if (isForFilter) 'filter': true,
      };

      Map<String, dynamic> response = await Api.get(
        url: Api.getCustomFieldsApi,
        queryParameters: parameters,
      );

      List<CustomFieldModel> modelList = (response['data'] as List)
          .map((e) => CustomFieldModel.fromMap(e))
          .toList();

      return modelList;
    } catch (e) {
      throw "$e";
    }
  }

  Future<List<CustomFieldV2>> getCustomFieldsV2({
    required int categoryId,
    bool isForFilter = false,
  }) async {
    try {
      final response = await Api.get(
        url: Api.getCustomFieldsApi,
        queryParameters: {
          Api.categoryId: categoryId,
          if (isForFilter) 'filter': true,
        },
      );

      final fields = JsonHelper.parseList(
        response['data'] as List?,
        CustomFieldV2.parse,
      );

      return fields;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
