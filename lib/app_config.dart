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
}
