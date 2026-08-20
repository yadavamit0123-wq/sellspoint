 import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/reel_chat_button.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/reel_like_button.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/tap_guard.dart';
import 'package:flutter/material.dart';

class ReelActions extends StatelessWidget {
  const ReelActions({
    required this.ad,
    required this.isMutedNotifier,
    super.key,
  });

  final VideoAd ad;
  final ValueNotifier<bool> isMutedNotifier;

  @override
  Widget build(BuildContext context) {
    final myId = HiveUtils.getUserId();
    final TapGuard _guard = TapGuard();
    return Theme(
      data: context.theme.copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: .2),
            foregroundColor: Colors.white,
            minimumSize: Size.square(40),
            fixedSize: Size.square(40),
          ),
        ),
      ),
      child: Column(
        spacing: 24,
        children: [
          ReelLikeButton(ad: ad),
          if (myId != ad.item.userId?.toString()) ReelChatButton(ad: ad),
          _IconButtonWithText(
            onPressed: () {
              _guard.run(() async {
                HelperUtils.shareItem(context, 'reel', ad.id.toString());
              });
            },
            icon: AppIcons.shareNetwork,
            text: 'share'.translate(context),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isMutedNotifier,
            builder: (context, isMuted, child) {
              return _IconButtonWithText(
                onPressed: () {
                  isMutedNotifier.value = !isMuted;
                },
                icon: isMuted ? AppIcons.speakerX : AppIcons.speakerHigh,
                text: 'sound'.translate(context),
              );
            },
          ),
          8.vGap,
        ],
      ),
    );
  }
}

class _IconButtonWithText extends StatelessWidget {
  const _IconButtonWithText({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String? text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(onPressed: onPressed, icon: Icon(icon)),
        if (text.isNotNullAndNotEmpty)
          Text(text!, style: context.titleSmall.withColor(Colors.white)),
      ],
    );
  }
}
