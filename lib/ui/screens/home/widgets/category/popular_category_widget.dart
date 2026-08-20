import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/home/popular_categories_cubit.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/ui/screens/home/widgets/category/popular_category_card.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PopularCategoryWidget extends StatelessWidget {
  const PopularCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: BlocBuilder<PopularCategoriesCubit, PopularCategoriesState>(
        builder: (context, state) {
          if (state is PopularCategoriesLoading) {
            return _CategoryList(
              itemCount: 5,
              itemBuilder: (_, _) => Column(
                spacing: 5,
                children: [
                  CustomShimmer(height: 70, width: 70, borderRadius: 18),
                  CustomShimmer(height: 20, width: 70, borderRadius: 18),
                ],
              ),
            );
          }
          if (state is PopularCategoriesSuccess) {
            final categories = state.categories;
            if (categories.isEmpty) return const SizedBox.shrink();
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Constant.horizontalPadding,
                      vertical: 10,
                    ),
                    child: Text(
                      'popularCategories'.translate(context),
                      style: context.titleMedium,
                    ),
                  ),
                  Expanded(
                    child: _CategoryList(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return PopularCategoryCard(
                          title: category.name.localized,
                          icon: category.image,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.itemsList,
                              arguments: CategoryMetaData(category: category),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 120),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
        separatorBuilder: (context, index) => 10.hGap,
      ),
    );
  }
}
