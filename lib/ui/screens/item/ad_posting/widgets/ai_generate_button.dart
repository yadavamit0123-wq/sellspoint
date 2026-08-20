import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/app_icons.dart';

class AIGenerateButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AIGenerateButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if AI is enabled in system settings
    if (!(Constant.systemSettings.geminiAiEnabled)) {
      return const SizedBox.shrink();
    }

    final child = OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(AppIcons.sparkleFill, size: 18),
      label: Text(
        isLoading
            ? 'generating'.translate(context)
            : 'generateWithAi'.translate(context),
      ),
    );

    return child;
  }
}
