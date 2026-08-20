import 'package:eClassify/data/repositories/ai_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GenerateMetaState {}

class GenerateMetaInitial extends GenerateMetaState {}

class GenerateMetaInProgress extends GenerateMetaState {}

class GenerateMetaSuccess extends GenerateMetaState {
  final Map<String, dynamic> data;

  GenerateMetaSuccess(this.data);
}

class GenerateMetaFailure extends GenerateMetaState {
  final String errorMessage;

  GenerateMetaFailure(this.errorMessage);
}

class GenerateMetaCubit extends Cubit<GenerateMetaState> {
  GenerateMetaCubit() : super(GenerateMetaInitial());

  Future<void> generate({
    required String title,
    required String price,
    required String languageId,
    required String currencyISOCode,
    required String category,
  }) async {
    try {
      emit(GenerateMetaInProgress());
      final data = await AIRepository.instance.generateMeta(
        title: title,
        price: price,
        languageId: languageId,
        currencyISOCode: currencyISOCode,
        category: category,
      );
      emit(GenerateMetaSuccess(data));
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(GenerateMetaFailure(e.toString()));
    }
  }
}
