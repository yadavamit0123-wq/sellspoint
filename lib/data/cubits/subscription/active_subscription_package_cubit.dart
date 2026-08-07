import 'package:eClassify/data/model/subscription_pacakage_model.dart';
import 'package:eClassify/data/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ActiveSubscriptionPackageState {}

class ActiveSubscriptionPackageInitial extends ActiveSubscriptionPackageState {}

class ActiveSubscriptionPackageInProgress
    extends ActiveSubscriptionPackageState {}

class ActiveSubscriptionPackageSuccess extends ActiveSubscriptionPackageState {
  ActiveSubscriptionPackageSuccess({required this.activePackages});

  final List<SubscriptionPackageModel> activePackages;
}

class ActiveSubscriptionPackageFailure extends ActiveSubscriptionPackageState {
  ActiveSubscriptionPackageFailure(this.message);

  final String message;
}

class ActiveSubscriptionPackageCubit extends Cubit<ActiveSubscriptionPackageState> {
  ActiveSubscriptionPackageCubit()
      : super(ActiveSubscriptionPackageInitial());

  final SubscriptionRepository _repository = SubscriptionRepository();

  Future<void> fetchActivePackages() async {
    emit(ActiveSubscriptionPackageInProgress());
    try {
      final listing = await _repository.getActiveUserPackages(
        type: 'item_listing',
      );
      final featured = await _repository.getActiveUserPackages(
        type: 'advertisement',
      );
      final combined = [...listing, ...featured];
      emit(ActiveSubscriptionPackageSuccess(activePackages: combined));
    } catch (e) {
      emit(ActiveSubscriptionPackageFailure(e.toString()));
    }
  }
}
