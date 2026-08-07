import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/reel_subscription_access.dart';
import 'package:eClassify/utils/reel_subscription_refresh.dart';
import 'package:eClassify/utils/subscription_navigation.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _refreshHint();
    ReelSubscriptionRefresh.activePlansRevision.addListener(_refreshHint);
  }

  @override
  void dispose() {
    ReelSubscriptionRefresh.activePlansRevision.removeListener(_refreshHint);
    super.dispose();
  }

  Future<void> _refreshHint() async {
    if (!AppConfig.enableProfileReelSubscriptionHintV214 ||
        !HiveUtils.isUserAuthenticated()) {
      if (mounted) setState(() => _subtitle = null);
      return;
    }
    final prompt = await ReelSubscriptionAccess.shouldPromptReelUpgrade();
    if (!mounted) return;
    setState(() {
      _subtitle = prompt ? 'profileReelUpgradeHint'.translate(context) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.buildTile(
      context,
      title: 'subscription'.translate(context),
      svgImagePath: AppIcons.subscription,
      subtitle: _subtitle,
      onTap: () {
        UiUtils.checkUser(
          onNotGuest: () {
            SubscriptionNavigation.openPackageCatalog(context);
          },
          context: context,
        );
      },
    );
  }
}
