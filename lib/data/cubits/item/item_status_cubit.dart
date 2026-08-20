import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ItemStatusState {}

class ItemStatusInitial extends ItemStatusState {}

class ItemStatusLoading extends ItemStatusState {}

class ItemStatusSuccess extends ItemStatusState {
  ItemStatusSuccess({required this.status});
  final ItemStatus status;
}

class ItemStatusFailure extends ItemStatusState {
  ItemStatusFailure({required this.message});
  final String message;
}

class ItemStatusCubit extends Cubit<ItemStatusState> {
  ItemStatusCubit() : super(ItemStatusInitial());

  Future<void> getItemStatus({required int itemId}) async {
    try {
      emit(ItemStatusLoading());

      final status = await ItemRepository().getItemStatus(itemId: itemId);

      emit(ItemStatusSuccess(status: status));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ItemStatusFailure(message: e.toString()));
    }
  }
}
