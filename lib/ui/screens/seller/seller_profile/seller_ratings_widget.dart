import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/ui/screens/seller/seller_profile/seller_rating/seller_rating_card.dart';
import 'package:eClassify/ui/screens/seller/seller_profile/seller_rating/seller_review_list.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerRatingsWidget extends StatelessWidget {
  const SellerRatingsWidget({required this.sellerId, super.key});

  final int sellerId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchSellerRatingsCubit, FetchSellerRatingsState>(
      builder: (context, state) {
        if (state is FetchSellerRatingsFail) {
          return SomethingWentWrong();
        }
        if (state is FetchSellerRatingsSuccess) {
          if (state.ratings.isEmpty) {
            return Center(
              child: NoDataFound(
                onTap: () {
                  context.read<FetchSellerRatingsCubit>().fetch(
                    sellerId: sellerId,
                  );
                },
              ),
            );
          }

          return Column(
            spacing: 10,
            children: [
              SellerRatingCard(),
              Flexible(child: SellerReviewList()),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
