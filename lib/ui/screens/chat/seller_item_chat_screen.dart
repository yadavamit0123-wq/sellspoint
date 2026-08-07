import 'package:eClassify/data/cubits/chat/get_seller_chat_users_cubit.dart';
import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/ui/screens/chat/chatTile.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 2.14 [Routes.sellerItemChatScreen] — chats for one listing (seller view).
class SellerItemChatScreen extends StatefulWidget {
  const SellerItemChatScreen({
    super.key,
    required this.itemId,
    this.itemName,
  });

  final int itemId;
  final String? itemName;

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map? ?? {};
    final itemId = args['item_id'] as int? ?? args['itemId'] as int? ?? 0;
    return BlurredRouter(
      builder: (_) => SellerItemChatScreen(
        itemId: itemId,
        itemName: args['item_name'] as String? ?? args['itemName'] as String?,
      ),
    );
  }

  @override
  State<SellerItemChatScreen> createState() => _SellerItemChatScreenState();
}

class _SellerItemChatScreenState extends State<SellerItemChatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetSellerChatListCubit>().fetch();
  }

  List<ChatUser> _filter(List<ChatUser> all) {
    return all.where((u) => u.itemId == widget.itemId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: widget.itemName ?? 'chat'.translate(context),
      ),
      body: BlocBuilder<GetSellerChatListCubit, GetSellerChatListState>(
        builder: (context, state) {
          if (state is GetSellerChatListInProgress) {
            return UiUtils.progress();
          }
          if (state is GetSellerChatListSuccess) {
            final chats = _filter(state.chatedUserList);
            if (chats.isEmpty) {
              return NoDataFound(onTap: () {
                context.read<GetSellerChatListCubit>().fetch();
              });
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chatedUser = chats[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChatTile(
                    id: chatedUser.buyerId.toString(),
                    itemId: chatedUser.itemId.toString(),
                    isBuyerList: false,
                    profilePicture: chatedUser.buyer?.profile ?? '',
                    userName: chatedUser.buyer?.name ?? '',
                    itemPicture: chatedUser.item?.image ?? '',
                    itemName: chatedUser.item?.name ?? '',
                    pendingMessageCount: '0',
                    date: chatedUser.createdAt ?? '',
                    itemOfferId: chatedUser.id ?? 0,
                    itemPrice: chatedUser.item?.price ?? 0,
                    itemAmount: chatedUser.amount,
                    status: chatedUser.item?.status,
                    buyerId: chatedUser.buyerId?.toString(),
                    isPurchased: chatedUser.item?.isPurchased ?? 0,
                    alreadyReview: chatedUser.item?.review != null,
                    unreadCount: chatedUser.unreadCount,
                  ),
                );
              },
            );
          }
          return NoDataFound(onTap: () {});
        },
      ),
    );
  }
}
