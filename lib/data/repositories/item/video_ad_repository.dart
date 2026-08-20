import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';

class VideoAdRepository {
  VideoAdRepository._internal();

  static final VideoAdRepository _instance = VideoAdRepository._internal();

  static VideoAdRepository get instance => _instance;

  Future<DataOutput<VideoAd>> getVideoAds({
    LeafLocation? location,
    int? reelId,
    int? itemId,
    bool following = false,
    int page = 1,
    bool showCurrentUserReel = false,
  }) async {
    try {
      final response = await Api.get(
        url: showCurrentUserReel ? Api.getMyReelsApi : Api.getReelsApi,
        queryParameters: {
          ...?location?.toApiJson(),
          'item_id': ?itemId,
          'reel_id': ?reelId,
          'following': ?(following ? 1 : null),
          'per_page': 10,
          'page': page,
        },
      );

      final ads = JsonHelper.parseList(
        response['data']?['data'] as List?,
        VideoAd.fromJson,
      );

      final total = response['data']?['total'] ?? 0;

      return DataOutput(total: total, modelList: ads);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<DataOutput<VideoAd>> getLikedReels({int page = 1}) async {
    try {
      final response = await Api.get(
        url: Api.getLikedReelsApi,
        queryParameters: {'per_page': 10, 'page': page},
      );

      final ads = JsonHelper.parseList(
        response['data']?['data'] as List?,
        VideoAd.fromJson,
      );

      final total = response['data']?['total'] ?? 0;

      return DataOutput(total: total, modelList: ads);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> manageReelLike({required int reelId}) async {
    try {
      await Api.post(
        url: Api.manageReelLikeApi,
        parameter: {'reel_id': reelId},
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
