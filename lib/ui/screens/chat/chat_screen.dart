import 'package:eClassify/data/cubits/add_item_review_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_message_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_session_cubit.dart';
import 'package:eClassify/data/cubits/chat/load_chat_cubit.dart';
import 'package:eClassify/data/cubits/chat/user_block_cubit.dart';
import 'package:eClassify/data/cubits/item/item_status_cubit.dart';
import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/model/chat/chat_message.dart';
import 'package:eClassify/data/services/chat/chat_event_bus.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_date_chip.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_listeners_scope.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_message_widget.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_screen_app_bar.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_shimmer_widget.dart';
import 'package:eClassify/ui/screens/chat/widgets/dialogs/block_user_dialog.dart';
import 'package:eClassify/ui/screens/chat/widgets/dialogs/delete_messages_dialog.dart';
import 'package:eClassify/ui/screens/chat/widgets/dialogs/rating_dialog.dart';
import 'package:eClassify/ui/screens/chat/widgets/item_offer_widget.dart';
import 'package:eClassify/ui/screens/chat/widgets/message_composing_widgets/message_composer.dart';
import 'package:eClassify/ui/screens/chat/widgets/unread_messages_indicator.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/collection_notifiers.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/data/cubits/chat/delete_chat_cubit.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({this.chat, this.isSeller, this.id, super.key});

  final Chat? chat;

  // Determine whether the current user is seller or buyer
  final bool? isSeller;

  final int? id;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    final chat = args['chat_user'] as Chat?;
    final id = args['id'] as int?;

    if (chat == null && id == null) {
      throw ArgumentError('Both chat and id cannot be null');
    }

    final myId = int.parse(HiveUtils.getUserId()!);
    final isSeller = chat != null ? chat.sellerId == myId : false;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => ChatScreen(chat: chat, isSeller: isSeller, id: id),
    );
  }

  Widget buildChatContent(Chat chatVal) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ChatSessionCubit(chatVal, isCurrentUserSeller: isSeller ?? false),
        ),
        BlocProvider(create: (_) => ChatMessageCubit(chatVal.id)),
        BlocProvider(create: (_) => UserBlockCubit()),
        BlocProvider(create: (_) => AddItemReviewCubit()),
        BlocProvider(create: (_) => ItemStatusCubit()),
        BlocProvider(create: (_) => DeleteChatCubit()),
      ],
      child: _ChatScreenContent(chat: chatVal, isSeller: isSeller ?? false),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (chat != null) {
      return buildChatContent(chat!);
    }

    return BlocProvider(
      create: (_) => LoadChatCubit()..loadChat(itemOfferId: id!),
      child: BlocBuilder<LoadChatCubit, LoadChatState>(
        builder: (context, state) {
          if (state is LoadChatInProgress) {
            return const Center(child: LoadingIndicator());
          } else if (state is LoadChatFailure) {
            return QErrorWidget(
              error: state.error,
              onRetry: () {
                context.read<LoadChatCubit>().loadChat(itemOfferId: id!);
              },
            );
          } else if (state is LoadChatSuccess) {
            return buildChatContent(state.chat);
          }
          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }
}

class _ChatScreenContent extends StatefulWidget {
  const _ChatScreenContent({required this.chat, required this.isSeller});

  final Chat chat;
  final bool isSeller;

  @override
  State<_ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent>
    with RouteAware {
  late int myId = int.parse(HiveUtils.getUserId()!);
  late final SetNotifier<int> _selectionNotifier = SetNotifier({});
  int? _unreadMessageId;
  bool _hasCalculatedUnreadId = false;

  ChatMessageCubit get messageCubit => context.read<ChatMessageCubit>();

  ChatUser get receiver =>
      widget.isSeller ? widget.chat.buyer : widget.chat.seller;

  @override
  void initState() {
    super.initState();
    context.read<ChatMessageCubit>().getMessages();
    context.read<ItemStatusCubit>().getItemStatus(itemId: widget.chat.item.id!);
    ChatEventBus.instance.emit(
      ChatEvent.read(widget.chat.id, itemId: widget.chat.itemId),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Constant.routeObserver.subscribe(this, ModalRoute.of(context)!);

      if (widget.chat.item.status == Constant.statusSoldOut &&
          widget.chat.item.isPurchased == 1 &&
          !(widget.chat.item.hasReviewed ?? false)) {
        RatingDialog.show(context, itemId: widget.chat.item.id!);
      }
    });
  }

  @override
  void dispose() {
    _selectionNotifier.dispose();
    Constant.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Called when this route has been pushed.
    AppSession.activeChatId = widget.chat.id;
    Log.debug('Pushed Chat Route');
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and this route shows up.
    AppSession.activeChatId = widget.chat.id;
  }

  @override
  void didPushNext() {
    // Called when a new route has been pushed, and this route is no longer visible.
    AppSession.activeChatId = null;
  }

  @override
  void didPop() {
    // Called when this route has been popped off.
    AppSession.activeChatId = null;
  }

  void _handleOnTap(ChatMessage message) {
    if (_selectionNotifier.isNotEmpty) {
      if (message.id != null && message.senderId == myId) {
        _selectionNotifier.toggle(message.id!);
      }
    }
  }

  void _handleOnLongPress(ChatMessage message) {
    if (_selectionNotifier.isEmpty) {
      if (message.id != null && message.senderId == myId) {
        _selectionNotifier.add(message.id!);
      }
    }
  }

  Future<void> _onDelete() async {
    final ids = _selectionNotifier.value.toList();
    final confirmed =
        await DeleteMessagesDialog.show(context, count: ids.length) ?? false;
    if (confirmed) {
      context.read<ChatMessageCubit>().deleteMessages(widget.chat.id, ids);
      _selectionNotifier.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChatListenersScope(
      child: Scaffold(
        appBar: ChatScreenAppBar(
          user: receiver,
          item: widget.chat.item,
          chatId: widget.chat.id,
          selectionNotifier: _selectionNotifier,
          onDelete: _onDelete,
        ),
        bottomNavigationBar: _ChatBottomBar(
          receiver: receiver,
          status: widget.chat.item.status,
        ),
        body: Padding(
          padding: Constant.appContentPadding,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.isNearBottom && messageCubit.hasMore) {
                messageCubit.getMessages();
              }
              return false;
            },
            child: Column(
              spacing: 20,
              children: [
                if (widget.chat.formattedAmount.isNotNullAndNotEmpty)
                  Align(
                    alignment: widget.chat.buyerId == myId
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: ItemOfferWidget(
                      offerAmount: widget.chat.formattedAmount!,
                      isMe: widget.chat.buyerId == myId,
                    ),
                  ),
                Expanded(
                  child: BlocConsumer<ChatMessageCubit, ChatMessageState>(
                    listener: (context, state) {
                      if (!_hasCalculatedUnreadId &&
                          state.messages.isNotEmpty) {
                        if (widget.chat.unreadCount > 0) {
                          final targetIndex = widget.chat.unreadCount - 1;
                          if (targetIndex < state.messages.length) {
                            _unreadMessageId = state.messages[targetIndex].id;
                            _hasCalculatedUnreadId = true;
                          }
                        } else {
                          _hasCalculatedUnreadId = true;
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state.isLoading && state.messages.isEmpty) {
                        return SingleChildScrollView(
                          reverse: true,
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ChatShimmerWidget(seed: widget.chat.id),
                        );
                      }

                      if (state.messages.isNotEmpty) {
                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 20),
                          physics: const ClampingScrollPhysics(),
                          itemCount: state.messages.length + 1,
                          reverse: true,
                          itemBuilder: (context, index) {
                            if (index == state.messages.length) {
                              if (state.isLoading) {
                                return const ChatShimmerWidget(count: 4);
                              }
                              return const SizedBox.shrink();
                            }
                            final message = state.messages[index];
                            return ListenableBuilder(
                              listenable: _selectionNotifier,
                              builder: (context, _) {
                                return ChatMessageWidget(
                                  key: ValueKey(message.localId ?? message.id),
                                  message: message,
                                  isMe: message.senderId == myId,
                                  isSelected: _selectionNotifier.contains(
                                    message.id ?? -1,
                                  ),
                                  onTap: () => _handleOnTap(message),
                                  onLongPress: () =>
                                      _handleOnLongPress(message),
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            //The reason we check with index == (length - 1) is
                            //because separatorBuilder is always
                            //called in between the items
                            //Hence, it will always have one less index than the itemBuilder
                            if (index == state.messages.length - 1) {
                              final separator = ChatDateChip(
                                date: state.messages[index].dateTime,
                              );

                              if (state.messages[index].id != null &&
                                  state.messages[index].id ==
                                      _unreadMessageId) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const UnreadMessagesIndicator(),
                                    separator,
                                  ],
                                );
                              }
                              return separator;
                            }
                            final current = state.messages[index];
                            final previous = state.messages[index + 1];

                            Widget separator = 10.vGap;

                            if (!DateUtils.isSameDay(
                              current.dateTime,
                              previous.dateTime,
                            )) {
                              separator = ChatDateChip(date: current.dateTime);
                            }

                            if (current.id != null &&
                                current.id == _unreadMessageId) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const UnreadMessagesIndicator(),
                                  separator,
                                ],
                              );
                            }

                            return separator;
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBottomBar extends StatelessWidget {
  const _ChatBottomBar({required this.receiver, required this.status});

  final ChatUser receiver;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final (isBlockedByMe, isBlockedByOther) = context
        .select<ChatSessionCubit, (bool, bool)>(
          (cubit) => (cubit.isBlockedByMe, cubit.isBlockedByOther),
        );

    final status = context.select<ItemStatusCubit, ItemStatus>(
      (c) => switch (c.state) {
        ItemStatusSuccess(status: final status) => status,
        _ => ItemStatus.parse(this.status ?? ''),
      },
    );

    final _isChatDisabled =
        !(status == ItemStatus.approved || status == ItemStatus.unknown);

    final child = switch ((_isChatDisabled, isBlockedByMe, isBlockedByOther)) {
      (_, true, _) => GestureDetector(
        onTap: () async {
          final shouldUnblock =
              await BlockUserDialog.show(
                context,
                user: receiver,
                isUserBlocked: isBlockedByMe,
              ) ??
              false;

          if (shouldUnblock) {
            context.read<UserBlockCubit>().toggleBlockUser(
              userId: receiver.id,
              isUserBlocked: isBlockedByMe,
            );
          }
        },
        child: Text(
          'youBlockedThisContact'.translate(context),
          textAlign: TextAlign.center,
        ),
      ),
      (_, _, true) => Text(
        'youCanNoLongerSendMessagesToThisContact'.translate(context),
        textAlign: TextAlign.center,
      ),
      (true, false, false) => Text(
        '${'thisItemIs'.translate(context)} ${status.name.translate(context)}',
        textAlign: TextAlign.center,
      ),
      (false, false, false) => const MessageComposer(),
    };

    return ColoredBox(
      color: context.colorScheme.secondary,
      child: Padding(
        padding: Constant.appContentPadding.copyWith(
          bottom:
              MediaQuery.paddingOf(context).bottom +
              MediaQuery.viewInsetsOf(context).bottom +
              10,
        ),
        child: child,
      ),
    );
  }
}
