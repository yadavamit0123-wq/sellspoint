import 'dart:async';

import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/reel_subscription_access.dart';
import 'package:flutter/foundation.dart';

/// Hooks subscription checkout → reel gate cache refresh.
abstract final class ReelSubscriptionRefresh {
  /// Bumped after checkout; [ActivePlanScreen] refetches active packages.
  static final ValueNotifier<int> activePlansRevision = ValueNotifier(0);

  /// [ProfileSubscriptionTile] re-checks reel/listing hints.
  static final ValueNotifier<int> profileHintRevision = ValueNotifier(0);

  static void onProfileTabVisible() {
    if (AppConfig.enableReelGateRefreshOnProfileTabV214) {
      ReelSubscriptionAccess.invalidateCache();
      unawaited(
        ReelSubscriptionAccess.fetchGateSnapshot(forceRefresh: true),
      );
    }
    if (!AppConfig.enableProfileReelHintRefreshOnTabV214) {
      return;
    }
    profileHintRevision.value++;
  }

  static void onReelsTabVisible() {
    if (!AppConfig.enableReelGateRefreshOnReelsTabV214) {
      return;
    }
    ReelSubscriptionAccess.invalidateCache();
    unawaited(
      ReelSubscriptionAccess.fetchGateSnapshot(forceRefresh: true),
    );
  }

  static void onMyAdsTabVisible() {
    if (!AppConfig.enableReelGateRefreshOnMyAdsTabV214) {
      return;
    }
    ReelSubscriptionAccess.invalidateCache();
    unawaited(
      ReelSubscriptionAccess.fetchGateSnapshot(forceRefresh: true),
    );
  }

  static void onSubscriptionCatalogVisible() {
    if (!AppConfig.enableSubscriptionCatalogGateRefreshOnOpenV214) {
      return;
    }
    ReelSubscriptionAccess.invalidateCache();
    unawaited(
      ReelSubscriptionAccess.fetchGateSnapshot(forceRefresh: true),
    );
    if (AppConfig.enableProfileReelHintRefreshOnTabV214) {
      profileHintRevision.value++;
    }
  }

  static void onAdPostingWizardVisible() {
    if (!AppConfig.enableAdPostingWizardGateRefreshOnOpenV214) {
      return;
    }
    ReelSubscriptionAccess.invalidateCache();
    unawaited(
      ReelSubscriptionAccess.fetchGateSnapshot(forceRefresh: true),
    );
    if (AppConfig.enableProfileReelHintRefreshOnTabV214) {
      profileHintRevision.value++;
    }
  }

  static void onAdDetailsOwnerVisible() {
    if (!AppConfig.enableAdDetailsOwnerReelGateRefreshV214) {
      return;
    }
    ReelSubscriptionAccess.invalidateCache();
    unawaited(
      ReelSubscriptionAccess.fetchGateSnapshot(forceRefresh: true),
    );
  }

  static void onReelUploadComplete() {
    if (!AppConfig.enableProfileHintRefreshAfterReelUploadCompleteV214) {
      return;
    }
    ReelSubscriptionAccess.invalidateCache();
    if (AppConfig.enableProfileReelHintRefreshOnTabV214) {
      profileHintRevision.value++;
    }
  }

  static void onActivePlansScreenVisible() {
    if (!AppConfig.enableActivePlanGateRefreshOnOpenV214) {
      return;
    }
    ReelSubscriptionAccess.invalidateCache();
    unawaited(
      ReelSubscriptionAccess.fetchGateSnapshot(forceRefresh: true),
    );
  }

  static void afterPackagePurchase() {
    if (!AppConfig.enableReelSubscriptionRefreshAfterPurchaseV214) {
      return;
    }
    ReelSubscriptionAccess.invalidateCache();
    if (AppConfig.enableReelSubscriptionPrefetchAfterPurchaseV214) {
      unawaited(
        ReelSubscriptionAccess.canUseReelFeatures(forceRefresh: true),
      );
    }
    if (AppConfig.enableActivePlanRefreshAfterPurchaseV214) {
      activePlansRevision.value++;
    }
    if (AppConfig.enableProfileReelHintRefreshOnTabV214) {
      profileHintRevision.value++;
    }
  }
}
