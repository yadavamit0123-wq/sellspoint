import 'package:eClassify/data/model/user/seller_ratings_model.dart';
import 'package:eClassify/ui/screens/my_review_screen.dart';
import 'package:eClassify/ui/screens/widgets/profile_avatar.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserReviewCard extends StatelessWidget {
  const UserReviewCard({required this.rating, super.key});

  final UserRatings rating;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            ProfileAvatar(
              src: rating.buyer.profile ?? '',
              tag: rating.id.toString(),
              size: Size.square(48),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rating.buyer.name,
                          style: context.titleMedium,
                        ),
                      ),
                      if (rating.createdAt != null)
                        Text(
                          timeago.format(
                            rating.createdAt!,
                            locale: '${AppSession.currentLocale}_short',
                          ),
                          style: context.labelMedium.withColor(
                            context.mutedColor,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomRatingBar(
                        rating: rating.ratings.toDouble(),
                        allowHalfRating: true,
                        inactiveColor: context.colorScheme.onSurface.withValues(
                          alpha: .1,
                        ),
                      ),
                      Text(
                        '${rating.ratings}',
                        style: context.labelMedium.withColor(
                          context.mutedColor,
                        ),
                      ),
                    ],
                  ),
                  if (rating.review != null)
                    Text(rating.review!, style: context.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
