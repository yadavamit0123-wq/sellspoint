/// Admin / backend reference for reel entitlement on subscription APIs.
///
/// The mobile app does **not** send a server-side “reels only” filter on the
/// catalog. It loads packages via `get-package` and applies **client-side**
/// sorting when the user arrives from the reel upgrade flow
/// ([SubscriptionPackageListScreen.highlightReelPlans]).
///
/// ### Catalog — `GET get-package`
/// Query: `type=item_listing` (and optional `category_id`, `platform=ios`).
///
/// Each package object should include:
/// - **`is_reel_allowed`**: `1` / `0` (or boolean) — when true, the plan allows
///   video reel ads (`item_type=video` + background `upload-media`).
///
/// The app maps this to [SubscriptionPackageModel.isReelAllowed].
///
/// ### Active entitlements — `GET get-user-purchased-packages`
/// Query: `type=item_listing` (optional `category_id`, `item_type`).
///
/// Same **`is_reel_allowed`** on active rows. [ReelSubscriptionAccess] allows
/// reel features when **any** active item_listing package has reel allowed.
/// If the list is empty, the app treats reel access as allowed (legacy users).
///
/// Optional backend filter (not required by the app today):
/// `item_type=video` — only packages valid for video listings, if supported.
///
/// Reel upgrade UI may hide plans without [packageReelAllowedField] when
/// [AppConfig.enableReelSubscriptionHideNonReelPlansV214] is enabled.
abstract final class ReelSubscriptionAdmin {
  static const catalogTypeItemListing = 'item_listing';
  static const packageReelAllowedField = 'is_reel_allowed';
  static const activePackagesApi = 'get-user-purchased-packages';
  static const catalogPackagesApi = 'get-package';
}
