import 'package:eClassify/data/model/banner/banner_ad.dart';
import 'package:eClassify/data/model/banner/banner_ad_factory.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/log.dart';

class BannerRepository {
  BannerRepository._();

  static final _instance = BannerRepository._();

  static BannerRepository get instance => _instance;

  Future<List<BannerAd>> fetchBannerAds({required String page}) async {
    try {
      final response = await Api.get(
        url: Api.getBannerAdsApi,
        queryParameters: {'page': page, 'platform': 'app'},
      );

      final data = response['data'] as List;

      return data.map((item) => BannerAdFactory.createBannerAd(item)).toList();
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
