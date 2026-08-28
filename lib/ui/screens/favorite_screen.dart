import 'package:eClassify/ui/screens/widgets/contained_blur_image.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/liked_reels_cubit.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/home/widgets/item_horizontal_card.dart';
import 'package:eClassify/ui/screens/widgets/app_tab_bar.dart';
import 'package:eClassify/ui/screens/widgets/promoted_widget.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/interstitial_ad_on_exit_mixin.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return const FavoriteScreen();
      },
    );
  }

  @override
  FavoriteScreenState createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen>
    with InterstitialAdOnExitMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("favorites".translate(context)),
        bottom: AppTabBar(
          controller: _tabController,
          tabs: AdItemType.values
              .map((type) => type.name.translate(context))
              .toList(),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: const [FavoriteItemsWidget(), LikedReelsWidget()],
        ),
      ),
    );
  }
}

class FavoriteItemsWidget extends StatefulWidget {
  const FavoriteItemsWidget({super.key});

  @override
  State<FavoriteItemsWidget> createState() => _FavoriteItemsWidgetState();
}

class _FavoriteItemsWidgetState extends State<FavoriteItemsWidget> {
  late final ScrollController _controller = ScrollController()
    ..addListener(() {
      if (_controller.offset >= _controller.position.maxScrollExtent) {
        if (context.read<FavoriteCubit>().hasMoreFavorite()) {
          setState(() {});
          context.read<FavoriteCubit>().getMoreFavorite();
        }
      }
    });

  @override
  void initState() {
    super.initState();
    getFavorite();
  }

  void getFavorite() async {
    context.read<FavoriteCubit>().getFavorite();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        getFavorite();
      },
      color: context.color.territoryColor,
      child: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteFetchInProgress) {
            return shimmerEffect();
          } else if (state is FavoriteFetchSuccess) {
            if (state.favorite.isEmpty) {
              return const QErrorWidget.emptyData();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.favorite.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      ItemModel item = state.favorite[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.adDetailsScreen,
                            arguments: {'model': item},
                          );
                        },
                        child: ItemHorizontalCard(
                          item: item,
                          showLikeButton: true,
                        ),
                      );
                    },
                  ),
                ),
                if (state.isLoadingMore)
                  UiUtils.progress(color: context.color.territoryColor),
              ],
            );
          } else if (state is FavoriteFetchFailure) {
            return QErrorWidget(
              error: state.error,
              onRetry: () {
                context.read<FavoriteCubit>().getFavorite();
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  ListView shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomShimmer(height: 90, width: 90, borderRadius: 15),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        CustomShimmer(height: 10, width: c.maxWidth - 50),
                        const CustomShimmer(height: 10),
                        CustomShimmer(height: 10, width: c.maxWidth / 1.2),
                        Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: CustomShimmer(width: c.maxWidth / 4),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LikedReelsWidget extends StatefulWidget {
  const LikedReelsWidget({super.key});

  @override
  State<LikedReelsWidget> createState() => _LikedReelsWidgetState();
}

class _LikedReelsWidgetState extends State<LikedReelsWidget> {
  late final ScrollController _controller = ScrollController()
    ..addListener(() {
      if (_controller.offset >= _controller.position.maxScrollExtent) {
        if (context.read<LikedReelsCubit>().hasMore) {
          setState(() {});
          context.read<LikedReelsCubit>().getMoreLikedReels();
        }
      }
    });

  @override
  void initState() {
    super.initState();
    getLikedReels();
  }

  void getLikedReels() async {
    context.read<LikedReelsCubit>().getLikedReels();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        getLikedReels();
      },
      color: context.color.territoryColor,
      child: BlocBuilder<LikedReelsCubit, LikedReelsState>(
        builder: (context, state) {
          if (state is LikedReelsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LikedReelsSuccess) {
            if (state.ads.isEmpty) {
              return const QErrorWidget.emptyData();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: state.ads.length,
                    itemBuilder: (context, index) {
                      final ad = state.ads[index];
                      // Displaying a small thumbnail for the reel
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.videoAdsScreen,
                              arguments: {'reel_id': ad.id},
                            );
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ContainedBlurImage(
                                src: ad.thumbnail,
                                radius: 16,
                              ),
                              PositionedDirectional(
                                top: 8,
                                end: 8,
                                start: 8,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (ad.item.isFeature ?? false)
                                      PromotedCard(),
                                  ],
                                ),
                              ),
                              PositionedDirectional(
                                end: 8,
                                start: 8,
                                bottom: 8,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      ad.item.translatedName ??
                                          ad.item.name ??
                                          '',
                                      maxLines: 1,
                                      style: context.titleMedium.withColor(
                                        Colors.white,
                                      ),
                                    ),
                                    if (ad
                                        .item
                                        .formattedAmount
                                        .isNotNullAndNotEmpty)
                                      Text(
                                        ad.item.formattedAmount!,
                                        maxLines: 1,
                                        style: context.titleMedium.withColor(
                                          Colors.white,
                                        ),
                                      ),
                                    if (ad.item.address != null)
                                      Text(
                                        ad.item.address!.localized,
                                        maxLines: 1,
                                        style: context.titleMedium.withColor(
                                          Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (state.isLoadingPage)
                  UiUtils.progress(color: context.color.territoryColor),
              ],
            );
          } else if (state is LikedReelsFailure) {
            return QErrorWidget(
              error: state.exception.toString(),
              onRetry: () {
                context.read<LikedReelsCubit>().getLikedReels();
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
