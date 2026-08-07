import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/video_ad_trimmer_panel.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/reel_upload_payload.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/video_ad_editor_draft.dart';
import 'package:eClassify/utils/video_ad_thumbnail_utility.dart';
import 'package:flutter/material.dart';

/// Reel editor — [VideoAdTrimmerPanel] when trimmer flag is on, else legacy stub.
class VideoAdEditorScreen extends StatefulWidget {
  const VideoAdEditorScreen({super.key, this.from, this.attachItemId});

  final String? from;
  final int? attachItemId;

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map? ?? {};
    final attachRaw = args['attach_item_id'] ?? args['attachItemId'];
    return BlurredRouter(
      builder: (_) => VideoAdEditorScreen(
        from: args['from']?.toString(),
        attachItemId: attachRaw is int
            ? attachRaw
            : int.tryParse(attachRaw?.toString() ?? ''),
      ),
    );
  }

  @override
  State<VideoAdEditorScreen> createState() => _VideoAdEditorScreenState();
}

class _VideoAdEditorScreenState extends State<VideoAdEditorScreen> {
  File? _previewFile;
  bool _uploading = false;

  bool get _attachMode => widget.attachItemId != null;

  bool get _fromAdPostingWizard => widget.from == 'adPostingWizard';

  @override
  void initState() {
    super.initState();
    _previewFile = VideoAdEditorDraft.trimmedVideo;
  }

  Future<void> _onTrimmed(File file) async {
    VideoAdEditorDraft.trimmedVideo = file;
    VideoAdEditorDraft.thumbnailFile =
        await VideoAdThumbnailUtility.fromVideo(file);
    if (!mounted) return;
    setState(() => _previewFile = file);
    UiUtils.showSnackBarMessage(
      context,
      'successfullySaved'.translate(context),
    );
  }

  Future<void> _uploadToExistingListing() async {
    final itemId = widget.attachItemId;
    if (itemId == null || !VideoAdEditorDraft.hasVideo) {
      UiUtils.showSnackBarMessage(
        context,
        'selectVideo'.translate(context),
      );
      return;
    }
    setState(() => _uploading = true);
    final files = ReelUploadPayload.files(
      videoPath: VideoAdEditorDraft.trimmedVideo!.path,
      thumbnailPath: VideoAdEditorDraft.thumbnailFile?.path,
    );
    final ok = await ItemRepository().scheduleBackgroundMediaUpload(
      item: ItemModel(id: itemId),
      files: files,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    if (ok) {
      VideoAdEditorDraft.clear();
      UiUtils.showSnackBarMessage(
        context,
        'reelUploadInProgress'.translate(context),
      );
      Navigator.pop(context, 'reel_upload');
      return;
    }
    UiUtils.showSnackBarMessage(
      context,
      'somethingWentWrong'.translate(context),
    );
  }

  void _returnToWizard() {
    if (!VideoAdEditorDraft.hasVideo) {
      UiUtils.showSnackBarMessage(
        context,
        'selectVideo'.translate(context),
      );
      return;
    }
    Navigator.pop(context, 'reel_draft');
  }

  void _openListingWizard() {
    final hasVideo = VideoAdEditorDraft.hasVideo;
    Navigator.pushReplacementNamed(
      context,
      Routes.adPostingScreen,
      arguments: {
        'initialAdType': hasVideo
            ? AdItemType.videoAd.value
            : AdItemType.regularAd.value,
        'skipAdTypeStep': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmerEnabled = AppConfig.enableVideoAdEditorTrimmerV214;

    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'videoAdEditorTitle'.translate(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_attachMode)
              CustomText(
                'uploadReelToListingHint'.translate(context),
                color: context.color.textLightColor,
              ),
            if (!_attachMode && !trimmerEnabled)
              CustomText(
                'videoAdEditorBody'.translate(context),
                color: context.color.textLightColor,
              )
            else if (trimmerEnabled) ...[
              if (_previewFile != null) ...[
                const SizedBox(height: 8),
                CustomText(
                  'videoAds'.translate(context),
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 120,
                    color: context.color.borderColor.withValues(alpha: 0.2),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.check_circle,
                      color: context.color.territoryColor,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: VideoAdTrimmerPanel(onTrimmed: _onTrimmed),
              ),
            ],
            if (!trimmerEnabled && !_attachMode) const Spacer(),
            UiUtils.buildButton(
              context,
              width: context.screenWidth,
              height: 48,
              radius: 10,
              buttonTitle: _attachMode
                  ? 'uploadReelToListing'.translate(context)
                  : _fromAdPostingWizard
                      ? 'continue'.translate(context)
                      : 'postAdTitle'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: _uploading
                  ? () {}
                  : (_attachMode
                      ? _uploadToExistingListing
                      : _fromAdPostingWizard
                          ? _returnToWizard
                          : _openListingWizard),
            ),
            if (!_attachMode && !_fromAdPostingWizard) ...[
              const SizedBox(height: 12),
              UiUtils.buildButton(
                context,
                width: context.screenWidth,
                height: 48,
                radius: 10,
                buttonTitle: 'viewReels'.translate(context),
                buttonColor: context.color.secondaryColor,
                textColor: context.color.textDefaultColor,
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    Routes.videoAdsScreen,
                    arguments: {'show_current_user_reel': true},
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
