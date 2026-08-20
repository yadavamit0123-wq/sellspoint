import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/delete_chat_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/model/chat/item_offer.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/chat_delete_confirmation_dialog.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/chat_search_bar.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/chat_tile.dart';
import 'package:eClassify/ui/screens/widgets/profile_avatar.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/collection_notifiers.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerItemChatScreen extends StatefulWidget {
  const SellerItemChatScreen({
    required this.itemId,
    required this.offer,
    this.itemOfferId,
    super.key,
  });

  final int itemId;
  final ItemOffer? offer;
  final int? itemOfferId;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    final itemId = args['item_id'] as int;
    final offer = args['offer'] as ItemOffer?;
    final itemOfferId = args['item_offer_id'] as int?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SellerChatListCubit(itemId)),
          BlocProvider(create: (_) => DeleteChatCubit()),
        ],
        child: SellerItemChatScreen(
          itemId: itemId,
          offer: offer,
          itemOfferId: itemOfferId,
        ),
      ),
    );
  }

  @override
  State<SellerItemChatScreen> createState() => _SellerItemChatScreenState();
}

class _SellerItemChatScreenState extends State<SellerItemChatScreen> {
  final ValueNotifier<bool> _showLoading = ValueNotifier<bool>(false);
  final SetNotifier<int> _selectedChats = SetNotifier({});
  bool _isFirstLoad = true;

  ItemModel? item;

  @override
  void initState() {
    super.initState();
    context.read<SellerChatListCubit>().getChatUsers();
    context.read<SellerItemOffersCubit>().clearOfferUnreadCount(widget.itemId);
  }

