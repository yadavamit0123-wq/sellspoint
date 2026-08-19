import 'package:eClassify/data/repositories/ai_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GenerateDescriptionState {}

class GenerateDescriptionInitial extends GenerateDescriptionState {}

class GenerateDescriptionInProgress extends GenerateDescriptionState {}

class GenerateDescriptionSuccess extends GenerateDescriptionState {
  final String description;

  GenerateDescriptionSuccess(this.description);
}

class GenerateDescriptionFailure extends GenerateDescriptionState {
  final String errorMessage;

  GenerateDescriptionFailure(this.errorMessage);
}

class GenerateDescriptionCubit extends Cubit<GenerateDescriptionState> {
  final AIRepository _repository;

  GenerateDescriptionCubit(this._repository)
    : super(GenerateDescriptionInitial());

  Future<void> generate({
    required String title,
    required String price,
    required String languageId,
    required String category,
    required String currencyISOCode,
  }) async {
    try {
      emit(GenerateDescriptionInProgress());
      final description = await _repository.generateDescription(
        title: title,
        price: price,
        languageId: languageId,
        category: category,
        currencyISOCode: currencyISOCode,
      );
      emit(GenerateDescriptionSuccess(description));
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(GenerateDescriptionFailure(e.toString()));
    }
  }
}
