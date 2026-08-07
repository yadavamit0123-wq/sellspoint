import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/utils/api.dart';

/// Normalizes post-ad API maps before [ManageItemCubit] / cloud handoff.
abstract final class AdPostingItemPayload {
  static void ensureItemType(
    Map<String, dynamic> payload, {
    AdItemType? adType,
  }) {
    final resolved = adType ?? AdItemType.regularAd;
    payload[Api.itemType] = resolved.value;
  }
}
