import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/followers/follow_cubit.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/user/follow_user.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReelUserCard extends StatelessWidget {
  const ReelUserCard({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final isMyUser = HiveUtils.getUserId().toString() == user.id.toString();
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(Routes.sellerProfileScreen, arguments: user.id);
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 16,
            child: CustomImage(
              src: user.profile,
              size: Size.square(32),
              radius: 32,
            ),
          ),
          12.hGap,
          Flexible(
            child: Text(
              user.name ?? '',
              maxLines: 1,
              style: context.titleMedium.withColor(Colors.white),
            ),
          ),
          if (user.isVerified ?? false) ...[
            4.hGap,
            Icon(
              AppIcons.sealCheckFill,
              size: 16,
              color: context.colorScheme.tertiary,
            ),
          ],
          if (HiveUtils.isUserAuthenticated() && !isMyUser) ...[
            8.hGap,
            BlocProvider(
              create: (_) => FollowCubit(),
              child: _FollowButton(user: user),
            ),
          ],
        ],
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  const _FollowButton({required this.user});

  final User user;

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  late bool isFollowing = widget.user.isFollowing ?? false;
  late bool isMyUser =
      HiveUtils.getUserId().toString() == widget.user.id.toString();

  @override
  void initState() {
    super.initState();
    // Add user if not already present in the list to consistently sync the follow
    // state across all the reels without refreshing
    final wasUserRemoved = context.read<FollowingListCubit>().removedUsers.any(
      (id) => id == widget.user.id,
    );
    if (isFollowing && !wasUserRemoved) {
      context.read<FollowingListCubit>().addUser(
        FollowUser.fromUser(widget.user, isFollowing: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<FollowCubit>();
    isFollowing = context.select<FollowingListCubit, bool>(
      (cubit) => switch (cubit.state) {
        FollowUsersListSuccess(:final users) => users.any(
          (u) => u.id == widget.user.id,
        ),
        _ => false,
      },
    );

    return BlocBuilder<FollowCubit, FollowState>(
      builder: (context, state) {
        return FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          onPressed: () {
            if (isFollowing) {
              context.read<FollowCubit>().unFollowSeller(
                userId: widget.user.id!,
              );
              context.read<FollowingListCubit>().removeUser(widget.user.id!);
              isFollowing = false;
            } else {
              context.read<FollowCubit>().followSeller(userId: widget.user.id!);
              context.read<FollowingListCubit>().addUser(
                FollowUser.fromUser(widget.user, isFollowing: true),
              );
              isFollowing = true;
            }
          },
          child: Text(
            isFollowing
                ? 'following'.translate(context)
                : 'follow'.translate(context),
          ),
        );
      },
    );
  }
}
