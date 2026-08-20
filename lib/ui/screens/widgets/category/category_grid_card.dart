import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/ui/screens/widgets/category/category_config_scope.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/grayscale.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

/// Unified grid card for categories.
class CategoryGridCard extends StatelessWidget {
  const CategoryGridCard({
    required this.category,
    required this.onTap,
    super.key,
  });

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final config = CategoryConfigScope.of(context);
    final disabled = config?.isDisabled?.call(category) ?? false;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: disabled ? () => config?.onDisabledTap?.call(category) : onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 5,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Grayscale(
                  applyGrayScale: disabled,
                  child: CustomImage(src: category.image),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 2,
                  children: [
                    Text(
                      category.name.localized,
                      style: context.labelLarge,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                    ?CategoryConfigScope.of(
                      context,
                    )?.subtitleBuilder?.call(context, category),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
