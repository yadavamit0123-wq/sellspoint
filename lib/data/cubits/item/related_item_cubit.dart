import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchRelatedItemsState {}

class FetchRelatedItemsInitial extends FetchRelatedItemsState {}

class FetchRelatedItemsInProgress extends FetchRelatedItemsState {}

class FetchRelatedItemsSuccess extends FetchRelatedItemsState {
  final List<ItemModel> itemModel;
  final int? categoryId;

  FetchRelatedItemsSuccess({required this.itemModel, this.categoryId});
}

class FetchRelatedItemsFailure extends FetchRelatedItemsState {
  final String errorMessage;

  FetchRelatedItemsFailure(this.errorMessage);
}

class FetchRelatedItemsCubit extends Cubit<FetchRelatedItemsState> {
  FetchRelatedItemsCubit() : super(FetchRelatedItemsInitial());

  final ItemRepository _itemRepository = ItemRepository();

  Future<void> fetchRelatedItems({
    required int categoryId,
    required LeafLocation? location,
    required int excludedItemId,
  }) async {
    try {
      emit(FetchRelatedItemsInProgress());

      DataOutput<ItemModel> result = await _itemRepository.fetchItemFromCatId(
        categoryId: categoryId,
        page: 1,
        location: location,
        excludedItemId: excludedItemId,
      );

      emit(
        FetchRelatedItemsSuccess(
          itemModel: result.modelList,
          categoryId: categoryId,
        ),
      );
    } catch (e) {
      emit(FetchRelatedItemsFailure(e.toString()));
    }
  }
}
