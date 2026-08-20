import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/app_icons.dart';

class MessageSendButton extends StatelessWidget {
  const MessageSendButton({required this.onSend, super.key});

  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.onPrimary,
        fixedSize: Size.square(40),
        iconSize: 20,
      ),
      onPressed: onSend,
      icon: Icon(AppIcons.paperPlaneRightFill),
    );
  }
}
