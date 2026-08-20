import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MakeAnOfferItemState {}

class MakeAnOfferItemInitial extends MakeAnOfferItemState {}

class MakeAnOfferItemInProgress extends MakeAnOfferItemState {}

class MakeAnOfferItemSuccess extends MakeAnOfferItemState {
  final String message;
  final String from;
  final Chat chatUser;

  MakeAnOfferItemSuccess(this.message, this.from, this.chatUser);
}

class MakeAnOfferItemFailure extends MakeAnOfferItemState {
  final String errorMessage;

  MakeAnOfferItemFailure(this.errorMessage);
}

class MakeAnOfferItemCubit extends Cubit<MakeAnOfferItemState> {
  final ItemRepository _itemRepository = ItemRepository();

  MakeAnOfferItemCubit() : super(MakeAnOfferItemInitial());

  Future<void> makeAnOfferItem({
    required int id,
    required String from,
    double? amount,
  }) async {
    try {
      emit(MakeAnOfferItemInProgress());

      final response = await _itemRepository.makeAnOfferItem(id, amount);

      emit(
        MakeAnOfferItemSuccess(
          response['message'] as String,
          from,
          response['data'] as Chat,
        ),
      );
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(MakeAnOfferItemFailure(e.toString()));
    }
  }
}
