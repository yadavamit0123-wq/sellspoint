import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/ui/screens/followers/follow_user_list_tile.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUsersList<C extends FollowUsersListCubit> extends StatefulWidget {
  const FollowUsersList({super.key, required this.showUnfollowButton});

  final bool showUnfollowButton;

  @override
  State<FollowUsersList<C>> createState() => _FollowUsersListState<C>();
}

class _FollowUsersListState<C extends FollowUsersListCubit>
    extends State<FollowUsersList<C>> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.isEndReached()) return;
      if (context.read<C>().hasMore) {
        context.read<C>().getMoreUsers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<C, FollowUsersListState>(
      builder: (context, state) {
        if (state is FollowUsersListLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CustomShimmer(height: 56, width: double.infinity),
            ),
          );
        }
        if (state is FollowUsersListFailure) {
          return SomethingWentWrong(onTap: () => context.read<C>().getUsers());
        }
        if (state is FollowUsersListSuccess) {
          if (state.users.isEmpty) {
            return NoDataFound(onTap: () => context.read<C>().getUsers());
          }
          return RefreshIndicator(
            onRefresh: () => context.read<C>().getUsers(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: state.users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return FollowUserListTile(
                  followUser: state.users[index],
                  showUnfollowButton: widget.showUnfollowButton,
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
