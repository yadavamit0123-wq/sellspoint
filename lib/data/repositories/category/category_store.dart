import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/repositories/category/category_repository.dart';
import 'package:eClassify/utils/log.dart';

/// Central store for managing category data, caching, and pagination.
class CategoryStore {
  CategoryStore._();

  static final CategoryStore _instance = CategoryStore._();

  static CategoryStore get instance => _instance;

  final CategoryRepository _repository = CategoryRepository.instance;

  /// Global cache of categories per parent ID.
  /// Null key represents root (Main Categories).
  final Map<int?, _CategoryCache> _cache = {};

  /// Fetches the first page of categories for a given parent ID.
  Future<DataOutput<Category>> fetchCategories({
    int? parentId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.containsKey(parentId)) {
      final cache = _cache[parentId]!;
      return DataOutput(
        total: cache.total,
        modelList: List.unmodifiable(cache.categories),
        extraData: cache.selfCategory != null
            ? ExtraData<Category>(data: cache.selfCategory!)
            : null,
      );
    }

    final result = await _repository.fetchCategories(
      parentId: parentId,
      page: 1,
    );

    final selfCategory = result.extraData?.data as Category?;
    Log.info('${selfCategory?.packagesCount}');

    _cache[parentId] = _CategoryCache(
      categories: result.modelList,
      page: 1,
      total: result.total,
      selfCategory: selfCategory,
    );

    return result;
  }

  /// Loads the next page of categories for a given parent ID.
  Future<DataOutput<Category>> fetchMore({int? parentId}) async {
    final cache = _cache[parentId];
    if (cache == null || !cache.hasMore) {
      return DataOutput(
        total: cache?.total ?? 0,
        modelList: List.unmodifiable(cache?.categories ?? []),
        extraData: cache?.selfCategory != null
            ? ExtraData<Category>(data: cache!.selfCategory!)
            : null,
      );
    }

    final result = await _repository.fetchCategories(
      parentId: parentId,
      page: cache.page + 1,
    );

    final selfCategory =
        result.extraData?.data as Category? ?? cache.selfCategory;

    final updatedCategories = [...cache.categories, ...result.modelList];
    _cache[parentId] = _CategoryCache(
      categories: updatedCategories,
      page: cache.page + 1,
      total: result.total,
      selfCategory: selfCategory,
    );

    return DataOutput(
      total: result.total,
      modelList: List.unmodifiable(updatedCategories),
      extraData: selfCategory != null
          ? ExtraData<Category>(data: selfCategory)
          : null,
    );
  }

  /// Clears the cache for a specific parent ID or all categories if [parentId] is null.
  void clearCache({int? parentId, bool all = false}) {
    if (all) {
      _cache.clear();
    } else {
      _cache.remove(parentId);
    }
  }

  /// Checks if more categories are available for a given parent ID.
  bool hasMore(int? parentId) => _cache[parentId]?.hasMore ?? false;

  /// Gets currently cached categories for a given parent ID.
  List<Category>? getCachedCategories(int? parentId) =>
      _cache[parentId]?.categories;
}

class _CategoryCache {
  _CategoryCache({
    required this.categories,
    required this.page,
    required this.total,
    this.selfCategory,
  });

  final List<Category> categories;
  final int page;
  final int total;
  final Category? selfCategory;

  bool get hasMore => categories.length < total;
}
