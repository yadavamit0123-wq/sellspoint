import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUsersCountWidget extends StatelessWidget {
  const FollowUsersCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final followersCount = context.select<FollowersListCubit, int>(
      (cubit) => switch (cubit.state) {
        final FollowUsersListSuccess s => s.totalCount,
        _ => 0,
      },
    );

    final followingCount = context.select<FollowingListCubit, int>(
      (cubit) => switch (cubit.state) {
        final FollowUsersListSuccess s => s.totalCount,
        _ => 0,
      },
    );

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.followersScreen,
                arguments: {
                  'title': 'followers'.translate(context),
                  'default_tab': 0,
                },
              );
            },
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: context.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    '${followersCount.compact} ${'followers'.translate(context)}',
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.followersScreen,
                arguments: {
                  'title': 'followers'.translate(context),
                  'default_tab': 1,
                },
              );
            },
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: context.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    '${followingCount.compact} ${'following'.translate(context)}',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
