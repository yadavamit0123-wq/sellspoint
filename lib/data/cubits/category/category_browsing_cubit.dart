import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CategoryBrowsingState {}

class CategoryBrowsingInitial extends CategoryBrowsingState {}

class CategoryBrowsingInProgress extends CategoryBrowsingState {}

class CategoryBrowsingSuccess extends CategoryBrowsingState {
  CategoryBrowsingSuccess({
    required this.path,
    required this.categories,
    required this.page,
    required this.total,
    required this.isLoadingMore,
    required this.usesApiPagination,
  });

  final List<CategoryModel> path;
  final List<CategoryModel> categories;
  final int page;
  final int total;
  final bool isLoadingMore;
  final bool usesApiPagination;

  CategoryBrowsingSuccess copyWith({
    List<CategoryModel>? path,
    List<CategoryModel>? categories,
    int? page,
    int? total,
    bool? isLoadingMore,
    bool? usesApiPagination,
  }) {
    return CategoryBrowsingSuccess(
      path: path ?? this.path,
      categories: categories ?? this.categories,
      page: page ?? this.page,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      usesApiPagination: usesApiPagination ?? this.usesApiPagination,
    );
  }
}

class CategoryBrowsingFailure extends CategoryBrowsingState {
  CategoryBrowsingFailure(this.message);

  final String message;
}

/// Hierarchical category browser (2.14-style) using legacy [CategoryModel] APIs.
class CategoryBrowsingCubit extends Cubit<CategoryBrowsingState> {
  CategoryBrowsingCubit({List<CategoryModel> initialPath = const []})
      : _path = List<CategoryModel>.from(initialPath),
        super(CategoryBrowsingInitial());

  final CategoryRepository _repository = CategoryRepository();
  final List<CategoryModel> _path;

  List<CategoryModel> get path => List.unmodifiable(_path);

  static bool hasSubCategories(CategoryModel category) {
    final childCount = category.children?.length ?? 0;
    return childCount > 0 || (category.subcategoriesCount ?? 0) > 0;
  }

  Future<void> start() async {
    if (_path.isEmpty) {
      await _fetchLevel(parentId: null);
      return;
    }
    final tail = _path.last;
    await _showLevelForCategory(tail);
  }

  Future<void> openCategory(CategoryModel category) async {
    _path.add(category);
    await _showLevelForCategory(category);
  }

  Future<void> navigateToRoot() async {
    _path.clear();
    await _fetchLevel(parentId: null);
  }

  Future<void> navigateToIndex(int index) async {
    if (index < 0) {
      await navigateToRoot();
      return;
    }
    if (index >= _path.length) return;
    _path.removeRange(index + 1, _path.length);
    if (_path.isEmpty) {
      await _fetchLevel(parentId: null);
    } else {
      await _showLevelForCategory(_path.last);
    }
  }

  Future<void> popLevel() async {
    if (_path.isEmpty) return;
    _path.removeLast();
    if (_path.isEmpty) {
      await _fetchLevel(parentId: null);
    } else {
      await _showLevelForCategory(_path.last);
    }
  }

  bool canPopLevel() => _path.isNotEmpty;

  Future<void> fetchMore() async {
    if (state is! CategoryBrowsingSuccess) return;
    final current = state as CategoryBrowsingSuccess;
    if (!current.usesApiPagination ||
        current.isLoadingMore ||
        current.categories.length >= current.total) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final parentId = _path.isEmpty ? null : _path.last.id;
      final result = await _repository.fetchCategories(
        page: current.page + 1,
        categoryId: parentId,
      );
      if (isClosed) return;
      final merged = [...current.categories, ...result.modelList];
      emit(
        CategoryBrowsingSuccess(
          path: List.from(_path),
          categories: merged,
          page: current.page + 1,
          total: result.total,
          isLoadingMore: false,
          usesApiPagination: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _showLevelForCategory(CategoryModel category) async {
    final embedded = category.children ?? [];
    if (embedded.isNotEmpty) {
      emit(
        CategoryBrowsingSuccess(
          path: List.from(_path),
          categories: embedded,
          page: 1,
          total: embedded.length,
          isLoadingMore: false,
          usesApiPagination: false,
        ),
      );
      return;
    }
    await _fetchLevel(parentId: category.id);
  }

  Future<void> _fetchLevel({required int? parentId}) async {
    emit(CategoryBrowsingInProgress());
    try {
      final DataOutput<CategoryModel> result = await _repository.fetchCategories(
        page: 1,
        categoryId: parentId,
      );
      if (isClosed) return;
      emit(
        CategoryBrowsingSuccess(
          path: List.from(_path),
          categories: result.modelList,
          page: 1,
          total: result.total,
          isLoadingMore: false,
          usesApiPagination: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(CategoryBrowsingFailure(e.toString()));
    }
  }
}
