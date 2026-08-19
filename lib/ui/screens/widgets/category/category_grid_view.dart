import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/ui/screens/widgets/category/category_grid_card.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

/// Grid view for top-level categories.
class CategoryGridView extends StatelessWidget {
  const CategoryGridView({
    required this.categories,
    required this.isPageLoading,
    required this.onTap,
    super.key,
  });

  final List<Category> categories;
  final ValueNotifier<bool> isPageLoading;
  final void Function(Category category, {bool isAllCategory}) onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isPageLoading,
      builder: (context, value, child) {
        final isLoading = value;
        return GridView.builder(
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.only(bottom: Constant.bottomPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: .6,
          ),
          itemCount: categories.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return value
                  ? Center(child: UiUtils.progress())
                  : const SizedBox.shrink();
            }
            final category = categories[index];
            return CategoryGridCard(
              category: category,
              onTap: () => onTap(category),
            );
          },
        );
      },
    );
  }
}

class CategoryGridShimmer extends StatelessWidget {
  const CategoryGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: .65,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      children: List.generate(9, (index) => CustomShimmer(borderRadius: 12)),
    );
  }
}
