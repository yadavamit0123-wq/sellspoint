// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/home/widgets/favorite_button.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/promoted_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemHorizontalCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onDeleteTap;
  final bool? showLikeButton;
  final VoidCallback? onTap;

  const ItemHorizontalCard({
    super.key,
    required this.item,
    this.onDeleteTap,
    this.showLikeButton,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {"item_id": item.id},
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.5),
        child: RepaintBoundary(
          child: Container(
            height: 124,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.color.textLightColor.withValues(alpha: 0.28),
              ),
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 122,
                        maxWidth: 100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImage(
                          src: item.image ?? '',
                          size: const Size(100, 122),
                          fit: BoxFit.cover,
                          adaptive: true,
                        ),
                      ),
                    ),
                    if (item.isFeature ?? false)
                      const PositionedDirectional(
                        start: 5,
                        top: 5,
                        child: PromotedCard(),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: 0,
                      start: 12,
                      bottom: 5,
                      end: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            if (UiUtils.displayPrice(item))
                              Expanded(
                                child: UiUtils.getPriceWidget(item, context),
                              )
                            else
                              Expanded(
                                child: CustomText(
                                  item.translatedName ?? "",
                                  maxLines: 2,
                                  firstUpperCaseWidget: true,
                                ),
                              ),
                            if (showLikeButton ?? true)
                              FavoriteButton(item: item),
                          ],
                        ),
                        if (UiUtils.displayPrice(item))
                          CustomText(
                            item.translatedName!.firstUpperCase(),
                            fontSize: context.font.normal,
                            color: context.color.textDefaultColor,
                            maxLines: 2,
                          ),
                        if (item.translatedAddress != "")
                          RichText(
                            maxLines: 1,
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    AppIcons.mapPinLine,
                                    size: 13,
                                    color: context.color.textLightColor,
                                  ),
                                ),
                                TextSpan(text: ' '),
                                TextSpan(
                                  text: UiUtils.formatDisplayAddress(
                                    item.translatedAddress ?? '',
                                  ),
                                  style: TextStyle(
                                    fontSize: context.font.smaller,
                                    color: context.color.textLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.created != null && item.created != '')
                          RichText(
                            maxLines: 1,
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    AppIcons.clock,
                                    size: 13,
                                    color: context.color.textLightColor,
                                  ),
                                ),
                                TextSpan(text: ' '),
                                TextSpan(
                                  text: timeago.format(
                                    DateTime.parse(item.created!),
                                    locale: AppSession.currentLocale,
                                  ),
                                  style: TextStyle(
                                    fontSize: context.font.smaller,
                                    color: context.color.textLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
