import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/utils/app_icons.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({required this.item, super.key});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final bool isLike = context.select<FavoriteCubit, bool>(
      (cubit) => cubit.isItemFavorite(item.id!),
    );

    return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
      listenWhen: (previous, current) => current.itemId == item.id!,
      listener: (context, state) {
        if (state is UpdateFavoriteSuccess) {
          if (state.wasProcess) {
            context.read<FavoriteCubit>().addFavoriteitem(state.item);
          } else {
            context.read<FavoriteCubit>().removeFavoriteItem(state.item);
          }
        }
      },
      buildWhen: (previous, current) => current.itemId == item.id!,
      builder: (context, state) {
        final isLoading = state is UpdateFavoriteInProgress;

        return IconButton.filled(
          style: IconButton.styleFrom(
            elevation: 1,
            foregroundColor: context.colorScheme.primary,
            backgroundColor: context.colorScheme.secondary,
            iconSize: 20,
          ),
          onPressed: () {
            UiUtils.checkUser(
              onNotGuest: () {
                context.read<UpdateFavoriteCubit>().setFavoriteItem(
                  item: item,
                  type: isLike ? 0 : 1,
                );
              },
              context: context,
            );
          },
          icon: switch (isLoading) {
            true => UiUtils.progress(height: 28, width: 28),
            false => Icon(
              isLike ? AppIcons.heartFill : AppIcons.heart,
              color: context.colorScheme.primary,
            ),
          },
        );
      },
    );
  }
}
