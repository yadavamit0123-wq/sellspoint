/// FCM **data** payload reference for reel-related pushes (admin / backend).
///
/// All values should be strings in Firebase data messages. The app reads these
/// in [NotificationDeepLinkNavigation] when [typeKey] matches [reelsTabTypes].
///
/// Example — upload finished, open seller's listing reel:
/// ```json
/// {
///   "type": "reel-uploaded",
///   "item_id": "12345",
///   "reel_id": "678"
/// }
/// ```
///
/// Owner ad details instead of feed (`navigate=ad_details`):
/// ```json
/// {
///   "type": "reel-uploaded",
///   "item_id": "12345",
///   "navigate": "ad_details"
/// }
/// ```
///
/// Example — reel approved, focus feed on reel:
/// ```json
/// {
///   "type": "reel-ready",
///   "reel_id": "678"
/// }
/// ```
abstract final class ReelNotificationPayload {
  static const typeKey = 'type';
  static const itemIdKey = 'item_id';
  static const reelIdKey = 'reel_id';

  /// Alternate camelCase keys accepted when parsing [reelIdKey].
  static const reelIdAltKey = 'reelId';

  /// Opens the reels tab (5-tab shell) or [Routes.videoAdsScreen] (legacy).
  static const reelsTabTypes = {
    'reel',
    'reel-ready',
    'reel-uploaded',
    'video-reel',
  };

  static bool isReelsTabType(String type) => reelsTabTypes.contains(type);

  static const reelUploadFailedTypes = {'reel-upload-failed', 'reel_upload_failed'};

  static const reelUploadProgressTypes = {'reel-upload', 'reel_upload_progress'};

  static bool isReelUploadFailedType(String type) =>
      reelUploadFailedTypes.contains(type);

  static bool isReelUploadProgressType(String type) =>
      reelUploadProgressTypes.contains(type);
}
