import 'package:eClassify/settings.dart';

/// Live Sells Point values for the 2.14 codebase merge.
///
/// New eClassify sources read [AppConfig]; the live app still uses [AppSettings]
/// for API URLs and branding. This bridge keeps a single source of truth in
/// [AppSettings] until modules are migrated.
class AppConfig {
  static const String applicationName = AppSettings.applicationName;

  /// Admin panel origin without trailing slash (no `/api/` suffix).
  static String get hostUrl {
    var url = AppSettings.demoUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Public website origin for share links.
  static String get shareDomain {
    final web = AppSettings.shareNavigationWebUrl.trim();
    if (web.startsWith('http://') || web.startsWith('https://')) {
      var u = web;
      while (u.endsWith('/')) {
        u = u.substring(0, u.length - 1);
      }
      return u;
    }
    return 'https://$web';
  }

  /// 0 uses admin panel defaults after location merge.
  static double defaultLatitude = 0.0;
  static double defaultLongitude = 0.0;

  static const String defaultCountryCode = 'IN';
  static const String defaultPhoneCode = AppSettings.defaultCountryCode;

  static String get apiBaseUrl => '${hostUrl}/api/';

  static const bool showCompanyLogo = true;

  /// Sells Point custom modules (see [SellsPointModules]).
  static const bool enableStatusStories = true;
  static const bool enableReferralProgram = true;
  static const bool enableWallet = true;

  /// Group FAQs/contact and legal pages under 2.14-style hubs on profile.
  static const bool enableHelpAndLegalHubs = true;

  /// Phone OTP + API reset-password flow on forgot-password screen.
  static const bool enablePhoneForgotPassword = true;

  /// OTP re-auth before delete for phone accounts (2.14).
  static const bool enableDeleteAccountOtpVerification = true;

  /// Use [VersionUpdateDialog] + semantic version compare on main entry.
  static const bool enableVersionUpdateDialogV214 = true;

  /// Leaf location model + cubit (Hive-compatible); home uses [LeafLocationBridge].
  static const bool enableLeafLocationFoundation = true;

  /// Breadcrumb category browser at [Routes.categoryBrowsing] (2.14 route name).
  static const bool enableCategoryBrowsingV214 = true;

  /// 2.14 [Routes.locationScreen] hub (legacy list + nearby until map picker).
  static const bool enableLocationScreenV214 = true;

  /// Category-scoped packages + active plan routes (2.14 subscription flow).
  static const bool enableSubscriptionFlowV214 = true;

  /// Job apply form + applications list (2.14 routes).
  static const bool enableJobApplicationsV214 = true;

  /// Follow / unfollow + [Routes.followersScreen] lists.
  static const bool enableFollowersV214 = true;

  /// 2.14 [Routes.adPostingScreen] gateway before legacy category wizard.
  static const bool enableAdPostingRouteV214 = true;

  /// Map pin picker at [Routes.locationMapPicker].
  static const bool enableLocationMapPickerV214 = true;

  /// [Routes.chatScreen] and [Routes.sellerItemChatScreen] wrappers.
  static const bool enableChatRoutesV214 = true;

  /// [Routes.videoAdEditor] stub until trimmer lands.
  static const bool enableVideoAdEditorRouteV214 = true;

  /// Native pick + trim on [VideoAdEditorScreen] ([video_trimmer]).
  static const bool enableVideoAdEditorTrimmerV214 = true;

  /// Cold start + tap handlers use [NotificationDeepLinkNavigation].
  static const bool enableNotificationDeepLinksV214 = true;

  /// My ads / owner ad details → [Routes.sellerItemChatScreen].
  static const bool enableSellerItemChatV214 = true;

  /// 2.14 shell: 5 tabs + center FAB (reels tab); legacy 4-tab + notch FAB when off.
  static const bool enableFiveTabNavV214 = true;

  /// Linear step bar on legacy category → details → location post flow.
  static const bool enableAdPostingWizardProgressV214 = true;

  /// Ad type step + [Routes.categoryBrowsing] leaf for post-ad (vs legacy select category).
  static const bool enableAdPostingWizardV214 = true;

  /// In-app [AdPostingCubit] wizard (ad type, category, basic fields; media/location legacy).
  static const bool enableAdPostingInAppWizardV214 = true;

  /// Pinned search + [CustomScrollView] on home ([AppConfig.enableHomeSliverV214]).
  static const bool enableHomeSliverV214 = true;

  /// Home block order from admin `get-home-screen`; falls back to fixed order on failure.
  static const bool enableHomeConfigurationV214 = true;

  /// After wizard photos, seed cloud payload and open [Routes.confirmLocationScreen].
  static const bool enableAdPostingWizardDirectLocationV214 = true;

  /// Prefill confirm-location map from [LeafLocationBridge] on wizard handoff.
  static const bool enableAdPostingWizardLocationPrefillV214 = true;

  /// "Pin on map" shortcut on wizard confirm location ([Routes.locationMapPicker]).
  static const bool enableAdPostingWizardMapPickerV214 = true;

  /// Clear cloud/custom-field state when starting a new post-ad session.
  static const bool enableAdPostingWizardSessionResetV214 = true;

  /// Video ad tile on in-app wizard routes to [Routes.videoAdEditor] (stub).
  static const bool enableAdPostingVideoAdTypeV214 = true;

  /// Centralized popUntil + cleanup from post-ad success screen.
  static const bool enableAdPostingSuccessStackCleanupV214 = true;

  /// JPEG thumb from trimmed reel for main listing image + [Api.uploadMediaThumbnailField].
  static const bool enableAdPostingVideoReelThumbnailV214 = true;

  /// Hide [Api.videoLink] on media step when a local reel file is attached.
  static const bool enableAdPostingHideVideoLinkWhenReelV214 = true;

  /// Track reel background uploads + retry on success screen.
  static const bool enableReelUploadTrackerV214 = true;

  /// Pending/failed reel chip on My Ads list rows.
  static const bool enableReelUploadMyAdsBadgeV214 = true;

  /// Owner reel panel on [AdDetailsScreen] (video listings + upload retry).
  static const bool enableSellerReelOwnerSectionV214 = true;

  /// Push/deep links open reels tab with `reel_id` / `item_id`.
  static const bool enableReelNotificationDeepLinkV214 = true;

  /// Video/reel flows require active package with `is_reel_allowed`.
  static const bool enableReelSubscriptionGateV214 = true;

  /// When reel gate blocks, show upgrade dialog → subscription catalog.
  static const bool enableReelSubscriptionUpgradePromptV214 = true;

  /// Upgrade dialog opens item listing packages (reel plans first).
  static const bool enableReelSubscriptionDirectListingV214 = true;

  /// Short TTL cache for [ReelSubscriptionAccess.canUseReelFeatures].
  static const bool enableReelSubscriptionAccessCacheV214 = true;

  /// Invalidate reel gate cache after subscription checkout completes.
  static const bool enableReelSubscriptionRefreshAfterPurchaseV214 = true;

  /// Warm reel gate cache immediately after checkout.
  static const bool enableReelSubscriptionPrefetchAfterPurchaseV214 = true;

  /// Reel upgrade flow lists only packages with `is_reel_allowed`.
  static const bool enableReelSubscriptionHideNonReelPlansV214 = true;

  /// Reel included chip on [ActivePlanScreen] item listing rows.
  static const bool enableActivePlanReelBadgeV214 = true;

  /// Upgrade CTA on active listing plan without reels.
  static const bool enableActivePlanGetReelsCtaV214 = true;

  /// Refetch [ActivePlanScreen] when [ReelSubscriptionRefresh] runs after checkout.
  static const bool enableActivePlanRefreshAfterPurchaseV214 = true;

  /// Subtitle on profile subscription row when listing plan lacks reels.
  static const bool enableProfileReelSubscriptionHintV214 = true;

  /// Profile subscription tap (reel hint visible) → reel listing catalog.
  static const bool enableProfileReelDirectCatalogV214 = true;

  /// Reel plans tile + footnote on subscription category hub.
  static const bool enableSubscriptionReelPlansEntryV214 = true;

  /// Empty active plans → CTA for ad listing / reel plans.
  static const bool enableActivePlanEmptyReelCtaV214 = true;

  /// Refresh profile subscription/reel hint when Profile tab is opened.
  static const bool enableProfileReelHintRefreshOnTabV214 = true;

  /// Reel flows require an active item listing plan (not only reel upgrade).
  static const bool enableReelGateRequiresListingPlanV214 = true;

  /// Profile subtitle when user has no active listing plan.
  static const bool enableProfileReelHintNoListingPlanV214 = true;

  /// Listing-plan gate dialog → ad listing package list (not category hub).
  static const bool enableReelGateDirectListingCatalogV214 = true;

  /// Profile hint (no listing plan) tap → ad listing packages.
  static const bool enableProfileDirectListingCatalogV214 = true;

  /// Subscription hub “All packages” → global ad listing catalog (2.14).
  static const bool enableSubscriptionHubDirectListingV214 = true;

  /// Profile tab visible → invalidate reel gate snapshot and refetch.
  static const bool enableReelGateRefreshOnProfileTabV214 = true;

  /// Global listing package screen app bar title (non–reel-filtered).
  static const bool enableSubscriptionListingScreenTitleV214 = true;

  /// Post-ad / active plan / payment prompts → direct ad listing catalog.
  static const bool enableSubscriptionPrimaryListingCatalogV214 = true;

  /// Profile subscription row (no hint) → [SubscriptionNavigation.openPrimaryAdListingCatalog].
  static const bool enableProfileDefaultListingCatalogV214 = true;

  /// Opening active plans refreshes reel gate snapshot for profile hints.
  static const bool enableActivePlanGateRefreshOnOpenV214 = true;

  /// Reels tab selected → refresh reel gate snapshot (browse/post CTAs).
  static const bool enableReelGateRefreshOnReelsTabV214 = true;

  /// Ad listing package list app bar → active plans shortcut.
  static const bool enableSubscriptionPackageListActivePlansV214 = true;

  /// My Ads tab → refresh reel gate before retry/upload flows.
  static const bool enableReelGateRefreshOnMyAdsTabV214 = true;

  /// Package catalog screen open → refresh gate + profile subscription hints.
  static const bool enableSubscriptionCatalogGateRefreshOnOpenV214 = true;

  /// Reel-filtered catalog empty → CTA for all ad listing plans.
  static const bool enableReelPlansEmptyAllListingCtaV214 = true;

  /// FCM types `subscription` / `package*` → ad listing catalog.
  static const bool enableSubscriptionNotificationDeepLinkV214 = true;

  /// Reels tab re-selected → refetch feed + gate snapshot.
  static const bool enableReelsTabRepeatTapRefreshV214 = true;

  /// 5-tab reels screen: no back affordance, optional post CTA.
  static const bool enableReelsTabEmbeddedShellV214 = true;

  /// App bar + on reels tab → post ad (package limit check).
  static const bool enableReelsTabPostAdCtaV214 = true;

  /// Empty reels feed → post video ad CTA (embedded tab).
  static const bool enableReelsTabEmptyPostCtaV214 = true;

  /// Post-ad wizard video type card shows listing/reel plan hints.
  static const bool enableAdPostingVideoAdReelHintV214 = true;

  /// `package-expired` push → active plans (not catalog).
  static const bool enableSubscriptionExpiredActivePlansDeepLinkV214 = true;

  /// Reels post CTA → wizard with video ad type + skip type step.
  static const bool enableAdPostingLaunchVideoAdFromReelsV214 = true;

  static const bool enableReelsTabPostAdSkipsTypeStepV214 = true;

  /// After package limit on reels tab, run reel gate before wizard.
  static const bool enableReelsTabPostAdReelGateV214 = true;

  /// Video ad type card: gate on select when subscription gate is on.
  static const bool enableAdPostingVideoAdGateOnSelectV214 = true;

  /// My Ads tab re-selected → refetch listings + gate refresh.
  static const bool enableMyAdsTabRepeatTapRefreshV214 = true;

  /// Post-ad in-app wizard open → refresh reel gate + profile hints.
  static const bool enableAdPostingWizardGateRefreshOnOpenV214 = true;

  /// Media step: attach reel video via editor (video ad type).
  static const bool enableAdPostingMediaStepVideoEditorCtaV214 = true;

  /// Video ad without local reel must attach reel when link field is hidden.
  static const bool enableAdPostingMediaStepRequireReelVideoV214 = true;

  /// FCM `payment-success` → active plans screen.
  static const bool enablePaymentSuccessActivePlansDeepLinkV214 = true;

  /// Video editor during wizard uses push/pop (keeps wizard stack).
  static const bool enableAdPostingVideoEditorReturnToWizardV214 = true;

  /// Media step label when reel draft is already attached.
  static const bool enableAdPostingMediaStepReelAttachedLabelV214 = true;

  /// Success screen extra CTAs when background reel upload was queued.
  static const bool enableAdPostingSuccessReelUploadCtasV214 = true;

  /// After reel upload queued → refresh My Ads lists.
  static const bool enableMyAdsRefreshAfterReelUploadV214 = true;

  /// After reel upload queued → refresh reels tab feed.
  static const bool enableReelFeedRefreshAfterReelUploadV214 = true;

  /// Upload finished → refresh My Ads + reels feed listeners.
  static const bool enableReelUploadCompleteFeedRefreshV214 = true;

  /// Success / details banner shows “upload complete” + view reel CTA.
  static const bool enableReelUploadBannerCompleteCtaV214 = true;

  /// Owner ad details open → refresh reel gate (upload / post CTAs).
  static const bool enableAdDetailsOwnerReelGateRefreshV214 = true;

  /// My Ads row → open reels feed for video listings (5-tab).
  static const bool enableMyAdsVideoReelsShortcutV214 = true;

  /// Seller upload CTA only when listing has no video URL yet.
  static const bool enableSellerReelUploadOnlyWhenMissingMediaV214 = true;

  /// Reel push handled → refresh My Ads + reels listeners.
  static const bool enableReelNotificationRefreshListsV214 = true;

  /// FCM `reel-upload-failed` → owner ad details.
  static const bool enableReelUploadFailedNotificationV214 = true;

  /// Media step: replace attached reel video.
  static const bool enableAdPostingMediaStepReplaceReelV214 = true;

  /// `item-update` push → refresh My Ads / reels listeners.
  static const bool enableItemUpdateNotificationRefreshV214 = true;

  /// Reel upload finished → profile subscription hint refresh.
  static const bool enableProfileHintRefreshAfterReelUploadCompleteV214 = true;

  /// My Ads pending upload chip tap → open ad details.
  static const bool enableMyAdsReelPendingBadgeOpensDetailsV214 = true;

  /// Reels shortcut on My Ads only when listing has URL or is live.
  static const bool enableMyAdsVideoReelsShortcutRequiresPlayableMediaV214 = true;

  /// Failed upload chip tap → ad details (retry on banner).
  static const bool enableMyAdsReelFailedBadgeOpensDetailsV214 = true;

  /// Ad details refreshes after attach-reel editor returns success.
  static const bool enableAdDetailsRefreshAfterReelEditorV214 = true;

  /// FCM `reel-upload` (in progress) → My Ads + item details when possible.
  static const bool enableReelUploadProgressNotificationV214 = true;

  /// Buyers see watch-in-reels on playable video listings.
  static const bool enableAdDetailsBuyerViewReelsCtaV214 = true;

  /// Confirm location step hint when wizard queued background reel upload.
  static const bool enableConfirmLocationPendingReelHintV214 = true;

  /// Reel FCM with `navigate=ad_details` opens owner ad details.
  static const bool enableReelNotificationDestinationAdDetailsV214 = true;

  /// Upload-complete banner includes dismiss control.
  static const bool enableReelUploadBannerCompleteDismissV214 = true;

  /// My Ads rows label for video listing type.
  static const bool enableMyAdsVideoListingLabelV214 = true;

  /// Reels HUD: buyer opens ad details to message seller.
  static const bool enableReelFeedBuyerContactCtaV214 = true;

  /// Reels HUD: owner opens ad details to manage listing.
  static const bool enableReelFeedOwnerManageCtaV214 = true;

  /// Reels feed empty for `item_id` filter → view listing CTA.
  static const bool enableReelsFeedEmptyItemAdDetailsCtaV214 = true;

  /// Reels HUD buyer chat opens seller chat (not ad details only).
  static const bool enableReelFeedBuyerDirectChatV214 = true;

  /// Reels HUD share reel deep link (copy / system share).
  static const bool enableReelFeedShareActionV214 = true;

  /// Owner edit icon on own reel → edit listing flow (not ad details only).
  static const bool enableReelFeedOwnerEditListingV214 = true;

  /// After chat opened from reels, refresh buyer chat list on pop.
  static const bool enableReelFeedBuyerChatReturnRefreshV214 = true;
}
