import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/reel_subscription_access.dart';
import 'package:eClassify/utils/reel_subscription_refresh.dart';
import 'package:eClassify/utils/subscription_navigation.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

enum _ProfileSubscriptionHintMode {
  none,
  needsListingPlan,
  needsReelUpgrade,
}

/// Profile **Subscription** row with optional reel upgrade subtitle.
class ProfileSubscriptionTile extends StatefulWidget {
  const ProfileSubscriptionTile({
    super.key,
    required this.buildTile,
  });

  final Widget Function(
    BuildContext context, {
    required String title,
    required String svgImagePath,
    String? subtitle,
    required VoidCallback onTap,
  }) buildTile;

  @override
  State<ProfileSubscriptionTile> createState() =>
      _ProfileSubscriptionTileState();
}

class _ProfileSubscriptionTileState extends State<ProfileSubscriptionTile> {
  String? _subtitle;
  _ProfileSubscriptionHintMode _hintMode = _ProfileSubscriptionHintMode.none;

  @override
  void initState() {
    super.initState();
    _refreshHint();
    ReelSubscriptionRefresh.activePlansRevision.addListener(_refreshHint);
    ReelSubscriptionRefresh.profileHintRevision.addListener(_refreshHint);
  }

  @override
  void dispose() {
    ReelSubscriptionRefresh.activePlansRevision.removeListener(_refreshHint);
    ReelSubscriptionRefresh.profileHintRevision.removeListener(_refreshHint);
    super.dispose();
  }

  Future<void> _refreshHint() async {
    if (!HiveUtils.isUserAuthenticated()) {
      if (mounted) {
        setState(() {
          _subtitle = null;
          _hintMode = _ProfileSubscriptionHintMode.none;
        });
      }
      return;
    }

    if (!AppConfig.enableProfileReelSubscriptionHintV214) {
      if (mounted) {
        setState(() {
          _subtitle = null;
          _hintMode = _ProfileSubscriptionHintMode.none;
        });
      }
      return;
    }

    final snap = await ReelSubscriptionAccess.fetchGateSnapshot();
    if (!mounted) return;

    if (AppConfig.enableProfileReelHintNoListingPlanV214 &&
        !snap.hasActiveListingPlan) {
      setState(() {
        _hintMode = _ProfileSubscriptionHintMode.needsListingPlan;
        _subtitle = 'profileNeedsListingPlanHint'.translate(context);
      });
      return;
    }

    if (!snap.reelFeaturesAllowed && snap.hasActiveListingPlan) {
      setState(() {
        _hintMode = _ProfileSubscriptionHintMode.needsReelUpgrade;
        _subtitle = 'profileReelUpgradeHint'.translate(context);
      });
      return;
    }

    setState(() {
      _hintMode = _ProfileSubscriptionHintMode.none;
      _subtitle = null;
    });
  }

  void _onTap() {
    UiUtils.checkUser(
      onNotGuest: () {
        switch (_hintMode) {
          case _ProfileSubscriptionHintMode.needsReelUpgrade:
            if (AppConfig.enableProfileReelDirectCatalogV214) {
              SubscriptionNavigation.openItemListingPackagesForReels(context);
              return;
            }
            break;
          case _ProfileSubscriptionHintMode.needsListingPlan:
            if (AppConfig.enableProfileDirectListingCatalogV214) {
              SubscriptionNavigation.openItemListingPackages(context);
              return;
            }
            break;
          case _ProfileSubscriptionHintMode.none:
            break;
        }
        if (AppConfig.enableProfileDefaultListingCatalogV214) {
          SubscriptionNavigation.openPrimaryAdListingCatalog(context);
        } else {
          SubscriptionNavigation.openPackageCatalog(context);
        }
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.buildTile(
      context,
      title: 'subscription'.translate(context),
      svgImagePath: AppIcons.subscription,
      subtitle: _subtitle,
      onTap: _onTap,
    );
  }
}
