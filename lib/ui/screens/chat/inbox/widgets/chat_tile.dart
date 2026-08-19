import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatTile extends StatelessWidget {
  const ChatTile({
    required this.onTap,
    required this.onLongPress,
    required this.title,
    required this.leading,
    required this.lastMessageTime,
    required this.unreadCount,
    this.subtitle,
    this.selected = false,
    super.key,
  });

  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String title;
  final String? subtitle;
  final Widget leading;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 70,
      onTap: onTap,
      onLongPress: onLongPress,
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: context.colorScheme.primary),
            )
          : null,
      leading: leading,
      title: Text(
        title,
        style: context.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 5,
        children: [
          Text(
            timeago.format(
              lastMessageTime,
              locale: '${AppSession.currentLocale}_short',
            ),
            style: context.labelMedium.withColor(context.mutedColor),
          ),
          if (unreadCount != 0)
            Badge(
              backgroundColor: context.colorScheme.primary,
              label: Text('${unreadCount}'),
            ),
        ],
      ),
    );
  }
}
