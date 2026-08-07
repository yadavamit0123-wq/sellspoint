import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class AiGenerateButton extends StatelessWidget {
  const AiGenerateButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!Constant.geminiAiEnabled) {
      return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.color.territoryColor,
              ),
            )
          : Icon(Icons.auto_awesome, size: 18, color: context.color.territoryColor),
      label: Text(
        isLoading
            ? 'generating'.translate(context)
            : 'generateWithAi'.translate(context),
      ),
    );
  }
}
