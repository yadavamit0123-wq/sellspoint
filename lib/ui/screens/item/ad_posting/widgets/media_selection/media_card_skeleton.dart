import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class MediaCardSkeleton extends StatelessWidget {
  const MediaCardSkeleton({
    required this.title,
    required this.child,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    title.translate(context),
                    style: context.labelLarge,
                  ),
                ),
                ?trailing,
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}
