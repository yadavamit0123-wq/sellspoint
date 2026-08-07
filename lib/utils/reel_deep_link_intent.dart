/// Pending reels feed target when opening the Video Ads tab from a push/deep link.
abstract final class ReelDeepLinkIntent {
  static int? pendingReelId;
  static int? pendingItemId;

  static void set({int? reelId, int? itemId}) {
    pendingReelId = reelId;
    pendingItemId = itemId;
  }

  static ({int? reelId, int? itemId}) peek() => (
        reelId: pendingReelId,
        itemId: pendingItemId,
      );

  static ({int? reelId, int? itemId}) consume() {
    final value = peek();
    pendingReelId = null;
    pendingItemId = null;
    return value;
  }
}
