import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/data/repositories/subscription/subscription_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ActiveSubscriptionPackageState {}

class ActiveSubscriptionPackageInitial extends ActiveSubscriptionPackageState {}

class ActiveSubscriptionPackageLoading extends ActiveSubscriptionPackageState {}

class ActiveSubscriptionPackageSuccess extends ActiveSubscriptionPackageState {
  ActiveSubscriptionPackageSuccess({required this.activePackages});

  final List<SubscriptionPackage> activePackages;
}

class ActiveSubscriptionPackageFailure extends ActiveSubscriptionPackageState {
  ActiveSubscriptionPackageFailure({required this.error});

  final Object error;
}

class ActiveSubscriptionPackageCubit
    extends Cubit<ActiveSubscriptionPackageState> {
  ActiveSubscriptionPackageCubit() : super(ActiveSubscriptionPackageInitial());

  Future<void> getPackages({
    SubscriptionPackageType? type,
    int? categoryId,
    AdItemType? adItemType,
  }) async {
    try {
      emit(ActiveSubscriptionPackageLoading());

      final activePackages = await SubscriptionRepository.instance
          .getActivePackages(
            type: type,
            categoryId: categoryId,
            adItemType: adItemType,
          );

      emit(ActiveSubscriptionPackageSuccess(activePackages: activePackages));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ActiveSubscriptionPackageFailure(error: e));
    }
  }
}
