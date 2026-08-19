import 'package:eClassify/ui/screens/widgets/auto_size_text.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final Widget? icon;
  final Widget title;
  final Widget? content;

  // Configuration for simple positive/negative buttons
  final String? positiveButtonLabel;
  final VoidCallback? onPositiveTapped;
  final String? negativeButtonLabel;
  final VoidCallback? onNegativeTapped;

  // Fully custom actions list (if provided, configuration buttons are ignored)
  final List<Widget>? actions;

  const AppDialog({
    super.key,
    this.icon,
    required this.title,
    this.content,
    this.positiveButtonLabel,
    this.onPositiveTapped,
    this.negativeButtonLabel,
    this.onNegativeTapped,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.color.secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding * 2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [?icon, title, ?content, 12.vGap, _buildActions(context)],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (actions != null) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!);
    }

    final hasPositive = positiveButtonLabel != null;
    final hasNegative = negativeButtonLabel != null;

    if (!hasPositive && !hasNegative) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        if (hasNegative)
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colorScheme.surface,
                foregroundColor: context.colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(8),
                fixedSize: Size.fromHeight(40),
              ),
              onPressed:
                  onNegativeTapped ?? () => Navigator.pop(context, false),
              child: AutoSizeText(
                text: negativeButtonLabel!,
                style: context.titleMedium,
                maxLines: 1,
                minimumFontSize: 14,
              ),
            ),
          ),
        if (hasPositive)
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(8),
                fixedSize: Size.fromHeight(40),
              ),
              onPressed: onPositiveTapped ?? () => Navigator.pop(context, true),
              child: AutoSizeText(
                text: positiveButtonLabel!,
                style: context.titleMedium.withColor(
                  context.colorScheme.onPrimary,
                ),
                maxLines: 1,
                minimumFontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
