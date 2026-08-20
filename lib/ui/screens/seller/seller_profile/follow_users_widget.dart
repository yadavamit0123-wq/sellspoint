import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/followers/follow_cubit.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/model/user/seller_ratings_model.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/utils/app_icons.dart';

class FollowUsersWidget extends StatelessWidget {
  const FollowUsersWidget({required this.seller, super.key});

  final Seller seller;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        chipTheme: ChipThemeData(
          backgroundColor: context.colorScheme.surface,
          labelStyle: context.labelMedium,
          side: BorderSide.none,
          shape: StadiumBorder(),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.followersScreen,
                arguments: {
                  'user_id': seller.id,
                  'title': seller.name,
                  'default_tab': 0,
                },
              );
            },
            child: Chip(
              label: Text(
                '${seller.followers} ${'followers'.translate(context)}',
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.followersScreen,
                arguments: {
                  'user_id': seller.id,
                  'title': seller.name,
                  'default_tab': 1,
                },
              );
            },
            child: Chip(
              label: Text(
                '${seller.following} ${'following'.translate(context)}',
              ),
            ),
          ),
          if (HiveUtils.isUserAuthenticated())
            BlocConsumer<FollowCubit, FollowState>(
              listenWhen: (prev, curr) =>
                  prev.isLoading &&
                  !curr.isLoading &&
                  prev.isFollowing != curr.isFollowing,
              listener: (context, state) {
                context
                    .read<FetchSellerRatingsCubit>()
                    .updateSellerFollowerCount(isFollowing: state.isFollowing);
                if (state.isFollowing) {
                  context.read<FollowingListCubit>().increaseTotalCount();
                } else {
                  context.read<FollowingListCubit>().decreaseTotalCount();
                }
              },
              builder: (context, followState) {
                final textWidget = switch ((
                  followState.isFollowing,
                  followState.isLoading,
                )) {
                  (_, true) => UiUtils.progress(
                    width: 30,
                    height: 30,
                    color: context.colorScheme.onPrimary,
                  ),
                  (false, false) => Text('follow'.translate(context)),
                  (true, false) => Text('unfollow'.translate(context)),
                };

                final iconWidget = switch ((
                  followState.isFollowing,
                  followState.isLoading,
                )) {
                  (_, true) => null,
                  (false, false) => const Icon(AppIcons.plus),
                  (true, false) => const Icon(AppIcons.check),
                };

                return FilledButton.icon(
                  onPressed: () {
                    if (followState.isLoading) return;
                    if (followState.isFollowing) {
                      context.read<FollowCubit>().unFollowSeller(
                        userId: seller.id,
                      );
                    } else {
                      context.read<FollowCubit>().followSeller(
                        userId: seller.id,
                      );
                    }
                  },
                  label: textWidget,
                  icon: iconWidget,
                );
              },
            ),
        ],
      ),
    );
  }
}
