import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:flutter/material.dart';

/// Opens [Routes.videoAdEditor] stub or legacy reels/post-ad paths.
abstract final class VideoAdEditorLauncher {
  static void open(BuildContext context) {
    if (AppConfig.enableVideoAdEditorRouteV214) {
      Navigator.pushNamed(context, Routes.videoAdEditor);
      return;
    }
    Navigator.pushNamed(
      context,
      Routes.videoAdsScreen,
      arguments: {'show_current_user_reel': true},
    );
  }
}
