import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/user/seller_ratings_model.dart';
import 'package:eClassify/data/repositories/seller/seller_ratings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchSellerRatingsState {}

class FetchSellerRatingsInitial extends FetchSellerRatingsState {}

class FetchSellerRatingsInProgress extends FetchSellerRatingsState {}

class FetchSellerRatingsSuccess extends FetchSellerRatingsState {
  final Seller seller;
  final List<UserRatings> ratings;
  final Map<String, int> ratingsCount;
  final bool isLoadingMore;
  final bool loadingMoreError;
  final int page;
  final int total;

  FetchSellerRatingsSuccess({
    required this.ratings,
    required this.seller,
    required this.ratingsCount,
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.page,
    required this.total,
  });

  FetchSellerRatingsSuccess copyWith({
    List<UserRatings>? ratings,
    Seller? seller,
    Map<String, int>? ratingsCount,
    bool? isLoadingMore,
    bool? loadingMoreError,
    int? page,
    int? total,
  }) {
    return FetchSellerRatingsSuccess(
      ratings: ratings ?? this.ratings,
      seller: seller ?? this.seller,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class FetchSellerRatingsFail extends FetchSellerRatingsState {
  final dynamic error;

  FetchSellerRatingsFail(this.error);
}

class FetchSellerRatingsCubit extends Cubit<FetchSellerRatingsState> {
  FetchSellerRatingsCubit() : super(FetchSellerRatingsInitial());

  final SellerRatingsRepository _sellerRatingsRepository =
      SellerRatingsRepository();

  void fetch({required int sellerId}) async {
    try {
      emit(FetchSellerRatingsInProgress());
      DataOutput<UserRatings> result = await _sellerRatingsRepository
          .fetchSellerRatingsAllRatings(page: 1, sellerId: sellerId);

      emit(
        FetchSellerRatingsSuccess(
          page: 1,
          seller: (result.extraData?.data as SellerRatingsModel).seller,
          ratingsCount:
              (result.extraData?.data as SellerRatingsModel).ratingsCount,
          isLoadingMore: false,
          loadingMoreError: false,
          ratings: result.modelList,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(FetchSellerRatingsFail(e.toString()));
    }
  }

  Future<void> fetchMore({required int sellerId}) async {
    try {
      if (state is FetchSellerRatingsSuccess) {
        if ((state as FetchSellerRatingsSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchSellerRatingsSuccess).copyWith(isLoadingMore: true),
        );
        DataOutput<UserRatings> result = await _sellerRatingsRepository
            .fetchSellerRatingsAllRatings(
              page: (state as FetchSellerRatingsSuccess).page + 1,
              sellerId: sellerId,
            );

        FetchSellerRatingsSuccess sellerRatingsModelState =
            (state as FetchSellerRatingsSuccess);
        sellerRatingsModelState.ratings.addAll(result.modelList);
        emit(
          FetchSellerRatingsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            seller: (result.extraData?.data as SellerRatingsModel).seller,
            ratingsCount:
                (result.extraData?.data as SellerRatingsModel).ratingsCount,
            ratings: sellerRatingsModelState.ratings,
            page: (state as FetchSellerRatingsSuccess).page + 1,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as FetchSellerRatingsSuccess).copyWith(
          isLoadingMore: false,
          loadingMoreError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchSellerRatingsSuccess) {
      return (state as FetchSellerRatingsSuccess).ratings.length <
          (state as FetchSellerRatingsSuccess).total;
    }
    return false;
  }

  Seller? sellerData() {
    if (state is FetchSellerRatingsSuccess) {
      return (state as FetchSellerRatingsSuccess).seller;
    }

    return null;
  }

  int? totalSellerRatings() {
    if (state is FetchSellerRatingsSuccess) {
      return (state as FetchSellerRatingsSuccess).ratings.length;
    }

    return null;
  }

  void updateSellerFollowerCount({required bool isFollowing}) {
    if (state is! FetchSellerRatingsSuccess) return;
    final successState = state as FetchSellerRatingsSuccess;
    final newState = successState.copyWith(
      seller: successState.seller.copyWith(
        followers: isFollowing
            ? successState.seller.followers + 1
            : successState.seller.followers - 1,
      ),
    );
    emit(newState);
  }
}
