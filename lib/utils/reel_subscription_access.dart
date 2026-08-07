import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/repositories/subscription_repository.dart';

/// Gates video/reel posting using active package [isReelAllowed] (admin).
///
/// API fields: [ReelSubscriptionAdmin].
abstract final class ReelSubscriptionAccess {
  static final SubscriptionRepository _repository = SubscriptionRepository();

  static bool? _cachedAllowed;
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 45);

  /// Clears in-memory gate cache (call after any package purchase).
  static void invalidateCache() {
    _cachedAllowed = null;
    _cachedAt = null;
  }

  static Future<bool> canUseReelFeatures({bool forceRefresh = false}) async {
    if (!AppConfig.enableReelSubscriptionGateV214) {
      return true;
    }
    if (!forceRefresh &&
        AppConfig.enableReelSubscriptionAccessCacheV214 &&
        _cachedAllowed != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl) {
      return _cachedAllowed!;
    }

    try {
      final packages = await _repository.getActiveUserPackages(
        type: ReelSubscriptionAdmin.catalogTypeItemListing,
      );
      final allowed = packages.isEmpty ||
          packages.any((p) => p.isReelAllowed == true);
      _cachedAllowed = allowed;
      _cachedAt = DateTime.now();
      return allowed;
    } catch (_) {
      return true;
    }
  }

  /// User has item listing plan(s) but none allow reels — show upgrade hints.
  static Future<bool> shouldPromptReelUpgrade() async {
    if (!AppConfig.enableReelSubscriptionGateV214) {
      return false;
    }
    try {
      final packages = await _repository.getActiveUserPackages(
        type: ReelSubscriptionAdmin.catalogTypeItemListing,
      );
      if (packages.isEmpty) {
        return false;
      }
      return !packages.any((p) => p.isReelAllowed == true);
    } catch (_) {
      return false;
    }
  }
}
