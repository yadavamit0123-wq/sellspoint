import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_item_cubit.dart';
import 'package:eClassify/ui/screens/home/widgets/item_card_widget.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerLiveAdsWidget extends StatelessWidget {
  const SellerLiveAdsWidget({required this.sellerId, super.key});
  final int sellerId;

  Widget buildItemsShimmer(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: .7,
      children: List.generate(4, (index) => CustomShimmer()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchSellerItemsCubit, FetchSellerItemsState>(
      builder: (context, state) {
        if (state is FetchSellerItemsInProgress) {
          return buildItemsShimmer(context);
        }

        if (state is FetchSellerItemsFail) {
          return SomethingWentWrong();
        }
        if (state is FetchSellerItemsSuccess) {
          if (state.items.isEmpty) {
            return Center(
              child: NoDataFound(
                onTap: () {
                  context.read<FetchSellerItemsCubit>().fetch(
                    sellerId: sellerId,
                  );
                },
              ),
            );
          }

          final totalLength =
              state.items.length + (state.items.length < state.total ? 1 : 0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                '${state.total} ${'itemsLive'.translate(context)}',
                style: context.bodyMedium,
              ),
              Flexible(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      if (context.read<FetchSellerItemsCubit>().hasMoreData()) {
                        context.read<FetchSellerItemsCubit>().fetchMore(
                          sellerId: sellerId,
                        );
                      }
                    }
                    return true;
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: .6,
                    ),
                    itemCount: totalLength,
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        if (state.isLoadingMore) {
                          return Center(
                            child: UiUtils.progress(height: 80, width: 80),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }

                      final item = state.items[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.adDetailsScreen,
                            arguments: {'model': item},
                          );
                        },
                        child: ItemCard(item: item),
                      );
                    },
                  ),
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
