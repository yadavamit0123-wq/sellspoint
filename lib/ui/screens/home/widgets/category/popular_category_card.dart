import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class PopularCategoryCard extends StatelessWidget {
  const PopularCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          spacing: 4,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: DecoratedBox(
                decoration: BoxDecoration(color: context.color.secondaryColor),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomImage(
                    src: icon,
                    fit: BoxFit.cover,
                    size: const Size.square(70),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: context.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
