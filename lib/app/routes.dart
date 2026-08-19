import 'package:eClassify/app/sells_point_modules.dart';
import 'package:eClassify/ui/screens/advertisement/details/ad_details_screen.dart';
import 'package:eClassify/ui/screens/advertisement/my_advertisment_screen.dart';
import 'package:eClassify/ui/screens/auth/delete_account_verification_screen.dart';
import 'package:eClassify/ui/screens/auth/forgot_password_otp_verification_screen.dart';
import 'package:eClassify/ui/screens/auth/login/login_screen.dart';
import 'package:eClassify/ui/screens/auth/reset_password_screen.dart';
import 'package:eClassify/ui/screens/auth/sign_up/signup_screen.dart';
import 'package:eClassify/ui/screens/blogs/blog_details_screen.dart';
import 'package:eClassify/ui/screens/blogs/blogs_screen.dart';
import 'package:eClassify/ui/screens/chat/chat_screen.dart';
import 'package:eClassify/ui/screens/chat/inbox/blocked_user_list_screen.dart';
import 'package:eClassify/ui/screens/chat/inbox/seller_item_chat_screen.dart';
import 'package:eClassify/ui/screens/company_details/company_page_screen.dart';
import 'package:eClassify/ui/screens/company_details/contact_us.dart';
import 'package:eClassify/ui/screens/faqs_screen.dart';
import 'package:eClassify/ui/screens/favorite_screen.dart';
import 'package:eClassify/ui/screens/followers/follow_users_screen.dart';
import 'package:eClassify/ui/screens/home/change_language_screen.dart';
import 'package:eClassify/ui/screens/home/widgets/category/category_browsing_screen.dart';
import 'package:eClassify/ui/screens/item/ad_posting/ad_posting_screen.dart';
import 'package:eClassify/ui/screens/item/ad_posting/ad_posting_success_screen.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/video_ad_editor.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/category_filter_screen.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/filter_screen.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_list_screen.dart';
import 'package:eClassify/ui/screens/item/job_application/job_application_form.dart';
import 'package:eClassify/ui/screens/item/job_application/job_application_list_screen.dart';
import 'package:eClassify/ui/screens/item/my_items_screen.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/video_ads_screen.dart';
import 'package:eClassify/ui/screens/location/location_screen.dart';
import 'package:eClassify/ui/screens/location/widgets/location_map_picker.dart';
import 'package:eClassify/ui/screens/main_activity.dart';
import 'package:eClassify/ui/screens/my_wallet/my_wallet_screen.dart';
import 'package:eClassify/ui/screens/referral_program/referral_program_screen.dart';
import 'package:eClassify/new_development/status/models/status_models.dart';
import 'package:eClassify/new_development/status/screens/status_user_viewer.dart';
import 'package:eClassify/ui/screens/my_review_screen.dart';
import 'package:eClassify/ui/screens/onboarding/onboarding_screen.dart';
import 'package:eClassify/ui/screens/pdf_viewer.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/help_and_support_screen.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/legal_information_screen.dart';
import 'package:eClassify/ui/screens/seller/seller_intro_verification.dart';
import 'package:eClassify/ui/screens/seller/seller_profile/seller_profile_screen.dart';
import 'package:eClassify/ui/screens/seller/seller_verification.dart';
import 'package:eClassify/ui/screens/seller/seller_verification_complete.dart';
import 'package:eClassify/ui/screens/settings/notification_detail.dart';
import 'package:eClassify/ui/screens/settings/notifications.dart';
import 'package:eClassify/ui/screens/sold_out_bought_screen.dart';
import 'package:eClassify/ui/screens/splash_screen.dart';
import 'package:eClassify/ui/screens/subscription/active_plan_screen.dart';
import 'package:eClassify/ui/screens/subscription/subscription_package_screen.dart';
import 'package:eClassify/ui/screens/subscription/subscription_screen.dart';
import 'package:eClassify/ui/screens/subscription/transaction_history_screen.dart';
import 'package:eClassify/ui/screens/subscription/transaction_receipt_screen.dart';
import 'package:eClassify/ui/screens/subscription/widgets/subscription_category_selection.dart';
import 'package:eClassify/ui/screens/user_profile/edit_profile.dart';
import 'package:eClassify/ui/screens/widgets/maintenance_mode.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Class containing all route names and navigation logic
class Routes {
  /// Authentication Routes
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String forgotPassword = 'forgotPassword';
  static const String forgotPasswordOtpVerification =
      'forgotPasswordOtpVerification';
  static const String resetPassword = 'resetPassword';
  static const String signup = 'signup';
  static const String completeProfile = 'complete_profile';
  static const String deleteAccountVerification = 'deleteAccountVerification';

