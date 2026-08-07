import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/reel_subscription_access.dart';
import 'package:eClassify/utils/subscription_navigation.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

abstract final class ReelFeatureGate {
  static Future<bool> ensureAllowed(BuildContext context) async {
    if (!AppConfig.enableReelSubscriptionGateV214) {
      return true;
    }

    final snap = await ReelSubscriptionAccess.fetchGateSnapshot();
    if (!context.mounted) return false;

    if (AppConfig.enableReelGateRequiresListingPlanV214 &&
        !snap.hasActiveListingPlan) {
      if (AppConfig.enableReelSubscriptionUpgradePromptV214) {
        await _showListingPlanRequiredDialog(context);
      } else {
        UiUtils.showSnackBarMessage(
          context,
          'reelNeedsListingPlanBody'.translate(context),
        );
      }
      return false;
    }

    if (!snap.reelFeaturesAllowed) {
      if (AppConfig.enableReelSubscriptionUpgradePromptV214) {
        await _showUpgradeDialog(context);
      } else {
        UiUtils.showSnackBarMessage(
          context,
          'reelNotIncludedInPlan'.translate(context),
        );
      }
      return false;
    }
    return true;
  }

  static Future<void> _showListingPlanRequiredDialog(BuildContext context) {
    return UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: 'reelNeedsListingPlanTitle'.translate(context),
        acceptButtonName: 'subscribe'.translate(context),
        cancelButtonName: 'cancelLbl'.translate(context),
        acceptButtonColor: context.color.territoryColor,
        acceptTextColor: context.color.secondaryColor,
        content: CustomText('reelNeedsListingPlanBody'.translate(context)),
        isAcceptContainerPush: false,
        onAccept: () async {
          if (!context.mounted) return;
          if (AppConfig.enableReelGateDirectListingCatalogV214) {
            SubscriptionNavigation.openItemListingPackages(context);
          } else {
            SubscriptionNavigation.openPrimaryAdListingCatalog(context);
          }
        },
      ),
    );
  }

  static Future<void> _showUpgradeDialog(BuildContext context) {
    return UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: 'reelUpgradeDialogTitle'.translate(context),
        acceptButtonName: 'subscribe'.translate(context),
        cancelButtonName: 'cancelLbl'.translate(context),
        acceptButtonColor: context.color.territoryColor,
        acceptTextColor: context.color.secondaryColor,
        content: CustomText('reelNotIncludedInPlan'.translate(context)),
        isAcceptContainerPush: false,
        onAccept: () async {
          if (!context.mounted) return;
          if (AppConfig.enableReelSubscriptionDirectListingV214) {
            SubscriptionNavigation.openItemListingPackagesForReels(context);
          } else {
            SubscriptionNavigation.openPrimaryAdListingCatalog(context);
          }
        },
      ),
    );
  }
}
