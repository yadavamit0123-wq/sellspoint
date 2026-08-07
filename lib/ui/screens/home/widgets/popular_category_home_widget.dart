import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/home/popular_categories_cubit.dart';
import 'package:eClassify/ui/screens/home/home_screen.dart';
import 'package:eClassify/ui/screens/home/widgets/category_home_card.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Popular categories row (2.14 API). Hidden if API unavailable.
class PopularCategoryHomeWidget extends StatelessWidget {
  const PopularCategoryHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PopularCategoriesCubit, PopularCategoriesState>(
      builder: (context, state) {
        if (state is PopularCategoriesLoading) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 103,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: sidePadding),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => const CustomShimmer(height: 90, width: 72),
              ),
            ),
          );
        }
        if (state is PopularCategoriesSuccess && state.categories.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  sidePadding,
                  16,
                  sidePadding,
                  8,
                ),
                child: CustomText(
                  'popularCategories'.translate(context),
                  fontWeight: FontWeight.w600,
                  fontSize: context.font.large,
                  color: context.color.textDefaultColor,
                ),
              ),
              SizedBox(
                height: 103,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: sidePadding),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return CategoryHomeCard(
                      title: category.name ?? '',
                      url: category.url ?? '',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.itemsList,
                          arguments: {
                            'catID': category.id.toString(),
                            'catName': category.name,
                            'categoryIds': [category.id.toString()],
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
