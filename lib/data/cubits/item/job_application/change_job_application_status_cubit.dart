import 'package:eClassify/data/repositories/item/job_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChangeJobApplicationStatusState {}

class ChangeJobApplicationStatusInitial extends ChangeJobApplicationStatusState {}

class ChangeJobApplicationStatusInProgress
    extends ChangeJobApplicationStatusState {}

class ChangeJobApplicationStatusSuccess extends ChangeJobApplicationStatusState {
  ChangeJobApplicationStatusSuccess(this.message, this.id, this.status);

  final String message;
  final int id;
  final String status;
}

class ChangeJobApplicationStatusFailure extends ChangeJobApplicationStatusState {
  ChangeJobApplicationStatusFailure(this.errorMessage);

  final String errorMessage;
}

class ChangeJobApplicationStatusCubit
    extends Cubit<ChangeJobApplicationStatusState> {
  ChangeJobApplicationStatusCubit() : super(ChangeJobApplicationStatusInitial());

  final JobRepository _jobRepository = JobRepository();

  Future<void> changeJobApplicationStatus({
    required int id,
    required String status,
  }) async {
    try {
      emit(ChangeJobApplicationStatusInProgress());
      final value = await _jobRepository.changeJobApplicationStatus(
        jobId: id,
        status: status,
      );
      emit(ChangeJobApplicationStatusSuccess(
        value['message']?.toString() ?? '',
        id,
        status,
      ));
    } catch (e) {
      emit(ChangeJobApplicationStatusFailure(e.toString()));
    }
  }
}
