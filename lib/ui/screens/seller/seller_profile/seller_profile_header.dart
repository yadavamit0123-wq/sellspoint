import 'package:eClassify/data/cubits/followers/follow_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/ui/screens/seller/seller_profile/follow_users_widget.dart';
import 'package:eClassify/ui/screens/seller/seller_profile/seller_profile_tab_bar.dart';
import 'package:eClassify/ui/screens/widgets/profile_avatar.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/date_extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SellerProfileHeaderDelegate({
    required this.controller,
    required this.sellerId,
  });

  final TabController controller;
  final int sellerId;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SellerProfileHeader(controller: controller, sellerId: sellerId);

  @override
  double get maxExtent => kToolbarHeight * 6;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class SellerProfileHeader extends StatelessWidget {
  const SellerProfileHeader({
    required this.controller,
    required this.sellerId,
    super.key,
  });

  final TabController controller;
  final int sellerId;

  @override
  Widget build(BuildContext context) {
    final expandedHeight = kToolbarHeight * 7;
    final collapsedHeight = kToolbarHeight;

    return SliverAppBar(
      actions: [
        IconButton(
          onPressed: () {
            HelperUtils.shareItem(context, 'seller', sellerId.toString());
          },
          icon: Icon(AppIcons.shareNetwork),
        ),
      ],
      pinned: true,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SellerProfileTabBar(controller: controller),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 60),
          child: BlocConsumer<FetchSellerRatingsCubit, FetchSellerRatingsState>(
            listenWhen: (previous, current) =>
                previous is! FetchSellerRatingsSuccess &&
                current is FetchSellerRatingsSuccess,
            listener: (context, state) {
              if (state is FetchSellerRatingsSuccess) {
                final followCubit = context.read<FollowCubit>();
                final sellerFollowing = state.seller.isFollowing;
                if (followCubit.state.isFollowing != sellerFollowing) {
                  followCubit.setFollowingStatus(sellerFollowing);
                }
              }
            },
            builder: (context, state) {
              if (state is FetchSellerRatingsInProgress) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4,
                  children: [
                    CustomShimmer(height: 80, width: 80, borderRadius: 40),
                    CustomShimmer(height: 20, width: 100),
                    CustomShimmer(height: 20, width: 150),
                  ],
                );
              }
              if (state is FetchSellerRatingsSuccess) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4,
                  children: [
                    ProfileAvatar(
                      src: state.seller.profile ?? '',
                      size: Size.square(80),
                    ),
                    4.vGap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          state.seller.name,
                          style: context.titleMedium.bold,
                        ),
                        if (state.seller.isVerified ?? false)
                          Icon(
                            AppIcons.sealCheckFill,
                            color: const Color(0xff05a61d),
                            size: 16,
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Icon(AppIcons.starFill, color: Colors.amber, size: 16),
                        Text(
                          state.seller.averageRating.toStringAsFixed(1),
                          style: context.labelLarge,
                        ),

                        Text(
                          '(${state.ratings.length}  ${'ratings'.translate(context)})',
                          style: context.labelLarge,
                        ),
                      ],
                    ),
                    if (state.seller.createdAt != null)
                      Text(
                        '${'memberSince'.translate(context)} ${state.seller.createdAt!.format(formatString: 'MMMM yyyy')}',
                        style: context.labelMedium.withColor(
                          context.mutedColor,
                        ),
                      ),
                    4.vGap,
                    FollowUsersWidget(seller: state.seller),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
