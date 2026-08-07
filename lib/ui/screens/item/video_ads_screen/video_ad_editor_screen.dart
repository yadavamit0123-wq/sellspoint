import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

/// 2.14 reel editor route — full trimmer pending; links to listing + reels feed.
class VideoAdEditorScreen extends StatelessWidget {
  const VideoAdEditorScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(builder: (_) => const VideoAdEditorScreen());
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'videoAdEditorBody'.translate(context),
              color: context.color.textLightColor,
            ),
            const Spacer(),
            UiUtils.buildButton(
              context,
              width: context.screenWidth,
              height: 48,
              radius: 10,
              buttonTitle: 'postAdTitle'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.adPostingScreen,
                );
              },
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
