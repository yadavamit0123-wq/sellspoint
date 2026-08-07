import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/cubits/category/fetch_category_cubit.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/ui/screens/home/home_screen.dart';
import 'package:eClassify/ui/screens/home/widgets/category_home_card.dart';
import 'package:eClassify/ui/screens/main_activity.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryWidgetHome extends StatelessWidget {
  const CategoryWidgetHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
      builder: (context, state) {
        if (state is FetchCategorySuccess) {
          if (state.categories.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: context.screenWidth,
                height: 103,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: sidePadding,
                  ),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (state.categories.length > 10 && index == state.categories.length) {
                      return moreCategory(context);
                    } else {
                      return CategoryHomeCard(
                        title: state.categories[index].name!,
                        url: state.categories[index].url!,
                        onTap: () => _openHomeCategory(
                          context,
                          state.categories[index],
                        ),
                      );
                    }
                  },
                  itemCount: state.categories.length > 10
                      ? state.categories.length + 1
                      : state.categories.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 12,
                    );
                  },
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(50.0),
              child: NoDataFound(
                onTap: () {},
              ),
            );
          }
        }
        return Container();
      },
    );
  }

  void _openHomeCategory(BuildContext context, CategoryModel category) {
    if (AppConfig.enableCategoryBrowsingV214) {
      if (CategoryBrowsingCubit.hasSubCategories(category)) {
        Navigator.pushNamed(
          context,
          Routes.categoryBrowsing,
          arguments: {
            'initialPath': [category],
          },
        );
        return;
      }
      Navigator.pushNamed(context, Routes.itemsList, arguments: {
        'catID': category.id.toString(),
        'catName': category.name,
        'categoryIds': [category.id.toString()],
      });
      return;
    }
    if (category.children!.isNotEmpty) {
      Navigator.pushNamed(context, Routes.subCategoryScreen, arguments: {
        'categoryList': category.children,
        'catName': category.name,
        'catId': category.id,
        'categoryIds': [category.id.toString()],
      });
    } else {
      Navigator.pushNamed(context, Routes.itemsList, arguments: {
        'catID': category.id.toString(),
        'catName': category.name,
        'categoryIds': [category.id.toString()],
      });
    }
  }

  Widget moreCategory(BuildContext context) {
    final route = AppConfig.enableCategoryBrowsingV214
        ? Routes.categoryBrowsing
        : Routes.categories;
    final args = AppConfig.enableCategoryBrowsingV214
        ? null
        : {'from': Routes.home};

    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, route, arguments: args).then(
            (dynamic value) {
              if (value != null) {
                selectedCategory = value;
              }
            },
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: context.color.borderColor.darken(60), width: 1),
                  color: context.color.secondaryColor,
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      // color: Colors.blue,
                      width: 48,
                      height: 48,
                      child: Center(
                        child: RotatedBox(
                            quarterTurns: 1,
                            child: UiUtils.getSvg(AppIcons.more,
                                color: context.color.territoryColor)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: CustomText(
                        "more".translate(context),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        color: context.color.textDefaultColor,
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
