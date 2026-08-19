import 'package:eClassify/data/model/item/ad_posting_data.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ManageItemState {}

class ManageItemInitial extends ManageItemState {}

class ManageItemLoading extends ManageItemState {}

class ManageItemSuccess extends ManageItemState {
  ManageItemSuccess({required this.item, required this.isUploadInProgress});

  final ItemModel item;
  final bool isUploadInProgress;
}

class ManageItemFailure extends ManageItemState {
  ManageItemFailure({required this.message});

  final String message;
}

class ManageItemCubit extends Cubit<ManageItemState> {
  ManageItemCubit() : super(ManageItemInitial());

  Future<void> createItem({required AdPostingData data}) async {
    try {
      emit(ManageItemLoading());

      final result = await ItemRepository().createAdvertisement(data: data);

      emit(ManageItemSuccess(
        item: result.item,
        isUploadInProgress: result.isUploadInProgress,
      ));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ManageItemFailure(message: e.toString()));
    }
  }
}
