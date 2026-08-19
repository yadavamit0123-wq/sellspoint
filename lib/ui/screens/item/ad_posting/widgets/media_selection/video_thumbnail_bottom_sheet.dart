import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/debounce_mixin.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/file_picker_utility.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class VideoThumbnailBottomSheet {
  static void show({
    required BuildContext context,
    required String videoPath,
    required double startMs,
    required double endMs,
    required FileResource? customThumbnail,
    required void Function(FileResource? thumbnail, bool isCustom)
    onThumbnailChanged,
  }) {
    UiUtils.showBottomSheet(
      context,
      height: MediaQuery.sizeOf(context).height * .9,
      child: _ThumbnailSelectorWidget(
        videoPath: videoPath,
        startMs: startMs,
        endMs: endMs,
        initialCustomThumbnail: customThumbnail,
        onThumbnailChanged: onThumbnailChanged,
      ),
    );
  }
}

class _ThumbnailSelectorWidget extends StatefulWidget {
  const _ThumbnailSelectorWidget({
    required this.videoPath,
    required this.startMs,
    required this.endMs,
    required this.initialCustomThumbnail,
    required this.onThumbnailChanged,
  });

  final String videoPath;
  final double startMs;
  final double endMs;
  final FileResource? initialCustomThumbnail;
  final void Function(FileResource? thumbnail, bool isCustom)
  onThumbnailChanged;

  @override
  State<_ThumbnailSelectorWidget> createState() =>
      _ThumbnailSelectorWidgetState();
}

