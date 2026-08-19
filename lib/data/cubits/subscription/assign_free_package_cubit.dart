import 'package:eClassify/data/repositories/item/advertisement_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AssignFreePackageState {}

class AssignFreePackageInitial extends AssignFreePackageState {}

class AssignFreePackageInProgress extends AssignFreePackageState {}

class AssignFreePackageInSuccess extends AssignFreePackageState {
  final String responseMessage;

  AssignFreePackageInSuccess(this.responseMessage);
}

class AssignFreePackageFailure extends AssignFreePackageState {
  final dynamic error;

  AssignFreePackageFailure(this.error);
}

class AssignFreePackageCubit extends Cubit<AssignFreePackageState> {
  AssignFreePackageCubit() : super(AssignFreePackageInitial());
  AdvertisementRepository repository = AdvertisementRepository.instance;

  void assignFreePackage({
    required int packageId,
  }) async {
    try {
      emit(AssignFreePackageInProgress());

      final response = await AdvertisementRepository.instance.assignFreePackages(packageId: packageId);

      emit(AssignFreePackageInSuccess(response['message']));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(AssignFreePackageFailure(e.toString()));
    }
  }
}
