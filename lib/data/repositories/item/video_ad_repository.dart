import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';

class VideoAdRepository {
  VideoAdRepository._internal();

  static final VideoAdRepository instance = VideoAdRepository._internal();

  Map<String, dynamic> _locationQueryParameters() {
    final radius = HiveUtils.getNearbyRadius();
    if (radius != null) {
      return {
        'radius': radius,
        if (HiveUtils.getLatitude() != null)
          'latitude': HiveUtils.getLatitude(),
        if (HiveUtils.getLongitude() != null)
          'longitude': HiveUtils.getLongitude(),
      };
    }
    return {
      if (HiveUtils.getCityName()?.isNotEmpty == true)
        'city': HiveUtils.getCityName(),
      if (HiveUtils.getAreaId() != null) 'area_id': HiveUtils.getAreaId(),
      if (HiveUtils.getCountryName()?.isNotEmpty == true)
        'country': HiveUtils.getCountryName(),
      if (HiveUtils.getStateName()?.isNotEmpty == true)
        'state': HiveUtils.getStateName(),
    };
  }

  Future<DataOutput<VideoAd>> getVideoAds({
    int? reelId,
    int? itemId,
    bool following = false,
    int page = 1,
    bool showCurrentUserReel = false,
  }) async {
    try {
      final parameters = <String, dynamic>{
        ..._locationQueryParameters(),
        'per_page': 10,
        'page': page,
        if (reelId != null) 'reel_id': reelId,
        if (itemId != null) 'item_id': itemId,
        if (following) 'following': 1,
      };
      parameters.removeWhere((_, v) => v == null);

      final response = await Api.get(
        url: showCurrentUserReel ? Api.getMyReelsApi : Api.getReelsApi,
        queryParameters: parameters,
      );

      final data = response['data'];
      final list = (data is Map ? data['data'] : null) as List? ?? [];
      final ads = list
          .map((e) => VideoAd.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final total = data is Map ? (data['total'] ?? ads.length) : ads.length;

      return DataOutput(total: total, modelList: ads);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> manageReelLike({required int reelId}) async {
    await Api.post(
      url: Api.manageReelLikeApi,
      parameter: {'reel_id': reelId},
    );
  }
}
