import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/ui/screens/widgets/category/category_list_tile.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Multi-level category list view.
class CategoryListView extends StatelessWidget {
  const CategoryListView({
    required this.categories,
    required this.isPageLoading,
    required this.onTap,
    this.showAllOption = false,
    super.key,
  });

  final List<Category> categories;
  final ValueNotifier<bool> isPageLoading;
  final bool showAllOption;
  final void Function(Category category, {bool isAllCategory}) onTap;

  @override
  Widget build(BuildContext context) {
    final length = categories.length;
    final effectiveLength = length + (showAllOption ? 2 : 1);
    final path = context.read<CategoryBrowsingCubit>().pathNotifier;

    return Material(
      color: Colors.transparent,
      child: ListView.separated(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: Constant.bottomPadding),
        itemCount: effectiveLength,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          if (index == 0 && showAllOption) {
            if (path.isEmpty) {
              return const SizedBox.shrink();
            }
            final category = path.last;
            return CategoryListTile(
              category: category,
              isForAllCategory: true,
              onTap: () => onTap(category, isAllCategory: true),
            );
          }
          index -= showAllOption ? 1 : 0;
          if (index == categories.length) {
            return ValueListenableBuilder(
              valueListenable: isPageLoading,
              builder: (context, value, child) {
                return value
                    ? Center(child: UiUtils.progress())
                    : const SizedBox.shrink();
              },
            );
          }
          final category = categories[index];
          return CategoryListTile(
            category: category,
            onTap: () => onTap(category),
          );
        },
      ),
    );
  }
}

class CategoryListShimmer extends StatelessWidget {
  const CategoryListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => 2.vGap,
      itemBuilder: (_, _) =>
          CustomShimmer(height: 60, width: double.maxFinite, borderRadius: 12),
    );
  }
}
