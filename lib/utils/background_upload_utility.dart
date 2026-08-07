import 'package:background_downloader/background_downloader.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';

/// eClassify 2.14 — background upload for large item media (video ads, etc.).
class BackgroundUploadUtility {
  static const String uploadGroup = 'item_media_upload';

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

  static Future<void> uploadMedia({
    required String itemId,
    required Map<String, String> files,
  }) async {
    if (files.isEmpty) return;

    Log.info('Background upload for item $itemId: $files');

    final token = HiveUtils.isUserAuthenticated() ? HiveUtils.getJWT() : null;
    final url = '${Api.baseUrl}${Api.uploadMediaApi}';

    try {
      final multiTask = MultiUploadTask(
        url: url,
        files: files.entries.map((e) => (e.key, e.value)).toList(),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
        fields: {'item_id': itemId},
        group: uploadGroup,
        updates: Updates.statusAndProgress,
      );

      await FileDownloader().enqueue(multiTask).catchError((Object error) {
        Log.error(error.toString(), error, null);
        return false;
      });
    } catch (e, st) {
      Log.error(e.toString(), e, st);
    }
  }
}
