import 'package:eClassify/data/repositories/ai_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GenerateDescriptionState {}

class GenerateDescriptionInitial extends GenerateDescriptionState {}

class GenerateDescriptionInProgress extends GenerateDescriptionState {}

class GenerateDescriptionSuccess extends GenerateDescriptionState {
  GenerateDescriptionSuccess(this.description);

  final String description;
}

class GenerateDescriptionFailure extends GenerateDescriptionState {
  GenerateDescriptionFailure(this.errorMessage);

  final String errorMessage;
}

class GenerateDescriptionCubit extends Cubit<GenerateDescriptionState> {
  GenerateDescriptionCubit() : super(GenerateDescriptionInitial());

  Future<void> generate({
    required String title,
    required String price,
    required String languageId,
    required String category,
    required String currencyISOCode,
  }) async {
    try {
      emit(GenerateDescriptionInProgress());
      final description = await AIRepository.instance.generateDescription(
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
