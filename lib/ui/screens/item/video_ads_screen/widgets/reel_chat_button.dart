import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/chat/make_an_offer_item_cubit.dart';
import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/utils/chat_navigation.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReelChatButton extends StatelessWidget {
  const ReelChatButton({required this.ad, super.key});

  final VideoAd ad;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MakeAnOfferItemCubit(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<MakeAnOfferItemCubit, MakeAnOfferItemState>(
            listener: (context, state) async {
              if (state is MakeAnOfferItemSuccess) {
                ChatNavigation.syncBuyerChatListAfterMakeOffer(
                  context,
                  state.data,
                );
                await ChatNavigation.openChatUser(
                  context,
                  ChatNavigation.chatUserFromMakeOfferPayload(state.data),
                  refreshBuyerChatListOnPop:
                      AppConfig.enableReelFeedBuyerChatReturnRefreshV214,
                );
              } else if (state is MakeAnOfferItemFailure) {
                HelperUtils.showSnackBarMessage(
                  context,
                  state.errorMessage,
                  type: MessageType.error,
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is MakeAnOfferItemInProgress;

              return IconButton(
                tooltip: 'reelFeedContactSeller'.translate(context),
                onPressed: () {
                  if (isLoading) return;
                  UiUtils.checkUser(
                    onNotGuest: () async {
                      final item = ad.item;
                      final itemId = item.id;
                      if (itemId == null) return;

                      final refreshOnPop =
                          AppConfig.enableReelFeedBuyerChatReturnRefreshV214;
                      if (await ChatNavigation.openBuyerChatForListingItem(
                        context,
                        item,
                        refreshBuyerChatListOnPop: refreshOnPop,
                      )) {
                        return;
                      }

                      if (!context.mounted) return;
                      context.read<MakeAnOfferItemCubit>().makeAnOfferItem(
                            id: itemId,
                            from: 'reel',
                          );
                    },
                    context: context,
                  );
                },
                icon: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.chat_bubble_outline, color: Colors.white),
              );
            },
          );
        },
      ),
    );
  }
}
