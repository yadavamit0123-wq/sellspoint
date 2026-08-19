import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/ui/screens/seller/seller_profile/seller_rating/user_review_card.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerReviewList extends StatelessWidget {
  const SellerReviewList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchSellerRatingsCubit, FetchSellerRatingsState>(
      builder: (context, state) {
        if (state is FetchSellerRatingsInProgress) {
          return Column(
            children: List.generate(3, (i) {
              return Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    spacing: 10,
                    children: [
                      CustomShimmer(height: 40, width: 40, borderRadius: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            CustomShimmer(width: 80, height: 15),
                            CustomShimmer(width: 180, height: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }
        if (state is FetchSellerRatingsSuccess) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) =>
                UserReviewCard(rating: state.ratings[index]),
            itemCount: state.ratings.length,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
