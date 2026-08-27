import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/seller_profile/verified_badge.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/color_mappers/svg_color_mapper.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerProfileCard extends StatelessWidget {
  const SellerProfileCard({required this.user, required this.item, super.key});

  final User user;
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final sellerRatings = context.watch<FetchSellerRatingsCubit>();

    final seller = sellerRatings.sellerData();
    final totalRating = sellerRatings.totalSellerRatings();
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.sellerProfileScreen,
          arguments: user.id,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CustomImage(
              src: user.profile ?? '',
              size: Size.square(70),
              radius: 16,
              fit: BoxFit.cover,
              errorImage: CustomImage(
                src: AppAssets.profile.defaultPerson,
                size: Size.square(50),
                radius: 16,
                fit: BoxFit.cover,
                svgColorMapper: SvgColorMapper(),
              ),
            ),
            10.hGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.isVerified ?? false) VerifiedBadge(),
                  Text(user.name!, style: context.bodyLarge),
                  if (seller != null)
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(AppIcons.starFill, size: 16),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: seller.averageRating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: context.color.textDefaultColor,
                                  fontSize: context.font.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10, child: VerticalDivider()),
                        if (totalRating != null)
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: totalRating.toString(),
                                  style: TextStyle(
                                    color: context.color.textDefaultColor,
                                    fontSize: context.font.normal,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: 'ratings'.translate(context),
                                  style: TextStyle(
                                    color: context.color.textDefaultColor,
                                    fontSize: context.font.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
