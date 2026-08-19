import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/log.dart';

class UrlValidator {
  static const _allowedExtensions = [
    'mp4',
    'webm',
    'ogg',
    'ogv',
    'mov',
    'm3u8',
    'mkv',
    'avi',
  ];

  static String? validateExtension(String value) {
    final url = Uri.tryParse(value);
    if (url == null) return 'invalidVideoUrl';
    final extension = url.pathSegments.last.split('.').last;
    if (_allowedExtensions.contains(extension.toLowerCase())) {
      return null;
    } else {
      return 'invalidVideoUrl';
    }
  }

  static Future<String?> validateStreamingCapability(String value) async {
    try {
      final response = await Api.head(url: value);
      if (response.statusCode != 200) return 'invalidVideoUrl';
      final headers = response.headers.map;
      final isRangeSupported = headers['accept-ranges']?.first == 'bytes';
      final contentType = headers['content-type']?.first;
      final isContentTypeSupported =
          contentType.isNotNullAndNotEmpty &&
          (contentType!.startsWith('video/') ||
              contentType == 'application/vnd.apple.mpegurl' ||
              contentType == 'application/dash+xml');

      return (isRangeSupported && isContentTypeSupported)
          ? null
          : 'invalidVideoUrl';
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      return 'invalidVideoUrl';
    }
  }

  static String? validateYoutubeUrl(String value) {
    final url = Uri.tryParse(value);
    if (url == null) return 'invalidYoutubeUrl';

    return switch (url.host) {
      'youtu.be' => null,
      'youtube.com' => null,
      _ => 'invalidYoutubeUrl',
    };
  }

  static String? validateVimeoUrl(String value) {
    final url = Uri.tryParse(value);
    if (url == null) return 'invalidVimeoUrl';

    return switch (url.host) {
      'vimeo.com' => null,
      'player.vimeo.com' => null,
      _ => 'invalidVimeoUrl',
    };
  }
}
