import 'dart:io';

import 'package:eClassify/data/repositories/item/job_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ApplyJobApplicationState {}

class ApplyJobApplicationInitial extends ApplyJobApplicationState {}

class ApplyJobApplicationInProgress extends ApplyJobApplicationState {}

class ApplyJobApplicationSuccess extends ApplyJobApplicationState {
  ApplyJobApplicationSuccess(this.successMessage, this.data);

  final String successMessage;
  final dynamic data;
}

class ApplyJobApplicationFail extends ApplyJobApplicationState {
  ApplyJobApplicationFail(this.error);

  final dynamic error;
}

class ApplyJobApplicationCubit extends Cubit<ApplyJobApplicationState> {
  ApplyJobApplicationCubit() : super(ApplyJobApplicationInitial());

  final JobRepository _jobRepository = JobRepository();

  Future<void> applyJobApplication(
    Map<String, dynamic> data,
    File? attachment,
  ) async {
    try {
      emit(ApplyJobApplicationInProgress());
      final response = await _jobRepository.applyJobApplication(data, attachment);
      emit(ApplyJobApplicationSuccess(
        response['message']?.toString() ?? '',
        response['data'],
      ));
    } catch (e) {
      emit(ApplyJobApplicationFail(e.toString()));
    }
  }
}
