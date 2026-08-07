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
    'reel-upload',
    'reel-uploaded',
    'video-reel',
  };

  static bool isReelsTabType(String type) => reelsTabTypes.contains(type);
}
