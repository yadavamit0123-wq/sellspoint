import 'package:eClassify/ui/screens/chat/widgets/message_composing_widgets/pulsating_dot_indicator.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eClassify/utils/app_icons.dart';

class MessageAudioInput extends StatelessWidget {
  const MessageAudioInput({
    required this.duration,
    required this.offset,
    required this.isLocked,
    this.onDiscard,
    super.key,
  });

  final Duration duration;
  final Offset offset;
  final bool isLocked;
  final VoidCallback? onDiscard;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isLocked)
          IconButton(
            icon: const Icon(AppIcons.trash, color: Colors.grey),
            onPressed: onDiscard,
          )
        else
          const PulsatingDotIndicator(color: Colors.red),
        const SizedBox(width: 12),
        Text(
          _formatDuration(duration),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (!isLocked) _SlideToCancel(offset: offset),
      ],
    );
  }
}

class _SlideToCancel extends StatelessWidget {
  const _SlideToCancel({required this.offset});

  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    // In LTR: user swipes left (negative dx). Indicator moves left.
    // In RTL: user swipes right (positive dx). Indicator moves right.
    final horizontalShift = isRtl
        ? offset.dx.clamp(0.0, 100.0)
        : offset.dx.clamp(-100.0, 0.0);

    // Opacity fades as shift increases (either direction)
    final opacity = (1.0 - (horizontalShift.abs() / 100.0)).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(horizontalShift, 0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade600,
          highlightColor: Colors.white,
          direction: isRtl ? ShimmerDirection.ltr : ShimmerDirection.rtl,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Icon(AppIcons.caretLeft, size: 20),
              Text('slideToCancel'.translate(context)),
            ],
          ),
        ),
      ),
    );
  }
}
