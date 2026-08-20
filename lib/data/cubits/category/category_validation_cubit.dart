import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/repositories/category/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// States for Category Validation process.
abstract class CategoryValidationState {}

/// Initial state of the validation cubit.
class CategoryValidationInitial extends CategoryValidationState {}

/// Validation is ongoing for the target [category].
class CategoryValidationInProgress extends CategoryValidationState {
  CategoryValidationInProgress(this.category);
  final Category category;
}

/// Validation succeeded for the target [category].
class CategoryValidationSuccess extends CategoryValidationState {
  CategoryValidationSuccess(this.category);
  final Category category;
}

/// Validation failed (restricted) for the target [category] due to [error].
class CategoryValidationRestricted extends CategoryValidationState {
  CategoryValidationRestricted(this.category, this.error);
  final Category category;
  final Object error;
}

/// Cubit to handle the logic of validating if a user can post ads in a category.
class CategoryValidationCubit extends Cubit<CategoryValidationState> {
  CategoryValidationCubit() : super(CategoryValidationInitial());

  final CategoryRepository _repository = CategoryRepository.instance;

  /// Starts the validation process for the given [category].
  Future<void> validate(Category category) async {
    emit(CategoryValidationInProgress(category));
    try {
      await _repository.validateCategoryForListing(category.id);
      emit(CategoryValidationSuccess(category));
    } catch (e) {
      emit(CategoryValidationRestricted(category, e));
    }
  }
}
