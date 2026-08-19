import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/data/repositories/item/video_ad_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LikedReelsState {}

class LikedReelsInitial extends LikedReelsState {}

class LikedReelsLoading extends LikedReelsState {}

class LikedReelsSuccess extends LikedReelsState {
  LikedReelsSuccess({
    required this.ads,
    this.isLoadingPage = false,
    this.loadingMoreError = false,
  });

  final List<VideoAd> ads;
  final bool isLoadingPage;
  final Object? loadingMoreError;

  LikedReelsSuccess copyWith({
    List<VideoAd>? ads,
    bool? isLoadingPage,
    Object? loadingMoreError,
  }) =>
      LikedReelsSuccess(
        ads: ads ?? this.ads,
        isLoadingPage: isLoadingPage ?? this.isLoadingPage,
        loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      );
}

class LikedReelsFailure extends LikedReelsState {
  LikedReelsFailure({required this.exception});

  final Exception exception;
}

class LikedReelsCubit extends Cubit<LikedReelsState> {
  LikedReelsCubit() : super(LikedReelsInitial());

  int _page = 1;
  int _total = 0;

  bool get hasMore {
    if (state case LikedReelsSuccess s) {
      return s.ads.length < _total;
    }
    return false;
  }

  Future<void> getLikedReels() async {
    try {
      _page = 1;
      _total = 0;
      emit(LikedReelsLoading());

      final data = await VideoAdRepository.instance.getLikedReels();

      emit(LikedReelsSuccess(ads: data.modelList));
      _total = data.total;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(LikedReelsFailure(exception: e));
    }
  }

  Future<void> getMoreLikedReels() async {
    try {
      if (state is! LikedReelsSuccess) return;
      if (state case final LikedReelsSuccess state when state.isLoadingPage) {
        return;
      }
      if (!hasMore) return;

      emit((state as LikedReelsSuccess).copyWith(isLoadingPage: true));

      final data = await VideoAdRepository.instance.getLikedReels(
        page: _page + 1,
      );

      final successState = state as LikedReelsSuccess;
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
        (state as LikedReelsSuccess).copyWith(
          isLoadingPage: false,
          loadingMoreError: e,
        ),
      );
    }
  }

  void updateLikeState({required int reelId, required bool isLiked}) {
    if (state is LikedReelsSuccess) {
      final successState = state as LikedReelsSuccess;
      final updatedAds = successState.ads.map((ad) {
        if (ad.id == reelId) {
          if (ad.isLiked == isLiked) {
            return ad;
          }
          final diff = isLiked ? 1 : -1;
          return ad.copyWith(
            isLiked: isLiked,
            likeCount: ad.likeCount + diff,
          );
        }
        return ad;
      }).toList();
      emit(successState.copyWith(ads: updatedAds));
    }
  }

  void removeLikedReel(int reelId) {
    if (state is LikedReelsSuccess) {
      final successState = state as LikedReelsSuccess;
      final updatedAds = successState.ads.where((ad) => ad.id != reelId).toList();
      emit(successState.copyWith(ads: updatedAds));
      _total -= 1;
    }
  }
}
