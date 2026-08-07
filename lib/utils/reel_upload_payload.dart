import 'package:eClassify/utils/api.dart';

/// Maps local reel files to [Api.uploadMediaApi] multipart field names.
abstract final class ReelUploadPayload {
  static Map<String, String> files({
    required String videoPath,
    String? thumbnailPath,
  }) {
    final map = <String, String>{
      Api.uploadMediaVideoField: videoPath,
    };
    if (thumbnailPath != null && thumbnailPath.isNotEmpty) {
      map[Api.uploadMediaThumbnailField] = thumbnailPath;
    }
    return map;
  }

  /// Cloud / handoff map stored under `pending_reel_upload`.
  static Map<String, String> toCloudMap({
    required String videoPath,
    String? thumbnailPath,
  }) {
    return files(videoPath: videoPath, thumbnailPath: thumbnailPath);
  }

  static Map<String, String>? fromCloud(dynamic pending) {
    if (pending is! Map) return null;
    final video = pending[Api.uploadMediaVideoField] ??
        pending['video'] ??
        pending['path'];
    if (video == null || video.toString().isEmpty) return null;
    final thumb = pending[Api.uploadMediaThumbnailField] ??
        pending['thumbnail'] ??
        pending['thumbnail_path'];
    return files(
      videoPath: video.toString(),
      thumbnailPath: thumb?.toString(),
    );
  }
}
