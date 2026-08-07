import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/data/repositories/home/home_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PopularCategoriesState {}

class PopularCategoriesInitial extends PopularCategoriesState {}

class PopularCategoriesLoading extends PopularCategoriesState {}

class PopularCategoriesSuccess extends PopularCategoriesState {
  PopularCategoriesSuccess({required this.categories});

  final List<CategoryModel> categories;
}

class PopularCategoriesFailure extends PopularCategoriesState {
  PopularCategoriesFailure({required this.message});

  final String message;
}

class PopularCategoriesCubit extends Cubit<PopularCategoriesState> {
  PopularCategoriesCubit() : super(PopularCategoriesInitial());

  final HomeRepository _repository = HomeRepository();

  Future<void> fetchPopularCategories() async {
    try {
      emit(PopularCategoriesLoading());
      final categories = await _repository.fetchPopularCategories();
      emit(PopularCategoriesSuccess(categories: categories));
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(PopularCategoriesFailure(message: e.toString()));
    }
  }
}
