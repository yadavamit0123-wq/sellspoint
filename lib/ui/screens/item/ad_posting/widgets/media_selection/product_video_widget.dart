import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/data/model/item/product_video.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/media_controller.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_field.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
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
import 'package:omni_video_player/omni_video_player.dart';
import 'package:video_player/video_player.dart';

class ProductVideoWidget extends StatefulWidget {
  const ProductVideoWidget({super.key});

  @override
  State<ProductVideoWidget> createState() => _ProductVideoWidgetState();
}

class _ProductVideoWidgetState extends State<ProductVideoWidget> {
  FileResource? _video;
  MediaController? _mediaController;

  void _selectVideo() async {
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
      if (fileSize > Constant.systemSettings.maxVideoSize * 1024 * 1024) {
        HelperUtils.showSnackBarMessage(
          context,
          'videoSizeExceedError'.translate(context, {
            'size': Constant.systemSettings.maxVideoSize.toString(),
          }),
        );
        return;
      }

      try {
        final controller = VideoPlayerController.file(File(file.path));
        await controller.initialize();

        final size = controller.value.size;
        await controller.dispose();

        if (size.longestSide > 3840) {
          HelperUtils.showSnackBarMessage(
            context,
            'videoDimensionExceedError'.translate(context, {'dimension': '4K'}),
          );
          return;
        }
      } catch (e, st) {
        Log.error("Error reading video metadata: $e", e, st);
        HelperUtils.showSnackBarMessage(
          context,
          'failedToProcessVideo'.translate(context),
        );
        return;
      }

      setState(() {
        _video = LocalFileResource(file);
      });
      _mediaController?.productVideo = ProductVideo(
        type: ProductVideoType.custom,
        videoSource: _video!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _mediaController ??= MediaControllerProvider.of(context);
    if (_mediaController!.productVideo != null) {
      _video = _mediaController!.productVideo!.videoSource;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ValueListenableBuilder(
          valueListenable: _mediaController!.videoTypeNotifier,
          builder: (context, type, child) {
            if (type == ProductVideoType.custom) {
              if (_video == null) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _selectVideo,
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      radius: const Radius.circular(8),
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
                            'uploadProductVideo'.translate(context),
                            style: context.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                          4.vGap,
                          Text(
                            'videoUploadInstruction'.translate(context, {
                              'size': Constant.systemSettings.maxVideoSize
                                  .toString(),
                            }),
                            style: context.labelSmall.withColor(
                              context.mutedColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Stack(
                  children: [
                    SizedBox.fromSize(
                      size: Size.fromHeight(200),
                      child: OmniVideoPlayer(
                        configuration: VideoPlayerConfiguration(
                          videoSourceConfiguration: _video is LocalFileResource
                              ? VideoSourceConfiguration.file(
                                  videoFile: (_video as LocalFileResource).file,
                                )
                              : VideoSourceConfiguration.network(
                                  videoUrl: (_video as RemoteFileResource).url,
                                ),
                        ),
                        callbacks: VideoPlayerCallbacks(),
                      ),
                    ),
                    PositionedDirectional(
                      end: 16,
                      top: 16,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: context.colorScheme.secondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _video = null;
                          });
                          _mediaController!.productVideo = null;
                          if (_video is RemoteFileResource) {
                            _mediaController!.deleteProductVideo = true;
                          }
                        },
                        icon: Icon(AppIcons.x),
                      ),
                    ),
                  ],
                );
              }
            } else {
              _video = null;
              _mediaController!.productVideo = null;
              return CustomTextField(
                controller: _mediaController!.linkController,
                hintKey: type.key.translate(context),
              );
            }
          },
        ),
        ListenableBuilder(
          listenable: _mediaController!.errors,
          builder: (context, child) {
            final errorKey = _mediaController!.errors[MediaType.video];
            if (errorKey != null) {
              final maxVideoSize = Constant.systemSettings.maxVideoSize
                  .toString();
              return Text(
                errorKey.translate(context, {'size': maxVideoSize}),
                style: context.labelMedium.withColor(context.colorScheme.error),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
