import 'dart:developer';

import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/data/repositories/item/video_ad_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchReelState {}

class FetchReelInitial extends FetchReelState {}

class FetchReelLoading extends FetchReelState {}

class FetchReelSuccess extends FetchReelState {
  final VideoAd ad;

  FetchReelSuccess({required this.ad});
}

class FetchReelFailure extends FetchReelState {
  final String errorMessage;

  FetchReelFailure({required this.errorMessage});
}

class FetchReelCubit extends Cubit<FetchReelState> {
  FetchReelCubit() : super(FetchReelInitial());

  Future<void> fetchReel({required int itemId, bool isMyReel = false}) async {
    try {
      emit(FetchReelLoading());

      final data = await VideoAdRepository.instance.getVideoAds(
        itemId: itemId,
        showCurrentUserReel: isMyReel,
      );

      if (data.modelList.isNotEmpty) {
        emit(FetchReelSuccess(ad: data.modelList.first));
      } else {
        emit(FetchReelFailure(errorMessage: "Reel not found"));
      }
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'fetchReel');
      log('$stack', name: 'fetchReel');
      emit(FetchReelFailure(errorMessage: e.toString()));
    }
  }
}
