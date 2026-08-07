import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/category/fetch_category_cubit.dart';
import 'package:eClassify/data/cubits/home/fetch_home_all_items_cubit.dart';
import 'package:eClassify/data/cubits/home/fetch_home_screen_cubit.dart';
import 'package:eClassify/data/cubits/home/home_screen_configuration_cubit.dart';
import 'package:eClassify/data/cubits/home/popular_categories_cubit.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/ui/screens/home/widgets/home_section_layout_builder.dart';
import 'package:eClassify/utils/leaf_location_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Refreshes home-related data after locale / admin layout changes.
abstract final class HomeLocaleRefresh {
  static void afterLanguageChange(BuildContext context) {
    context.read<FetchCategoryCubit>().fetchCategories();
    context.read<PopularCategoriesCubit>().fetchPopularCategories();

    if (AppConfig.enableHomeConfigurationV214) {
      context.read<HomeConfigurationCubit>().getHomeConfiguration();
    }

    context.read<LeafLocationCubit>().syncFromLegacyHive();
    final featured = LeafLocationBridge.featuredSection;
    context.read<FetchHomeScreenCubit>().fetch(
          city: featured.city,
          areaId: featured.areaId,
          country: featured.country,
          state: featured.state,
        );
    final configState = context.read<HomeConfigurationCubit>().state;
    if (!HomeSectionLayoutBuilder.shouldFetchAllItems(configState)) {
      return;
    }
    final items = LeafLocationBridge.allItems;
    context.read<FetchHomeAllItemsCubit>().fetch(
          city: items.city,
          areaId: items.areaId,
          radius: items.radius,
          longitude: items.longitude,
          latitude: items.latitude,
          country: items.country,
          state: items.state,
        );
  }
}
