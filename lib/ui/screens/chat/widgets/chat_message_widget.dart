import 'package:eClassify/data/cubits/chat/chat_message_cubit.dart';
import 'package:eClassify/data/model/chat/chat_message.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_bubble.dart';
import 'package:eClassify/ui/screens/chat/widgets/chat_message_widget_factory/chat_message_widget_factory.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/date_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    required this.message,
    required this.isMe,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  final ChatMessage message;
  final bool isMe;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final child = ChatMessageWidgetFactory.create(message);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.screenWidth * .7),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          spacing: 5,
          children: [
            _buildBubbleWithProgress(context, child),
            _buildTimeAndStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBubbleWithProgress(BuildContext context, Widget child) {
    final bool isRTL = Directionality.of(context) == TextDirection.RTL;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ChatBubble(
          isMe: isMe,
          child: Padding(padding: const EdgeInsets.all(12.0), child: child),
        ),
        if (isSelected)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withAlpha(80),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                  bottomLeft: isMe != isRTL
                      ? const Radius.circular(10)
                      : Radius.zero,
                  bottomRight: isMe == isRTL
                      ? const Radius.circular(10)
                      : Radius.zero,
                ),
              ),
            ),
          ),
        if (message.isSending && message.uploadProgress != null)
          Positioned(
            bottom: -2,
            left: 12,
            right: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: message.uploadProgress,
                minHeight: 2,
                backgroundColor: context.colorScheme.surface.withAlpha(100),
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeAndStatus(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.dateTime.format(formatString: DateFormat.HOUR_MINUTE),
          style: context.bodySmall,
        ),
        if (isMe) ...[const SizedBox(width: 4), _buildStatusIcon(context)],
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    if (message.isSending) {
      return Icon(
        AppIcons.clock,
        size: 14,
        color: context.colorScheme.onSurfaceVariant.withAlpha(150),
      );
    }
    if (message.isFailed) {
      return GestureDetector(
        onTap: () {
          if (message.localId != null) {
            context.read<ChatMessageCubit>().retryMessage(message.localId!);
          }
        },
        child: Icon(
          AppIcons.warningCircle,
          size: 16,
          color: context.colorScheme.error,
        ),
      );
    }
    // Success state: no icon as per feedback
    return const SizedBox.shrink();
  }
}