  @override
  void dispose() {
    _selectedChats.dispose();
    _showLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chats'.translate(context)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.blockedUserListScreen);
            },
            icon: Icon(AppIcons.prohibit, size: 20),
          ),
          ListenableBuilder(
            listenable: _selectedChats,
            builder: (context, child) {
              if (_selectedChats.isEmpty) {
                return const SizedBox.shrink();
              } else {
                return child!;
              }
            },
            child: IconButton(
              onPressed: () async {
                final shouldDelete =
                    await ChatDeleteConfirmationDialog.show(context) ?? false;
                if (shouldDelete) {
                  final ids = _selectedChats.value.toList();
                  context.read<SellerChatListCubit>().removeChatsLocally(ids);
                  context.read<DeleteChatCubit>().deleteChats(
                    itemOfferIds: ids,
                  );
                  _selectedChats.clear();
                }
              },
              icon: Icon(AppIcons.trash),
            ),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SellerItemOffersCubit, SellerItemOffersState>(
            listenWhen: (prev, curr) =>
                curr is SellerItemOffersSuccess &&
                curr.lastUpdatedMessage?.itemId == widget.itemId,
            listener: (context, state) {
              if (state case final SellerItemOffersSuccess s
                  when s.lastUpdatedMessage != null) {
                context.read<SellerChatListCubit>().updateChat(
                  state.lastUpdatedMessage!,
                );
              }
            },
          ),
          BlocListener<DeleteChatCubit, DeleteChatState>(
            listener: (context, state) {
              if (state is DeleteChatFailure) {
                context.read<SellerChatListCubit>().rollbackDeletion();
                HelperUtils.showSnackBarMessage(context, state.error);
              }
              if (state is DeleteChatSuccess) {
                context.read<SellerChatListCubit>().commitDeletion();
                context.read<SellerItemOffersCubit>().removeUsers(
                  widget.itemId,
                  state.itemOfferIds,
                );
              }
            },
          ),
        ],
        child: Column(
          children: [
            BlocBuilder<SellerChatListCubit, ChatListState>(
              buildWhen: (prev, curr) =>
                  curr is ChatListSuccess || prev is ChatListInitial,
              builder: (context, state) {
                if (state is ChatListLoading) {
                  return ListTile(
                    tileColor: context.colorScheme.secondary,
                    leading: CustomShimmer(
                      height: 50,
                      width: 50,
                      borderRadius: 25,
                    ),
                    title: CustomShimmer(height: 16, width: 100),
                    subtitle: CustomShimmer(height: 14, width: 50),
                  );
                }
                if (state is ChatListSuccess) {
                  item ??= state.item;
                  return _ItemDetailsHeader(
                    item: item!,
                    unreadCount: widget.offer?.unreadCount ?? state.unreadCount,
                    buyerCount: widget.offer?.totalUsers ?? state.users.length,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Padding(
              padding: Constant.appContentPadding,
              child: ChatSearchBar(
                onSearch: (value) {
                  context.read<SellerChatListCubit>().getChatUsers(
                    search: value,
                  );
                },
                onClear: () {
                  context.read<SellerChatListCubit>().getChatUsers(
                    search: null,
                  );
                },
              ),
            ),
            20.vGap,
            Expanded(
              child: BlocConsumer<SellerChatListCubit, ChatListState>(
                listener: (context, state) {
                  if (state is ChatListSuccess) {
                    if (_isFirstLoad) {
                      _isFirstLoad = false;
                      if (widget.itemOfferId != null) {
                        final index = state.users.indexWhere(
                          (element) => element.id == widget.itemOfferId,
                        );
                        if (index != -1) {
                          final chat = state.users[index];
                          Navigator.of(context).pushNamed(
                            Routes.chatScreen,
                            arguments: {'chat_user': chat, 'is_seller': true},
                          );
                        }
                      }
                    }
                  }
                },
                builder: (context, state) {
                  if (state is ChatListFailure) {
                    return QErrorWidget(
                      error: state.error,
                      onRetry: () {
                        context.read<SellerChatListCubit>().getChatUsers();
                      },
                    );
                  }

                  if (state is ChatListSuccess) {
                    if (state.users.isEmpty) {
                      return const QErrorWidget.emptyData();
                    }

                    return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.isNearBottom && !_showLoading.value) {
                            if (context.read<SellerChatListCubit>().hasMore) {
                              _showLoading.value = true;
                              context
                                  .read<SellerChatListCubit>()
                                  .getMoreChatUsers()
                                  .whenComplete(() {
                                _showLoading.value = false;
                              });
                            }
                          }
                          return false;
                        },
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<SellerChatListCubit>().getChatUsers();
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: Constant.horizontalPadding,
                            ),
                            itemBuilder: (context, index) {
                              if (index == state.users.length) {
                                return ValueListenableBuilder(
                                  valueListenable: _showLoading,
                                  builder: (context, value, child) {
                                    return value
                                        ? UiUtils.progress()
                                        : const SizedBox.shrink();
                                  },
                                );
                              }
                              final chat = state.users[index];

                              return ListenableBuilder(
                                listenable: _selectedChats,
                                builder: (context, child) {
                                  return ChatTile(
                                    onTap: () {
                                      if (_selectedChats.isNotEmpty) {
                                        _selectedChats.toggle(chat.id);
                                        return;
                                      }

                                      Navigator.of(context).pushNamed(
                                        Routes.chatScreen,
                                        arguments: {
                                          'chat_user': chat,
                                          'is_seller': true,
                                        },
                                      );
                                    },
                                    onLongPress: () {
                                      if (_selectedChats.isEmpty) {
                                        _selectedChats.add(chat.id);
                                      }
                                    },
                                    title: chat.buyer.name,
                                    subtitle: chat.lastChatMessage,
                                    leading: ProfileAvatar(
                                      src: chat.buyer.profile ?? '',
                                      size: Size.square(40),
                                      tag: chat.id.toString(),
                                    ),
                                    lastMessageTime: chat.lastMessageTime,
                                    unreadCount: chat.unreadCount,
                                    selected: _selectedChats.contains(chat.id),
                                  );
                                },
                              );
                            },
                            separatorBuilder: (context, index) => 10.vGap,
                            itemCount: state.users.length + 1,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: Constant.appContentPadding,
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: ListTile(
                          leading: CustomShimmer(
                            height: 40,
                            width: 40,
                            borderRadius: 20,
                          ),
                          title: CustomShimmer(height: 10, borderRadius: 10),
                          subtitle: CustomShimmer(height: 10, borderRadius: 10),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDetailsHeader extends StatelessWidget {
  const _ItemDetailsHeader({
    required this.item,
    required this.unreadCount,
    required this.buyerCount,
  });

  final ItemModel item;
  final int unreadCount;
  final int? buyerCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.adDetailsScreen,
          arguments: {'slug': item.slug, 'is_my_ad': true},
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.secondary,
          border: Border(
            top: BorderSide(color: context.colorScheme.outlineVariant),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            spacing: 10,
            children: [
              ProfileAvatar(src: item.image!, size: Size.square(50)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.translatedName ?? item.name!,
                      style: context.titleSmall,
                    ),
                    if (buyerCount != null || unreadCount > 0)
                      RichText(
                        text: TextSpan(
                          children: [
                            if (buyerCount != null)
                              TextSpan(
                                text:
                                    '${buyerCount} ${'buyers'.translate(context)}',
                                style: context.labelMedium.withColor(
                                  context.mutedColor,
                                ),
                              ),
                            if (unreadCount > 0) ...[
                              WidgetSpan(
                                alignment: PlaceholderAlignment.aboveBaseline,
                                baseline: TextBaseline.alphabetic,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3.0,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: context.mutedColor,
                                    radius: 2,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${unreadCount} ${'unread'.translate(context)}',
                                style: context.labelMedium.withColor(
                                  context.mutedColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                item.formattedAmount ?? '',
                style: context.titleMedium.copyWith(
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
