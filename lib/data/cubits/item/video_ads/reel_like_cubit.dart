import 'package:eClassify/data/repositories/item/video_ad_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReelLikeState {}

class ReelLikeInitial extends ReelLikeState {}

class ReelLikeLoading extends ReelLikeState {}

class ReelLikeSuccess extends ReelLikeState {
  final int reelId;
  final bool isLiked;
  ReelLikeSuccess({required this.reelId, required this.isLiked});
}

class ReelLikeFailure extends ReelLikeState {
  final int reelId;
  final String error;
  ReelLikeFailure({required this.reelId, required this.error});
}

class ReelLikeCubit extends Cubit<ReelLikeState> {
  ReelLikeCubit() : super(ReelLikeInitial());

  Future<void> manageLike({required int reelId, required bool isLiked}) async {
    try {
      emit(ReelLikeLoading());
      await VideoAdRepository.instance.manageReelLike(reelId: reelId);
      emit(ReelLikeSuccess(reelId: reelId, isLiked: isLiked));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ReelLikeFailure(reelId: reelId, error: e.toString()));
    }
  }
}
