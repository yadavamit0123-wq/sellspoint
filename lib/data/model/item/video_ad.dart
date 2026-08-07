import 'package:eClassify/data/model/item/item_model.dart';

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

  factory VideoAd.fromJson(Map<String, dynamic> json) {
    ItemModel? item;
    final rawItem = json['item'];
    if (rawItem is Map) {
      item = ItemModel.fromJson(Map<String, dynamic>.from(rawItem));
    }
    return VideoAd(
      id: (json['id'] as num).toInt(),
      itemId: (json['item_id'] as num).toInt(),
      video: (json['video'] ?? '').toString(),
      thumbnail: (json['thumbnail'] ?? '').toString(),
      likeCount: (json['liked_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] == true || json['is_liked'] == 1,
      item: item ?? ItemModel(id: json['item_id'] as int?),
    );
  }

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