class _ThumbnailSelectorWidgetState extends State<_ThumbnailSelectorWidget>
    with DebounceMixin<_ThumbnailSelectorWidget, double> {
  List<Uint8List> _stripBytes = [];
  late final ValueNotifier<double> _sliderRatioNotifier;
  late final ValueNotifier<Object?> _previewNotifier;
  late final ValueNotifier<bool> _isGeneratingPreviewNotifier;
  FileResource? _customThumbnail;
  bool _isCustomThumbnail = false;

  @override
  Duration get debounceDuration => const Duration(milliseconds: 150);

  @override
  void onDebounced(double value) {
    _requestThumbnailGeneration(value);
  }

  @override
  void initState() {
    super.initState();
    _customThumbnail = widget.initialCustomThumbnail;
    _isCustomThumbnail = widget.initialCustomThumbnail != null;
    _sliderRatioNotifier = ValueNotifier<double>(0.0);
    _previewNotifier = ValueNotifier<Object?>(widget.initialCustomThumbnail);
    _isGeneratingPreviewNotifier = ValueNotifier<bool>(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCustomThumbnail == null) {
        _requestThumbnailGeneration(0.0, isDefault: true);
      }
      _generateStripThumbnails();
    });
  }

  @override
  void dispose() {
    _sliderRatioNotifier.dispose();
    _previewNotifier.dispose();
    _isGeneratingPreviewNotifier.dispose();
    super.dispose();
  }

  Future<void> _generateStripThumbnails() async {
    final double step = (widget.endMs - widget.startMs) / 7.0; // 8 intervals
    final List<Uint8List> bytesList = [];

    for (int i = 0; i < 8; i++) {
      if (!mounted) return;
      final double timeMs = widget.startMs + (i * step);

      try {
        final Uint8List? bytes = await VideoThumbnail.thumbnailData(
          video: widget.videoPath,
          imageFormat: ImageFormat.JPEG,
          quality: 75,
          timeMs: timeMs.round(),
          maxHeight: 240,
          maxWidth: 135,
        );

        if (bytes != null && mounted) {
          bytesList.add(bytes);
          setState(() {
            _stripBytes = List.from(bytesList);
          });
        }
      } catch (e, st) {
        Log.error("Error generating strip thumbnail $i: $e", e, st);
      }

      // Small delay to let the UI thread breathe and prevent lag/ANR
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _updatePlayhead(double dx, double totalWidth) {
    if (totalWidth <= 0) return;
    final double ratio = (dx / totalWidth).clamp(0.0, 1.0);
    _sliderRatioNotifier.value = ratio;
    debounce(ratio);
  }

  Future<void> _requestThumbnailGeneration(
    double ratio, {
    bool isDefault = false,
  }) async {
    try {
      _isGeneratingPreviewNotifier.value = true;
      final double targetMs =
          widget.startMs + ratio * (widget.endMs - widget.startMs);
      final Uint8List? bytes = await VideoThumbnail.thumbnailData(
        video: widget.videoPath,
        imageFormat: ImageFormat.JPEG,
        quality: 85,
        timeMs: targetMs.round(),
        maxHeight: 1280,
        maxWidth: 720,
      );
      if (mounted && bytes != null) {
        _previewNotifier.value = bytes;
        _customThumbnail = isDefault ? null : null;
        _isCustomThumbnail = !isDefault;
      }
    } catch (e, st) {
      Log.error("Error generating preview: $e", e, st);
    } finally {
      if (mounted) _isGeneratingPreviewNotifier.value = false;
    }
  }

  Future<void> _uploadNew() async {
    final files = await FilePickerUtility.pick(
      type: FileType.image,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      onInvalidExtension: () {
        HelperUtils.showSnackBarMessage(
          context,
          'invalidFileExtension'.translate(context, {
            'supported_types': 'jpg, jpeg, png',
          }),
        );
      },
    );
    if (files.isNotNullAndNotEmpty) {
      final file = files!.first;
      final newThumbnail = LocalFileResource(file);
      _previewNotifier.value = newThumbnail;
      _customThumbnail = newThumbnail;
      _isCustomThumbnail = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'videoAdsThumbnails'.translate(context),
                  style: context.labelLarge.bold,
                ),
                IconButton(
                  icon: Icon(AppIcons.x),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: context.screenHeight * .45,
                    ),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ValueListenableBuilder<Object?>(
                                valueListenable: _previewNotifier,
                                builder: (context, preview, child) {
                                  if (preview is Uint8List) {
                                    return Image.memory(
                                      preview,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                    );
                                  } else if (preview is FileResource) {
                                    return CustomImage(
                                      key: ValueKey(preview.filePath),
                                      src: preview.filePath,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return ColoredBox(
                                      color: context
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      child: const Center(
                                        child: LoadingIndicator(),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: _isGeneratingPreviewNotifier,
                                builder: (context, isGenerating, child) {
                                  if (!isGenerating)
                                    return const SizedBox.shrink();
                                  return ColoredBox(
                                    color: Colors.black26,
                                    child: const Center(
                                      child: LoadingIndicator(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'selectThumbnail'.translate(context),
                              style: context.labelLarge,
                            ),
                            TextButton(
                              onPressed: _uploadNew,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'uploadImage'.translate(context),
                                style: context.labelLarge.copyWith(
                                  color: context.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: context.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final totalWidth = constraints.maxWidth;
                            final frameWidth = totalWidth / 8;
                            return GestureDetector(
                              onHorizontalDragStart: (details) {
                                _updatePlayhead(
                                  details.localPosition.dx,
                                  totalWidth,
                                );
                              },
                              onHorizontalDragUpdate: (details) {
                                _updatePlayhead(
                                  details.localPosition.dx,
                                  totalWidth,
                                );
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      height: 60,
                                      color: context
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      child: _stripBytes.isEmpty
                                          ? const Center(
                                              child: LoadingIndicator(),
                                            )
                                          : Row(
                                              children: List.generate(8, (
                                                index,
                                              ) {
                                                if (index <
                                                    _stripBytes.length) {
                                                  return Expanded(
                                                    child: Image.memory(
                                                      _stripBytes[index],
                                                      fit: BoxFit.cover,
                                                      height: 60,
                                                    ),
                                                  );
                                                } else {
                                                  return const Expanded(
                                                    child: SizedBox.shrink(),
                                                  );
                                                }
                                              }),
                                            ),
                                    ),
                                  ),
                                  ValueListenableBuilder<double>(
                                    valueListenable: _sliderRatioNotifier,
                                    builder: (context, ratio, child) {
                                      final maxLeft = totalWidth - frameWidth;
                                      final position =
                                          (ratio * totalWidth - frameWidth / 2)
                                              .clamp(0.0, maxLeft);
                                      return Positioned(
                                        left: position,
                                        top: -2,
                                        bottom: -2,
                                        child: SizedBox(
                                          width: frameWidth,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    context.colorScheme.primary,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: FilledButton(
                      onPressed: () async {
                        FileResource? finalThumbnail = _customThumbnail;

                        if (_previewNotifier.value is Uint8List) {
                          final bytes = _previewNotifier.value as Uint8List;
                          final tempDir = await getTemporaryDirectory();
                          final file = File(
                            '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
                          );
                          await file.writeAsBytes(bytes);
                          final fileResource = LocalFileResource(file);
                          finalThumbnail = _isCustomThumbnail
                              ? fileResource
                              : null;
                        }

                        widget.onThumbnailChanged(
                          finalThumbnail,
                          _isCustomThumbnail,
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text('saveThumbnail'.translate(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
