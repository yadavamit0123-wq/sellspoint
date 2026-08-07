import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/data/model/home/home_screen_section.dart';
import 'package:eClassify/data/model/home/home_section.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/item_model.dart';

class HomeRepository {
  Future<List<HomeScreenSection>> fetchHome(
      {String? country, String? state, String? city, int? areaId}) async {
    try {
      Map<String, dynamic> parameters = {
        if (city != null && city != "") 'city': city,
        if (areaId != null && areaId != "") 'area_id': areaId,
        if (country != null && country != "") 'country': country,
        if (state != null && state != "") 'state': state,
      };

      Map<String, dynamic> response = await Api.get(
          url: Api.getFeaturedSectionApi, queryParameters: parameters);
      List<HomeScreenSection> homeScreenDataList =
          (response['data'] as List).map((element) {
        return HomeScreenSection.fromJson(element);
      }).toList();

      return homeScreenDataList;
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchHomeAllItems(
      {required int page,
      String? country,
      String? state,
      String? city,
      double? latitude,
      double? longitude,
      int? areaId,
      int? radius}) async {
    try {
      Map<String, dynamic> parameters = {
        "page": page,
        if (radius == null) ...{
          if (city != null && city != "") 'city': city,
          if (areaId != null && areaId != "") 'area_id': areaId,
          if (country != null && country != "") 'country': country,
          if (state != null && state != "") 'state': state,
        },
        if (radius != null && radius != "") 'radius': radius,
        if (latitude != null && latitude != "") 'latitude': latitude,
        if (longitude != null && longitude != "") 'longitude': longitude,
        "sort_by": "new-to-old",
        "current_page": "home",
      };

      Map<String, dynamic> response =
          await Api.get(url: Api.getItemApi, queryParameters: parameters);
      List<ItemModel> items = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(
          total: response['data']['total'] ?? 0, modelList: items);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CategoryModel>> fetchPopularCategories() async {
    final response = await Api.get(url: Api.getPopularCategoriesApi);
    if (response['error'] == true) {
      throw Exception(response['message']?.toString() ?? 'error');
    }
    final list = response['data'] as List? ?? [];
    return list
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Admin-driven home layout (`get-home-screen`). Empty list if shape unknown.
  Future<List<HomeSection>> fetchHomeConfiguration() async {
    final response = await Api.get(url: Api.getHomeConfigurationApi);
    if (response['error'] == true) {
      throw Exception(response['message']?.toString() ?? 'error');
    }

    final data = response['data'];
    List<dynamic> raw = [];
    if (data is Map && data['sections'] is List) {
      raw = data['sections'] as List;
    } else if (data is List) {
      raw = data;
    } else {
      return [];
    }

    final sections = <HomeSection>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      try {
        sections.add(
          HomeSection.fromJson(Map<String, dynamic>.from(entry)),
        );
      } catch (_) {
        continue;
      }
    }
    return sections;
  }

  Future<DataOutput<ItemModel>> fetchSectionItems(
      {required int page,
      required int sectionId,
      String? country,
      String? state,
      String? city,
      int? areaId}) async {
    try {
      Map<String, dynamic> parameters = {
        "page": page,
        "featured_section_id": sectionId,
        if (city != null && city != "") 'city': city,
        if (areaId != null && areaId != "") 'area_id': areaId,
        if (country != null && country != "") 'country': country,
        if (state != null && state != "") 'state': state,
      };

      Map<String, dynamic> response =
          await Api.get(url: Api.getItemApi, queryParameters: parameters);
      List<ItemModel> items = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(
          total: response['data']['total'] ?? 0, modelList: items);
    } catch (error) {
      rethrow;
    }
  }
}
