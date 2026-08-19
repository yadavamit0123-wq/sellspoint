import 'package:dotted_border/dotted_border.dart';
import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/media_controller.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/file_picker_utility.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdImageWidget extends StatelessWidget {
  const AdImageWidget({super.key});

  void _showAllImages(
    BuildContext context,
    MediaController controller,
    int maxAllowed,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .8,
      ),
      builder: (context) =>
          _ImageBottomSheet(max: maxAllowed, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = MediaControllerProvider.of(context);
    final maxAllowed = Constant.systemSettings.maxGalleryImages;

    return ListenableBuilder(
      listenable: controller.images,
      builder: (context, child) {
        final imagesList = controller.images.value;

        return Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imagesList.length < maxAllowed)
              _ImageSelector(
                remainingImages: maxAllowed - imagesList.length,
                onSelect: controller.addImages,
              ),
            if (imagesList.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final imagesToDisplay = maxWidth ~/ 55;
                  final displayImages = imagesList
                      .take(imagesToDisplay + 1)
                      .toList();
                  final hasMore = imagesList.length - 1 > imagesToDisplay;
                  final remainingImages =
                      imagesList.length - displayImages.length;

                  return Row(
                    spacing: 5,
                    children: [
                      for (
                        int i = 0;
                        i < displayImages.length - (hasMore ? 1 : 0);
                        ++i
                      )
                        _ImagePreview(
                          image: displayImages[i].filePath,
                          controller: controller,
                          onDelete: () => controller.removeImageAt(i),
                        ),
                      if (hasMore)
                        SizedBox.fromSize(
                          size: const Size.square(48),
                          child: Stack(
                            children: [
                              CustomImage(
                                src: displayImages.last.filePath,
                                size: const Size.square(48),
                                radius: 8,
                              ),
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () => _showAllImages(
                                    context,
                                    controller,
                                    maxAllowed,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ColoredBox(
                                      color: context.colorScheme.inverseSurface
                                          .withValues(alpha: .7),
                                      child: Center(
                                        child: Text(
                                          '+$remainingImages\nmore',
                                          style: context.labelMedium.withColor(
                                            context
                                                .colorScheme
                                                .onInverseSurface,
                                          ),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ListenableBuilder(
              listenable: controller.errors,
              builder: (context, child) {
                final errorKey = controller.errors[MediaType.images];
                if (errorKey != null) {
                  return Text(
                    errorKey.translate(context),
                    style: context.labelMedium.withColor(
                      context.colorScheme.error,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }
}

class _ImageSelector extends StatelessWidget {
  const _ImageSelector({required this.remainingImages, required this.onSelect});

  final int remainingImages;
  final ValueChanged<List<FileResource>> onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final allowedExtension = ['jpg', 'jpeg', 'png'];
        final images = await FilePickerUtility.pickWithSheet(
          context: context,
          allowMultiple: true,
          limit: remainingImages,
          allowedExtensions: allowedExtension,
          type: FileType.image,
          onInvalidExtension: () {
            HelperUtils.showSnackBarMessage(
              context,
              'invalidImageExtension'.translate(context, {
                'supported_types': allowedExtension.join(', '),
              }),
            );
          },
          onLimitExceeded: () {
            HelperUtils.showSnackBarMessage(
              context,
              'imageLimitExceeded'.translate(context),
            );
          },
        );

        if (images.isNotNullAndNotEmpty) {
          final files = images!.map((e) => LocalFileResource(e)).toList();
          onSelect(files);
        }
      },
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
                'uploadAdImages'.translate(context),
                style: context.labelMedium,
                textAlign: TextAlign.center,
              ),
              4.vGap,
              Text(
                'imageUploadInstructions'.translate(context, {
                  'maximum': Constant.systemSettings.maxGalleryImages
                      .toString(),
                  'size': '7',
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

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.image,
    required this.onDelete,
    required this.controller,
    this.size = const Size.square(48),
  });

  final String image;
  final VoidCallback onDelete;
  final Size size;
  final MediaController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.oversizedImages,
      builder: (context, child) {
        final isOversized = controller.oversizedImages.contains(image);
        return ConstrainedBox(
          constraints: BoxConstraints.tight(size),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomImage(src: image, size: size, radius: 8),
              if (isOversized)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ColoredBox(
                      color: context.colorScheme.inverseSurface.withValues(
                        alpha: .6,
                      ),
                      child: Icon(
                        AppIcons.warning,
                        color: context.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              PositionedDirectional(
                end: -4,
                top: -6,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: context.colorScheme.surface,
                    iconSize: 10,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: const CircleBorder(),
                    minimumSize: const Size.square(20),
                    fixedSize: const Size.square(20),
                  ),
                  onPressed: onDelete,
                  icon: Icon(AppIcons.x),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageBottomSheet extends StatelessWidget {
  const _ImageBottomSheet({required this.max, required this.controller});

  final int max;
  final MediaController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.images,
      builder: (context, child) {
        final imagesList = controller.images.value;

        return SafeArea(
          child: Padding(
            padding: Constant.safeAreaMinimumPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                Text(
                  'adImages'.translate(context),
                  style: context.labelLarge.semiBold,
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'imagesCount'.translate(context, {
                                      'count': imagesList.length.toString(),
                                      'max': max.toString(),
                                    }),
                                    style: context.labelLarge,
                                  ),
                                ),
                                Text(
                                  'remainingImagesCount'.translate(context, {
                                    'remaining': (max - imagesList.length)
                                        .toString(),
                                  }),
                                  style: context.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _ImageSelector(
                          remainingImages: max - imagesList.length,
                          onSelect: controller.addImages,
                        ),
                        Wrap(
                          spacing: 22,
                          runSpacing: 22,
                          children: imagesList.indexed
                              .map(
                                (image) => _ImagePreview(
                                  image: image.$2.filePath,
                                  size: const Size.square(64),
                                  controller: controller,
                                  onDelete: () =>
                                      controller.removeImageAt(image.$1),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    fixedSize: const Size.fromHeight(48),
                  ),
                  onPressed: Navigator.of(context).pop,
                  child: Text('saveImages'.translate(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