  /// Main Navigation Routes
  static const String main = 'main';
  static const String home = 'Home';
  static const String itemsList = 'itemsList';
  static const String addItem = 'addItem';

  /// Settings & Profile Routes
  static const String contactUs = '/contactUs';
  static const String companyPage = '/companyPage';
  static const String notificationPage = 'notificationpage';
  static const String notificationDetailPage = 'notificationdetailpage';
  static const String helpAndSupportScreen = '/helpAndSupport';
  static const String legalInformationScreen = '/legalInformation';

  /// Feature Routes
  static const String filterScreen = 'filterScreen';
  static const String blogsScreen = '/blogsScreen';
  static const String blogDetailsScreen = '/blogDetailsScreen';
  static const String maintenanceMode = '/maintenanceMode';
  static const String favoritesScreen = '/favoritescreen';
  static const String myReviewsScreen = '/myReviewsScreenRoute';

  /// Location & Category Routes
  static const String languageListScreenRoute = '/languageListScreenRoute';
  static const String subCategoryScreen = '/subCategoryScreen';
  static const String categoryFilterScreen = '/categoryFilterScreen';
  static const String postedSinceFilterScreen = '/postedSinceFilterScreen';
  static const String categoryBrowsing = '/categoryBrowsing';

  /// Item Management Routes
  static const String myAdvertisment = '/myAdvertisment';
  static const String transactionHistory = '/transactionHistory';
  static const String myItemScreen = '/myItemScreen';
  static const String pdfViewerScreen = '/pdfViewerScreen';
  static const String adDetailsScreen = '/adDetailsScreen';

  /// Location Management Routes
  static const String locationScreen = '/locationScreen';
  static const String locationMapPicker = '/locationMapPicker';

  /// Seller Routes
  static const String sellerProfileScreen = '/sellerProfileScreen';
  static const String sellerIntroVerificationScreen =
      '/sellerIntroVerificationScreen';
  static const String sellerVerificationScreen = '/sellerVerificationScreen';
  static const String sellerVerificationComplteScreen =
      '/sellerVerificationCompleteScreen';

  /// Item Creation Routes
  static const String adPostingScreen = '/adPostingScreen';
  static const String adPostingSuccessScreen = '/adPostingSuccessScreen';
  static const String videoAdEditor = '/videoAdEditor';
  static const String videoAdsScreen = '/videoAdsScreen';

  /// Other Routes
  static const String faqsScreen = '/faqsScreen';
  static const String soldOutBoughtScreen = '/soldOutBoughtScreen';
  static const String blockedUserListScreen = '/blockedUserListScreen';
  static const String jobApplicationForm = '/jobApplicationForm';
  static const String jobApplicationList = '/jobApplicationList';

  static const String followersScreen = '/followersScreen';

  static const String subscriptionScreen = '/subscriptionScreen';
  static const String subscriptionCategorySelectionScreen =
      '/subscriptionCategorySelectionScreen';
  static const String subscriptionPackageScreen = '/subscriptionPackageScreen';
  static const String activePlanScreen = '/activePlanScreen';

  static const String sellerItemChatScreen = '/sellerItemChatScreen';
  static const String chatScreen = '/chatScreen';

