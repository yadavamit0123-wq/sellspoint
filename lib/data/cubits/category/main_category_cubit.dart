import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/repositories/category/category_store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MainCategoryState {}

class MainCategoryInitial extends MainCategoryState {}

class MainCategoryLoading extends MainCategoryState {}

class MainCategorySuccess extends MainCategoryState {
  MainCategorySuccess({required this.categories, required this.hasMore});

  final List<Category> categories;
  final bool hasMore;
}

class MainCategoryFailure extends MainCategoryState {
  MainCategoryFailure(this.error);

  final Object error;
}

/// Cubit responsible for fetching top-level categories.
class MainCategoryCubit extends Cubit<MainCategoryState> {
  MainCategoryCubit() : super(MainCategoryInitial());

  final CategoryStore _store = CategoryStore.instance;

  /// Fetches top-level categories (parentId: null).
  Future<void> fetch({bool forceRefresh = false}) async {
    try {
      emit(MainCategoryLoading());

      final result = await _store.fetchCategories(
        parentId: null,
        forceRefresh: forceRefresh,
      );

      emit(
        MainCategorySuccess(
          categories: result.modelList,
          hasMore: _store.hasMore(null),
        ),
      );
    } catch (e) {
      emit(MainCategoryFailure(e));
    }
  }

  /// Loads more top-level categories.
  Future<void> fetchMore() async {
    if (state is! MainCategorySuccess) return;
    final currentState = state as MainCategorySuccess;
    if (!currentState.hasMore) return;

    try {
      final result = await _store.fetchMore(parentId: null);
      emit(
        MainCategorySuccess(
          categories: result.modelList,
          hasMore: _store.hasMore(null),
        ),
      );
    } catch (e) {
      // Ignore or log error for infinite scroll.
    }
  }
}
