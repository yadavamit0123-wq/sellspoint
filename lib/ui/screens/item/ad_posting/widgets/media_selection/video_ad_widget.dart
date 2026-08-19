import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/media_controller.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/file_picker_utility.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:video_player/video_player.dart';

class VideoAdWidget extends StatefulWidget {
  const VideoAdWidget({super.key});

  @override
  State<VideoAdWidget> createState() => _VideoAdWidgetState();
}

class _VideoAdWidgetState extends State<VideoAdWidget> {
  FileResource? _video;
  FileResource? _thumbnail;

  @override
  Widget build(BuildContext context) {
    final controller = MediaControllerProvider.of(context);
    _video = controller.videoAd;
    _thumbnail = controller.thumbnail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        if (_video == null)
          _VideoSelector(
            onSelect: (video) {
              setState(() {
                _video = video;
              });
              controller.videoAd = video;
            },
          )
        else
          _VideoPreview(
            video: _video,
            thumbnail: _thumbnail,
            onThumbnailGenerated: (thumbnail) {
              _thumbnail = thumbnail;
              controller.thumbnail = thumbnail;
            },
            onDelete: () {
              setState(() {
                _video = null;
                _thumbnail = null;
              });
              controller.videoAd = null;
              controller.thumbnail = null;
            },
            onEdited: (video, newThumbnail, isCustom) {
              setState(() {
                _video = video;
                _thumbnail = newThumbnail;
              });
              controller.videoAd = video;
              controller.thumbnail = newThumbnail;
              controller.isCustomThumbnail = isCustom;
            },
          ),
        ListenableBuilder(
          listenable: controller.errors,
          builder: (context, child) {
            final error = controller.errors[MediaType.reel];
            if (error != null) {
              return Text(
                error.translate(context),
                style: context.labelSmall.withColor(context.colorScheme.error),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({
    required this.video,
    required this.thumbnail,
    required this.onThumbnailGenerated,
    required this.onDelete,
    required this.onEdited,
  });

  final FileResource? video;
  final FileResource? thumbnail;
  final ValueChanged<FileResource> onThumbnailGenerated;
  final VoidCallback onDelete;
  final void Function(
    FileResource video,
    FileResource? thumbnail,
    bool isCustomThumbnail,
  )
  onEdited;

  Future<FileResource?> _getVideoThumbnail(BuildContext context) async {
    if (this.thumbnail != null) return this.thumbnail;
    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: video!.filePath,
        quality: 80,
      );
      final file = File(thumbnail.path);
      onThumbnailGenerated(LocalFileResource(file));
      return LocalFileResource(file);
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width,
        maxHeight: 200,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder(
              future: _getVideoThumbnail(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: LoadingIndicator());
                } else if (snapshot.hasData && snapshot.data != null) {
                  return CustomImage(
                    src: snapshot.data!.filePath,
                    fit: BoxFit.cover,
                  );
                } else if (snapshot.hasError) {
                  Log.error(snapshot.error.toString(), snapshot.error, null);
                  return CustomImage(src: AppAssets.branding.placeholder);
                } else {
                  return CustomImage(src: AppAssets.branding.placeholder);
                }
              },
            ),
          ),
          PositionedDirectional(
            end: 16,
            top: 8,
            child: Row(
              spacing: 8,
              children: [
                if (video is LocalFileResource)
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: context.colorScheme.surface,
                      foregroundColor: context.colorScheme.onSurface,
                    ),
                    onPressed: () async {
                      final controller = MediaControllerProvider.of(context);
                      final result =
                          await Navigator.of(context).pushNamed(
                                Routes.videoAdEditor,
                                arguments: {
                                  'video': video as LocalFileResource,
                                  'thumbnail': controller.isCustomThumbnail
                                      ? controller.thumbnail
                                      : null,
                                  'isCustomThumbnail':
                                      controller.isCustomThumbnail,
                                },
                              )
                              as Map<String, dynamic>?;
                      if (result != null) {
                        final videoPath = result['videoPath'] as String?;
                        final newThumbnail =
                            result['thumbnail'] as FileResource?;
                        final isCustom =
                            result['isCustomThumbnail'] as bool? ?? false;
                        if (videoPath.isNotNullAndNotEmpty) {
                          onEdited(
                            LocalFileResource(File(videoPath!)),
                            newThumbnail,
                            isCustom,
                          );
                        }
                      }
                    },
                    icon: Icon(AppIcons.pencilSimpleLine),
                  ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: context.colorScheme.surface,
                    foregroundColor: context.colorScheme.onSurface,
                  ),
                  onPressed: onDelete,
                  icon: Icon(AppIcons.x),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoSelector extends StatelessWidget {
  const _VideoSelector({required this.onSelect});

  final ValueChanged<FileResource> onSelect;

  Future<void> _handleVideoSelection(BuildContext context) async {
    final files = await FilePickerUtility.pick(
      type: FileType.video,
      allowedExtensions: ['mp4'],
      onInvalidExtension: () {
        HelperUtils.showSnackBarMessage(
          context,
          'invalidFileExtension'.translate(context, {'supported_types': 'mp4'}),
        );
      },
    );

    if (files.isNotNullAndNotEmpty) {
      final file = files!.first;
      final fileSize = file.lengthSync();
      if (fileSize > Constant.systemSettings.maxReelSize * 1024 * 1024) {
        HelperUtils.showSnackBarMessage(
          context,
          'videoSizeExceedError'.translate(context, {
            'size': Constant.systemSettings.maxReelSize.toString(),
          }),
        );
        return;
      }

      try {
        final controller = VideoPlayerController.file(File(file.path));
        await controller.initialize();

        final duration = controller.value.duration;
        final size = controller.value.size;
        await controller.dispose();

        if (duration.inSeconds > Constant.systemSettings.maxReelDuration) {
          HelperUtils.showSnackBarMessage(
            context,
            'videoDurationExceedError'.translate(context, {
              'duration': Constant.systemSettings.maxReelDuration.toString(),
            }),
          );
          return;
        }

        if (size.longestSide > 3840) {
          HelperUtils.showSnackBarMessage(
            context,
            'videoDimensionExceedError'.translate(context, {'dimension': '4K'}),
          );
          return;
        }
      } catch (e, st) {
        Log.error("Error reading video metadata: $e", e, st);
        if (context.mounted) {
          HelperUtils.showSnackBarMessage(
            context,
            'failedToProcessVideo'.translate(context),
          );
        }
        return;
      }

      onSelect(LocalFileResource(files.first));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleVideoSelection(context),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: Radius.circular(8),
          color: context.theme.dividerColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: context.colorScheme.surface,
                foregroundColor: context.colorScheme.onSurface,
                child: Icon(AppIcons.uploadSimple),
              ),
              8.vGap,
              Text(
                'uploadVideoAd'.translate(context),
                style: context.labelMedium,
                textAlign: TextAlign.center,
              ),
              4.vGap,
              Text(
                'videoAdInstructions'.translate(context, {
                  'size': Constant.systemSettings.maxReelSize.toString(),
                  'duration': Constant.systemSettings.maxReelDuration
                      .toString(),
                }),
                style: context.labelSmall.withColor(context.mutedColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
