import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/data/repositories/item/video_ad_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class VideoAdsState {}

class VideoAdsInitial extends VideoAdsState {}

class VideoAdsLoading extends VideoAdsState {}

class VideoAdsSuccess extends VideoAdsState {
  VideoAdsSuccess({
    required this.ads,
    this.isLoadingPage = false,
    this.loadingMoreError = false,
  });

  final List<VideoAd> ads;
  final bool isLoadingPage;
  final Object? loadingMoreError;

  VideoAdsSuccess copyWith({
    List<VideoAd>? ads,
    bool? isLoadingPage,
    Object? loadingMoreError,
  }) => VideoAdsSuccess(
    ads: ads ?? this.ads,
    isLoadingPage: isLoadingPage ?? this.isLoadingPage,
    loadingMoreError: loadingMoreError ?? this.loadingMoreError,
  );
}

class VideoAdsFailure extends VideoAdsState {
  VideoAdsFailure({required this.exception});

  final Exception exception;
}

class VideoAdsCubit extends Cubit<VideoAdsState> {
  VideoAdsCubit() : super(VideoAdsInitial());

  int _page = 1;
  int _total = 0;

  bool get hasMore {
    if (state case VideoAdsSuccess s) {
      return s.ads.length < _total;
    }
    return false;
  }

  Future<void> getVideoAds({
    LeafLocation? location,
    int? reelId,
    int? itemId,
    bool following = false,
    bool showCurrentUserReel = false,
  }) async {
    try {
      _page = 1;
      _total = 0;
      emit(VideoAdsLoading());

      final data = await VideoAdRepository.instance.getVideoAds(
        location: location,
        reelId: reelId,
        itemId: itemId,
        following: following,
        showCurrentUserReel: showCurrentUserReel,
      );

      emit(VideoAdsSuccess(ads: data.modelList));
      _total = data.total;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(VideoAdsFailure(exception: e));
    }
  }

  Future<void> getMoreVideoAds({
    LeafLocation? location,
    int? reelId,
    int? itemId,
    bool following = false,
  }) async {
    try {
      if (state is! VideoAdsSuccess) return;
      if (state case final VideoAdsSuccess state when state.isLoadingPage) {
        return;
      }
      if (!hasMore) return;

      emit((state as VideoAdsSuccess).copyWith(isLoadingPage: true));

      final data = await VideoAdRepository.instance.getVideoAds(
        location: location,
        reelId: reelId,
        itemId: itemId,
        following: following,
        page: _page + 1,
      );

      final successState = state as VideoAdsSuccess;
      final updatedState = successState.copyWith(
        ads: [...successState.ads, ...data.modelList],
        isLoadingPage: false,
        loadingMoreError: false,
      );
      emit(updatedState);
      _total = data.total;
      if (hasMore) ++_page;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(
        (state as VideoAdsSuccess).copyWith(
          isLoadingPage: false,
          loadingMoreError: e,
        ),
      );
    }
  }

  void updateLikeState({required int reelId, required bool isLiked}) {
    if (state is VideoAdsSuccess) {
      final successState = state as VideoAdsSuccess;
      final updatedAds = successState.ads.map((ad) {
        if (ad.id == reelId) {
          if (ad.isLiked == isLiked) {
            return ad;
          }
          final diff = isLiked ? 1 : -1;
          return ad.copyWith(isLiked: isLiked, likeCount: ad.likeCount + diff);
        }
        return ad;
      }).toList();
      emit(successState.copyWith(ads: updatedAds));
    }
  }
}