  static const String transactionReceipt = '/transactionReceipt';

  /// Sells Point — wallet, referral, status stories
  static const String myWalletScreen = '/myWalletScreen';
  static const String referralProgramScreen = '/referralProgramScreen';
  static const String statusStoriesViewer = '/statusStoriesViewer';

  /// Route tracking
  static String currentRoute = '';
  static String previousRoute = '';

  /// Generates routes based on the provided settings
  static Route onGenerateRouted(RouteSettings routeSettings) {
    previousRoute = currentRoute;
    currentRoute = routeSettings.name ?? '';

    // Handle dynamic routes (product-details and seller)
    if (_isDynamicRoute(routeSettings.name)) {
      return _handleDynamicRoute(routeSettings);
    }

    // Handle static routes
    return _handleStaticRoute(routeSettings);
  }

  /// Checks if the route is a dynamic route
  static bool _isDynamicRoute(String? routeName) {
    return routeName?.contains('/ad-details/') == true ||
        routeName?.contains('/seller/') == true;
  }

  /// Handles dynamic routes (product-details and seller)
  static Route _handleDynamicRoute(RouteSettings routeSettings) {
    final uri = Uri.parse(routeSettings.name!);
    final pathSegments = uri.pathSegments;
    final type = pathSegments[0];
    final value = pathSegments[1];

    HiveUtils.setUserSkip();

    if (type == 'ad-details') {
      return _handleProductDetailsRoute(value);
    } else if (type == 'seller') {
      return _handleSellerRoute(value);
    }

    return _defaultRoute();
  }

  /// Handles product details route
  static Route _handleProductDetailsRoute(String value) {
    if (previousRoute.isEmpty) {
      //return MaterialPageRoute(builder: (_) => SplashScreen(itemSlug: value));
    }

    if (currentRoute == adDetailsScreen) {
      Constant.navigatorKey.currentState?.pop();
    }

    return AdDetailsScreen.route(RouteSettings(arguments: {"slug": value}));
  }

  /// Handles seller route
  static Route _handleSellerRoute(String value) {
    if (previousRoute.isEmpty) {
      //return MaterialPageRoute(builder: (_) => SplashScreen(sellerId: value));
    }

    if (currentRoute == sellerProfileScreen) {
      Constant.navigatorKey.currentState?.pop();
    }

    return SellerProfileScreen.route(
      RouteSettings(arguments: int.parse(value)),
    );
  }

