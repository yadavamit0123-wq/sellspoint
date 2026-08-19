import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/utils/api.dart';

class AdvertisementRepository {
  AdvertisementRepository._internal();

  static final AdvertisementRepository _instance =
      AdvertisementRepository._internal();

  static AdvertisementRepository get instance => _instance;

  Future<Map> assignFreePackages({required int packageId}) async {
    Map response = await Api.post(
      url: Api.assignFreePackageApi,
      parameter: {Api.packageId: packageId},
    );

    return response;
  }

  Future<Map> fetchUserPackageLimit({
    required SubscriptionPackageType packageType,
  }) async {
    Map response = await Api.get(
      url: Api.getLimitsOfPackageApi,
      queryParameters: {Api.packageType: packageType.label},
    );
    return response;
  }

  Future<Map> getPaymentIntent({
    required int packageId,
    required String paymentMethod,
  }) async {
    Map response = await Api.post(
      url: Api.getPaymentIntentApi,
      parameter: {
        Api.packageId: packageId,
        Api.paymentMethod: paymentMethod,
        if (paymentMethod case == "Paystack" || "PhonePe" || "PayPal")
          Api.platformType: "app",
      },
    );
    return response;
  }
}
