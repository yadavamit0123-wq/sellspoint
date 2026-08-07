import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/followers/follow_cubit.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/user/follow_user.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUserListTile extends StatefulWidget {
  const FollowUserListTile({
    super.key,
    required this.followUser,
    this.showUnfollowButton = false,
  });

  final FollowUser followUser;
  final bool showUnfollowButton;

  @override
  State<FollowUserListTile> createState() => _FollowUserListTileState();
}

class _FollowUserListTileState extends State<FollowUserListTile> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.followUser.isFollowing;
  }

  User _toUser() {
    return User(
      id: widget.followUser.id,
      name: widget.followUser.name,
      email: widget.followUser.email,
      mobile: widget.followUser.mobile,
      profile: widget.followUser.profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: context.color.borderColor),
      ),
      tileColor: context.color.secondaryColor,
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.sellerProfileScreen,
          arguments: {'model': _toUser()},
        );
      },
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: context.color.backgroundColor,
        child: ClipOval(
          child: widget.followUser.profile != null &&
                  widget.followUser.profile!.isNotEmpty
              ? UiUtils.getImage(
                  widget.followUser.profile!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                )
              : UiUtils.getSvg(
                  AppIcons.defaultPersonLogo,
                  color: context.color.territoryColor,
                ),
        ),
      ),
      title: CustomText(
        widget.followUser.name,
        fontWeight: FontWeight.w600,
        color: context.color.textDefaultColor,
      ),
      trailing: widget.showUnfollowButton ? _followButton(context) : null,
    );
  }

  Widget _followButton(BuildContext context) {
    return BlocConsumer<FollowCubit, FollowState>(
      listenWhen: (prev, curr) =>
          curr.userId == widget.followUser.id && !curr.isLoading,
      listener: (context, state) {
        setState(() => _isFollowing = state.isFollowing);
        if (state.isFollowing) {
          context.read<FollowingListCubit>().increaseTotalCount();
        } else {
          context.read<FollowingListCubit>().decreaseTotalCount();
        }
      },
      buildWhen: (prev, curr) => curr.userId == widget.followUser.id,
      builder: (context, state) {
        final loading =
            state.isLoading && state.userId == widget.followUser.id;
        if (loading) {
          return SizedBox(
            width: 32,
            height: 32,
            child: UiUtils.progress(),
          );
        }
        return TextButton(
          onPressed: () {
            if (_isFollowing) {
              context
                  .read<FollowCubit>()
                  .unFollowSeller(userId: widget.followUser.id);
            } else {
              context
                  .read<FollowCubit>()
                  .followSeller(userId: widget.followUser.id);
            }
          },
          child: CustomText(
            _isFollowing
                ? 'unfollow'.translate(context)
                : 'follow'.translate(context),
            color: _isFollowing ? Colors.red : context.color.territoryColor,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
