import 'dart:io';

import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/ui/screens/widgets/category/category_breadcrumbs_widget.dart';
import 'package:eClassify/ui/screens/widgets/category/category_listeners_scope.dart';
import 'package:eClassify/ui/screens/widgets/category/category_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Top-level widget for picking a category. Provides breadcrumb navigation and switches between grid/list views.
class CategoryPicker extends StatefulWidget {
  const CategoryPicker({
    super.key,
    required this.onSelect,
    this.showAllOption = true,
    this.showBreadcrumbs = true,
    this.mainCategoryMode = CategoryViewMode.grid,
    this.subCategoryMode = CategoryViewMode.list,
    this.padding,
    this.resetSelection = true,
  });

  /// [onSelect] is called when a category is tapped.
  /// It should return a [Future<bool>].
  /// - If [true], the picker will automatically navigate deeper if subcategories exist.
  /// - If [false], the picker does nothing, assuming the caller has handled the interaction.
  final void Function(Category selected, List<Category> path) onSelect;

  final bool showAllOption;
  final bool showBreadcrumbs;
  final CategoryViewMode mainCategoryMode;
  final CategoryViewMode subCategoryMode;
  final EdgeInsetsGeometry? padding;
  final bool resetSelection;

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  @override
  void initState() {
    super.initState();
    if (widget.resetSelection) {
      // Start with a fresh selection flow but keep the global cache.
      context.read<CategoryBrowsingCubit>().clearSelection();
    }
    context.read<CategoryBrowsingCubit>().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final path = context.read<CategoryBrowsingCubit>().pathNotifier;
    return ListenableBuilder(
      listenable: path,
      builder: (context, child) {
        return PopScope(
          canPop: !Platform.isAndroid || path.isEmpty,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (path.isNotEmpty) {
              context.read<CategoryBrowsingCubit>().pop();
            }
          },
          child: child!,
        );
      },
      child: CategoryListenersScope(
        onSelect: widget.onSelect,
        child: SafeArea(
          child: Column(
            spacing: 10,
            children: [
              if (widget.showBreadcrumbs)
                CategoryBreadcrumbs.dynamic(
                  notifier: context.read<CategoryBrowsingCubit>().pathNotifier,
                ),
              Expanded(
                child: CategoryView(
                  showAllOption: widget.showAllOption,
                  onSelect: (selected, path) async {},
                  mainCategoryMode: widget.mainCategoryMode,
                  subCategoryMode: widget.subCategoryMode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
