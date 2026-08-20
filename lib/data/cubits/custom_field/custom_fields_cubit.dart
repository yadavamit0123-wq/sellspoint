import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/data/repositories/item/custom_fields_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CustomFieldsState {}

class CustomFieldsInitial extends CustomFieldsState {}

class CustomFieldsLoading extends CustomFieldsState {}

class CustomFieldsSuccess extends CustomFieldsState {
  CustomFieldsSuccess({required this.fields});

  final List<CustomFieldV2> fields;
}

class CustomFieldsFailure extends CustomFieldsState {
  CustomFieldsFailure({required this.message});

  final String message;
}

class CustomFieldsCubit extends Cubit<CustomFieldsState> {
  CustomFieldsCubit() : super(CustomFieldsInitial());

  Future<void> getCustomFields({
    required int categoryId,
    bool isForFilter = false,
  }) async {
    try {
      emit(CustomFieldsLoading());

      final fields = await CustomFieldRepository.instance.getCustomFieldsV2(
        categoryId: categoryId,
        isForFilter: isForFilter,
      );

      emit(CustomFieldsSuccess(fields: fields));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(CustomFieldsFailure(message: e.toString()));
    }
  }
}
