import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/ad_posting_data.dart';
import 'package:eClassify/data/model/item/item_filter.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/item/product_video.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/background_upload_utility.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';
import 'package:path/path.dart' as path;

class ItemRepository {
  factory ItemRepository() => _instance;

  ItemRepository._internal();

  static final ItemRepository _instance = ItemRepository._internal();

  Future<({ItemModel item, bool isUploadInProgress})> createAdvertisement({
    required AdPostingData data,
  }) async {
    try {
      final content = data.toJson;
      Log.info('${data.seoData}');
      final isEdit = data.id != null;

      if (data.images.isNotNullAndNotEmpty) {
        final images = await _processImages(data.images!);
        content['gallery_images'] = images;
        content.remove('images');
      }

      if (data.customFields.isNotNullAndNotEmpty) {
        final customFieldsData = _processCustomFields(data.customFields!);
        if (customFieldsData.fields.isNotNullAndNotEmpty) {
          content['custom_field_translations'] = customFieldsData.fields;
        }
        if (customFieldsData.files.isNotNullAndNotEmpty) {
          content['custom_field_files'] = customFieldsData.files;
        }
      }

      if (data.localizedContent.isNotNullAndNotEmpty) {
        content['translations'] = jsonEncode(
          data.localizedContent?.map(
            (l, data) => MapEntry(l.toString(), data.toJson),
          ),
        );
      }

      if (data.productVideo != null &&
          data.productVideo!.type != ProductVideoType.custom) {
        content['video_link'] = data.productVideo!.videoSource.filePath;
        content['video_type'] = data.productVideo!.type.key;
      }

      final response = await Api.post(
        url: isEdit ? Api.updateItemApi : Api.addItemApi,
        parameter: content,
      );

      final item = JsonHelper.parseObject(
        (response['data'] as List).first as Json,
        ItemModel.fromJson,
      );

      Map<String, String> files = {};
      if (data.productVideo != null &&
          data.productVideo!.type == ProductVideoType.custom &&
          data.productVideo!.videoSource is LocalFileResource) {
        files['product_video'] =
            (data.productVideo!.videoSource as LocalFileResource).filePath;
      }

      if (data.videoAd != null && data.videoAd is LocalFileResource) {
        files['video'] = (data.videoAd as LocalFileResource).filePath;
      }

      if (data.thumbnail != null && data.thumbnail is LocalFileResource) {
        files['thumbnail'] = (data.thumbnail as LocalFileResource).filePath;
      }

      if (files.isNotNullAndNotEmpty) {
        BackgroundUploadUtility.uploadMedia(
          itemId: item.id.toString(),
          files: files,
        );
      }

      return (item: item, isUploadInProgress: files.isNotNullAndNotEmpty);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<dynamic>> _processImages(List<FileResource> images) async {
    final files = List.empty(growable: true);
    final multiPartFiles = List<Future<MultipartFile>>.empty(growable: true);
    for (final image in images) {
      if (image is RemoteFileResource) {
        files.add(image.filePath);
        continue;
      } else {
        final file = (image as LocalFileResource).file;
        multiPartFiles.add(
          MultipartFile.fromFile(file.path, filename: path.basename(file.path)),
        );
      }
    }
    final result = await Future.wait(multiPartFiles);
    files.addAll(result);
    return files;
  }

  ({String? fields, Map<String, MultipartFile>? files}) _processCustomFields(
    Map<String, CustomFieldData> customFields,
  ) {
    final Map<String, CustomFieldData> processedCustomFields = {};
    final Map<String, MultipartFile> processedFiles = {};

    for (final field in customFields.entries) {
      final fieldId = field.key;
      final fieldData = field.value;
      final Map<String, dynamic> newFieldData = {};

      for (final entry in fieldData.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value is String) {
          newFieldData[key] = [value];
        } else if (value is FileResource) {
          if (value is RemoteFileResource) {
            newFieldData[key] = [value.filePath];
          } else {
            final filePath = value.filePath;
            processedFiles[key] = MultipartFile.fromFileSync(
              filePath,
              filename: path.basename(filePath),
            );
          }
        } else {
          newFieldData[key] = value;
        }
      }
      processedCustomFields[fieldId] = newFieldData;
    }

    return (fields: jsonEncode(processedCustomFields), files: processedFiles);
  }

  Future<DataOutput<ItemModel>> fetchMyFeaturedItems({int? page}) async {
    try {
      Map<String, dynamic> parameters = {
        Api.status: "featured",
        Api.page: page,
      };

      Map<String, dynamic> response = await Api.get(
        url: Api.getMyItemApi,
        queryParameters: parameters,
      );
      List<ItemModel> itemList = (response['data']['data'] as List)
          .map((element) => ItemModel.fromJson(element))
          .toList();

      return DataOutput(
        total: response['data']['total'] ?? 0,
        modelList: itemList,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchMyItems({
    String? getItemsWithStatus,
    int? page,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        if (getItemsWithStatus != null) Api.status: getItemsWithStatus,
        if (page != null) Api.page: page,
      };

      if (parameters[Api.status] == "") parameters.remove(Api.status);
      Map<String, dynamic> response = await Api.get(
        url: Api.getMyItemApi,
        queryParameters: parameters,
      );
      List<ItemModel> itemList = (response['data']['data'] as List)
          .map((element) => ItemModel.fromJson(element))
          .toList();

      return DataOutput(
        total: response['data']['total'] ?? 0,
        modelList: itemList,
      );
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchItemFromItemId(
    int id, {
    bool isMyAd = false,
  }) async {
    Map<String, dynamic> parameters = {Api.id: id};

    Map<String, dynamic> response = await Api.get(
      url: isMyAd ? Api.getMyItemApi : Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> modelList = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: modelList.length, modelList: modelList);
  }

  Future<DataOutput<ItemModel>> fetchItemFromItemSlug(
    String slug, {
    bool isMyAd = false,
  }) async {
    Map<String, dynamic> parameters = {Api.slug: slug};

    Map<String, dynamic> response = await Api.get(
      url: isMyAd ? Api.getMyItemApi : Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> modelList = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: modelList.length, modelList: modelList);
  }

  Future<Map> changeMyItemStatus({
    required int itemId,
    required String status,
    int? userId,
  }) async {
    Map response = await Api.post(
      url: Api.updateItemStatusApi,
      parameter: {
        Api.status: status,
        Api.itemId: itemId,
        if (userId != null) Api.soldTo: userId,
      },
    );
    return response;
  }

  Future<Map> createFeaturedAds({required int itemId}) async {
    Map response = await Api.post(
      url: Api.makeItemFeaturedApi,
      parameter: {Api.itemId: itemId},
    );
    return response;
  }

  Future<DataOutput<ItemModel>> fetchItemFromCatId({
    required int categoryId,
    required int page,
    LeafLocation? location,
    String? search,
    String? sortBy,
    ItemFilter? filter,
    int? excludedItemId,
  }) async {
    Map<String, dynamic> parameters = {
      Api.categoryId: categoryId,
      Api.page: page,
      Api.excludedItemId: ?excludedItemId,
    };

    if (filter != null) {
      parameters.addAll(filter.toJson);

      if (filter.customFields != null) {
        filter.customFields!.forEach((key, value) {
          if (value is List) {
            parameters[key] = value.map((v) => v.toString()).join(',');
          } else {
            parameters[key] = value.toString();
          }
        });
      }
    } else if (location != null) {
      parameters.addAll(location.toApiJson());
    }

    if (search != null) {
      parameters[Api.search] = search;
    }

    if (sortBy != null) {
      parameters[Api.sortBy] = sortBy;
    }

    Map<String, dynamic> response = await Api.get(
      url: Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> items = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: response['data']['total'] ?? 0, modelList: items);
  }

  Future<DataOutput<ItemModel>> fetchPopularItems({
    required String sortBy,
    required int page,
    required LeafLocation? location,
  }) async {
    Map<String, dynamic> parameters = {
      Api.sortBy: sortBy,
      Api.page: page,
      ...?location?.toApiJson(),
    };

    Map<String, dynamic> response = await Api.get(
      url: Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> items = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: response['data']['total'] ?? 0, modelList: items);
  }

  Future<void> deleteItem({int? id, Iterable<int>? ids}) async {
    assert(
      (id != null) ^ (ids != null),
      "Either id or ids should be present but not both",
    );
    Map<String, dynamic> parameters = {};
    if (id != null) {
      parameters[Api.itemId] = id;
    } else {
      parameters[Api.itemIds] = ids!.join(",");
    }
    await Api.post(url: Api.deleteItemApi, parameter: parameters);
  }

  Future<void> itemTotalClick(int id) async {
    await Api.post(url: Api.setItemTotalClickApi, parameter: {Api.itemId: id});
  }

  Future<Json> makeAnOfferItem(int id, double? amount) async {
    try {
      final response = await Api.post(
        url: Api.itemOfferApi,
        parameter: {Api.itemId: id, Api.amount: ?amount},
      );

      final responseMap = response['data'] as Json;
      final itemMap = responseMap.remove('item');
      itemMap['formatted_price'] = responseMap['item_formatted_price'];

      final user = Chat.fromJson({
        ...response['data'] as Json,
        'item': itemMap,
        'last_message_time': response['data']['updated_at'] as String,
        'item_id': int.parse(response['data']['item_id'].toString()),
        'formatted_amount':
            response['data']['item_offer_formatted_amount'] as String?,
      });

      return {'message': response['message'] as String, 'data': user};
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> searchItem(
    String query,
    ItemFilter? filter, {
    required int page,
  }) async {
    Map<String, dynamic> parameters = {
      Api.search: query,
      Api.page: page,
      if (filter != null) ...filter.toJson,
    };

    if (filter != null) {
      parameters.remove(Api.area);
      if (filter.customFields != null) {
        parameters.addAll(filter.customFields!);
      }
    }

    Map<String, dynamic> response = await Api.get(
      url: Api.getItemApi,
      queryParameters: parameters,
    );

    List<ItemModel> items = (response['data']['data'] as List)
        .map((e) => ItemModel.fromJson(e))
        .toList();

    return DataOutput(total: response['data']['total'] ?? 0, modelList: items);
  }

  Future<Json> getItem({required ItemMetaData metadata, int page = 1}) async {
    try {
      final response = await Api.get(
        url: Api.getItemApi,
        queryParameters: {...metadata.toJson, Api.page: page},
      );

      final items = JsonHelper.parseList(
        response['data']['data'] as List?,
        ItemModel.fromJson,
      );

      final hasMore = items.length == response['data']['per_page'] as int;

      return {'data': items, 'has_more': hasMore};
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'getItem');
      log('$stack', name: 'getItem');
      throw ApiException(e.toString());
    }
  }

  Future<ItemStatus> getItemStatus({required int itemId}) async {
    try {
      final response = await Api.get(
        url: Api.getItemStatusApi,
        queryParameters: {'item_id': itemId},
      );

      final status = ItemStatus.parse(response['data']['status'] as String);

      return status;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      return ItemStatus.unknown;
    }
  }
}
