import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/select_category.dart';
import 'package:eClassify/ui/screens/main_activity.dart';
import 'package:eClassify/utils/ad_posting_wizard_cleanup.dart';
import 'package:flutter/material.dart';

/// Pops post-ad routes (confirm, success, wizard) back to home or ad details.
abstract final class AdPostingSuccessNavigation {
  static void _prepareExit() {
    screenStack = 0;
    if (AppConfig.enableAdPostingWizardSessionResetV214) {
      AdPostingWizardCleanup.prepareForNewSession();
    }
  }

  static void exitToHome(BuildContext context) {
    _prepareExit();
    Navigator.popUntil(context, (route) => route.isFirst);
    MainActivity.globalKey.currentState?.onItemTapped(0);
  }

  static void exitToAdDetails(BuildContext context, {required ItemModel model}) {
    _prepareExit();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushNamed(
      context,
      Routes.adDetailsScreen,
      arguments: {'model': model},
    );
  }
}
