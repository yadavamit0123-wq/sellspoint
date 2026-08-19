import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/data/model/item/product_video.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/url_validator.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_field.dart';
import 'package:eClassify/utils/collection_notifiers.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:flutter/material.dart';

enum MediaType { images, video, reel }

class MediaController {
  MediaController({
    required List<FileResource>? initialImages,
    required ProductVideo? initialVideo,
    required FileResource? initialVideoAd,
    required FileResource? initialThumbnail,
  }) {
    images = ListNotifier(initialImages ?? []);
    linkController = TextController(
      text: initialVideo?.videoSource.filePath ?? '',
    );
    videoTypeNotifier = ValueNotifier(
      initialVideo?.type ?? ProductVideoType.custom,
    );
    productVideo = initialVideo;
    videoAd = initialVideoAd;
    thumbnail = initialThumbnail;
    isCustomThumbnail = initialThumbnail != null;
  }

  late final ListNotifier<FileResource> images;
  final List<int> deletedImages = [];
  late final TextController linkController;
  late final ValueNotifier<ProductVideoType> videoTypeNotifier;
  ProductVideo? productVideo;

  // Set to true if the video is of type RemoteFileResource and should be deleted
  bool? deleteProductVideo;
  FileResource? videoAd; // Reel
  FileResource? thumbnail;
  bool isCustomThumbnail = false;

  final MapNotifier<MediaType, String> errors = MapNotifier();
  final SetNotifier<String> oversizedImages = SetNotifier({});

  void clearError(MediaType type) {
    errors.remove(type);
  }

  void addImages(List<FileResource> newImages) {
    images.addAll(newImages);
    clearError(MediaType.images);
  }

  void removeImageAt(int index) {
    final file = images[index];
    images.removeAt(index);
    removeOversizedImage(file.filePath);
    if (file is RemoteFileResource) {
      if (file.id != null) {
        deletedImages.add(file.id!);
      }
    }
    clearError(MediaType.images);
  }

  void removeOversizedImage(String path) {
    oversizedImages.delete(path);
    if (oversizedImages.isEmpty) {
      errors.remove(MediaType.images);
    }
  }

  void dispose() {
    linkController.dispose();
    videoTypeNotifier.dispose();
  }

  Future<bool> validate({bool shouldValidateVideoAd = false}) async {
    errors.clear();
    oversizedImages.clear();

    bool isValid = true;

    // 1. Validate images
    if (images.isEmpty) {
      errors.put(MediaType.images, 'imagesRequiredError');
      isValid &= false;
    } else {
      for (final image in images.value) {
        if (image is LocalFileResource) {
          try {
            if (await image.file.exists() &&
                (await image.file.length()) > 7 * 1024 * 1024) {
              oversizedImages.add(image.filePath);
            }
          } catch (_) {}
        }
      }
      if (oversizedImages.isNotEmpty) {
        errors.put(MediaType.images, 'imageSizeExceedError');
        isValid &= false;
      }
    }

    // 2. Validate video
    final videoType = videoTypeNotifier.value;
    if (videoType == ProductVideoType.custom) {
      final videoFile = productVideo?.videoSource;
      if (videoFile != null && videoFile is LocalFileResource) {
        try {
          final file = videoFile.file;
          if (await file.exists()) {
            final sizeInBytes = await file.length();
            final maxSizeInBytes =
                Constant.systemSettings.maxVideoSize * 1024 * 1024;
            if (sizeInBytes > maxSizeInBytes) {
              errors.put(MediaType.video, 'videoSizeExceedError');
              isValid = false;
            }
          }
        } catch (_) {}
      }
    } else if (linkController.text.isNotNullAndNotEmpty) {
      final link = linkController.text.trim();
      final error = switch (videoTypeNotifier.value) {
        ProductVideoType.youtube => UrlValidator.validateYoutubeUrl(link),
        ProductVideoType.vimeo => UrlValidator.validateVimeoUrl(link),
        ProductVideoType.otherLink =>
          UrlValidator.validateExtension(link) ??
              await UrlValidator.validateStreamingCapability(link),
        ProductVideoType.custom => null,
      };
      if (error != null) {
        errors.put(MediaType.video, error);
        isValid &= false;
      } else {
        productVideo = ProductVideo(
          type: videoType,
          videoSource: RemoteFileResource(Uri.parse(link)),
        );
      }
    }

    // 3. Validate Reel
    if (shouldValidateVideoAd) {
      if (videoAd == null) {
        errors.put(MediaType.reel, 'videoAdRequiredError');
        isValid &= false;
      } else if (videoAd case LocalFileResource r) {
        final sizeInBytes = await r.file.length();
        final maxSizeInBytes =
            Constant.systemSettings.maxVideoSize * 1024 * 1024;
        if (sizeInBytes > maxSizeInBytes) {
          errors.put(MediaType.reel, 'videoSizeExceedError');
          isValid &= false;
        }
      } else if (thumbnail == null) {
        errors.put(MediaType.reel, 'thumbnailRequiredError');
        isValid &= false;
      }
    }
    return isValid;
  }
}

class MediaControllerProvider extends InheritedWidget {
  const MediaControllerProvider({
    required this.controller,
    required super.child,
    super.key,
  });

  final MediaController controller;

  static MediaControllerProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MediaControllerProvider>();
  }

  static MediaController of(BuildContext context) {
    final provider = maybeOf(context);
    assert(provider != null, 'No MediaControllerProvider found in context');
    return provider!.controller;
  }

  @override
  bool updateShouldNotify(covariant MediaControllerProvider oldWidget) =>
      oldWidget.controller != controller;
}