  /// Handles static routes
  static Route _handleStaticRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return SplashScreen.route(routeSettings);
      case onboarding:
        return OnboardingScreen.route(routeSettings);
      case main:
        return MainActivity.route(routeSettings);
      case login:
        return LoginScreen.route(routeSettings);
      case forgotPasswordOtpVerification:
        return ForgotPasswordOtpVerificationScreen.route(routeSettings);
      case resetPassword:
        return ResetPasswordScreen.route(routeSettings);
      case signup:
        return SignupScreen.route(routeSettings);
      case completeProfile:
        return UserProfileScreen.route(routeSettings);
      case deleteAccountVerification:
        return DeleteAccountVerificationScreen.route(routeSettings);
      case categoryFilterScreen:
        return CategoryFilterScreen.route(routeSettings);
      case maintenanceMode:
        return MaintenanceMode.route(routeSettings);
      case languageListScreenRoute:
        return LanguagesListScreen.route(routeSettings);
      case contactUs:
        return ContactUs.route(routeSettings);
      case companyPage:
        return CompanyPageScreen.route(routeSettings);
      case filterScreen:
        return FilterScreen.route(routeSettings);
      case blogsScreen:
        return BlogsScreen.route(routeSettings);
      case blogDetailsScreen:
        return BlogDetailsScreen.route(routeSettings);
      case notificationPage:
        return Notifications.route(routeSettings);
      case notificationDetailPage:
        return NotificationDetail.route(routeSettings);
      case jobApplicationForm:
        return JobApplicationForm.route(routeSettings);
      case jobApplicationList:
        return JobApplicationListScreen.route(routeSettings);
      case favoritesScreen:
        return FavoriteScreen.route(routeSettings);
      case transactionHistory:
        return TransactionHistory.route(routeSettings);
      case blockedUserListScreen:
        return BlockedUserListScreen.route(routeSettings);
      case locationScreen:
        return LocationScreen.route(routeSettings);
      case locationMapPicker:
        return LocationMapPicker.route(routeSettings);
      case myAdvertisment:
        return MyAdvertisementScreen.route(routeSettings);
      case myItemScreen:
        return ItemsScreen.route(routeSettings);
      case itemsList:
        return ItemListScreen.route(routeSettings);
      case faqsScreen:
        return FaqsScreen.route(routeSettings);
      case adPostingScreen:
        return AdPostingScreen.route(routeSettings);
      case adPostingSuccessScreen:
        return AdPostingSuccessScreen.route(routeSettings);
      case videoAdEditor:
        return VideoAdEditor.route(routeSettings);
      case videoAdsScreen:
        return VideoAdsScreen.route(routeSettings);
      case adDetailsScreen:
        return AdDetailsScreen.route(routeSettings);
      case pdfViewerScreen:
        return PdfViewer.route(routeSettings);
      case soldOutBoughtScreen:
        return SoldOutBoughtScreen.route(routeSettings);
      case sellerProfileScreen:
        return SellerProfileScreen.route(routeSettings);
      case sellerIntroVerificationScreen:
        return SellerIntroVerificationScreen.route(routeSettings);
      case sellerVerificationScreen:
        return SellerVerificationScreen.route(routeSettings);
      case sellerVerificationComplteScreen:
        return SellerVerificationCompleteScreen.route(routeSettings);
      case myReviewsScreen:
        return MyReviewScreen.route(routeSettings);
      case followersScreen:
        return FollowUsersScreen.route(routeSettings);
      case subscriptionScreen:
        return SubscriptionScreen.route(routeSettings);
      case subscriptionCategorySelectionScreen:
        return SubscriptionCategorySelection.route(routeSettings);
      case subscriptionPackageScreen:
        return SubscriptionPackageScreen.route(routeSettings);
      case activePlanScreen:
        return ActivePlanScreen.route(routeSettings);
      case sellerItemChatScreen:
        return SellerItemChatScreen.route(routeSettings);
      case chatScreen:
        return ChatScreen.route(routeSettings);
      case categoryBrowsing:
        return CategoryBrowsingScreen.route(routeSettings);
      case transactionReceipt:
        return TransactionReceiptScreen.route(routeSettings);
      case myWalletScreen:
        if (!SellsPointModules.wallet) return _defaultRoute();
        return MyWalletScreen.route(routeSettings);
      case referralProgramScreen:
        if (!SellsPointModules.referralProgram) return _defaultRoute();
        return ReferralProgramScreen.route(routeSettings);
      case statusStoriesViewer:
        if (!SellsPointModules.statusStories) return _defaultRoute();
        return _statusStoriesRoute(routeSettings);
      case helpAndSupportScreen:
        return HelpAndSupportScreen.route(routeSettings);
      case legalInformationScreen:
        return LegalInformationScreen.route(routeSettings);
      default:
        return _defaultRoute();
    }
  }

  /// Returns the default route
  static Route _defaultRoute() {
    return CupertinoPageRoute(builder: (context) => const Scaffold());
  }

  static Route _statusStoriesRoute(RouteSettings settings) {
    final args = settings.arguments;
    if (args is! Map) {
      return _defaultRoute();
    }
    final users = args['allUsers'];
    if (users is! List<StatusModel>) {
      return _defaultRoute();
    }
    final index = args['initialUserIndex'];
    return MaterialPageRoute(
      builder: (context) => StatusUserViewer(
        allUsers: users,
        initialUserIndex: index is int ? index : 0,
      ),
    );
  }
}
