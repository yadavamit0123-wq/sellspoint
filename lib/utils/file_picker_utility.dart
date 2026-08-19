import 'dart:io';

import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/log.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image_picker/image_picker.dart';

enum PickSource { gallery, camera, document }

/// Centralized utility for file picking using both [file_picker] and [image_picker] packages.
/// Standardizes selection logic and limit enforcement across the app.
class FilePickerUtility {
  /// Picks one or more files based on the provided configuration.
  ///
  /// [source]: The source to pick from (gallery or camera).
  /// [allowMultiple]: Whether to allow selecting multiple files (only for gallery).
  /// [type]: The type of files to pick (e.g., [FileType.image], [FileType.any]).
  /// [allowedExtensions]: Optional list of extensions for filtering.
  /// [limit]: Optional maximum number of files to return.
  /// [onLimitExceeded]: Callback triggered if the selection exceeds [limit].
  static Future<List<File>?> pick({
    PickSource source = PickSource.gallery,
    bool allowMultiple = false,
    FileType type = FileType.any,
    List<String>? allowedExtensions = const ['jpg', 'jpeg', 'png'],
    int? limit,
    VoidCallback? onLimitExceeded,
    VoidCallback? onInvalidExtension,
  }) async {
    try {
      List<File> files = [];

      if (source == PickSource.camera) {
        final ImagePicker picker = ImagePicker();
        final XFile? photo = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (photo == null) return null;
        files.add(File(photo.path));
      } else {
        final result = await FilePicker.pickFiles(
          allowMultiple: allowMultiple,
          type: type,
        );

        if (result == null || result.files.isEmpty) {
          return null;
        }

        files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }

      // Quirks of iOS: Images selected from the Camera or Photo Library (Gallery)
      // might be in the HEIC format. We convert HEIC images to JPEG to ensure compatibility.
      if (Platform.isIOS) {
        final convertedFiles = <File>[];
        for (final file in files) {
          convertedFiles.add(await _handleHEICConversion(file));
        }
        files = convertedFiles;
      }

      // Filter by extensions if provided (extra safety check)
      if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
        files = files.where((file) {
          final ext = file.path.split('.').last.toLowerCase();
          return allowedExtensions.contains(ext);
        }).toList();

        if (files.isEmpty) {
          onInvalidExtension?.call();
          return null;
        }
      }

      if (limit != null && files.length > limit) {
        onLimitExceeded?.call();
        // Return only the first [limit] files
        return files.take(limit).toList();
      }

      return files;
    } catch (e) {
      debugPrint('Error picking files: $e');
      return null;
    }
  }

  /// Picks files showing a source selection bottom sheet.
  ///
  /// Quirks of iOS:
  /// 1. `FileType.any` with standard gallery picks from the Files app on iOS rather than the Photo Library.
  /// 2. To allow selecting images from Photo Library and files/documents from Files app, we show three options:
  ///    - Camera: For taking a picture (converts HEIC -> JPEG if needed).
  ///    - Gallery: For selecting images from Photo Library (uses FileType.image and converts HEIC -> JPEG).
  ///    - Document: For selecting any file type from Files app (uses FileType.any).
  static Future<List<File>?> pickWithSheet({
    required BuildContext context,
    bool allowMultiple = false,
    FileType? type,
    List<String>? allowedExtensions,
    int? limit,
    VoidCallback? onLimitExceeded,
    VoidCallback? onInvalidExtension,
  }) async {
    final bool showDocumentOption = Platform.isIOS && type != FileType.image;

    final PickSource? selectedSource = await _showSourceBottomSheet(
      context,
      showDocumentOption: showDocumentOption,
    );

    if (selectedSource == null) return null;

    PickSource finalSource = selectedSource;

    final finalType = switch (selectedSource) {
      PickSource.gallery => FileType.image,
      PickSource.camera => FileType.image,
      PickSource.document => FileType.any,
    };

    return pick(
      source: finalSource == PickSource.document
          ? PickSource.gallery
          : finalSource,
      allowMultiple: finalSource == PickSource.gallery ? allowMultiple : false,
      type: finalType,
      allowedExtensions: allowedExtensions,
      limit: limit,
      onLimitExceeded: onLimitExceeded,
      onInvalidExtension: onInvalidExtension,
    );
  }

  /// Converts HEIC file to JPEG if on iOS and the file has .heic extension.
  static Future<File> _handleHEICConversion(File file) async {
    if (!Platform.isIOS) return file;

    final path = file.path;
    final extension = path.split('.').last.toLowerCase();
    if (extension == 'heic') {
      try {
        final String? outputPath = await HeifConverter.convert(
          path,
          format: 'jpg',
        );

        if (outputPath != null) {
          Log.debug('Successfully converted HEIC to JPEG: $outputPath');
          return File(outputPath);
        }
      } catch (e, st) {
        Log.error('Error converting HEIC to JPEG', e, st);
      }
    }
    return file;
  }

  static Future<PickSource?> _showSourceBottomSheet(
    BuildContext context, {
    bool showDocumentOption = false,
  }) {
    return showModalBottomSheet<PickSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  "selectImageSource".translate(bottomSheetContext),
                  fontSize: bottomSheetContext.font.larger,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildSourceCard(
                      bottomSheetContext,
                      title: "camera".translate(bottomSheetContext),
                      icon: AppIcons.cameraFill,
                      onTap: () {
                        Navigator.pop(bottomSheetContext, PickSource.camera);
                      },
                    ),
                    const SizedBox(width: 15),
                    _buildSourceCard(
                      bottomSheetContext,
                      title: "gallery".translate(bottomSheetContext),
                      icon: AppIcons.imagesFill,
                      onTap: () {
                        Navigator.pop(bottomSheetContext, PickSource.gallery);
                      },
                    ),
                    if (showDocumentOption) ...[
                      const SizedBox(width: 15),
                      _buildSourceCard(
                        bottomSheetContext,
                        title: "document".translate(bottomSheetContext),
                        icon: AppIcons.fileFill,
                        onTap: () {
                          Navigator.pop(
                            bottomSheetContext,
                            PickSource.document,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSourceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: context.color.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Icon(icon, size: 24, color: context.colorScheme.primary),
                Text(title, style: context.labelMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
