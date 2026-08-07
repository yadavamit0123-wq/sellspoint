import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/repositories/subscription_repository.dart';

/// Gates video/reel posting using active package [isReelAllowed] (admin).
abstract final class ReelSubscriptionAccess {
  static final SubscriptionRepository _repository = SubscriptionRepository();

  static Future<bool> canUseReelFeatures() async {
    if (!AppConfig.enableReelSubscriptionGateV214) {
      return true;
    }
    try {
      final packages = await _repository.getActiveUserPackages(
        type: 'item_listing',
      );
      if (packages.isEmpty) {
        return true;
      }
      return packages.any((p) => p.isReelAllowed == true);
    } catch (_) {
      return true;
    }
  }
}
