import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/data/repositories/subscription/subscription_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubscriptionPackageState {}

class SubscriptionPackageInitial extends SubscriptionPackageState {}

class SubscriptionPackageLoading extends SubscriptionPackageState {}

class SubscriptionPackageSuccess extends SubscriptionPackageState {
  SubscriptionPackageSuccess({required this.packages});

  final List<SubscriptionPackage> packages;
}

class SubscriptionPackageFailure extends SubscriptionPackageState {
  final Object error;
  SubscriptionPackageFailure({required this.error});
}

class SubscriptionPackageCubit extends Cubit<SubscriptionPackageState> {
  SubscriptionPackageCubit() : super(SubscriptionPackageInitial());

  Future<void> getPackages({required SubscriptionPackageType type, int? categoryId}) async {
    try {
      emit(SubscriptionPackageLoading());

      final packages = await SubscriptionRepository.instance
          .getPackages(type: type,categoryId: categoryId);

      emit(SubscriptionPackageSuccess(packages: packages));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(SubscriptionPackageFailure(error: e));
    }
  }
}
