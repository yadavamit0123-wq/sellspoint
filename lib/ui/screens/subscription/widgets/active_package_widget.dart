import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/date_extensions.dart';
import 'package:flutter/material.dart';

class ActivePackageWidget extends StatelessWidget {
  const ActivePackageWidget({required this.package, super.key});

  final ActivePackage package;

  Widget _keyValueWidget(BuildContext context, String key, String value) {
    return Column(
      children: [
        Text(key, style: context.bodySmall.copyWith(color: context.mutedColor)),
        Text(value, style: context.labelMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUnlimitedLimit = package.itemLimit == null;
    final percentageUsed = hasUnlimitedLimit
        ? 1.0
        : 1.0 - package.remainingItemLimit! / package.itemLimit!;
    final hasUnlimitedDuration = package.end == null;
    return Column(
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('adsUsage'.translate(context), style: context.labelMedium),
            Text(
              '${hasUnlimitedLimit ? 'unlimited'.translate(context) : '${package.usedLimit}/${package.itemLimit}'}',
              style: context.labelMedium,
            ),
          ],
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: percentageUsed),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.decelerate,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              borderRadius: BorderRadius.circular(16),
              backgroundColor: context.colorScheme.primary.withValues(
                alpha: .2,
              ),
              minHeight: 8,
            );
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _keyValueWidget(
                  context,
                  'started'.translate(context),
                  package.start.format(formatString: 'dd MMM yyyy'),
                ),
                const SizedBox(height: 10, child: VerticalDivider()),
                _keyValueWidget(
                  context,
                  'expires'.translate(context),
                  hasUnlimitedDuration
                      ? '-'
                      : package.end!.format(formatString: 'dd MMM yyyy'),
                ),
                const SizedBox(height: 10, child: VerticalDivider()),
                _keyValueWidget(
                  context,
                  'remaining'.translate(context),
                  hasUnlimitedDuration
                      ? 'unlimited'.translate(context)
                      : '${package.end!.difference(package.start).inDays} ${'days'.translate(context)}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
