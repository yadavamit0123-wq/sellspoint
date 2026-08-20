import 'package:eClassify/data/cubits/category/category_path_notifier.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/repositories/category/category_store.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CategoryBrowsingState {}

class CategoryBrowsingInitial extends CategoryBrowsingState {}

class CategoryBrowsingLoading extends CategoryBrowsingState {}

class CategoryBrowsingSuccess extends CategoryBrowsingState {
  CategoryBrowsingSuccess({required this.categories, required this.hasMore});

  final List<Category> categories;
  final bool hasMore;
}

class CategoryBrowsingFailure extends CategoryBrowsingState {
  CategoryBrowsingFailure(this.error);

  final Object error;
}

/// Terminal state for hierarchy selection.
class CategorySelected extends CategoryBrowsingState {
  CategorySelected({required this.categoryTree});

  final List<Category> categoryTree;
}

/// Cubit responsible for hierarchical navigation and category selection.
class CategoryBrowsingCubit extends Cubit<CategoryBrowsingState> {
  CategoryBrowsingCubit({
    this.initialPath = const [],
    this.showLastCategory = false,
  }) : pathNotifier = CategoryPathNotifier(List.unmodifiable(initialPath)),
       super(CategoryBrowsingInitial());

  final List<Category> initialPath;
  final bool showLastCategory;

  final CategoryStore _store = CategoryStore.instance;

  /// Reactive path tracking.
  final CategoryPathNotifier pathNotifier;

  /// Fetches categories for the current level (current tail of path).
  Future<void> fetchCategories({bool forceRefresh = true}) async {
    final parentId = pathNotifier.value.lastOrNull?.id;
    try {
      emit(CategoryBrowsingLoading());

      final result = await _store.fetchCategories(
        parentId: parentId,
        forceRefresh: forceRefresh,
      );

      if (isClosed) return;

      // Check if the path changed while fetching (e.g., from rapid navigation)
      final currentParentId = pathNotifier.value.lastOrNull?.id;
      if (currentParentId != parentId) return;

      // Update parent category in path if selfCategory details are returned
      final selfCategory = result.extraData?.data as Category?;
      if (selfCategory != null && pathNotifier.isNotEmpty) {
        pathNotifier.updateLast(selfCategory);
      }

      emit(
        CategoryBrowsingSuccess(
          categories: result.modelList,
          hasMore: _store.hasMore(parentId),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      final currentParentId = pathNotifier.value.lastOrNull?.id;
      if (currentParentId != parentId) return;

      emit(CategoryBrowsingFailure(e));
    }
  }

  Future<void> selectCategory(Category category) async {
    // Leaf categories are not stored in the path since they are not needed for breadcrumb navigation.
    if (showLastCategory) {
      pathNotifier.push(category);
    }
    emit(
      CategorySelected(
        categoryTree: [...pathNotifier.value, if (!showLastCategory) category],
      ),
    );
  }

  /// Automatically decides whether to drill down (if subcategories exist) or select the category.
  Future<void> processCategory(Category category) async {
    if (category.hasSubCategories) {
      pathNotifier.push(category);
      await fetchCategories();
    } else {
      selectCategory(category);
    }
  }

  /// Navigates to a specific node in the hierarchy (or root if null).
  Future<void> navigateBackTo(Category? category) async {
    pathNotifier.navigateTo(category);
    await fetchCategories();
  }

  Future<void> pop() async {
    pathNotifier.pop();
    await fetchCategories();
  }

  /// Reset the selection and navigation.
  Future<void> clearSelection() async {
    pathNotifier.replaceAll(initialPath);
  }

  /// Infinite scroll support for the current level.
  Future<void> fetchMore() async {
    if (state is! CategoryBrowsingSuccess) return;
    final currentState = state as CategoryBrowsingSuccess;
    if (!currentState.hasMore) return;

    final parentId = pathNotifier.value.lastOrNull?.id;
    try {
      final result = await _store.fetchMore(parentId: parentId);

      // Update parent category in path if selfCategory details are returned
      final selfCategory = result.extraData?.data as Category?;
      if (selfCategory != null && pathNotifier.isNotEmpty) {
        pathNotifier.updateLast(selfCategory);
      }

      emit(
        CategoryBrowsingSuccess(
          categories: result.modelList,
          hasMore: _store.hasMore(parentId),
        ),
      );
    } catch (e, st) {
      Log.error(e.toString(), e, st);
    }
  }

  @override
  Future<void> close() {
    pathNotifier.dispose();
    return super.close();
  }
}
