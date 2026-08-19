import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class UnreadMessagesIndicator extends StatelessWidget {
  const UnreadMessagesIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: context.colorScheme.primary, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'newMessages'.translate(context),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: context.colorScheme.primary, thickness: 1),
          ),
        ],
      ),
    );
  }
}
