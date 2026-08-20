import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/user/my_review_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/log.dart';

class ReviewRepository {
  ReviewRepository._internal();

  static final ReviewRepository _instance = ReviewRepository._internal();

  static ReviewRepository get instance => _instance;

  Future<String> reviewItem({
    required int itemId,
    required int rating,
    required String review,
  }) async {
    try {
      final response = await Api.post(
        url: Api.addItemReviewApi,
        parameter: {
          Api.itemId: itemId,
          Api.ratings: rating,
          Api.review: review,
        },
      );

      return response['message'] as String;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<DataOutput<MyReviewModel>> fetchMyRatingsAllRatings({
    required int page,
  }) async {
    try {
      Map<String, dynamic> parameters = {Api.page: page};

      Map<String, dynamic> response = await Api.get(
        url: Api.getMyReviewApi,
        queryParameters: parameters,
      );

      int totalRatings = response["data"]["ratings"]["total"] ?? 0;

      List<MyReviewModel> userRatings =
          (response["data"]["ratings"]["data"] as List)
              .map((e) => MyReviewModel.fromJson(e))
              .toList();
      double? averageRatings;

      if (response["data"]["average_rating"] != null) {
        averageRatings = (response["data"]["average_rating"] as num).toDouble();
      }

      return DataOutput(
        total: totalRatings,
        modelList: userRatings,
        extraData: ExtraData(
          data: {
            'average_rating': averageRatings,
            'ratings_count': (response['data']['ratings_count'] as Map?)
                ?.cast<String, int>(),
          },
        ),
      );
    } catch (error) {
      rethrow;
    }
  }
}
