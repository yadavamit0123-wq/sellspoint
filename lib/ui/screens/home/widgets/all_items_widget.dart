import 'package:eClassify/data/cubits/home/home_items_cubit.dart';
import 'package:eClassify/ui/screens/home/widgets/item_card_widget.dart';
import 'package:eClassify/ui/screens/native_ads_widget.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:staggered_grid_view/flutter_staggered_grid_view.dart';

class AllItemsWidget extends StatelessWidget {
  const AllItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 5,
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          BlocBuilder<HomeItemsCubit, HomeItemsState>(
            builder: (context, state) {
              if (state is HomeItemsSuccess) {
                final isGlobalList =
                    state.message?.contains('No Ads found') ?? false;
                if (state.items.isEmpty) {
                  return SliverToBoxAdapter(child: const SizedBox.shrink());
                }
                return SliverMainAxisGroup(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 10),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'allAdvertisements'.translate(context),
                          style: context.titleMedium,
                        ),
                      ),
                    ),
                    if (isGlobalList)
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            state.message!,
                            style: context.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }
              return SliverToBoxAdapter(child: const SizedBox.shrink());
            },
          ),
          BlocBuilder<HomeItemsCubit, HomeItemsState>(
            builder: (context, state) {
              if (state is HomeItemsSuccess) {
                if (state.items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: QErrorWidget.emptyData(
                      onRetry: () {
                        context.read<HomeItemsCubit>().getHomeItems();
                      },
                    ),
                  );
                }

                final items = state.items;
                final intervalItems = Constant.nativeAdsAfterItemNumber;
                final adCount = items.length ~/ intervalItems;
                final showLoader = state.hasMore;
                final totalCount =
                    items.length + adCount + (showLoader ? 1 : 0);

                int adsBeforeIndex(int index) {
                  return (index + 1) ~/ (intervalItems + 1);
                }

                return SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 2,
                  itemCount: totalCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemBuilder: (context, index) {
                    final isLoader = showLoader && index == totalCount - 1;
                    if (isLoader) {
                      return Center(child: UiUtils.progress());
                    }

                    final isAd =
                        index != 0 && (index + 1) % (intervalItems + 1) == 0;
                    if (isAd) {
                      return const NativeAdWidget(type: TemplateType.medium);
                    }

                    final itemIndex = index - adsBeforeIndex(index);
                    final item = items[itemIndex];
                    return ItemCard(key: ValueKey(item.id!), item: item);
                  },
                  staggeredTileBuilder: (index) {
                    final isLoader = showLoader && index == totalCount - 1;
                    if (isLoader) {
                      return items.length.isEven
                          ? const StaggeredTile.fit(2)
                          : const StaggeredTile.count(1, 1.5);
                    }

                    final isAd =
                        index != 0 && (index + 1) % (intervalItems + 1) == 0;
                    return isAd
                        ? const StaggeredTile.fit(2)
                        : const StaggeredTile.count(1, 1.5);
                  },
                );
              }
              if (state is HomeItemsFailure) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .7,
                children: List.generate(
                  2,
                  (_) => const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer(height: 147, width: 250, borderRadius: 10),
                      CustomShimmer(
                        height: 15,
                        width: 90,
                        margin: EdgeInsetsDirectional.only(top: 8),
                      ),
                      CustomShimmer(
                        height: 14,
                        width: 230,
                        margin: EdgeInsetsDirectional.only(top: 8),
                      ),
                      CustomShimmer(
                        height: 14,
                        width: 200,
                        margin: EdgeInsetsDirectional.only(top: 8),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
