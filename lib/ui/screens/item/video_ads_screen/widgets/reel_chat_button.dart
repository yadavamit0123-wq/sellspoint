import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/make_an_offer_item_cubit.dart';
import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
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
            listener: (context, state) {
              if (state is MakeAnOfferItemSuccess) {
                Navigator.of(context).pushNamed(
                  Routes.chatScreen,
                  arguments: {'chat_user': state.chatUser},
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

              return Column(
                children: [
                  IconButton(
                    onPressed: () {
                      if (isLoading) return;
                      UiUtils.checkUser(
                        onNotGuest: () {
                          if (ad.item.itemOfferId != null) {
                            Navigator.of(context).pushNamed(
                              Routes.chatScreen,
                              arguments: {'id': ad.item.itemOfferId},
                            );
                          } else {
                            context
                                .read<MakeAnOfferItemCubit>()
                                .makeAnOfferItem(id: ad.item.id!, from: 'reel');
                          }
                        },
                        context: context,
                      );
                    },
                    icon: isLoading
                        ? LoadingIndicator(size: Size.square(24))
                        : const Icon(AppIcons.chatCircleText),
                  ),
                  Text(
                    'chat'.translate(context),
                    style: context.titleSmall.withColor(Colors.white),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
