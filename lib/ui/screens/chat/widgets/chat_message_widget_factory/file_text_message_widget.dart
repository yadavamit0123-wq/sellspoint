import 'package:eClassify/data/model/chat/chat_message.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_message_widget_factory/file_widget.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class FileTextMessageWidget extends StatelessWidget {
  const FileTextMessageWidget({required this.message, super.key});

  final FileAndTextMessage message;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.screenWidth * .7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          FileWidget(
            url: message.file,
            keepAspectRatioForImage: false,
            size: Size.fromHeight(250),
          ),
          SelectableText(message.message, style: context.labelLarge),
        ],
      ),
    );
  }
}
