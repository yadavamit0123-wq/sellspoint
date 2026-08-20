import 'package:eClassify/data/repositories/follow_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowState {
  FollowState({
    required this.userId,
    required this.isFollowing,
    required this.isLoading,
  });
  final int? userId;
  final bool isFollowing;
  final bool isLoading;

  FollowState copyWith({int? userId, bool? isFollowing, bool? isLoading}) =>
      FollowState(
        userId: userId ?? this.userId,
        isFollowing: isFollowing ?? this.isFollowing,
        isLoading: isLoading ?? this.isLoading,
      );
}

class FollowCubit extends Cubit<FollowState> {
  FollowCubit()
    : super(FollowState(userId: null, isFollowing: false, isLoading: false));

  Future<void> followSeller({required int userId}) async {
    try {
      emit(state.copyWith(userId: userId, isLoading: true));

      await FollowRepository.instance.followUser(userId: userId);

      emit(state.copyWith(isFollowing: true, isLoading: false));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> unFollowSeller({required int userId}) async {
    try {
      emit(state.copyWith(userId: userId, isLoading: true));

      await FollowRepository.instance.unFollowUser(userId: userId);

      emit(state.copyWith(isLoading: false, isFollowing: false));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(state.copyWith(isLoading: false));
    }
  }

  void setFollowingStatus(bool isFollowing) {
    emit(state.copyWith(isFollowing: isFollowing, isLoading: false));
  }
}
