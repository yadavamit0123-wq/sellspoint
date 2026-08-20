import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/chat_session_cubit.dart';
import 'package:eClassify/data/cubits/chat/delete_chat_cubit.dart';
import 'package:eClassify/data/cubits/chat/user_block_cubit.dart';
import 'package:eClassify/data/cubits/item/item_status_cubit.dart';
import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/chat_delete_confirmation_dialog.dart';
import 'package:eClassify/ui/screens/chat/widgets/dialogs/block_user_dialog.dart';
import 'package:eClassify/ui/screens/widgets/profile_avatar.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/collection_notifiers.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatScreenAppBar({
    required this.user,
    required this.item,
    required this.selectionNotifier,
    required this.chatId,
    this.onDelete,
    this.isCurrentUserSeller = false,
    super.key,
  });

  final ChatUser user;
  final ItemModel item;
  final int chatId;
  final SetNotifier<int> selectionNotifier;
  final VoidCallback? onDelete;
  final bool isCurrentUserSeller;

  Future<void> _handleBlockUser(
    BuildContext context,
    bool isUserBlocked,
  ) async {
    final shouldProceed =
        await BlockUserDialog.show(
          context,
          user: user,
          isUserBlocked: isUserBlocked,
        ) ??
        false;

    if (shouldProceed && context.mounted) {
      context.read<UserBlockCubit>().toggleBlockUser(
        userId: user.id,
        isUserBlocked: isUserBlocked,
      );
    }
  }

  Future<void> _handleDeleteChat(BuildContext context) async {
    final confirmed = await ChatDeleteConfirmationDialog.show(context) ?? false;
    if (confirmed && context.mounted) {
      context.read<DeleteChatCubit>().deleteChats(itemOfferIds: [chatId]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(Routes.sellerProfileScreen, arguments: user.id);
        },
        child: Row(
          spacing: 20,
          children: [
            ProfileAvatar(src: user.profile ?? '', size: Size.square(40)),
            Expanded(child: Text(user.name, style: context.titleMedium)),
          ],
        ),
      ),
      actions: [
        PopupMenuButton(
          icon: Icon(AppIcons.dotsThreeVertical),
          itemBuilder: (context) {
            final isUserBlocked = context
                .read<ChatSessionCubit>()
                .isBlockedByMe;
            return [
              PopupMenuItem(
                onTap: () => _handleBlockUser(context, isUserBlocked),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(AppIcons.prohibit, size: 16),
                    Text(
                      isUserBlocked
                          ? "unBlockLbl".translate(context)
                          : "blockLbl".translate(context),
                    ),
                  ],
                ),
              ),

              PopupMenuItem(
                onTap: () => _handleDeleteChat(context),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      AppIcons.trash,
                      size: 16,
                      color: context.colorScheme.error,
                    ),
                    Text(
                      "deleteChatTitle".translate(context),
                      style: context.bodyMedium.withColor(
                        context.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
        ListenableBuilder(
          listenable: selectionNotifier,
          builder: (context, _) {
            if (selectionNotifier.isNotEmpty) {
              return IconButton(
                onPressed: onDelete,
                icon: Icon(AppIcons.trash),
                tooltip: "delete".translate(context),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: _ItemBottomBar(
          item: item,
          isCurrentUserSeller: isCurrentUserSeller,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * 2);
}

class _ItemBottomBar extends StatelessWidget {
  const _ItemBottomBar({required this.isCurrentUserSeller, required this.item});

  final ItemModel item;
  final bool isCurrentUserSeller;

  @override
  Widget build(BuildContext context) {
    final status = context.select<ItemStatusCubit, ItemStatus>(
      (c) => switch (c.state) {
        ItemStatusSuccess(status: final status) => status,
        _ => ItemStatus.parse(item.status ?? ''),
      },
    );

    return GestureDetector(
      onTap: () {
        if (status == ItemStatus.approved || isCurrentUserSeller) {
          Navigator.of(context).pushNamed(
            Routes.adDetailsScreen,
            arguments: {'item_id': item.id, 'is_my_ad': isCurrentUserSeller},
          );
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.theme.dividerColor)),
        ),
        child: Padding(
          padding: Constant.appContentPadding.copyWith(bottom: 8, top: 8),
          child: Row(
            spacing: 20,
            children: [
              ProfileAvatar(src: item.image!, size: Size.square(40)),
              Expanded(
                child: Text(
                  item.translatedName ?? item.name!,
                  style: context.titleMedium,
                  maxLines: 2,
                ),
              ),
              if (item.formattedAmount.isNotNullAndNotEmpty)
                Text(
                  item.formattedAmount!,
                  style: context.titleSmall.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
