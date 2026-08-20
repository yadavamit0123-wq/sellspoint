import 'package:eClassify/data/cubits/app_update_cubit.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/delete_user_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/cubits/auth/reset_password_cubit.dart';
import 'package:eClassify/data/cubits/auth/user_profile_cubit.dart';
import 'package:eClassify/data/cubits/banner/banner_ad_cubit.dart';
import 'package:eClassify/data/cubits/category/category_validation_cubit.dart';
import 'package:eClassify/data/cubits/category/main_category_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/delete_chat_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/cubits/currency/currencies_cubit.dart';
import 'package:eClassify/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:eClassify/data/cubits/fetch_faqs_cubit.dart';
import 'package:eClassify/data/cubits/fetch_item_buyer_cubit.dart';
import 'package:eClassify/data/cubits/fetch_my_reviews_cubit.dart';
import 'package:eClassify/data/cubits/fetch_notifications_cubit.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/cubits/home/featured_section_cubit.dart';
import 'package:eClassify/data/cubits/home/home_items_cubit.dart';
import 'package:eClassify/data/cubits/home/home_screen_configuration_cubit.dart';
import 'package:eClassify/data/cubits/home/popular_categories_cubit.dart';
import 'package:eClassify/data/cubits/home/slider_cubit.dart';
import 'package:eClassify/data/cubits/item/change_my_items_status_cubit.dart';
import 'package:eClassify/data/cubits/item/delete_item_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_item_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_featured_items_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/cubits/item/item_total_click_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/cubits/item/related_item_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/liked_reels_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/reel_like_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/video_ads_cubit.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/cubits/location/location_cubit.dart';
import 'package:eClassify/data/cubits/my_item_review_report_cubit.dart';
import 'package:eClassify/data/cubits/notification/notification_event_cubit.dart';
import 'package:eClassify/data/cubits/renew_item_cubit.dart';
import 'package:eClassify/data/cubits/report/item_report_list_cubit.dart';
import 'package:eClassify/data/cubits/report/report_reason_cubit.dart';
import 'package:eClassify/data/cubits/safety_tips_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_item_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_verification_field.dart';
import 'package:eClassify/data/cubits/seller/fetch_verification_request_cubit.dart';
import 'package:eClassify/data/cubits/seller/send_verification_field_cubit.dart';
import 'package:eClassify/data/cubits/subscription/active_subscription_package_cubit.dart';
import 'package:eClassify/data/cubits/subscription/bank_transfer_update_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/cubits/subscription/in_app_purchase_cubit.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/data/cubits/system/get_payment_methods_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/data/cubits/system/system_settings_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/data/cubits/utility/fetch_transactions_cubit.dart';
import 'package:eClassify/data/repositories/item/favourites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

class RegisterCubits {
  List<SingleChildWidget> providers = [
    BlocProvider(create: (context) => AppUpdateCubit()),
    BlocProvider(create: (context) => FavoriteCubit(FavoriteRepository())),
    BlocProvider(
      create: (context) => UpdateFavoriteCubit(FavoriteRepository()),
    ),
    BlocProvider(create: (context) => LoginCubit()),
    BlocProvider(create: (context) => ResetPasswordCubit()),
    BlocProvider(create: (context) => SliderCubit()),
    BlocProvider(create: (context) => AppThemeCubit(), lazy: false),
    BlocProvider(create: (context) => FetchNotificationsCubit()),
    BlocProvider(create: (context) => LanguageCubit()),
    BlocProvider(create: (context) => SystemSettingsCubit()),
    BlocProvider(create: (context) => UserDetailsCubit()),
    BlocProvider(create: (context) => CurrenciesCubit()),
    BlocProvider(create: (context) => FetchMyFeaturedItemsCubit()),
    BlocProvider(create: (context) => GetPaymentMethodsCubit()),
    BlocProvider(create: (context) => FeaturedSectionCubit()),
    BlocProvider(create: (context) => AuthenticationCubit()),
    BlocProvider(create: (context) => FeaturedSectionCubit()),
    BlocProvider(create: (context) => HomeItemsCubit()),
    BlocProvider(create: (context) => DeleteItemCubit()),
    BlocProvider(create: (context) => ItemTotalClickCubit()),
    BlocProvider(create: (context) => FetchRelatedItemsCubit()),
    BlocProvider(create: (context) => ChangeMyItemStatusCubit()),
    BlocProvider(create: (context) => FetchUserPackageLimitCubit()),
    BlocProvider(create: (context) => DeleteUserCubit()),
    BlocProvider(create: (context) => InAppPurchaseCubit()),
    BlocProvider(create: (context) => DeleteChatCubit()),
    BlocProvider(create: (context) => FetchMyItemsCubit()),
    BlocProvider(create: (context) => ReportReasonCubit()),
    BlocProvider(create: (context) => ItemReportListCubit()),
    BlocProvider(create: (context) => FetchSafetyTipsListCubit()),
    BlocProvider(create: (context) => FetchCustomFieldsCubit()),
    BlocProvider(create: (context) => FetchFaqsCubit()),
    BlocProvider(create: (context) => GetItemBuyerListCubit()),
    BlocProvider(create: (context) => FetchSellerItemsCubit()),
    BlocProvider(create: (context) => FetchSellerRatingsCubit()),
    BlocProvider(create: (context) => FetchSellerVerificationFieldsCubit()),
    BlocProvider(create: (context) => SendVerificationFieldCubit()),
    BlocProvider(create: (context) => VerificationRequestCubit()),
    BlocProvider(create: (context) => FetchMyRatingsCubit()),
    BlocProvider(create: (context) => AddMyItemReviewReportCubit()),
    BlocProvider(create: (context) => RenewItemCubit()),
    BlocProvider(create: (context) => BankTransferUpdateCubit()),
    BlocProvider(create: (context) => FetchTransactionsCubit()),
    BlocProvider(create: (context) => FetchJobApplicationCubit()),
    BlocProvider(create: (_) => LocationCubit()),
    BlocProvider(create: (_) => LeafLocationCubit()),
    BlocProvider(create: (_) => UserProfileCubit()),
    BlocProvider(create: (_) => FetchItemCubit()),
    BlocProvider(create: (_) => ActiveSubscriptionPackageCubit()),
    BlocProvider(create: (_) => SellerItemOffersCubit()),
    BlocProvider(create: (_) => BuyingChatListCubit()),
    BlocProvider(create: (_) => FollowersListCubit()),
    BlocProvider(create: (_) => FollowingListCubit()),
    BlocProvider(create: (_) => MainCategoryCubit()),
    BlocProvider(create: (_) => CategoryValidationCubit()),
    BlocProvider(create: (_) => NotificationEventCubit()),
    BlocProvider(create: (_) => HomeConfigurationCubit()),
    BlocProvider(create: (_) => PopularCategoriesCubit()),
    BlocProvider(create: (_) => HomeBannerAdCubit()),
    BlocProvider(create: (_) => BottomNavCubit()),
    BlocProvider(create: (_) => VideoAdsCubit()),
    BlocProvider(create: (_) => ReelLikeCubit()),
    BlocProvider(create: (_) => LikedReelsCubit()),
  ];
}
