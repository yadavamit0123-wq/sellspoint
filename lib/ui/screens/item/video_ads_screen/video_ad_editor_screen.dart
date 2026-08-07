import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/video_ad_trimmer_panel.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/video_ad_thumbnail_utility.dart';
import 'package:flutter/material.dart';

/// Reel editor — [VideoAdTrimmerPanel] when trimmer flag is on, else legacy stub.
class VideoAdEditorScreen extends StatefulWidget {
  const VideoAdEditorScreen({super.key, this.from});

  final String? from;

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map? ?? {};
    return BlurredRouter(
      builder: (_) => VideoAdEditorScreen(
        from: args['from']?.toString(),
      ),
    );
  }

  @override
  State<VideoAdEditorScreen> createState() => _VideoAdEditorScreenState();
}

class _VideoAdEditorScreenState extends State<VideoAdEditorScreen> {
  File? _previewFile;

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
            if (!trimmerEnabled)
              CustomText(
                'videoAdEditorBody'.translate(context),
                color: context.color.textLightColor,
              )
            else ...[
              if (_previewFile != null) ...[
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
            if (!trimmerEnabled) const Spacer(),
            UiUtils.buildButton(
              context,
              width: context.screenWidth,
              height: 48,
              radius: 10,
              buttonTitle: 'postAdTitle'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: _openListingWizard,
            ),
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
        ),
      ),
    );
  }
}
