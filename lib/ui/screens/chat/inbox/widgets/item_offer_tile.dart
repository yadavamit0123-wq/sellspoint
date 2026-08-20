import 'dart:math';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/chat/item_offer.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/profile_avatar.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_assets.dart';

import 'package:eClassify/utils/app_session.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemOfferTile extends StatelessWidget {
  const ItemOfferTile({required this.offer, super.key});

  final ItemOffer offer;

  @override
  Widget build(BuildContext context) {
    final userCount = min(4, offer.users.length);
    final remainingUserCount = offer.remainingUsers;

    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.sellerItemChatScreen,
          arguments: {'item_id': offer.id, 'offer': offer},
        );
      },
      leading: ProfileAvatar(src: offer.image, size: Size.square(40)),
      title: Text(
        offer.name,
        style: context.titleSmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: SizedBox(
        width: 60,
        height: 20,
        child: Stack(
          children: List.generate(userCount + 1, (index) {
            if (index == userCount) {
              return remainingUserCount <= 0
                  ? const SizedBox.shrink()
                  : PositionedDirectional(
                      start: 10 * (userCount + 1) + 5,
                      child: Text(
                        '+${remainingUserCount}',
                        style: context.labelMedium,
                      ),
                    );
            }
            return PositionedDirectional(
              start: 10.0 * (userCount - index - 1),
              child: CustomImage(
                src: offer.users[userCount - index - 1].profile,
                size: Size.square(20),
                radius: 10,
                errorImage: CircleAvatar(
                  backgroundColor: context.colorScheme.primary,
                  radius: 10,
                  child: CustomImage(
                    src: AppAssets.profile.profile,
                    size: Size.square(15),
                    radius: 10,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 5,
        children: [
          Text(
            timeago.format(
              offer.lastUpdatedAt,
              locale: '${AppSession.currentLocale}_short',
            ),
            style: context.labelMedium.withColor(context.mutedColor),
          ),
          if (offer.totalUnreadCount != 0)
            Badge(
              backgroundColor: context.colorScheme.primary,
              label: Text('${offer.totalUnreadCount}'),
            ),
        ],
      ),
    );
  }
}
