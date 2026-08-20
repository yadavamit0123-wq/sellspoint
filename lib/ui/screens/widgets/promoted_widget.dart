import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class PromotedCard extends StatelessWidget {
  final Color? color;

  const PromotedCard({this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          "featured".translate(context),
          style: context.labelSmall.withColor(context.colorScheme.onPrimary),
        ),
      ),
    );
  }
}
