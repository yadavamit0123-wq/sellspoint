import 'dart:math';

import 'package:eClassify/data/model/user/follow_user.dart';
import 'package:eClassify/data/repositories/follow_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FollowUserListType { followers, following }

abstract class FollowUsersListState {}

class FollowUsersListInitial extends FollowUsersListState {}

class FollowUsersListLoading extends FollowUsersListState {}

class FollowUsersListSuccess extends FollowUsersListState {
  FollowUsersListSuccess({required this.users, required this.totalCount});

  final List<FollowUser> users;
  final int totalCount;

  FollowUsersListSuccess copyWith({
    List<FollowUser>? users,
    int? totalCount,
  }) {
    return FollowUsersListSuccess(
      users: users ?? this.users,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class FollowUsersListFailure extends FollowUsersListState {
  FollowUsersListFailure(this.error);

  final Object error;
}

abstract class FollowUsersListCubit extends Cubit<FollowUsersListState> {
  FollowUsersListCubit(this.type, [this.userId])
      : super(FollowUsersListInitial());

  final FollowUserListType type;
  final int? userId;
  final FollowRepository _repository = FollowRepository();

  int _page = 1;
  bool hasMore = true;

  Future<void> getUsers() async {
    try {
      emit(FollowUsersListLoading());
      _page = 1;
      final result = await _repository.getFollowUsers(
        type: type,
        userId: userId,
        page: _page,
      );
      hasMore = result.hasMore;
      emit(FollowUsersListSuccess(
        users: result.users,
        totalCount: result.total,
      ));
    } catch (e) {
      emit(FollowUsersListFailure(e));
    }
  }

  Future<void> getMoreUsers() async {
    if (state is! FollowUsersListSuccess || !hasMore) return;
    final current = state as FollowUsersListSuccess;
    try {
      final result = await _repository.getFollowUsers(
        type: type,
        userId: userId,
        page: _page + 1,
      );
      _page++;
      hasMore = result.hasMore;
      emit(FollowUsersListSuccess(
        users: [...current.users, ...result.users],
        totalCount: result.total,
      ));
    } catch (_) {}
  }
}

class FollowersListCubit extends FollowUsersListCubit {
  FollowersListCubit([int? userId])
      : super(FollowUserListType.followers, userId);
}

class FollowingListCubit extends FollowUsersListCubit {
  FollowingListCubit([int? userId])
      : super(FollowUserListType.following, userId);

  void increaseTotalCount() {
    if (state is! FollowUsersListSuccess) return;
    final s = state as FollowUsersListSuccess;
    emit(s.copyWith(totalCount: s.totalCount + 1));
  }

  void decreaseTotalCount() {
    if (state is! FollowUsersListSuccess) return;
    final s = state as FollowUsersListSuccess;
    emit(s.copyWith(totalCount: max(0, s.totalCount - 1)));
  }
}
