import 'dart:io';

/// Trimmed reel held between [VideoAdEditorScreen] and listing wizard.
abstract final class VideoAdEditorDraft {
  static File? trimmedVideo;
  static File? thumbnailFile;

  static bool get hasVideo => trimmedVideo != null;

  static void clear() {
    trimmedVideo = null;
    thumbnailFile = null;
  }
}
