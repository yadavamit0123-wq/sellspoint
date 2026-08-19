import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class BlogCategoryBadge extends StatelessWidget {
  const BlogCategoryBadge({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(
          name,
          style: context.bodySmall.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
