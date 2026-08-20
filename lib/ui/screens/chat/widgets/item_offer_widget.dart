import 'package:eClassify/ui/screens/chat/widgets/chat_bubble.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class ItemOfferWidget extends StatelessWidget {
  const ItemOfferWidget({
    required this.offerAmount,
    required this.isMe,
    super.key,
  });

  final String offerAmount;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      isMe: isMe,
      color: context.colorScheme.primary.withValues(alpha: .05),
      showBorder: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(
              (isMe ? 'yourOffer' : 'offerLbl').translate(context),
              style: context.labelMedium.withColor(context.colorScheme.primary),
            ),
            Text(
              offerAmount,
              style: context.titleMedium.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
