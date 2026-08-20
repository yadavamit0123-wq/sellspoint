import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/app_icons.dart';

class MessageInputField extends StatelessWidget {
  const MessageInputField({
    required this.controller,
    required this.onAttach,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onAttach;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: context.bodyMedium,
      minLines: 1,
      maxLines: 5,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.send,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        filled: false,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        hintText: 'message'.translate(context),
        hintStyle: context.bodyMedium.withColor(context.mutedColor),
        suffixIcon: IconButton(
          onPressed: onAttach,
          icon: Icon(AppIcons.paperclip),
        ),
      ),
    );
  }
}
