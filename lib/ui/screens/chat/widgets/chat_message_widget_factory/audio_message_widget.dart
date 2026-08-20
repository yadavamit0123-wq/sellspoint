import 'dart:math';

import 'package:eClassify/data/cubits/chat/chat_session_cubit.dart';
import 'package:eClassify/data/model/chat/chat_message.dart';
import 'package:eClassify/data/services/chat/audio_service.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/build_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/utils/app_icons.dart';

class AudioMessageWidget extends StatefulWidget {
  const AudioMessageWidget({required this.message, super.key});

  final AudioChatMessage message;

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  late final AudioService _audioService = context
      .read<ChatSessionCubit>()
      .audioService;

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ChatAudioState>(
      valueListenable: _audioService.stateNotifier,
      builder: (context, state, _) {
        final bool isCurrent = state.url == widget.message.audio;
        final bool isPlaying = isCurrent && state.status == AudioStatus.playing;

        // Calculate progress from service state
        double progress = 0.0;
        if (isCurrent && state.duration > Duration.zero) {
          progress =
              state.position.inMilliseconds / state.duration.inMilliseconds;
        }

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.screenWidth * .7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: 5,
                children: [
                  IconButton(
                    onPressed: () {
                      _audioService.play(widget.message.audio);
                    },
                    icon: Icon(
                      isPlaying
                          ? AppIcons.pauseFill
                          : AppIcons.playFill,
                    ),
                  ),
                  Expanded(
                    child: CustomPaint(
                      willChange: true,
                      size: const Size.fromHeight(40),
                      painter: _AudioBarPainter(
                        filledColor: context.colorScheme.primary,
                        unfilledColor: const Color(0xff4B5563),
                        value: progress,
                        seed: widget.message.id.hashCode,
                        isRTL: Directionality.of(context) == TextDirection.rtl,
                      ),
                    ),
                  ),
                ],
              ),
              if (isCurrent && state.duration > Duration.zero)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 48),
                  child: Text(
                    '${_formatDuration(state.position)} / ${_formatDuration(state.duration)}',
                    style: context.bodySmall.copyWith(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: .6,
                      ),
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AudioBarPainter extends CustomPainter {
  const _AudioBarPainter({
    required this.filledColor,
    required this.unfilledColor,
    required this.value,
    required this.seed,
    required this.isRTL,
  });

  final Color filledColor;
  final Color unfilledColor;
  final double value;
  final int seed;
  final bool isRTL;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint();

    // 1. Create the Layer
    canvas.saveLayer(rect, paint);

    // 2. DRAW THE STENCIL (The "Empty" Bars)
    final barPaint = Paint()..color = Colors.white;
    final _rand = Random(seed); // Stable seed is vital here
    const double barWidth = 3.0;
    const double spacing = 6.0;

    double x = 3;
    while (x < size.width - 3) {
      final h = _rand.nextDouble() * 30 + 5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, size.height / 2),
            width: barWidth,
            height: h,
          ),
          const Radius.circular(2),
        ),
        barPaint,
      );
      x += spacing;
    }

    // 3. APPLY THE "FILLED" COLOR (Progress part)
    // srcIn: Only keep the new color where the white bars already exist
    paint.blendMode = BlendMode.srcIn;
    paint.color = filledColor;

    if (isRTL) {
      // Progress from Right to Left
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * (1 - value),
          0,
          size.width * value,
          size.height,
        ),
        paint,
      );
    } else {
      // Progress from Left to Right
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * value, size.height),
        paint,
      );
    }

    // 4. APPLY THE "UNFILLED" COLOR (Remaining part)
    // srcAtop: Only draw on top of existing pixels (the white bars)
    // that haven't been colored by the previous step.
    paint.blendMode = BlendMode.srcATop;
    paint.color = unfilledColor; // Dim the unplayed part

    if (isRTL) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * (1 - value), size.height),
        paint,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(size.width * value, 0, size.width, size.height),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AudioBarPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
