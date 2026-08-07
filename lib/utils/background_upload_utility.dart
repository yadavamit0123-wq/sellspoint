import 'package:background_downloader/background_downloader.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/reel_upload_constants.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';

/// eClassify 2.14 — background upload for large item media (video ads, etc.).
class BackgroundUploadUtility {
  static const String uploadGroup = ReelUploadConstants.uploadGroup;

  static Future<void> initialize() async {
    await FileDownloader().configureNotificationForGroup(
      uploadGroup,
      running: const TaskNotification(
        'Uploading media',
        'Uploading {filename} {progress}',
      ),
      complete: const TaskNotification(
        'Upload complete',
        'All media files uploaded successfully',
      ),
      error: const TaskNotification(
        'Upload failed',
        'Failed to upload {filename}',
      ),
      progressBar: true,
      groupNotificationId: 'item_media_upload_notification',
    );
  }

  /// Returns enqueued task id when successful.
  static Future<String?> uploadMedia({
    required String itemId,
    required Map<String, String> files,
  }) async {
    if (files.isEmpty) return null;

    Log.info('Background upload for item $itemId: $files');

    final token = HiveUtils.isUserAuthenticated() ? HiveUtils.getJWT() : null;
    final url = '${Api.baseUrl}${Api.uploadMediaApi}';

    try {
      final multiTask = MultiUploadTask(
        url: url,
        files: files.entries.map((e) => (e.key, e.value)).toList(),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
        fields: {Api.uploadMediaItemIdField: itemId},
        group: uploadGroup,
        updates: Updates.statusAndProgress,
      );

      final enqueued = await FileDownloader().enqueue(multiTask).catchError((Object error) {
        Log.error(error.toString(), error, null);
        return false;
      });
      if (enqueued) {
        return multiTask.taskId;
      }
      return null;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      return null;
    }
  }
}
