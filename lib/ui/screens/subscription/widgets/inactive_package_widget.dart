import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class InactivePackageWidget extends StatelessWidget {
  const InactivePackageWidget({required this.package, super.key});

  final SubscriptionPackage package;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: Text(
                '${package.itemLimit.translate(context)} ${'ads'.translate(context)}',
                maxLines: 1,
                style: context.labelLarge.bold,
              ),
            ),
            if (package.discount != 0)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Text(
                    '${package.discount}% ${'off'.translate(context).toUpperCase()}',
                    style: context.labelMedium.withColor(
                      context.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            Text(
              '${package.isFree ? 'free'.translate(context) : package.formattedDiscountedPrice}',
              style: context.labelLarge.bold.withColor(
                context.colorScheme.primary,
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Text(
              '${package.listingDurationDays} ${'days'.translate(context)}',
              style: context.labelLarge.bold.withColor(context.mutedColor),
            ),
            const Spacer(),
            if (package.discount != 0)
              Text(
                '${package.formattedPrice}',
                style: context.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.mutedColor,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: context.mutedColor,
                  decorationThickness: 2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
