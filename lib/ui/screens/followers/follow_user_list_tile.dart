import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/followers/follow_cubit.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/model/user/follow_user.dart';
import 'package:eClassify/ui/screens/widgets/profile_avatar.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUserListTile extends StatefulWidget {
  const FollowUserListTile({
    required this.followUser,
    this.showUnfollowButton = false,
    super.key,
  });

  final FollowUser followUser;
  final bool showUnfollowButton;

  @override
  State<FollowUserListTile> createState() => _FollowUserListTileState();
}

class _FollowUserListTileState extends State<FollowUserListTile> {
  late bool isFollowing = true;

  Widget _getTrailingWidget() {
    return switch (widget.showUnfollowButton) {
      true => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 100, minWidth: 60, maxHeight: 30),
        child: BlocConsumer<FollowCubit, FollowState>(
          listenWhen: (prev, curr) =>
              curr.userId == widget.followUser.id && !curr.isLoading,
          listener: (context, state) {
            isFollowing = state.isFollowing;
            if (state.isFollowing) {
              context.read<FollowingListCubit>().increaseTotalCount();
            } else {
              context.read<FollowingListCubit>().decreaseTotalCount();
            }
          },
          buildWhen: (prev, curr) => curr.userId == widget.followUser.id,
          builder: (context, state) {
            var child = switch (state.isLoading) {
              true => Center(
                child: UiUtils.progress(
                  height: 30,
                  width: 30,
                  color: isFollowing
                      ? Colors.red
                      : context.colorScheme.onPrimary,
                ),
              ),
              false => Text(
                isFollowing
                    ? 'unfollow'.translate(context)
                    : 'follow'.translate(context),
              ),
            };
            return switch (isFollowing) {
              true => OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  minimumSize: const Size(120, 30),
                  fixedSize: const Size(60, 30),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  context.read<FollowCubit>().unFollowSeller(
                    userId: widget.followUser.id,
                  );
                },
                child: child,
              ),
              false => FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 30),
                  fixedSize: const Size(60, 30),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  context.read<FollowCubit>().followSeller(
                    userId: widget.followUser.id,
                  );
                },
                child: child,
              ),
            };
          },
        ),
      ),
      false => ConstrainedBox(
        constraints: BoxConstraints.tight(Size.square(30)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Icon(AppIcons.caretRight, size: 20)),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.sellerProfileScreen,
          arguments: widget.followUser.id,
        );
      },
      leading: ProfileAvatar(
        src: widget.followUser.profile ?? '',
        size: Size.square(48),
        tag: widget.followUser.id.toString(),
      ),
      title: Text(widget.followUser.name),
      trailing: _getTrailingWidget(),
    );
  }
}
