import 'package:eClassify/app/sells_point_modules.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/settings.dart';

/// Sells Point production config for the 2.14 codebase.
///
/// [AppSettings] is the single source of truth for URLs, app name, and package id.
/// Do not hardcode production URLs here — change [AppSettings] only.
class AppConfig {
  /// Used in SplashScreen to display application name under splash logo
  static const String applicationName = AppSettings.applicationName;

  /// DO NOT ADD "/" AT THE END OF DOMAINS ///
  /// Admin Panel URL
  static String get hostUrl {
    var url = AppSettings.demoUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Website URL to generate share links
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

  /// Default location to be used when App is unable to fetch current location
  static final LeafLocation defaultLocation = LeafLocation.global();

  /// Default latitude and longitude to show on the Google Map when seller
  /// the user hasn’t selected a location.
  ///
  /// 0.0 uses defaults from the Admin Panel.
  static double defaultLatitude = 0.0;
  static double defaultLongitude = 0.0;

  /// 2-Digit ISO code of Country
  static const String defaultCountryCode = 'IN';

  /// Calling code of country — DO NOT USE + SIGN IN FRONT OF CODE
  static const String defaultPhoneCode = AppSettings.defaultCountryCode;

  /// Show the company logo at the bottom of splash screen
  static const bool showCompanyLogo = true;

  /// Sells Point custom modules (see [SellsPointModules]).
  static const bool enableStatusStories = SellsPointModules.statusStories;
  static const bool enableReferralProgram = SellsPointModules.referralProgram;
  static const bool enableWallet = SellsPointModules.wallet;
}
