import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/item/item_model.dart';

abstract final class ItemVideoHelper {
  static bool isVideoListing(ItemModel item) {
    final raw = item.itemType?.trim().toLowerCase();
    if (raw == null || raw.isEmpty) return false;
    return raw == AdItemType.videoAd.value || raw == 'video_ad';
  }

  static bool hasVideoUrl(ItemModel item) {
    return item.videoLink != null && item.videoLink!.trim().isNotEmpty;
  }

  /// Reels tab shortcut / feed entry when media exists or listing is live.
  static bool isPlayableForReelsShortcut(ItemModel item) {
    if (!isVideoListing(item)) return false;
    return hasVideoUrl(item) ||
        item.status == 'active' ||
        item.status == 'approved';
  }
}
