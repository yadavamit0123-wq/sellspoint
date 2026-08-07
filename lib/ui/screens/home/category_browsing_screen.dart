import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/category.dart';
import 'package:eClassify/ui/screens/item/ad_posting/ad_posting_progress_header.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_silver_grid_delegate.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/subscription_navigation.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CategoryBrowsingLeafDestination { itemsList, subscription, adPosting }

/// 2.14-style category tree with breadcrumbs; uses legacy category APIs.
class CategoryBrowsingScreen extends StatefulWidget {
  const CategoryBrowsingScreen({
    super.key,
    this.initialPath = const [],
    this.leafDestination = CategoryBrowsingLeafDestination.itemsList,
  });

  final List<CategoryModel> initialPath;
  final CategoryBrowsingLeafDestination leafDestination;

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    final initialPath = args?['initialPath'] as List<CategoryModel>? ?? [];
    final leafRaw = args?['leafDestination'];
    final leafDestination = leafRaw is CategoryBrowsingLeafDestination
        ? leafRaw
        : leafRaw == 'subscription'
            ? CategoryBrowsingLeafDestination.subscription
            : leafRaw == 'adPosting'
                ? CategoryBrowsingLeafDestination.adPosting
                : CategoryBrowsingLeafDestination.itemsList;
    return BlurredRouter(
      builder: (_) => BlocProvider(
        create: (_) =>
            CategoryBrowsingCubit(initialPath: initialPath)..start(),
        child: CategoryBrowsingScreen(
          initialPath: initialPath,
          leafDestination: leafDestination,
        ),
      ),
    );
  }

  @override
  State<CategoryBrowsingScreen> createState() => _CategoryBrowsingScreenState();
}

class _CategoryBrowsingScreenState extends State<CategoryBrowsingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.isEndReached()) return;
    context.read<CategoryBrowsingCubit>().fetchMore();
  }

  List<String> _categoryIdsForPath(List<CategoryModel> path) {
    return path.map((c) => c.id.toString()).toList();
  }

  void _openLeaf(CategoryModel category, List<CategoryModel> path) {
    if (widget.leafDestination == CategoryBrowsingLeafDestination.adPosting) {
      Navigator.pushReplacementNamed(
        context,
        Routes.addItemDetails,
        arguments: {
          'breadCrumbItems': path,
          'isEdit': false,
        },
      );
      return;
    }
    if (widget.leafDestination == CategoryBrowsingLeafDestination.subscription) {
      SubscriptionNavigation.openPackagesForCategory(
        context,
        categoryId: category.id,
        categoryName: category.name,
      );
      return;
    }
    Constant.itemFilter = null;
    HelperUtils.goToNextPage(
      Routes.itemsList,
      context,
      false,
      args: {
        'catID': category.id.toString(),
        'catName': category.name,
        'categoryIds': _categoryIdsForPath(path),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !Platform.isAndroid,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final cubit = context.read<CategoryBrowsingCubit>();
        if (cubit.canPopLevel()) {
          cubit.popLevel();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: AnnotatedRegion(
        value: UiUtils.getSystemUiOverlayStyle(
          context: context,
          statusBarColor: context.color.secondaryColor,
        ),
        child: Scaffold(
          backgroundColor: context.color.backgroundColor,
          appBar: UiUtils.buildAppBar(
            context,
            showBackButton: true,
            title: widget.leafDestination ==
                    CategoryBrowsingLeafDestination.adPosting
                ? 'adListing'.translate(context)
                : 'categoriesLbl'.translate(context),
            onBackPress: () {
              final cubit = context.read<CategoryBrowsingCubit>();
              if (cubit.canPopLevel()) {
                cubit.popLevel();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.leafDestination ==
                      CategoryBrowsingLeafDestination.adPosting &&
                  AdPostingProgressHeader.isEnabled)
                const AdPostingProgressHeader(currentStep: 1),
              Expanded(
                child: BlocBuilder<CategoryBrowsingCubit, CategoryBrowsingState>(
                  builder: (context, state) {
              if (state is CategoryBrowsingInProgress ||
                  state is CategoryBrowsingInitial) {
                return UiUtils.progress();
              }
              if (state is CategoryBrowsingFailure) {
                return Center(child: CustomText(state.message));
              }
              if (state is! CategoryBrowsingSuccess) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBreadcrumb(
                    path: state.path,
                    onSelect: (index) {
                      context.read<CategoryBrowsingCubit>().navigateToIndex(index);
                    },
                  ),
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                        crossAxisCount: 3,
                        height: MediaQuery.of(context).size.height * 0.18,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        return CategoryCard(
                          title: category.name ?? '',
                          url: category.url ?? '',
                          onTap: () {
                            final cubit = context.read<CategoryBrowsingCubit>();
                            final path = [...state.path, category];
                            if (CategoryBrowsingCubit.hasSubCategories(category)) {
                              cubit.openCategory(category);
                            } else {
                              _openLeaf(category, path);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  if (state.isLoadingMore) UiUtils.progress(),
                ],
              );
            },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBreadcrumb extends StatelessWidget {
  const _CategoryBreadcrumb({
    required this.path,
    required this.onSelect,
  });

  final List<CategoryModel> path;
  final void Function(int index) onSelect;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
      child: Row(
        children: [
          _Crumb(
            label: 'allCategories'.translate(context),
            onTap: () => onSelect(-1),
          ),
          for (var i = 0; i < path.length; i++) ...[
            Icon(Icons.chevron_right, size: 18, color: context.color.textLightColor),
            _Crumb(
              label: path[i].name ?? '',
              onTap: () => onSelect(i),
              isLast: i == path.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: CustomText(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
          color: isLast
              ? context.color.territoryColor
              : context.color.textDefaultColor,
        ),
      ),
    );
  }
}
