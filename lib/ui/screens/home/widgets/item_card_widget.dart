import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/home/widgets/favorite_button.dart';
import 'package:eClassify/ui/screens/widgets/contained_blur_image.dart';
import 'package:eClassify/ui/screens/widgets/promoted_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemCard extends StatelessWidget {
  const ItemCard({
    required this.item,
    this.aspectRatio = 3 / 2,
    this.onTap,
    super.key,
  });

  final ItemModel? item;
  final VoidCallback? onTap;
  final double aspectRatio;

  // Cache the border radius to avoid repeated allocations
  static final _borderRadius = BorderRadius.circular(18);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {"item_id": item!.id},
        );
      },
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: context.color.textLightColor.withValues(alpha: 0.13),
              width: 1,
            ),
            color: context.color.secondaryColor,
            borderRadius: _borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.sizeOf(context).width;
                    final itemWidth =
                        (screenWidth - (2 * Constant.horizontalPadding) - 12) /
                        2;
                    final cardHeight = itemWidth / aspectRatio;
                    final imageAreaHeight = cardHeight * (6 / 10);
                    final size = Size(itemWidth, imageAreaHeight);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: _borderRadius,
                            child: ContainedBlurImage(
                              key: ValueKey(item?.id),
                              src: item?.image ?? '',
                              size: size,
                              radius: 18,
                              adaptive: true,
                            ),
                          ),
                        ),
                        if (item?.isFeature ?? false)
                          const PositionedDirectional(
                            start: 10,
                            top: 10,
                            child: PromotedCard(),
                          ),
                        PositionedDirectional(
                          bottom: -10,
                          end: 10,
                          child: FavoriteButton(item: item!),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (UiUtils.displayPrice(item!))
                        UiUtils.getPriceWidget(item!, context),
                      Text(
                        item!.translatedName ?? item!.name!,
                        style: context.bodyMedium,
                        maxLines: 1,
                      ),
                      if (item?.translatedAddress != "")
                        Row(
                          children: [
                            Icon(
                              AppIcons.mapPinLine,
                              size: 14,
                              color: context.mutedColor,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 3.0,
                                ),
                                child: Text(
                                  UiUtils.formatDisplayAddress(
                                    item?.translatedAddress ?? '',
                                  ),
                                  maxLines: 1,
                                  style: context.bodySmall.withColor(
                                    context.mutedColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (item?.created != "")
                        Row(
                          children: [
                            Icon(
                              AppIcons.clock,
                              size: 14,
                              color: context.mutedColor,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 3.0,
                                ),
                                child: Text(
                                  timeago.format(
                                    DateTime.parse(item!.created!),
                                    locale: AppSession.currentLocale,
                                  ),
                                  maxLines: 1,
                                  style: context.bodySmall.withColor(
                                    context.mutedColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
