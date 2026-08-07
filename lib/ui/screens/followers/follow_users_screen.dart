import 'package:eClassify/data/cubits/followers/follow_cubit.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/ui/screens/followers/follow_user_list.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUsersScreen extends StatefulWidget {
  const FollowUsersScreen({
    super.key,
    required this.title,
    this.defaultSelectedTab = 0,
    this.userId,
  });

  final String title;
  final int defaultSelectedTab;
  final int? userId;

  static bool showFollowActions(int? userId) {
    if (userId == null) return true;
    return userId.toString() == HiveUtils.getUserId();
  }

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map? ?? {};
    final userId = args['user_id'] as int?;
    return BlurredRouter(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => FollowersListCubit(userId)),
          BlocProvider(create: (_) => FollowingListCubit(userId)),
          if (FollowUsersScreen.showFollowActions(userId))
            BlocProvider(create: (_) => FollowCubit()),
        ],
        child: FollowUsersScreen(
          userId: userId,
          title: args['title']?.toString() ?? 'followers',
          defaultSelectedTab: args['default_tab'] as int? ?? 0,
        ),
      ),
    );
  }

  @override
  State<FollowUsersScreen> createState() => _FollowUsersScreenState();
}

class _FollowUsersScreenState extends State<FollowUsersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.defaultSelectedTab.clamp(0, 1),
    );
    context.read<FollowersListCubit>().getUsers();
    context.read<FollowingListCubit>().getUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: widget.title,
        bottomHeight: 49,
        bottom: [
          TabBar(
            controller: _controller,
            indicatorColor: context.color.territoryColor,
            labelColor: context.color.territoryColor,
            unselectedLabelColor:
                context.color.textDefaultColor.withValues(alpha: 0.5),
            tabs: [
              BlocSelector<FollowersListCubit, FollowUsersListState, int>(
                selector: (state) =>
                    state is FollowUsersListSuccess ? state.totalCount : 0,
                builder: (context, count) => Tab(
                  text: count > 0
                      ? '${'followers'.translate(context)} ($count)'
                      : 'followers'.translate(context),
                ),
              ),
              BlocSelector<FollowingListCubit, FollowUsersListState, int>(
                selector: (state) =>
                    state is FollowUsersListSuccess ? state.totalCount : 0,
                builder: (context, count) => Tab(
                  text: count > 0
                      ? '${'following'.translate(context)} ($count)'
                      : 'following'.translate(context),
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          FollowUsersList<FollowersListCubit>(showUnfollowButton: false),
          FollowUsersList<FollowingListCubit>(
            showUnfollowButton:
                FollowUsersScreen.showFollowActions(widget.userId),
          ),
        ],
      ),
    );
  }
}
