import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/ui/screens/my_review_screen.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/utils/app_icons.dart';

class SellerRatingCard extends StatelessWidget {
  const SellerRatingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<FetchSellerRatingsCubit, FetchSellerRatingsState>(
          builder: (context, state) {
            if (state is FetchSellerRatingsInProgress) {
              return Row(
                spacing: 10,
                children: [
                  Column(
                    spacing: 8,
                    children: [
                      CustomShimmer(height: 40, width: 40),
                      CustomShimmer(height: 20, width: 80),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      spacing: 5,
                      children: List.generate(5, (i) {
                        return CustomShimmer(height: 10);
                      }),
                    ),
                  ),
                ],
              );
            }
            if (state is FetchSellerRatingsSuccess) {
              final seller = state.seller;
              final totalRatings = state.ratingsCount.values.reduce(
                (a, b) => a + b,
              );
              return Row(
                spacing: 10,
                children: [
                  Column(
                    spacing: 4,
                    children: [
                      Text(
                        seller.averageRating.toStringAsFixed(1),
                        style: context.headlineMedium,
                      ),
                      CustomRatingBar(
                        rating: seller.averageRating.toDouble(),
                        allowHalfRating: true,
                        inactiveColor: context.colorScheme.onSurface.withValues(
                          alpha: .15,
                        ),
                      ),
                      Text(
                        '${totalRatings} ${'ratings'.translate(context)}',
                        style: context.labelLarge,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (i) {
                        final rating = 5 - i;
                        final count = state.ratingsCount['${rating}'] ?? 0;
                        final percentage = count / totalRatings;
                        return Row(
                          spacing: 5,
                          children: [
                            SizedBox(
                              width: 10,
                              height: 20,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  '$rating',
                                  style: context.labelMedium,
                                ),
                              ),
                            ),
                            Icon(
                              AppIcons.starFill,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Expanded(
                              child: TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: percentage),
                                duration: const Duration(milliseconds: 400),
                                builder: (context, value, child) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    color: Colors.amber,
                                    backgroundColor: context
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: .1),
                                    borderRadius: BorderRadius.circular(16),
                                    minHeight: 8,
                                  );
                                },
                              ),
                            ),
                            Text('$count', style: context.labelMedium),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
