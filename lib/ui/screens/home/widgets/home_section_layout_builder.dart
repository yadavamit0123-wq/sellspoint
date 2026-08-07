import 'package:eClassify/data/cubits/home/home_screen_configuration_cubit.dart';
import 'package:eClassify/data/model/home/home_screen_section.dart';
import 'package:eClassify/data/model/home/home_section.dart';
import 'package:eClassify/ui/screens/home/slider_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/all_items_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/category_widget_home.dart';
import 'package:eClassify/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:eClassify/ui/screens/home/widgets/popular_category_home_widget.dart';
import 'package:eClassify/app_config.dart';
import 'package:flutter/material.dart';

/// Builds home blocks in admin order from [HomeConfigurationSuccess].
abstract final class HomeSectionLayoutBuilder {
  static bool includesAllAdsSection(List<HomeSection> configuration) {
    return configuration.any((s) => s.type == HomeSectionType.allAds);
  }

  /// Fetches the all-items grid when the section is shown (2.14 home load rules).
  static bool shouldFetchAllItems(HomeConfigurationState state) {
    if (!AppConfig.enableHomeConfigurationV214) {
      return true;
    }
    if (state is HomeConfigurationSuccess && state.sections.isNotEmpty) {
      return includesAllAdsSection(state.sections);
    }
    return true;
  }

  /// Tail grid when admin layout is not active (legacy / config loading / failure).
  static bool showAllAdsAtTail(HomeConfigurationState state) {
    if (!AppConfig.enableHomeConfigurationV214) {
      return true;
    }
    if (state is HomeConfigurationSuccess && state.sections.isNotEmpty) {
      return false;
    }
    return true;
  }

  static List<Widget> build({
    required List<HomeSection> configuration,
    required List<HomeScreenSection> featuredSections,
  }) {
    final children = <Widget>[];
    var featuredEmitted = false;

    for (final section in configuration) {
      switch (section.type) {
        case HomeSectionType.slider:
          children.add(const SliderWidget());
        case HomeSectionType.categoryList:
          children.add(const CategoryWidgetHome());
        case HomeSectionType.popularCategories:
          children.add(const PopularCategoryHomeWidget());
        case HomeSectionType.featuredSection:
          if (!featuredEmitted) {
            featuredEmitted = true;
            for (final featured in featuredSections) {
              children.add(HomeSectionsAdapter(section: featured));
            }
          }
        case HomeSectionType.allAds:
          children.add(const AllItemsWidget(showGoogleBanner: true));
          break;
      }
    }

    if (children.isEmpty) {
      return _legacyBlockOrder(featuredSections);
    }
    return children;
  }

  static List<Widget> _legacyBlockOrder(List<HomeScreenSection> featuredSections) {
    return [
      const SliderWidget(),
      const CategoryWidgetHome(),
      const PopularCategoryHomeWidget(),
      ...featuredSections.map((s) => HomeSectionsAdapter(section: s)),
    ];
  }
}
