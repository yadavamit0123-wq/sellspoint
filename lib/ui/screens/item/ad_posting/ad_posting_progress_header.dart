import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Step indicator on legacy post-ad screens when wizard progress flag is on.
class AdPostingProgressHeader extends StatelessWidget {
  const AdPostingProgressHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  /// 1 = category, 2 = details/media, 3 = location, 4 = confirm/post.
  final int currentStep;
  final int totalSteps;

  static bool get isEnabled => AppConfig.enableAdPostingWizardProgressV214;

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) return const SizedBox.shrink();
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(
                '${'postAdStepPrefix'.translate(context)} $currentStep / $totalSteps',
                fontSize: context.font.small,
                color: context.color.textLightColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: context.color.borderColor.withValues(alpha: 0.3),
              color: context.color.territoryColor,
            ),
          ),
        ],
      ),
    );
  }
}
