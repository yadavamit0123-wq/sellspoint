class AppAssets {
  AppAssets._();

  static const bottomNavigation = const _BottomNavigation();
  static const branding = const _Branding();
  static const illustrators = const _Illustrators();
  static const payment = const _Payment();
  static const profile = const _Profile();
  static const social = const _Social();
  static const common = const _Common();
}

class _BottomNavigation {
  const _BottomNavigation();

  static const _basePath = 'assets/icons/bottom_navigation';

  final home = '$_basePath/home_inactive.svg';
  final homeActive = '$_basePath/home_active.svg';
  final chat = '$_basePath/chat_inactive.svg';
  final chatActive = '$_basePath/chat_active.svg';
  final videoAds = '$_basePath/video_ads_inactive.svg';
  final videoAdsActive = '$_basePath/video_ads_active.svg';
  final myAds = '$_basePath/my_ads_inactive.svg';
  final myAdsActive = '$_basePath/my_ads_active.svg';
  final profile = '$_basePath/profile_inactive.svg';
  final profileActive = '$_basePath/profile_active.svg';
}

class _Branding {
  const _Branding();

  static const _basePath = 'assets/icons/branding';

  final String logo = '$_basePath/logo.svg';
  final String company = '$_basePath/company_logo.svg';
  final String placeholder = '$_basePath/placeholder.svg';
}

class _Illustrators {
  const _Illustrators();

  static const _basePath = 'assets/icons/illustrators';

  final String somethingWentWrong = '$_basePath/something_went_wrong.svg';
  final String noDataFound = '$_basePath/no_data_found.svg';
  final String verificationMail = '$_basePath/mail_verification.svg';
  final String noInternet = '$_basePath/no_internet.svg';
  final String delete = '$_basePath/delete_user.svg';
  final String logout = '$_basePath/logout_user.svg';
  final String createAdd = '$_basePath/create_add.svg';
  final String locationDenied = '$_basePath/location_denied.svg';
  final String locationAccess = '$_basePath/location_access.svg';
  final String safetyTips = '$_basePath/safety_tips.svg';
  final String userVerification = '$_basePath/user_verification.svg';
  final String onboardingA = '$_basePath/onboarding_a.svg';
  final String onboardingB = '$_basePath/onboarding_b.svg';
  final String onboardingC = '$_basePath/onboarding_c.svg';
}

class _Payment {
  const _Payment();

  static const _basePath = 'assets/icons/payment';

  final String stripe = '$_basePath/ic_stripe.svg';
  final String razorpay = '$_basePath/ic_razorpay.svg';
  final String paystack = '$_basePath/ic_paystack.svg';
  final String phonePe = '$_basePath/ic_phonepe.svg';
  final String flutterwave = '$_basePath/ic_flutterwave.svg';
  final String bankTransfer = '$_basePath/ic_banktransfer.svg';
  final String paypal = '$_basePath/ic_paypal.svg';
  final String paytabs = '$_basePath/ic_paytabs.png';
  final String dpo = '$_basePath/ic_dpopay.png';
}

class _Profile {
  const _Profile();

  static const _basePath = 'assets/icons/profile';

  final String profile = '$_basePath/profile.svg';
  final String defaultPerson = '$_basePath/default_profile_icon.svg';
  final String contactUs = '$_basePath/contact_us_icon.svg';
}

class _Social {
  const _Social();

  static const _basePath = 'assets/icons/social';

  final String apple = '$_basePath/apple_icon.svg';
  final String google = '$_basePath/google_icon.svg';
  final String whatsapp = '$_basePath/whatsapp_icon.svg';
}

class _Common {
  const _Common();

  static const _basePath = 'assets/icons/common';

  final String adminEdit = '$_basePath/admin_edit.svg';
}
