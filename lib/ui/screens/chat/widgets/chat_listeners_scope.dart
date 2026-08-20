import 'package:eClassify/data/cubits/add_item_review_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_message_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_session_cubit.dart';
import 'package:eClassify/data/cubits/chat/user_block_cubit.dart';
import 'package:eClassify/data/cubits/notification/notification_event_cubit.dart';
import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/model/chat/chat_message.dart';
import 'package:eClassify/data/services/chat/chat_event_bus.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/data/cubits/chat/delete_chat_cubit.dart';

// These listeners emit events to ChatEventBus to sync data across different
// screens and cubits.
class ChatListenersScope extends StatelessWidget {
  const ChatListenersScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final chatSession = context.read<ChatSessionCubit>().state;
    final chat = chatSession.chat;
    return MultiBlocListener(
      listeners: [
        BlocListener<NotificationEventCubit, NotificationEventState>(
          listener: (context, state) {
            if (state case final ForegroundNotificationReceived notification
                when notification.type == NotificationType.chat) {
              final payload = notification.remoteMessage?.data;
              if (payload == null) return;

              final chatIdFromNotification = int.tryParse(
                payload['item_offer_id'].toString(),
              );

              if (chatIdFromNotification == chat.id) {
                final message = ChatMessageFactory.fromNotification(payload);
                context.read<ChatMessageCubit>().addIncomingMessage(message);
              }
            }
          },
        ),

        BlocListener<UserBlockCubit, UserBlockState>(
          listener: (context, state) {
            if (state is UserBlockLoading) {
              LoadingOverlay.show(context);
            }
            if (state is UserBlockFailure) {
              LoadingOverlay.hide();
              Log.error(state.message, null, null);
            }
            if (state is UserBlockSuccess) {
              LoadingOverlay.hide();
              final label = state.isBlocked
                  ? 'userBlockedSuccessfully'
                  : 'userUnblockedSuccessfully';
              HelperUtils.showSnackBarMessage(
                context,
                label.translate(context),
              );
              ChatEventBus.instance.emit(
                ChatEvent.blocked(
                  userId: state.userId,
                  isBlockedByMe: state.isBlocked,
                ),
              );
            }
          },
        ),
        BlocListener<AddItemReviewCubit, AddItemReviewState>(
          listener: (context, state) {
            if (state is AddItemReviewInProgress) {
              LoadingOverlay.show(context);
            }
            if (state is AddItemReviewFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.error.toString());
            }
            if (state is AddItemReviewSuccess) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.message);
              final sessionCubit = context.read<ChatSessionCubit>();

              ChatEventBus.instance.emit(
                ChatEvent.reviewed(sessionCubit.state.chat.itemId),
              );
            }
          },
        ),
        BlocListener<ChatMessageCubit, ChatMessageState>(
          listener: (context, state) {
            // TODO(I): Refactor this to avoid using magic strings
            if (state.error != null &&
                state.error.toString() == 'blocked_by_other_user') {
              final session = context.read<ChatSessionCubit>().state;
              ChatEventBus.instance.emit(
                ChatEvent.blocked(
                  userId: session.isCurrentUserSeller
                      ? session.chat.buyerId
                      : session.chat.sellerId,
                  isBlockedByOther: true,
                ),
              );
            }
          },
        ),
        BlocListener<DeleteChatCubit, DeleteChatState>(
          listener: (context, state) {
            if (state is DeleteChatInProgress) {
              LoadingOverlay.show(context);
            } else if (state is DeleteChatFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.error);
            } else if (state is DeleteChatSuccess) {
              LoadingOverlay.hide();
              final chatSession = context.read<ChatSessionCubit>().state;
              ChatEventBus.instance.emit(
                ChatEvent.deleted(
                  itemOfferIds: state.itemOfferIds,
                  itemId: chatSession.chat.itemId,
                ),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
        ),
      ],
      child: child,
    );
  }
}
