import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/repositories/home/home_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PopularCategoriesState {}

class PopularCategoriesInitial extends PopularCategoriesState {}

class PopularCategoriesLoading extends PopularCategoriesState {}

class PopularCategoriesSuccess extends PopularCategoriesState {
  PopularCategoriesSuccess({required this.categories});

  final List<Category> categories;
}

class PopularCategoriesFailure extends PopularCategoriesState {
  PopularCategoriesFailure({required this.message});

  final String message;
}

class PopularCategoriesCubit extends Cubit<PopularCategoriesState> {
  PopularCategoriesCubit() : super(PopularCategoriesInitial());

  Future<void> getCategories() async {
    try {
      emit(PopularCategoriesLoading());

      final categories = await HomeRepository.instance.getPopularCategories();

      emit(PopularCategoriesSuccess(categories: categories));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(PopularCategoriesFailure(message: e.toString()));
    }
  }
}
