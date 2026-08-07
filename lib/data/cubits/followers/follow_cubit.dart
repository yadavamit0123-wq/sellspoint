import 'package:eClassify/data/repositories/follow_repository.dart';
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

  FollowState copyWith({int? userId, bool? isFollowing, bool? isLoading}) {
    return FollowState(
      userId: userId ?? this.userId,
      isFollowing: isFollowing ?? this.isFollowing,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FollowCubit extends Cubit<FollowState> {
  FollowCubit()
      : super(FollowState(userId: null, isFollowing: false, isLoading: false));

  final FollowRepository _repository = FollowRepository();

  Future<void> followSeller({required int userId}) async {
    try {
      emit(state.copyWith(userId: userId, isLoading: true));
      await _repository.followUser(userId: userId);
      emit(state.copyWith(isFollowing: true, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> unFollowSeller({required int userId}) async {
    try {
      emit(state.copyWith(userId: userId, isLoading: true));
      await _repository.unFollowUser(userId: userId);
      emit(state.copyWith(isFollowing: false, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void setFollowingStatus(bool isFollowing, {int? userId}) {
    emit(state.copyWith(
      isFollowing: isFollowing,
      isLoading: false,
      userId: userId ?? state.userId,
    ));
  }
}
