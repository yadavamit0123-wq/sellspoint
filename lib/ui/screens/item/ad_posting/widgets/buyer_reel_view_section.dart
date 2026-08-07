import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/item_video_helper.dart';
import 'package:eClassify/utils/main_navigation_v214.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

/// Buyer CTA on video listings with playable reel media.
class BuyerReelViewSection extends StatelessWidget {
  const BuyerReelViewSection({super.key, required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.enableAdDetailsBuyerViewReelsCtaV214 ||
        !AppConfig.enableFiveTabNavV214 ||
        item.id == null ||
        !ItemVideoHelper.isPlayableForReelsShortcut(item)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: UiUtils.buildButton(
        context,
        height: 44,
        radius: 10,
        buttonTitle: 'adDetailsWatchInReels'.translate(context),
        buttonColor: context.color.territoryColor,
        textColor: context.color.secondaryColor,
        onPressed: () {
          MainNavigationV214.openReelsTab(itemId: item.id);
        },
      ),
    );
  }
}
