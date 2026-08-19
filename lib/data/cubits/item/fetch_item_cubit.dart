import 'dart:developer';

import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchItemState {}

class FetchItemInitial extends FetchItemState {}

class FetchItemLoading extends FetchItemState {}

class FetchItemSuccess extends FetchItemState {
  final ItemModel item;

  FetchItemSuccess({required this.item});
}

class FetchItemFailure extends FetchItemState {
  FetchItemFailure({required this.error});

  final Exception error;
}

class FetchItemCubit extends Cubit<FetchItemState> {
  FetchItemCubit() : super(FetchItemInitial());

  void fetchItem({int? itemId, String? slug, bool isMyAd = false}) {
    assert(
      itemId != null || slug != null,
      'Either itemId or slug should be provided to get the item data',
    );
    if (itemId != null) {
      _fetchItemFromId(id: itemId, isMyAd: isMyAd);
    } else {
      _fetchItemFromSlug(slug: slug!, isMyAd: isMyAd);
    }
  }

  Future<void> _fetchItemFromId({required int id, bool isMyAd = false}) async {
    try {
      emit(FetchItemLoading());

      final models = await ItemRepository().fetchItemFromItemId(
        id,
        isMyAd: isMyAd,
      );
      if (models.modelList.isEmpty) {
        emit(FetchItemFailure(error: ApiException('Item not found')));
        return;
      }
      emit(FetchItemSuccess(item: models.modelList.first));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'fetchItem');
      log('$stack', name: 'fetchItem');
      emit(FetchItemFailure(error: e));
    }
  }

  Future<void> _fetchItemFromSlug({
    required String slug,
    bool isMyAd = false,
  }) async {
    try {
      emit(FetchItemLoading());

      final models = await ItemRepository().fetchItemFromItemSlug(
        slug,
        isMyAd: isMyAd,
      );
      if (models.modelList.isEmpty) {
        emit(FetchItemFailure(error: ApiException('Item not found')));
        return;
      }

      emit(FetchItemSuccess(item: models.modelList.first));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'fetchItemFromSlug');
      log('$stack', name: 'fetchItemFromSlug');
      emit(FetchItemFailure(error: e));
    }
  }
}
