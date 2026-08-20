import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/reel_actions.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/reel_item_card.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/reel_user_card.dart';
import 'package:flutter/material.dart';

class ReelFeedHudOverlay extends StatelessWidget {
  const ReelFeedHudOverlay({
    required this.videoAd,
    required this.isMutedNotifier,
    super.key,
  });

  final VideoAd videoAd;
  final ValueNotifier<bool> isMutedNotifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 32,
      children: [
        Expanded(
          child: Column(
            spacing: 16,
            children: [
              if (videoAd.item.user != null)
                ReelUserCard(user: videoAd.item.user!),
              ReelItemCard(item: videoAd.item),
            ],
          ),
        ),
        ReelActions(ad: videoAd, isMutedNotifier: isMutedNotifier),
      ],
    );
  }
}
