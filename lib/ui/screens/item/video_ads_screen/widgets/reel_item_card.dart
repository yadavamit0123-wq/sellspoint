import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/item_model_extension.dart';
import 'package:flutter/material.dart';

class ReelItemCard extends StatelessWidget {
  const ReelItemCard({required this.item, super.key});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.adDetailsScreen,
          arguments: {'item_id': item.id, 'is_my_ad': item.isMyAd},
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .8,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.secondary.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            spacing: 8,
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.horizontal(
                  start: Radius.circular(16),
                ),
                child: CustomImage(src: item.image, size: Size.square(72)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.translatedName ?? item.name ?? '',
                      style: context.titleSmall.withColor(
                        context.colorScheme.onSecondary,
                      ),
                      maxLines: 2,
                    ),
                    if (item.formattedAmount.isNotNullAndNotEmpty)
                      Text(
                        item.formattedAmount!,
                        style: context.labelLarge.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
