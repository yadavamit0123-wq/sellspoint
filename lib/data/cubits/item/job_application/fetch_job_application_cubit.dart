import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/job_application.dart';
import 'package:eClassify/data/repositories/item/job_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchJobApplicationState {}

class FetchJobApplicationInitial extends FetchJobApplicationState {}

class FetchJobApplicationInProgress extends FetchJobApplicationState {}

class FetchJobApplicationSuccess extends FetchJobApplicationState {
  FetchJobApplicationSuccess({
    required this.total,
    required this.page,
    required this.isLoadingMore,
    required this.applications,
  });

  final int total;
  final int page;
  final bool isLoadingMore;
  final List<JobApplication> applications;

  FetchJobApplicationSuccess copyWith({
    int? total,
    int? page,
    bool? isLoadingMore,
    List<JobApplication>? applications,
  }) {
    return FetchJobApplicationSuccess(
      total: total ?? this.total,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      applications: applications ?? this.applications,
    );
  }
}

class FetchJobApplicationFailed extends FetchJobApplicationState {
  FetchJobApplicationFailed(this.error);

  final Object error;
}

class FetchJobApplicationCubit extends Cubit<FetchJobApplicationState> {
  FetchJobApplicationCubit() : super(FetchJobApplicationInitial());

  final JobRepository _jobRepository = JobRepository();

  Future<void> fetchApplications({
    required int itemId,
    required bool isMyJobApplications,
  }) async {
    try {
      emit(FetchJobApplicationInProgress());
      final DataOutput<JobApplication> result =
          await _jobRepository.fetchApplications(
        page: 1,
        itemId: itemId,
        isMyJobApplications: isMyJobApplications,
      );
      emit(FetchJobApplicationSuccess(
        page: 1,
        isLoadingMore: false,
        applications: result.modelList,
        total: result.total,
      ));
    } catch (e) {
      emit(FetchJobApplicationFailed(e));
    }
  }

  JobApplication? getJobAppliedItem(int itemId) {
    if (state is! FetchJobApplicationSuccess) return null;
    final list = (state as FetchJobApplicationSuccess).applications;
    for (final app in list) {
      if (app.itemId == itemId) return app;
    }
    return null;
  }

  void addJobApplication(JobApplication item) {
    if (state is! FetchJobApplicationSuccess) return;
    final current = state as FetchJobApplicationSuccess;
    emit(current.copyWith(applications: [item, ...current.applications]));
  }

  void updateApplication(JobApplication item) {
    if (state is! FetchJobApplicationSuccess) return;
    final current = state as FetchJobApplicationSuccess;
    final apps = [...current.applications];
    final index = apps.indexWhere((e) => e.id == item.id);
    if (index >= 0) apps[index] = item;
    emit(current.copyWith(applications: apps));
  }

  Future<void> fetchMore({
    required int itemId,
    required bool isMyJobApplications,
  }) async {
    if (state is! FetchJobApplicationSuccess) return;
    final current = state as FetchJobApplicationSuccess;
    if (current.isLoadingMore ||
        current.applications.length >= current.total) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final result = await _jobRepository.fetchApplications(
        page: current.page + 1,
        itemId: itemId,
        isMyJobApplications: isMyJobApplications,
      );
      emit(FetchJobApplicationSuccess(
        page: current.page + 1,
        isLoadingMore: false,
        applications: [...current.applications, ...result.modelList],
        total: result.total,
      ));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  bool hasMoreData() {
    if (state is! FetchJobApplicationSuccess) return false;
    final current = state as FetchJobApplicationSuccess;
    return current.applications.length < current.total;
  }
}
