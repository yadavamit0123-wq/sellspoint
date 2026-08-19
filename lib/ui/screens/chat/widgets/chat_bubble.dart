import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.child,
    required this.isMe,
    this.color,
    this.myColor,
    this.otherColor,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
    super.key,
  });

  final Widget child;
  final bool isMe;

  /// Base color used for both sides if [myColor] or [otherColor] are not provided.
  final Color? color;

  /// Explicit color for the current user's messages.
  final Color? myColor;

  /// Explicit color for the other user's messages.
  final Color? otherColor;

  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final Color primary =
        myColor ?? color ?? context.colorScheme.surfaceContainerHighest;
    final Color secondary = otherColor ?? color ?? context.colorScheme.secondary;

    return CustomPaint(
      painter: _ChatBubblePainter(
        color: isMe ? primary : secondary,
        isMe: isMe,
        isRTL: Directionality.of(context) == TextDirection.rtl,
        radius: 10,
        showBorder: showBorder,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
      child: child,
    );
  }
}

class _ChatBubblePainter extends CustomPainter {
  const _ChatBubblePainter({
    required this.color,
    required this.isMe,
    required this.radius,
    required this.showBorder,
    this.isRTL = false,
    this.borderColor,
    this.borderWidth,
  });

  final Color color;
  final bool isMe;
  final double radius;
  final bool isRTL;
  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: Radius.circular(isMe != isRTL ? radius : 0),
      bottomRight: Radius.circular(isMe == isRTL ? radius : 0),
    );

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, fillPaint);

    if (showBorder) {
      final borderPaint = Paint()
        ..color = borderColor ?? color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth ?? 1;
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChatBubblePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.isMe != isMe ||
      oldDelegate.showBorder != showBorder ||
      oldDelegate.isRTL != isRTL ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth;
}
