import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/delete_chat_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/buying_chat_list.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/chat_delete_confirmation_dialog.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/chat_search_bar.dart';
import 'package:eClassify/ui/screens/chat/inbox/widgets/seller_item_offer_list.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/collection_notifiers.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  late TabController _tabController = TabController(length: 2, vsync: this);
  final SetNotifier<int> _selectedChats = SetNotifier<int>({});
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_tabListener);
  }

  void _tabListener() {
    if (_tabController.indexIsChanging) return;
    if (_searchQuery.isNotNullAndNotEmpty) {
      _triggerSearch();
    }
  }

  void _triggerSearch() {
    if (_tabController.index == 0) {
      context.read<SellerItemOffersCubit>().getOffers(search: _searchQuery);
    } else {
      context.read<BuyingChatListCubit>().getChatUsers(search: _searchQuery);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    _selectedChats.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => DeleteChatCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text('chats'.translate(context)),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'selling'.translate(context)),
                  Tab(text: 'buying'.translate(context)),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.blockedUserListScreen);
                  },
                  icon: Icon(AppIcons.prohibit, size: 20),
                ),
                ListenableBuilder(
                  listenable: Listenable.merge([
                    _selectedChats,
                    _tabController,
                  ]),
                  builder: (context, child) {
                    if (_selectedChats.isEmpty || _tabController.index == 0) {
                      return const SizedBox.shrink();
                    } else {
                      return child!;
                    }
                  },
                  child: IconButton(
                    onPressed: () async {
                      final shouldDelete =
                          await ChatDeleteConfirmationDialog.show(context) ??
                          false;
                      if (shouldDelete) {
                        final ids = _selectedChats.value.toList();
                        context.read<BuyingChatListCubit>().removeChatsLocally(
                          ids,
                        );
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
            body: BlocListener<DeleteChatCubit, DeleteChatState>(
              listener: (context, state) {
                if (state is DeleteChatFailure) {
                  context.read<BuyingChatListCubit>().rollbackDeletion();
                  HelperUtils.showSnackBarMessage(context, state.error);
                }
                if (state is DeleteChatSuccess) {
                  context.read<BuyingChatListCubit>().commitDeletion();
                }
              },
              child: Padding(
                padding: Constant.appContentPadding,
                child: Column(
                  spacing: 20,
                  children: [
                    ChatSearchBar(
                      onSearch: (value) {
                        _searchQuery = value;
                        _triggerSearch();
                      },
                      onClear: () {
                        _searchQuery = null;
                        context.read<SellerItemOffersCubit>().getOffers(
                          search: null,
                        );
                        context.read<BuyingChatListCubit>().getChatUsers(
                          search: null,
                        );
                      },
                    ),
                    Flexible(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          const SellerItemOfferList(),
                          BuyingChatList(selectedChats: _selectedChats),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
