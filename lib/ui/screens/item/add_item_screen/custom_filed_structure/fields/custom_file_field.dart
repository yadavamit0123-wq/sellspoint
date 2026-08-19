import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/app_icons.dart';

class CustomFileField extends CustomField {
  @override
  String type = "fileinput";

  String? picked;

  @override
  void init() {
    if (parameters['isEdit'] == true) {
      if (parameters['value'] != null &&
          parameters['value'] is List &&
          (parameters['value'] as List).isNotEmpty) {
        picked = parameters['value'][0].toString();
        update(() {});
      }
    }
    super.init();
  }

  Future<File?> pickFile() async {
    FilePickerResult? picker = await FilePicker.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'svg', 'pdf'],
    );
    if (picker != null) {
      PlatformFile file = picker.files.first;
      File selectedFile = File(file.path!);
      picked = selectedFile.path;

      return selectedFile;
    }
    picked = null;
    return null;
  }

  @override
  Widget render() {
    return CustomValidator(
      validator: (value) {
        if (parameters['required'] == 1 && (value == null && picked == null)) {
          return "pleaseSelectFile".translate(context);
        }
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (parameters['image'] != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.color.territoryColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CustomImage(
                        src: parameters['image'],
                        size: Size.square(20),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
                Expanded(
                  child: CustomText(
                    parameters['translated_name'] ?? parameters['name'],
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 3,
                    fontSize: context.font.large,
                    fontWeight: FontWeight.w500,
                    color: context.color.textColorDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                File? file = await pickFile();
                if (file != null) {
                  MultipartFile multipartFile = await MultipartFile.fromFile(
                    file.path,
                  );
                  update(() {});
                  state.didChange(multipartFile);
                  AbstractField.files.addAll({
                    "custom_field_files[${parameters['id']}]": multipartFile,
                  });
                }
              },
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: const Radius.circular(10),
                  color: state.hasError
                      ? context.color.error
                      : context.color.textColorDark.withValues(alpha: 0.4),
                  strokeCap: StrokeCap.round,
                  padding: const EdgeInsets.all(5),
                  dashPattern: const [3, 3],
                ),

                child: Container(
                  width: double.infinity,
                  height: 43,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(AppIcons.plus),
                      const SizedBox(width: 5),
                      CustomText(
                        "addFile".translate(context),
                        color: context.color.textDefaultColor.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: context.font.large,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Builder(
              builder: (context) {
                if (picked == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.fileFill,
                        color: context.color.territoryColor,
                        size: 35,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              picked?.split("/").last ?? "",
                              maxLines: 1,
                              fontWeight: FontWeight.w500,
                            ),
                            if (!((picked ?? "").startsWith("http") ||
                                (picked ?? "").startsWith("https")))
                              CustomText(
                                HelperUtils.getFileSizeString(
                                  bytes: File((picked ?? "")).lengthSync(),
                                ).toUpperCase(),
                                fontSize: context.font.smaller,
                              ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 1),
                      IconButton(
                        onPressed: () {
                          state.didChange(null);
                          picked = null;
                          update(() {});
                        },
                        icon: const Icon(AppIcons.x),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            CustomText(
              'allowedFileTypes'.translate(context),
              color: context.color.error,
              fontSize: context.font.small,
            ),
          ],
        );
      },
    );
  }
}
