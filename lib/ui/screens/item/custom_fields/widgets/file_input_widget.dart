import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/ui/screens/item/custom_fields/custom_fields_controller.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/file_picker_utility.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';

class FileInputWidget extends StatefulWidget {
  const FileInputWidget({required this.field, super.key});

  final CustomFieldV2 field;

  @override
  State<FileInputWidget> createState() => _FileInputWidgetState();
}

class _FileInputWidgetState extends State<FileInputWidget> {
  FileResource? _file;

  CustomFieldsController? _controller;

  void _pickFile() async {
    final extensions = ['jpeg', 'jpg', 'png', 'doc', 'pdf', 'docx'];
    final file = Platform.isIOS
        ? await FilePickerUtility.pickWithSheet(
            context: context,
            allowedExtensions: extensions,
            onInvalidExtension: () {
              HelperUtils.showSnackBarMessage(
                context,
                'invalidFileExtension'.translate(context, {
                  'supported_types': extensions.join(', '),
                }),
              );
            },
          )
        : await FilePickerUtility.pick(allowedExtensions: extensions);

    if (file.isNotNullAndNotEmpty) {
      setState(() {
        _file = LocalFileResource(file!.first);
      });
      _controller?.updateValue(widget.field.id, _file!);
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller ??= CustomFieldsControllerProvider.maybeOf(context)?.controller;
    _file = _controller?.data[widget.field.id]?.value as FileResource?;
    final isNetwork = _file is RemoteFileResource;

    if (_file == null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _pickFile,
        child: SizedBox.fromSize(
          size: Size.fromHeight(56),
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: Radius.circular(8),
              color: context.theme.hintColor,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  Icon(AppIcons.plus, size: 20, color: context.theme.hintColor),
                  Text(
                    'addFile'.translate(context),
                    style: context.labelLarge.withColor(
                      context.theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      final name = _file!.filePath.split('/').last;
      final size = isNetwork
          ? null
          : (_file as LocalFileResource).file.lengthSync() / (1024 * 1024);
      final extension = name.split('.').last;
      final isImage = [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'heic',
      ].contains(extension);
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 80),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                if (isImage)
                  AspectRatio(
                    aspectRatio: 1,
                    child: CustomImage(src: _file!.filePath),
                  )
                else
                  Icon(
                    AppIcons.fileFill,
                    size: 20,
                    color: context.theme.hintColor,
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 2,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 2,
                          style: context.labelMedium,
                        ),
                      ),
                      if (size != null)
                        Text(
                          '${size.toStringAsFixed(2)} MB',
                          style: context.labelSmall.withColor(
                            context.theme.hintColor,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _file = null;
                    });
                    _controller?.updateValue(widget.field.id, null);
                  },
                  icon: Icon(
                    AppIcons.trash,
                    size: 20,
                    color: context.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
