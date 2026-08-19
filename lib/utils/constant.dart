import 'package:eClassify/data/model/system_settings.dart';
import 'package:eClassify/settings.dart';
import 'package:flutter/material.dart';

final class Constant {
  /// Immutable constants that will never be mutated during runtime

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String appName = AppSettings.applicationName;
  static const String inviteURL = 'https://sellspoint.in/refer';
  static const String shareappText = AppSettings.shareAppText;
  static const String shareappTextSecond = AppSettings.shareAppTextSecond;

  static final RouteObserver<ModalRoute> routeObserver =
      RouteObserver<ModalRoute>();

  static const double horizontalPadding = 16;
  static const double verticalPadding = 20;
  static const double bottomPadding = 20;
  static const double topPadding = 20;
  static const EdgeInsets appContentPadding = EdgeInsets.only(
    left: horizontalPadding,
    right: horizontalPadding,
    top: topPadding,
  );
  static const EdgeInsets safeAreaMinimumPadding = EdgeInsets.only(
    bottom: bottomPadding,
    left: horizontalPadding,
    right: horizontalPadding,
    top: topPadding,
  );

  // Interval for showing native ads in home screen's infinite scrolling
  // ONLY ADD EVEN NUMBERS
  static const int nativeAdsAfterItemNumber = 12;

  // Interstitial ad throttle settings
  static const int interstitialAdTimeDelaySeconds = 60;

  // Max ads shown per session. Set to -1 to disable count-based throttle.
  static const int interstitialAdMaxCountPerSession = 5;

  // This is only to show the actual google map in ad_details_screen.dart
  // It can be set to false in case there are any lags in loading the screen
  static const bool showGoogleMap = true;

  // Set to true to enforce manual terms/privacy acceptance during registration
  static const bool requireTermsConsent = true;

  // Quality of image to preserve during compression
  static const int uploadImageQuality = 80;

  // Decides whether to use lottie for loading indicator or regular circular indicator
  static const bool useLottieProgress = true;

  // Decides whether to show SEO fields or not during ad posting
  // Disable if you do not wish end users to fill SEO manually or you do not use
  // website
  static const bool showSEOFields = true;

  // Item/Seller status
  static const String statusReview = "review";
  static const String statusResubmitted = "resubmitted";
  static const String statusActive = "active";
  static const String statusApproved = "approved";
  static const String statusInactive = "inactive";
  static const String statusSoldOut = "sold out";
  static const String statusPermanentRejected = "permanent rejected";
  static const String statusSoftRejected = "soft rejected";
  static const String statusExpired = "expired";
  static const String statusRejected = "rejected";
  static const String statusPending = "pending";
  static const String statusUnderReview = "under review";

  // Payment types
  static const String paymentTypeStripe = "stripe";
  static const String paymentTypePaystack = "paystack";
  static const String paymentTypeRazorpay = "razorpay";
  static const String paymentTypePhonepe = "phonepe";
  static const String paymentTypeFlutterwave = "flutterwave";
  static const String paymentTypeBankTransfer = "bankTransfer";
  static const String paymentTypePaypal = "PayPal";
  static const String paymentTypePaytabs = "paytabs";
  static const String paymentTypeDpo = "dpo";

  ///========================================================================///

  /// Mutable values that are set after the initial API call and remains Immutable
  /// throughout the App's lifecycle
  // Storage path for media downloads
  static String savePath = '';

  static int otpTimeOutSecond = 60;

  static bool isUpdateAvailable = false;
  static String newVersionNumber = "";

  //Demo mode settings
  static bool isDemoModeOn = false;

  static late SystemSettings systemSettings;
}
