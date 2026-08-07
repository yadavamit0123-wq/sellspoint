import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/utils/video_ad_editor_draft.dart';

/// Applies [VideoAdEditorDraft] into the in-app post-ad wizard.
abstract final class AdPostingReelDraftBridge {
  static bool get hasDraft => VideoAdEditorDraft.hasVideo;

  static void applyToCubit(AdPostingCubit cubit) {
    if (!VideoAdEditorDraft.hasVideo) return;
    cubit.updateData(
      (d) => d.copyWith(
        adType: AdItemType.videoAd,
        reelVideoFile: VideoAdEditorDraft.trimmedVideo,
        reelThumbnailFile: VideoAdEditorDraft.thumbnailFile,
      ),
    );
  }
}
