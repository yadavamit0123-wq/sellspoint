import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/item/ad_posting_data.dart';
import 'package:eClassify/utils/api.dart';

/// When a local reel is attached, skip optional YouTube/external [Api.videoLink].
abstract final class AdPostingVideoLinkPolicy {
  static bool hasLocalReel(AdPostingData data) => data.reelVideoFile != null;

  static bool shouldShowLinkField(AdPostingData data) {
    if (!AppConfig.enableAdPostingHideVideoLinkWhenReelV214) {
      return true;
    }
    return !hasLocalReel(data);
  }

  static String? linkForCreatePayload(AdPostingData data, String? userInput) {
    if (AppConfig.enableAdPostingHideVideoLinkWhenReelV214 &&
        hasLocalReel(data)) {
      return null;
    }
    final trimmed = userInput?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  static void applyToPayload(
    Map<String, dynamic> payload,
    AdPostingData data, {
    String? userInput,
  }) {
    final link = linkForCreatePayload(data, userInput);
    if (link != null) {
      payload[Api.videoLink] = link;
    } else if (!AppConfig.enableAdPostingHideVideoLinkWhenReelV214 ||
        !hasLocalReel(data)) {
      payload[Api.videoLink] = '';
    }
  }
}
