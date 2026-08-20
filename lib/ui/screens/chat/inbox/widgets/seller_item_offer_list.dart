import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/item_offer_tile.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerItemOfferList extends StatefulWidget {
  const SellerItemOfferList({super.key});

  @override
  State<SellerItemOfferList> createState() => _SellerItemOfferListState();
}

class _SellerItemOfferListState extends State<SellerItemOfferList> {
  final ValueNotifier<bool> _showLoading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _showLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerItemOffersCubit, SellerItemOffersState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is SellerItemOffersInitial) {
          context.read<SellerItemOffersCubit>().getOffers();
        }
        if (state is SellerItemOffersFailure) {
          return QErrorWidget(
            error: state.error,
            onRetry: () {
              context.read<SellerItemOffersCubit>().getOffers();
            },
          );
        }
        if (state is SellerItemOffersSuccess) {
          if (state.offers.isEmpty) {
            return const QErrorWidget.emptyData();
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent) {
                if (!_showLoading.value && context.read<SellerItemOffersCubit>().hasMore) {
                  _showLoading.value = true;
                  context.read<SellerItemOffersCubit>().getMoreOffers().whenComplete(() {
                    _showLoading.value = false;
                  });
                }
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<SellerItemOffersCubit>().getOffers();
              },
              child: Material(
                color: Colors.transparent,
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    if (index == state.offers.length) {
                      return ValueListenableBuilder(
                        valueListenable: _showLoading,
                        builder: (context, value, child) {
                          return value
                              ? UiUtils.progress()
                              : const SizedBox.shrink();
                        },
                      );
                    }
                    return ItemOfferTile(offer: state.offers[index]);
                  },
                  separatorBuilder: (context, index) => 10.vGap,
                  itemCount: state.offers.length + 1,
                ),
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: List.generate(5, (index) {
            return ListTile(
              leading: CustomShimmer(height: 40, width: 40, borderRadius: 20),
              title: CustomShimmer(height: 10, borderRadius: 10),
              subtitle: SizedBox(
                width: 50,
                height: 20,
                child: Stack(
                  fit: StackFit.loose,
                  alignment: Alignment.center,
                  children: List.generate(5, (index) {
                    return PositionedDirectional(
                      start: 10.0 * index,
                      child: CustomShimmer(
                        height: 15,
                        width: 15,
                        borderRadius: 10,
                      ),
                    );
                  }),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
