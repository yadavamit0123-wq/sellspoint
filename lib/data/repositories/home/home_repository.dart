import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/home/featured_section.dart';
import 'package:eClassify/data/model/home/home_section.dart';
import 'package:eClassify/data/model/home/home_slider.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';

class HomeRepository {
  HomeRepository._internal();

  static final HomeRepository _instance = HomeRepository._internal();

  static HomeRepository get instance => _instance;

  Future<List<HomeSection>> getHomeConfiguration() async {
    try {
      final response = await Api.get(url: Api.getHomeConfigurationApi);

      final sections = JsonHelper.parseList(
        response['data']['sections'] as List?,
        (json) {
          try {
            return HomeSection.fromJson(json);
          } catch (e, stack) {
            Log.error('Error parsing HomeSection: ${e.toString()}', e, stack);
            return null;
          }
        },
      ).nonNulls.toList();

      return sections;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<HomeSlider>> getSliders({required LeafLocation? location}) async {
    try {
      final response = await Api.get(
        url: Api.getSliderApi,
        queryParameters: {
          Api.city: ?location?.city?.canonical,
          Api.state: ?location?.state?.canonical,
          Api.country: ?location?.country?.canonical,
        },
      );

      final sliders = JsonHelper.parseList(
        response['data'] as List?,
        HomeSlider.parse,
      );
      return sliders;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<Category>> getPopularCategories() async {
    try {
      final response = await Api.get(url: Api.getPopularCategoriesApi);
      final categories = JsonHelper.parseList(
        response['data'] as List?,
        Category.fromJson,
      );
      return categories;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<FeaturedSection>> getFeaturedSection({
    required LeafLocation? location,
  }) async {
    try {
      final response = await Api.get(
        url: Api.getFeaturedSectionApi,
        queryParameters: location?.toApiJson(),
      );
      final sections = JsonHelper.parseList(
        response['data'] as List?,
        FeaturedSection.fromJson,
      );
      return sections.where((element) => element.items.isNotEmpty).toList();
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchHomeAllItems({
    required int page,
    required LeafLocation? location,
  }) async {
    try {
      final response = await Api.get(
        url: Api.getItemApi,
        queryParameters: {
          Api.page: page,
          ...?location?.toApiJson(),
          // To Receive global items if none are available at given location
          'current_page': 'home',
        },
      );
      final items = JsonHelper.parseList(
        response['data']['data'] as List?,
        ItemModel.fromJson,
      );

      return DataOutput(
        total: response['data']['total'] ?? 0,
        modelList: items,
        extraData: ExtraData<String?>(data: response['message'] as String?),
      );
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
