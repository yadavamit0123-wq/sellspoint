import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/cubits/report/item_report_list_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:eClassify/utils/network_request_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';

class ApiException implements Exception {
  ApiException(this.errorMessage);

  dynamic errorMessage;

  @override
  String toString() {
    return errorMessage.toString();
  }
}

class Api {
  static final String _baseUrl = () {
    // Start with the compile-time host URL
    var url = AppConfig.hostUrl.trim();

    // Remove any trailing slashes
    url = url.replaceAll(RegExp(r'/+$'), '');

    // Append the correct '/api/' suffix
    return '$url/api/';
  }();

  static String get baseUrl => _baseUrl;

  static late final CacheOptions _cacheOptions;
  static late final Dio _dio;

  static Future<void> init() async {
    final internalPath = await getApplicationSupportDirectory();

    _cacheOptions = CacheOptions(store: HiveCacheStore(internalPath.path));

    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
      ),
    )
      ..interceptors.addAll([
        NetworkRequestInterceptor(),
        if (kReleaseMode) DioCacheInterceptor(options: _cacheOptions),
        CurlLoggerDioInterceptor(printOnSuccess: true),
      ]);
  }

  static bool _isProcessing = false;

  static Map<String, dynamic> headers({bool addContentLanguage = true}) {
    final token = HiveUtils.isUserAuthenticated() ? HiveUtils.getJWT() : null;
    final headersMap = <String, dynamic>{
      if (token != null) "Authorization": "Bearer $token",
      "Accept": "application/json",
      if (addContentLanguage)
        "Content-Language": AppSession.currentLanguageCode.toLowerCase(),
    };

    return headersMap;
  }

  //Twilio API
  static const String getTwilioOtp = 'get-otp';
  static const String verifyTwilioOtp = 'verify-otp';

  static String loginApi = "user-signup";
  static String logoutApi = "logout";
  static String userExistsApi = "user-exists";
  static String resetPasswordApi = "reset-password";
  static String updateProfileApi = "update-profile";
  static String userProfile = 'get-user-info';
  static String getSliderApi = "get-slider";
  static String getCategoriesApi = "get-categories";
  static String getItemApi = "get-item";
  static String getMyItemApi = "my-items";
  static String getNotificationListApi = "get-notification-list";
  static String deleteUserApi = "delete-user";
  static String manageFavouriteApi = "manage-favourite";
  static String getPackageApi = "get-package";
  static String getActivePackagesApi = "get-user-purchased-packages";
  static String getLanguageApi = "get-languages";
  static String getPaymentSettingsApi = "get-payment-settings";
  static String getSystemSettingsApi = "get-system-settings";
  static String getCurrenciesApi = "get-currencies";
  static String getFavoriteItemApi = "get-favourite-item";
  static String updateItemStatusApi = "update-item-status";
  static String getReportReasonsApi = "get-report-reasons";
  static String addReportsApi = "add-reports";
  static String getCustomFieldsApi = "get-customfields";
  static String getFeaturedSectionApi = "get-featured-section";
  static String updateItemApi = "update-item";
  static String addItemApi = "add-item";
  static String uploadMediaApi = "upload-media";
  static String deleteItemApi = "delete-item";
  static String setItemTotalClickApi = "set-item-total-click";
  static String makeItemFeaturedApi = "make-item-featured";
  static String assignFreePackageApi = "assign-free-package";
  static String getLimitsOfPackageApi = "get-limits";
  static String getPaymentIntentApi = "payment-intent";
  static String inAppPurchaseApi = "in-app-purchase";
  static String getTipsApi = "tips";
  static String getCountriesApi = "countries";
  static String getStatesApi = "states";
  static String getCitiesApi = "cities";
  static String getAreasApi = "areas";
  static String getFaqApi = "faq";
  static String getItemBuyerListApi = "item-buyer-list";
  static String getSellerApi = "get-seller";
  static String addItemReviewApi = "add-item-review";
  static String getVerificationFieldApi = "verification-fields";
  static String sendVerificationRequestApi = "send-verification-request";
  static String getVerificationRequestApi = "verification-request";
  static String getMyReviewApi = "my-review";
  static String addReviewReportApi = "add-review-report";
  static String renewItemApi = "renew-item";
  static String bankTransferUpdateApi = "bank-transfer-update";
  static String applyForJobApi = "job-apply";
  static String getJobApplicationsApi = "get-job-applications";
  static String myJobApplicationsApi = "my-job-applications";
  static String updateJobApplicationsStatusApi =
      "update-job-applications-status";
  static String getLocationApi = "get-location";
  static String contactUsApi = 'contact-us';

  static String sendMessageApi = "send-message";
  static String getChatListApi = "chat-list";
  static String itemOfferApi = "item-offer";
  static String chatMessagesApi = "chat-messages";
  static String blockUserApi = "block-user";
  static String unBlockUserApi = "unblock-user";
  static String blockedUsersListApi = "blocked-users";
  static String getPaymentDetailsApi = "payment-transactions";
  static String deleteChatApi = "delete-chat";
  static String deleteChatMessagesApi = "delete-chat-messages";

  static String userPurchasePackageApi = "user-purchase-package";
  static String deleteInquiryApi = "delete-inquiry";
  static String setItemEnquiryApi = "set-item_-inquiry";
  static String getItemApiEnquiry = "get-item-inquiry";
  static String interestedUsersApi = "interested-users";
  static String storeAdvertisementApi = "store-advertisement";
  static String deleteAdvertisementApi = "delete-advertisement";
  static String deleteChatMessageApi = "delete-chat-message";

  static String followUserApi = 'follow-user';
  static String unFollowUserApi = 'unfollow-user';
  static String followersApi = 'followers';
  static String followingApi = 'following';

  static String chatItemOffersApi = 'item-offer-list';
  static String getItemStatusApi = 'get-item-status';

  static String getHomeConfigurationApi = 'get-home-screen';
  static String getPopularCategoriesApi = 'get-popular-categories';

  static String paymentReceiptApi = 'get-payment-receipt';
  static String getBannerAdsApi = 'get-banner-ads';

  //AI
  static String generateMeta = 'gemini/generate-meta';
  static String generateDescription = 'gemini/generate-description';

  //Blog
  static String getBlogApi = "blogs";
  static String popularBlogsApi = 'get-popular-blogs';
  static String blogCategoriesApi = 'get-blog-categories';
  static String blogFeedbackApi = 'set-blog-feedback';
  static String blogTagsApi = 'blog-tags';

  //Reels
  static String getReelsApi = "get-reels";
  static String getMyReelsApi = "get-my-reels";
  static String getLikedReelsApi = "get-liked-reels";
  static String manageReelLikeApi = "manage-reel-like";

  // Sells Point (wallet / referral) — preserved from live
  static String referralCheckApi = "check-reffercode"; // path param: check-reffercode/{code}
  static String referralApplyApi = "apply-reffer";
  static String referralHistoryApi = "refferal-history";
  static String referralQuestionApi = "questions/Refferal";
  static String walletQuestionApi = "questions/Wallet";
  static String walletTransHistoryApi = "transaction-history";

  //params
  static String id = "id";
  static String itemId = "item_id";
  static String itemIds = 'item_ids';
  static String renewItem = 'renew-item';
  static String mobile = "mobile";
  static String type = "type";
  static String itemOfferId = "item_offer_id";
  static String flag = "flag";
  static String firebaseId = "firebase_id";
  static String profile = "profile";
  static String fcmId = "fcm_id";
  static String address = "address";
  static String clientAddress = "client_address";
  static String email = "email";
  static String name = "name";
  static String amount = "amount";
  static String error = "error";
  static String message = "message";
  static String showOnlyToPremium = "show_only_to_premium";
  static String loginType = "logintype";
  static String referredBy = "reffer_code";
  static String isActive = "isActive";
  static String image = "image";
  static String category = "category";
  static String typeids = "typeids";
  static String userid = "userid";
  static String measurement = "measurement";
  static String categoryId = "category_id";
  static String title = "title";
  static String description = "description";
  static String price = "price";
  static String galleryImages = "gallery_images";
  static String purchaseToken = "purchase_token";
  static String resume = "resume";
  static String reportReasonId = "report_reason_id";
  static String otherMessage = "other_message";
  static String typeId = "type_id";
  static String itemType = "item_type";
  static String imageUrl = "image_url";
  static String gallery = "gallery";
  static String parameterTypes = "parameter_types";
  static String status = "status";
  static String platform = "platform";
  static String totalView = "total_view";
  static String slug = "slug";
  static String addedBy = "added_by";
  static String state = "state";
  static String city = "city";
  static String languageCode = "language_code";
  static String country = "country";
  static String areaId = "area_id";
  static String area = "area";
  static String radius = "radius";
  static String latitude = "latitude";
  static String longitude = "longitude";
  static String lat = "lat";
  static String lng = "lng";
  static String lang = "lang";
  static String placeId = "place_id";

  static String currencySymbol = "currency_symbol";
  static String company = "company";
  static String data = "data";
  static String customerId = "customer_id";
  static String customersId = "customers_id";
  static String search = "search";
  static String createdAt = "created_at";
  static String sendType = "send_type";
  static String created = "created";
  static String maintenanceMode = "maintenance_mode";
  static String maxPrice = "max_price";
  static String minPrice = "min_price";
  static String postedSince = "posted_since";
  static String file = "file";
  static String audio = "audio";
  static String blockedUserId = "blocked_user_id";
  static String userId = "user_id";
  static String messageIds = "message_ids";
  static String clientId = "client_id";

  static String item = "item";
  static String page = "page";
  static String topRated = "top_rated";
  static String promoted = "promoted";
  static String packageId = "package_id";
  static String paymentMethod = "payment_method";
  static String notification = "notification";
  static String v360degImage = "threeD_image";
  static String videoLink = "video_link";
  static String categoryIds = "category_ids";
  static String sortBy = "sort_by";
  static String stateId = "state_id";
  static String countryId = "country_id";
  static String cityId = "city_id";
  static String countryCode = "country_code";
  static String regionCode = 'region_code';
  static String personalDetail = "show_personal_details";
  static String referralCode = "referral_code";
  static String soldTo = "sold_to";
  static String ratings = "ratings";
  static String review = "review";
  static String platformType = "platform_type";
  static String sellerReviewId = "seller_review_id";
  static String reportReason = "report_reason";
  static String featuredSectionId = "featured_section_id";
  static String packageType = "package_type";
  static String paymentTransectionId = "payment_transection_id";
  static String paymentReceipt = "payment_receipt";
  static String jobId = "job_id";
  static String popularItems = "popular_items";
  static String advertisement = "advertisement";
  static String razorpay = "Razorpay";
  static String payStack = "Paystack";
  static String stripe = "Stripe";
  static String phonePe = "PhonePe";
  static String flutterwave = "flutterwave";
  static String bankTransfer = "bankTransfer";
  static String paytabs = 'Paytabs';
  static String dpo = 'DPO';
  static String apiKey = "api_key";
  static String currencyCode = "currency_code";
  static String currencyId = "currency_id";
  static String accountHolderName = "account_holder_name";
  static String accountNumber = "account_number";
  static String bankName = "bank_name";
  static String ifscSwiftCode = "ifsc_swift_code";
  static String paypal = 'Paypal';
  static String number = 'number';
  static String excludedItemId = 'excluded_item_id';

  static Future<Map<String, dynamic>> post({
    required String url,
    dynamic parameter,
    Options? options,
    ProgressCallback? onSendProgress,
    // In some use-cases, the API's error field returns true but
    // we require to parse the data present inside the data parameter for further
    // processing the app. Hence, this parameter bypasses that default check and
    // returns the result as-is.
    //
    // Note: This does not by pass the app level exceptions
    bool catchApiError = true,
    bool useFormData = true,
  }) async {
    print('===parameer===$parameter');
    try {
      late FormData formData;

      if (parameter is Map<String, dynamic> && useFormData) {
        Map<String, dynamic> formMap = {};

        parameter.forEach((key, value) {
          if (value is File) {
            formMap[key] = MultipartFile.fromFileSync(
              value.path,
              filename: value.path.split('/').last,
            );
          } else if (value is List<File>) {
            formMap[key] = value
                .map(
                  (file) => MultipartFile.fromFileSync(
                    file.path,
                    filename: file.path.split('/').last,
                  ),
                )
                .toList();
          } else {
            formMap[key] = value;
          }
        });

        formData = FormData.fromMap(formMap, ListFormat.multiCompatible);
      }

      final response = await _dio.post(
        '$_baseUrl$url',
        data: useFormData ? formData : parameter,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: useFormData ? "multipart/form-data" : 'application/json',
          headers: headers()..addAll(options?.headers ?? {}),
        ),
      );

      var resp = response.data;

      if ((resp['error'] ?? false) && catchApiError) {
        throw ApiException(resp['message'].toString());
      }

      return Map.from(resp);
    } on DioException catch (e, st) {
      Log.error(e.toString(), e, st);
      if (e.response?.statusCode == 401) {
        userExpired();
      }

      rethrow;
    } on ApiException catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  static void userExpired() {
    if (!_isProcessing) {
      _isProcessing = true;
      HelperUtils.showSnackBarMessage(
        Constant.navigatorKey.currentContext!,
        "userIsDeactivated".translate(Constant.navigatorKey.currentContext!),
        messageDuration: 3,
        isFloating: true,
      );
      Future.delayed(Duration(seconds: 2), () async {
        Constant.navigatorKey.currentContext!.read<UserDetailsCubit>().clear();
        Constant.navigatorKey.currentContext!
            .read<FavoriteCubit>()
            .resetState();
        Constant.navigatorKey.currentContext!
            .read<ItemReportListCubit>()
            .clear();
        Constant.navigatorKey.currentContext!
            .read<FetchJobApplicationCubit>()
            .resetState();
        await HiveUtils.clear();
        await HiveUtils.logoutUser(
          Constant.navigatorKey.currentContext!,
          onLogout: () {
            Constant.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              Routes.login,
              (route) => false,
            );
          },
        );
        _isProcessing = false;
      });
    }
  }

  static Future<Map<String, dynamic>> delete({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl$url',
        queryParameters: queryParameters,
        options: Options(headers: headers()),
      );

      if (response.data['error'] == true) {
        throw ApiException(response.data['message'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e, st) {
      Log.error(e.toString(), e, st);
      if (e.response?.statusCode == 401) {
        userExpired();
      }
      rethrow;
    } on ApiException catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool addContentLanguage = true,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$url',
        queryParameters: queryParameters,
        options: Options(
          headers: headers(addContentLanguage: addContentLanguage),
        ),
      );

      if (response.data['error'] == true) {
        throw ApiException(response.data['message'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e, st) {
      Log.error(e.toString(), e, st);
      if (e.response?.statusCode == 401) {
        userExpired();
      }
      rethrow;
    } on ApiException catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  static Future<String> getRaw({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$url',
        queryParameters: queryParameters,
        options: Options(headers: headers(), responseType: ResponseType.plain),
      );

      return response.data.toString();
    } on DioException catch (e, st) {
      Log.error(e.toString(), e, st);
      if (e.response?.statusCode == 401) {
        userExpired();
      }
      rethrow;
    } on ApiException catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  static Future<void> download({
    required String url,
    required String savePath,
    CancelToken? cancelToken,
    ValueChanged<double>? onUpdate,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        options: Options(headers: {HttpHeaders.acceptEncodingHeader: '*'}),
        onReceiveProgress: onUpdate != null
            ? (count, total) {
                final percentage = (count / total) * 100;
                onUpdate(percentage < 0.0 ? 99.0 : percentage);
              }
            : null,
      );
    } on DioException catch (e, st) {
      Log.error(e.toString(), e, st);
      if (e.response?.statusCode == 401) {
        userExpired();
      }
      rethrow;
    } on ApiException catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  static Future<Response> head({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.head(url, queryParameters: queryParameters);
      return response;
    } on DioException catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }
}
