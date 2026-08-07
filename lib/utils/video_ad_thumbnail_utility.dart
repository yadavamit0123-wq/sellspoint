import 'dart:io';

import 'package:eClassify/app_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// First-frame JPEG from a local reel for listing `image` + upload `thumbnail`.
abstract final class VideoAdThumbnailUtility {
  static Future<File?> fromVideo(File videoFile) async {
    if (!AppConfig.enableAdPostingVideoReelThumbnailV214) return null;
    try {
      final dir = await getTemporaryDirectory();
      final path = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: dir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 720,
        quality: 80,
      );
      if (path == null) return null;
      return File(path);
    } catch (_) {
      return null;
    }
  }
}
