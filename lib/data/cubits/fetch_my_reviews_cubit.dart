import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/user/my_review_model.dart';
import 'package:eClassify/data/repositories/review/review_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMyRatingsState {}

class FetchMyRatingsInitial extends FetchMyRatingsState {}

class FetchMyRatingsInProgress extends FetchMyRatingsState {}

class FetchMyRatingsSuccess extends FetchMyRatingsState {
  final double? averageRating;
  final List<MyReviewModel> ratings;
  final Map<String, int> ratingsCount;
  final bool isLoadingMore;
  final bool loadingMoreError;
  final int page;
  final int total;

  FetchMyRatingsSuccess({
    required this.ratings,
    required this.averageRating,
    required this.ratingsCount,
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.page,
    required this.total,
  });

  FetchMyRatingsSuccess copyWith({
    List<MyReviewModel>? ratings,
    double? averageRating,
    Map<String, int>? ratingsCount,
    bool? isLoadingMore,
    bool? loadingMoreError,
    int? page,
    int? total,
  }) {
    return FetchMyRatingsSuccess(
      ratings: ratings ?? this.ratings,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class FetchMyRatingsFail extends FetchMyRatingsState {
  FetchMyRatingsFail(this.error);

  final Object error;
}

class FetchMyRatingsCubit extends Cubit<FetchMyRatingsState> {
  FetchMyRatingsCubit() : super(FetchMyRatingsInitial());

  final _repository = ReviewRepository.instance;

  void fetch() async {
    try {
      emit(FetchMyRatingsInProgress());
      DataOutput<MyReviewModel> result = await _repository
          .fetchMyRatingsAllRatings(page: 1);
      emit(
        FetchMyRatingsSuccess(
          page: 1,
          averageRating:
              (result.extraData?.data as Map)['average_rating'] as double?,
          ratingsCount:
              (result.extraData?.data as Map)['ratings_count']
                  as Map<String, int>,
          isLoadingMore: false,
          loadingMoreError: false,
          ratings: result.modelList,
          total: result.total,
        ),
      );
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(FetchMyRatingsFail(e));
    }
  }

  Future<void> fetchMore() async {
    try {
      if (state is FetchMyRatingsSuccess) {
        if ((state as FetchMyRatingsSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchMyRatingsSuccess).copyWith(isLoadingMore: true));
        DataOutput<MyReviewModel> result = await _repository
            .fetchMyRatingsAllRatings(
              page: (state as FetchMyRatingsSuccess).page + 1,
            );

        FetchMyRatingsSuccess myRatingsModelState =
            (state as FetchMyRatingsSuccess);
        myRatingsModelState.ratings.addAll(result.modelList);
        emit(
          FetchMyRatingsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            averageRating:
                (result.extraData?.data as Map)['average_rating'] as double?,
            ratingsCount:
                (result.extraData?.data as Map)['ratings_count']
                    as Map<String, int>,
            ratings: myRatingsModelState.ratings,
            page: (state as FetchMyRatingsSuccess).page + 1,
            total: result.total,
          ),
        );
      }
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(
        (state as FetchMyRatingsSuccess).copyWith(
          isLoadingMore: false,
          loadingMoreError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchMyRatingsSuccess) {
      return (state as FetchMyRatingsSuccess).ratings.length <
          (state as FetchMyRatingsSuccess).total;
    }
    return false;
  }

  double? averageRating() {
    if (state is FetchMyRatingsSuccess) {
      return (state as FetchMyRatingsSuccess).averageRating;
    }

    return null;
  }

  void updateIsExpanded(int index) {
    if (state is FetchMyRatingsSuccess) {
      List<MyReviewModel> ratingsList =
          (state as FetchMyRatingsSuccess).ratings;

      ratingsList[index] = ratingsList[index].copyWith(
        isExpanded: !(ratingsList[index].isExpanded ?? false),
      );
      if (!isClosed) {
        emit((state as FetchMyRatingsSuccess).copyWith(ratings: ratingsList));
      }
    }
  }

  void updateReportReason(int itemReportId, String reportReason) {
    if (state is FetchMyRatingsSuccess) {
      final ratings = (state as FetchMyRatingsSuccess).ratings;
      int indexToUpdate = ratings.indexWhere(
        (element) => element.id == itemReportId,
      );
      if (indexToUpdate != -1) {
        ratings[indexToUpdate].reportStatus = 'reported';
        ratings[indexToUpdate].reportReason = reportReason;

        final successState = (state as FetchMyRatingsSuccess).copyWith(
          ratings: ratings,
        );

        emit(successState);
      }
    }
  }
}
