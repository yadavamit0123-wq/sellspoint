import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/data/cubits/chat/delete_message_cubit.dart';
import 'package:eClassify/data/cubits/chat/load_chat_messages.dart';
import 'package:eClassify/data/cubits/chat/send_message.dart';
import 'package:eClassify/ui/screens/chat/chat_screen.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 2.14 [Routes.chatScreen] — opens legacy [ChatScreen] from [ChatUser] or legacy args.
abstract final class ChatScreenRoute {
  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
    final chatUser = args['chat_user'] as ChatUser?;
    if (chatUser != null) {
      return routeForChatUser(chatUser);
    }
    final legacy = args['legacy'] as Map<String, dynamic>?;
    if (legacy != null) {
      return routeForLegacy(legacy);
    }
    return BlurredRouter(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Chat unavailable')),
      ),
    );
  }

  static Route routeForChatUser(ChatUser chatedUser) {
    final myId = HiveUtils.getUserId();
    final isBuyerList = chatedUser.buyerId?.toString() == myId;

    final peerId = isBuyerList
        ? chatedUser.sellerId.toString()
        : chatedUser.buyerId.toString();
    final peerName = isBuyerList
        ? (chatedUser.seller?.name ?? '')
        : (chatedUser.buyer?.name ?? '');
    final peerProfile = isBuyerList
        ? (chatedUser.seller?.profile ?? '')
        : (chatedUser.buyer?.profile ?? '');

    currentlyChatingWith = peerId;
    currentlyChatItemId = chatedUser.itemId.toString();

    return BlurredRouter(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SendMessageCubit()),
            BlocProvider(create: (_) => LoadChatMessagesCubit()),
            BlocProvider(create: (_) => DeleteMessageCubit()),
          ],
          child: ChatScreen(
            profilePicture: peerProfile,
            userName: peerName,
            userId: peerId,
            itemImage: chatedUser.item?.image ?? '',
            itemTitle: chatedUser.item?.name ?? '',
            itemId: chatedUser.itemId.toString(),
            date: chatedUser.createdAt ?? '',
            itemOfferId: chatedUser.id ?? 0,
            itemPrice: chatedUser.item?.price ?? 0,
            itemOfferPrice: chatedUser.amount,
            status: chatedUser.item?.status,
            buyerId: chatedUser.buyerId?.toString(),
            isPurchased: chatedUser.item?.isPurchased ?? 0,
            alreadyReview: chatedUser.item?.review == null ? false : true,
            isFromBuyerList: isBuyerList,
          ),
        );
      },
    );
  }

  static Route routeForLegacy(Map<String, dynamic> l) {
    final userId = l['userId']?.toString() ?? '';
    final itemId = l['itemId']?.toString() ?? '';
    currentlyChatingWith = userId;
    currentlyChatItemId = itemId;

    return BlurredRouter(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SendMessageCubit()),
            BlocProvider(create: (_) => LoadChatMessagesCubit()),
            BlocProvider(create: (_) => DeleteMessageCubit()),
          ],
          child: ChatScreen(
            profilePicture: l['profilePicture']?.toString() ?? '',
            userName: l['userName']?.toString() ?? '',
            itemImage: l['itemImage']?.toString() ?? '',
            itemTitle: l['itemTitle']?.toString() ?? '',
            userId: userId,
            itemId: itemId,
            date: l['date']?.toString() ?? '',
            from: l['from']?.toString(),
            itemOfferId: l['itemOfferId'] as int? ?? 0,
            itemPrice: (l['itemPrice'] as num?)?.toDouble() ?? 0,
            itemOfferPrice: (l['itemOfferPrice'] as num?)?.toDouble(),
            status: l['status']?.toString(),
            buyerId: l['buyerId']?.toString(),
            isPurchased: l['isPurchased'] as int? ?? 0,
            alreadyReview: l['alreadyReview'] as bool? ?? false,
            isFromBuyerList: l['isFromBuyerList'] as bool? ?? true,
          ),
        );
      },
    );
  }
}
