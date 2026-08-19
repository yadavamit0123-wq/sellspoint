import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/user/seller_ratings_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/log.dart';

class SellerRatingsRepository {
  Future<DataOutput<UserRatings>> fetchSellerRatingsAllRatings({
    required int sellerId,
    required int page,
  }) async {
    try {
      Map<String, dynamic> parameters = {Api.id: sellerId, Api.page: page};

      Map<String, dynamic> response = await Api.get(
        url: Api.getSellerApi,
        queryParameters: parameters,
      );

      final sellerRatings = SellerRatingsModel.fromJson(response["data"]);

      return DataOutput(
        total: response['data']['ratings']['total'] as int,
        modelList: sellerRatings.ratings,
        extraData: ExtraData<SellerRatingsModel>(data: sellerRatings),
      );
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
