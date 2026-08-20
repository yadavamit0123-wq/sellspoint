import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/item/fetch_my_featured_items_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/home/widgets/item_horizontal_card.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_common_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/interstitial_ad_on_exit_mixin.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAdvertisementScreen extends StatefulWidget {
  const MyAdvertisementScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => FetchMyFeaturedItemsCubit(),
          child: const MyAdvertisementScreen(),
        );
      },
    );
  }

  @override
  State<MyAdvertisementScreen> createState() => _MyAdvertisementScreenState();
}

class _MyAdvertisementScreenState extends State<MyAdvertisementScreen>
    with InterstitialAdOnExitMixin {
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMyFeaturedItems();

    _pageScrollController.addListener(_pageScroll);
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  void fetchMyFeaturedItems() {
    context.read<FetchMyFeaturedItemsCubit>().fetchMyFeaturedItems();
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchMyFeaturedItemsCubit>().hasMoreData()) {
        context.read<FetchMyFeaturedItemsCubit>().fetchMyFeaturedItemsMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: "myFeaturedAds".translate(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchMyFeaturedItems();
        },
        color: context.color.territoryColor,
        child:
            BlocBuilder<FetchMyFeaturedItemsCubit, FetchMyFeaturedItemsState>(
              builder: (context, state) {
                if (state is FetchMyFeaturedItemsInProgress) {
                  return shimmerEffect();
                }
                if (state is FetchMyFeaturedItemsFailure) {
                  return QErrorWidget(
                    error: state.error,
                    onRetry: fetchMyFeaturedItems,
                  );
                }
                if (state is FetchMyFeaturedItemsSuccess) {
                  if (state.itemModel.isEmpty) {
                    return const QErrorWidget.emptyData();
                  }

                  return buildWidget(state);
                }
                return Container();
              },
            ),
      ),
    );
  }

  ListView shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        return ShimmerCommonWidget();
      },
    );
  }

  Widget buildWidget(FetchMyFeaturedItemsSuccess state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _pageScrollController,
            itemCount: state.itemModel.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              ItemModel item = state.itemModel[index];

              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.adDetailsScreen,
                    arguments: {'model': item},
                  );
                },
                child: ItemHorizontalCard(item: item),
              );
            },
          ),
        ),
        if (state.isLoadingMore) UiUtils.progress(),
      ],
    );
  }
}
