import 'package:background_downloader/background_downloader.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';

class BackgroundUploadUtility {
  static const String uploadGroup = 'item_media_upload';

  /// Initialises notification configurations for the background downloader.
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

  /// Uploads media files in the background using the background_downloader package.
  ///
  /// [itemId] is the ID of the posted item.
  /// [files] is a map of form fields (e.g. 'product_video') to their local file paths.
  static Future<void> uploadMedia({
    required String itemId,
    required Map<String, String> files,
  }) async {
    Log.info(
      'Uploading media in background for item $itemId with files $files',
    );
    final token = HiveUtils.isUserAuthenticated() ? HiveUtils.getJWT() : null;
    final url = '${Api.baseUrl}${Api.uploadMediaApi}';

    if (files.isEmpty) return;

    try {
      final multiTask = MultiUploadTask(
        url: url,
        files: files.entries.map((e) => (e.key, e.value)).toList(),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
        fields: {'item_id': itemId},
        group: uploadGroup,
        updates: Updates.statusAndProgress,
      );

      Log.info('Enqueuing MultiUploadTask for item $itemId');

      await FileDownloader().enqueue(multiTask).catchError((error) {
        Log.error(error.toString(), error, null);
        return false;
      });
    } catch (e, st) {
      Log.error(e.toString(), e, st);
    }
  }
}
