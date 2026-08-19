import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/utils/json_helper.dart';

class VideoAd {
  VideoAd({
    required this.id,
    required this.itemId,
    required this.video,
    required this.thumbnail,
    required this.likeCount,
    required this.isLiked,
    required this.item,
  });

  VideoAd.fromJson(Json json)
    : id = json['id'] as int,
      itemId = json['item_id'] as int,
      video = json['video'] as String,
      thumbnail = json['thumbnail'] as String,
      likeCount = json['liked_count'] as int,
      isLiked = json['is_liked'] as bool? ?? false,
      item = JsonHelper.parseObject(json['item'] as Json, ItemModel.fromJson);

  final int id;
  final int itemId;
  final String video;
  final String thumbnail;
  final int likeCount;
  final bool isLiked;
  final ItemModel item;

  VideoAd copyWith({int? likeCount, bool? isLiked}) {
    return VideoAd(
      id: id,
      itemId: itemId,
      video: video,
      thumbnail: thumbnail,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      item: item,
    );
  }
}
