import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';

class CategoryRepository {
  CategoryRepository._internal();

  static final CategoryRepository _instance = CategoryRepository._internal();

  static CategoryRepository get instance => _instance;

  Future<DataOutput<Category>> fetchCategories({
    required int? parentId,
    required int page,
  }) async {
    try {
      final response = await Api.get(
        url: Api.getCategoriesApi,
        queryParameters: {
          Api.page: page,
          if (parentId != null) Api.categoryId: parentId,
        },
      );

      final modelList = JsonHelper.parseList(
        response['data']['data'] as List?,
        Category.fromJson,
      );

      Category? selfCategory;
      if (response['self_category'] != null) {
        selfCategory = Category.fromJson(response['self_category'] as Json);
      }

      return DataOutput(
        total: response['data']['total'] ?? 0,
        modelList: modelList,
        extraData: selfCategory != null
            ? ExtraData<Category>(data: selfCategory)
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Specialized method to validate if a category is allowed for listing.
  /// Triggered only for leaf nodes (no subcategories).
  Future<bool> validateCategoryForListing(int categoryId) async {
    try {
      await Api.get(
        url: Api.getCategoriesApi,
        queryParameters: {Api.categoryId: categoryId},
      );
      // If the API call completes without throwing an error, we consider it validated.
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
