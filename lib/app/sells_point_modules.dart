/// Sells Point–only features (not in stock eClassify 2.14).
///
/// Used for navigation and merge documentation; keep enabled for production.
abstract final class SellsPointModules {
  static const bool statusStories = true;
  static const bool referralProgram = true;
  static const bool wallet = true;

  static const String statusModulePath = 'lib/new_development/status/';
  static const String referralModulePath =
      'lib/ui/screens/referral_program/';
  static const String walletModulePath = 'lib/ui/screens/my_wallet/';

  /// Merge flag mirror; browsing route is stock 2.14 ([Routes.categoryBrowsing]).
  static const bool categoryBrowsingV214 = true;

  /// Location hub at [Routes.locationScreen] (Phase 18).
  static const bool locationScreenV214 = true;

  /// Category-scoped subscription routes (Phase 19).
  static const bool subscriptionFlowV214 = true;

  /// Job apply + applications list (Phase 20).
  static const bool jobApplicationsV214 = true;

  /// Follow lists + seller follow (Phase 21).
  static const bool followersV214 = true;

  /// Ad posting gateway routes (Phase 22).
  static const bool adPostingRouteV214 = true;
}
