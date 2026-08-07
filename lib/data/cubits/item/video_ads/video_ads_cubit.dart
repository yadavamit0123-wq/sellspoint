import 'package:eClassify/data/model/item/video_ad.dart';
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
  });

  final List<VideoAd> ads;
  final bool isLoadingPage;

  VideoAdsSuccess copyWith({
    List<VideoAd>? ads,
    bool? isLoadingPage,
  }) {
    return VideoAdsSuccess(
      ads: ads ?? this.ads,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
    );
  }
}

class VideoAdsFailure extends VideoAdsState {
  VideoAdsFailure(this.error);

  final Object error;
}

class VideoAdsCubit extends Cubit<VideoAdsState> {
  VideoAdsCubit() : super(VideoAdsInitial());

  int _page = 1;
  int _total = 0;

  bool get hasMore {
    if (state is VideoAdsSuccess) {
      return (state as VideoAdsSuccess).ads.length < _total;
    }
    return false;
  }

  Future<void> getVideoAds({
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
        reelId: reelId,
        itemId: itemId,
        following: following,
        showCurrentUserReel: showCurrentUserReel,
      );

      _total = data.total;
      emit(VideoAdsSuccess(ads: data.modelList));
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(VideoAdsFailure(e));
    }
  }

  Future<void> getMoreVideoAds({
    int? reelId,
    int? itemId,
    bool following = false,
  }) async {
    if (state is! VideoAdsSuccess) return;
    final current = state as VideoAdsSuccess;
    if (current.isLoadingPage || !hasMore) return;

    try {
      emit(current.copyWith(isLoadingPage: true));

      final data = await VideoAdRepository.instance.getVideoAds(
        reelId: reelId,
        itemId: itemId,
        following: following,
        page: _page + 1,
      );

      _total = data.total;
      _page += 1;
      emit(VideoAdsSuccess(
        ads: [...current.ads, ...data.modelList],
        isLoadingPage: false,
      ));
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(current.copyWith(isLoadingPage: false));
    }
  }

  void updateLikeState({required int reelId, required bool isLiked}) {
    if (state is! VideoAdsSuccess) return;
    final current = state as VideoAdsSuccess;
    final updated = current.ads.map((ad) {
      if (ad.id != reelId) return ad;
      if (ad.isLiked == isLiked) return ad;
      final diff = isLiked ? 1 : -1;
      return ad.copyWith(
        isLiked: isLiked,
        likeCount: (ad.likeCount + diff).clamp(0, 1 << 30),
      );
    }).toList();
    emit(current.copyWith(ads: updated));
  }
}
