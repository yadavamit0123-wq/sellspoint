import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/reel_upload_status_banner.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/item_video_helper.dart';
import 'package:eClassify/utils/main_navigation_v214.dart';
import 'package:eClassify/utils/reel_feature_gate.dart';
import 'package:eClassify/utils/reel_upload_tracker.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/video_ad_editor_launcher.dart';
import 'package:flutter/material.dart';

/// Owner-only reel upload status + CTA on [AdDetailsScreen].
class SellerReelOwnerSection extends StatelessWidget {
  const SellerReelOwnerSection({super.key, required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.enableSellerReelOwnerSectionV214 || item.id == null) {
      return const SizedBox.shrink();
    }

    final itemId = item.id.toString();
    final uploadStatus = ReelUploadTracker.statusForItem(itemId);
    final isVideo = ItemVideoHelper.isVideoListing(item);
    if (!isVideo && uploadStatus == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isVideo)
            Row(
              children: [
                Icon(
                  Icons.videocam_outlined,
                  size: 18,
                  color: context.color.territoryColor,
                ),
                const SizedBox(width: 6),
                CustomText(
                  'videoListingTypeLabel'.translate(context),
                  fontWeight: FontWeight.w600,
                  color: context.color.textDefaultColor,
                ),
                if (item.status == 'review') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomText(
                      'videoListingUnderReview'.translate(context),
                      fontSize: context.font.small,
                      color: context.color.textLightColor,
                      maxLines: 2,
                    ),
                  ),
                ],
              ],
            ),
          if (uploadStatus != null) ...[
            const SizedBox(height: 10),
            ReelUploadStatusBanner(itemId: itemId),
          ],
          if (isVideo && uploadStatus == null) ...[
            const SizedBox(height: 10),
            UiUtils.buildButton(
              context,
              height: 44,
              radius: 10,
              buttonTitle: 'sellerReelUploadCta'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: () async {
                if (!await ReelFeatureGate.ensureAllowed(context)) return;
                if (!context.mounted) return;
                VideoAdEditorLauncher.openForExistingItem(
                  context,
                  itemId: item.id!,
                );
              },
            ),
          ],
          if (isVideo &&
              (item.status == 'active' || item.status == 'approved')) ...[
            const SizedBox(height: 8),
            UiUtils.buildButton(
              context,
              height: 40,
              radius: 10,
              buttonTitle: 'viewReelForListing'.translate(context),
              buttonColor: context.color.secondaryColor,
              textColor: context.color.textDefaultColor,
              onPressed: () {
                MainNavigationV214.openReelsTab(itemId: item.id);
              },
            ),
          ],
        ],
      ),
    );
  }
}
