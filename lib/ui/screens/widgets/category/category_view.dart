import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/ui/screens/widgets/category/category_grid_view.dart';
import 'package:eClassify/ui/screens/widgets/category/category_list_view.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CategoryViewMode { list, grid }

/// UI container that switches between Grid and List views for categories and unifies tap logic.
class CategoryView extends StatefulWidget {
  const CategoryView({
    super.key,
    required this.onSelect,
    this.showAllOption = false,
    this.mainCategoryMode = CategoryViewMode.grid,
    this.subCategoryMode = CategoryViewMode.list,
  });

  final void Function(Category selected, List<Category> path) onSelect;
  final bool showAllOption;
  final CategoryViewMode mainCategoryMode;
  final CategoryViewMode subCategoryMode;

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final _showLoader = ValueNotifier<bool>(false);

  void _onTap(Category category, {bool isAllCategory = false}) {
    if (isAllCategory) {
      // Selection logic for 'All' category can be handled by processCategory
      // If we need specialized logic, we can add it to the cubit.
      context.read<CategoryBrowsingCubit>().selectCategory(category);
    } else if (category.hasSubCategories) {
      context.read<CategoryBrowsingCubit>().processCategory(category);
    } else {
      context.read<CategoryBrowsingCubit>().selectCategory(category);
    }
  }

  @override
  void dispose() {
    _showLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBrowsingCubit, CategoryBrowsingState>(
      listener: (context, state) {
        if (state is! CategoryBrowsingLoading) {
          _showLoader.value = false;
        }
      },
      buildWhen: (prev, curr) => curr is! CategorySelected,
      builder: (context, state) {
        final path = context.read<CategoryBrowsingCubit>().pathNotifier.value;
        final viewMode = path.isNotEmpty
            ? widget.subCategoryMode
            : widget.mainCategoryMode;

        if (state is CategoryBrowsingFailure) {
          return QErrorWidget(
            error: state.error,
            onRetry: () {
              context.read<CategoryBrowsingCubit>().fetchCategories();
            },
          );
        }

        if (state is CategoryBrowsingSuccess) {
          if (state.categories.isEmpty) {
            return QErrorWidget.emptyData(
              onRetry: () {
                context.read<CategoryBrowsingCubit>().fetchCategories();
              },
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.isAtBottom && state.hasMore) {
                context.read<CategoryBrowsingCubit>().fetchMore();
                _showLoader.value = true;
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async => context
                  .read<CategoryBrowsingCubit>()
                  .fetchCategories(forceRefresh: true),
              child: switch (viewMode) {
                CategoryViewMode.list => CategoryListView(
                  categories: state.categories,
                  isPageLoading: _showLoader,
                  showAllOption: widget.showAllOption,
                  onTap: _onTap,
                ),
                CategoryViewMode.grid => CategoryGridView(
                  categories: state.categories,
                  isPageLoading: _showLoader,
                  onTap: _onTap,
                ),
              },
            ),
          );
        }

        if (state is CategoryBrowsingLoading) {
          return switch (viewMode) {
            CategoryViewMode.list => const CategoryListShimmer(),
            CategoryViewMode.grid => const CategoryGridShimmer(),
          };
        }

        return const SizedBox.shrink();
      },
    );
  }
}
