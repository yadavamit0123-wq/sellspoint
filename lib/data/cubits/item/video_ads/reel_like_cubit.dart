import 'package:eClassify/data/repositories/item/video_ad_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReelLikeState {}

class ReelLikeInitial extends ReelLikeState {}

class ReelLikeSuccess extends ReelLikeState {
  ReelLikeSuccess({required this.reelId, required this.isLiked});

  final int reelId;
  final bool isLiked;
}

class ReelLikeFailure extends ReelLikeState {
  ReelLikeFailure({required this.reelId, required this.error});

  final int reelId;
  final String error;
}

class ReelLikeCubit extends Cubit<ReelLikeState> {
  ReelLikeCubit() : super(ReelLikeInitial());

  Future<void> manageLike({required int reelId, required bool isLiked}) async {
    try {
      await VideoAdRepository.instance.manageReelLike(reelId: reelId);
      emit(ReelLikeSuccess(reelId: reelId, isLiked: isLiked));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ReelLikeFailure(reelId: reelId, error: e.toString()));
    }
  }
}
