import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class SkipButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const SkipButtonWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: context.color.tertiary.withValues(alpha: .2),
        foregroundColor: context.color.tertiary,
        shape: StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(70, 38),
      ),
      onPressed: onTap,
      child: Text('skip'.translate(context)),
    );
  }
}
