import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/chat_tile.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/profile_avatar.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/collection_notifiers.dart';
import 'package:eClassify/utils/color_mappers/svg_color_mapper.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyingChatList extends StatefulWidget {
  const BuyingChatList({required this.selectedChats, super.key});

  final SetNotifier<int> selectedChats;

  @override
  State<BuyingChatList> createState() => _BuyingChatListState();
}

class _BuyingChatListState extends State<BuyingChatList> {
  final ValueNotifier<bool> _showLoading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _showLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height),
      child: BlocConsumer<BuyingChatListCubit, ChatListState>(
                listener: (context, state) {},
        builder: (context, state) {
          if (state is ChatListInitial) {
            context.read<BuyingChatListCubit>().getChatUsers();
          }
          if (state is ChatListFailure) {
            return QErrorWidget(
              error: state.error,
              onRetry: () {
                context.read<BuyingChatListCubit>().getChatUsers();
              },
            );
          }

          if (state is ChatListSuccess) {
            if (state.users.isEmpty) {
              return const QErrorWidget.emptyData();
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent) {
                  if (!_showLoading.value && context.read<BuyingChatListCubit>().hasMore) {
                    _showLoading.value = true;
                    context.read<BuyingChatListCubit>().getMoreChatUsers().whenComplete(() {
                      _showLoading.value = false;
                    });
                  }
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<BuyingChatListCubit>().getChatUsers();
                },
                child: Material(
                  color: Colors.transparent,
                  child: ListView.separated(
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
                        listenable: widget.selectedChats,
                        builder: (context, child) {
                          return ChatTile(
                            onTap: () {
                              if (widget.selectedChats.isNotEmpty) {
                                widget.selectedChats.toggle(chat.id);
                                return;
                              }
                              Navigator.of(context).pushNamed(
                                Routes.chatScreen,
                                arguments: {'chat_user': chat},
                              );
                            },
                            onLongPress: () {
                              if (widget.selectedChats.isEmpty) {
                                widget.selectedChats.add(chat.id);
                              }
                            },
                            title: chat.item.translatedName ?? chat.item.name!,
                            subtitle: chat.seller.name,
                            lastMessageTime: chat.lastMessageTime,
                            unreadCount: chat.unreadCount,
                            selected: widget.selectedChats.contains(chat.id),
                            leading: SizedBox.square(
                              dimension: 50,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ProfileAvatar(
                                    src: chat.item.image ?? '',
                                    size: Size.square(40),
                                  ),
                                  PositionedDirectional(
                                    end: 4,
                                    bottom: 4,
                                    child: CustomImage(
                                      src: chat.seller.profile,
                                      size: Size.square(20),
                                      radius: 10,
                                      errorImage: CircleAvatar(
                                        radius: 10,
                                        backgroundColor:
                                            context.colorScheme.primary,
                                        child: CustomImage(
                                          src: AppAssets.profile.profile,
                                          size: Size.square(10),
                                          svgColorMapper: SvgColorMapper(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }
}
