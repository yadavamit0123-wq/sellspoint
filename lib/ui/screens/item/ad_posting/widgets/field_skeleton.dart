import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class FieldSkeleton extends StatelessWidget {
  const FieldSkeleton({
    required this.title,
    required this.child,
    this.isRequired = false,
    this.action,
    super.key,
  });

  final String title;
  final bool isRequired;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Row(
          children: [
            Text(title.translate(context), style: context.labelLarge),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: context.labelSmall.withColor(context.colorScheme.error),
              ),
            ],
            if (action != null) ...[
              const Spacer(),
              action!,
            ],
          ],
        ),
        child,
      ],
    );
  }
}
