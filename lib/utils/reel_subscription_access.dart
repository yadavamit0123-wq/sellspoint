import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/subscription_pacakage_model.dart';
import 'package:eClassify/data/repositories/subscription_repository.dart';

/// Result of one active `item_listing` packages fetch (shared by gate + profile).
class ReelListingGateSnapshot {
  const ReelListingGateSnapshot({
    required this.hasActiveListingPlan,
    required this.reelFeaturesAllowed,
  });

  final bool hasActiveListingPlan;
  final bool reelFeaturesAllowed;
}

/// Gates video/reel posting using active package [isReelAllowed] (admin).
///
/// API fields: [ReelSubscriptionAdmin].
abstract final class ReelSubscriptionAccess {
  static final SubscriptionRepository _repository = SubscriptionRepository();

  static ReelListingGateSnapshot? _snapshot;
  static DateTime? _snapshotAt;
  static const Duration _cacheTtl = Duration(seconds: 45);

  /// Clears in-memory gate cache (call after any package purchase).
  static void invalidateCache() {
    _snapshot = null;
    _snapshotAt = null;
  }

  static Future<List<SubscriptionPackageModel>> _activeItemListingPlans() async {
    return _repository.getActiveUserPackages(
      type: ReelSubscriptionAdmin.catalogTypeItemListing,
    );
  }

  static Future<ReelListingGateSnapshot> fetchGateSnapshot({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        AppConfig.enableReelSubscriptionAccessCacheV214 &&
        _snapshot != null &&
        _snapshotAt != null &&
        DateTime.now().difference(_snapshotAt!) < _cacheTtl) {
      return _snapshot!;
    }

    try {
      final packages = await _activeItemListingPlans();
      final snap = ReelListingGateSnapshot(
        hasActiveListingPlan: packages.isNotEmpty,
        reelFeaturesAllowed: packages.isEmpty ||
            packages.any((p) => p.isReelAllowed == true),
      );
      _snapshot = snap;
      _snapshotAt = DateTime.now();
      return snap;
    } catch (_) {
      return const ReelListingGateSnapshot(
        hasActiveListingPlan: true,
        reelFeaturesAllowed: true,
      );
    }
  }

  static Future<bool> canUseReelFeatures({bool forceRefresh = false}) async {
    if (!AppConfig.enableReelSubscriptionGateV214) {
      return true;
    }
    final snap = await fetchGateSnapshot(forceRefresh: forceRefresh);
    return snap.reelFeaturesAllowed;
  }

  /// User has item listing plan(s) but none allow reels — show upgrade hints.
  static Future<bool> shouldPromptReelUpgrade() async {
    if (!AppConfig.enableReelSubscriptionGateV214) {
      return false;
    }
    final snap = await fetchGateSnapshot();
    if (!snap.hasActiveListingPlan) {
      return false;
    }
    return !snap.reelFeaturesAllowed;
  }

  static Future<bool> hasActiveItemListingPlan() async {
    final snap = await fetchGateSnapshot();
    return snap.hasActiveListingPlan;
  }
}
