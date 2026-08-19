import 'dart:io';

import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/app_icons.dart';

class AttachmentPreview extends StatelessWidget {
  const AttachmentPreview({
    required this.file,
    required this.onRemove,
    super.key,
  });

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split('/').last;
    final isImage = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
    ].any((ext) => fileName.toLowerCase().endsWith(ext));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colorScheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: isImage
                ? CustomImage(src: file.path, radius: 4)
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryColor.withValues(
                        alpha: .1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      AppIcons.fileFill,
                      color: context.colorScheme.primaryColor,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodySmall,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(AppIcons.x, size: 20),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
