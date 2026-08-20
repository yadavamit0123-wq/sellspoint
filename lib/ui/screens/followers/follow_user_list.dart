import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/ui/screens/followers/follow_user_list_tile.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUsersList<C extends FollowUsersListCubit> extends StatefulWidget {
  const FollowUsersList({required this.showUnfollowButton, super.key});

  final bool showUnfollowButton;

  @override
  State<FollowUsersList<C>> createState() => _FollowUsersListState<C>();
}

class _FollowUsersListState<C extends FollowUsersListCubit>
    extends State<FollowUsersList<C>>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<C, FollowUsersListState>(
      builder: (context, state) {
        if (state is FollowUsersListLoading) {
          return Column(
            spacing: 10,
            children: List.generate(5, (i) {
              return ListTile(
                leading: CustomShimmer(height: 40, width: 40, borderRadius: 20),
                title: CustomShimmer(height: 10, width: 10),
                subtitle: CustomShimmer(height: 10, width: 100),
              );
            }),
          );
        }
        if (state is FollowUsersListSuccess) {
          if (state.users.isEmpty) {
            return const QErrorWidget.emptyData();
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<C>().getUsers(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent) {
                  if (context.read<C>().hasMore)
                    context.read<C>().getMoreUsers();
                }
                return false;
              },
              child: ListView.separated(
                itemCount: state.users.length,
                itemBuilder: (context, index) => FollowUserListTile(
                  followUser: state.users[index],
                  showUnfollowButton: widget.showUnfollowButton,
                ),
                separatorBuilder: (context, index) => 10.vGap,
              ),
            ),
          );
        }
        if (state is FollowUsersListFailure) {
          return QErrorWidget(
            error: state.error,
            onRetry: () {
              context.read<C>().getUsers();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
