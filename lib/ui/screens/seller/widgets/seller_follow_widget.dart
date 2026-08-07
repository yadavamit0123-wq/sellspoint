import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/followers/follow_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerFollowWidget extends StatelessWidget {
  const SellerFollowWidget({super.key, required this.seller});

  final User seller;

  bool get _isSelf =>
      seller.id?.toString() == HiveUtils.getUserId();

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.enableFollowersV214) return const SizedBox.shrink();

    final followers = seller.followersCount ?? 0;
    final following = seller.followingCount ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _countChip(
            context,
            label: '${'followers'.translate(context)}${followers > 0 ? ' ($followers)' : ''}',
            onTap: () => _openList(context, tab: 0),
          ),
          _countChip(
            context,
            label: '${'following'.translate(context)}${following > 0 ? ' ($following)' : ''}',
            onTap: () => _openList(context, tab: 1),
          ),
          if (!_isSelf && HiveUtils.isUserAuthenticated())
            BlocConsumer<FollowCubit, FollowState>(
              listener: (context, state) {},
              builder: (context, state) {
                final loading =
                    state.isLoading && state.userId == seller.id;
                final isFollowing = state.userId == seller.id
                    ? state.isFollowing
                    : (seller.isFollowingSeller ?? false);
                return OutlinedButton(
                  onPressed: loading || seller.id == null
                      ? null
                      : () {
                          if (isFollowing) {
                            context
                                .read<FollowCubit>()
                                .unFollowSeller(userId: seller.id!);
                          } else {
                            context
                                .read<FollowCubit>()
                                .followSeller(userId: seller.id!);
                          }
                        },
                  child: loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: UiUtils.progress(),
                        )
                      : CustomText(
                          isFollowing
                              ? 'unfollow'.translate(context)
                              : 'follow'.translate(context),
                          fontWeight: FontWeight.w600,
                        ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _countChip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.color.secondaryColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: CustomText(label, fontSize: context.font.small),
        ),
      ),
    );
  }

  void _openList(BuildContext context, {required int tab}) {
    Navigator.pushNamed(
      context,
      Routes.followersScreen,
      arguments: {
        'user_id': seller.id,
        'title': seller.name ?? '',
        'default_tab': tab,
      },
    );
  }
}
