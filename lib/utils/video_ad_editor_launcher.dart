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

  /// Leaves in-app post-ad wizard for the video editor stub.
  static Future<Object?> openFromAdPostingWizard(BuildContext context) {
    if (AppConfig.enableVideoAdEditorRouteV214) {
      if (AppConfig.enableAdPostingVideoEditorReturnToWizardV214) {
        return Navigator.pushNamed(
          context,
          Routes.videoAdEditor,
          arguments: const {'from': 'adPostingWizard'},
        );
      }
      Navigator.pushReplacementNamed(
        context,
        Routes.videoAdEditor,
        arguments: const {'from': 'adPostingWizard'},
      );
      return Future.value(null);
    }
    open(context);
    return Future.value(null);
  }

  /// Trim + background upload for an existing listing ([Api.uploadMediaApi]).
  static Future<Object?> openForExistingItem(
    BuildContext context, {
    required int itemId,
  }) {
    if (AppConfig.enableVideoAdEditorRouteV214) {
      return Navigator.pushNamed(
        context,
        Routes.videoAdEditor,
        arguments: {
          'from': 'existingListing',
          'attach_item_id': itemId,
        },
      );
    }
    open(context);
    return Future.value(null);
  }
}
