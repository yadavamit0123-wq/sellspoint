import 'dart:math' as math;

import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that slides in below a vertical [PageView] when the user
/// over-scrolls past the last item.
///
/// The height grows proportionally with the drag distance. The custom painter
/// fills a circular arc for the first half of the pull, then animates a
/// checkmark stroke for the second half. When the user releases, the height
/// snaps back with an ease-out spring.
///
/// All animation is driven by a single [AnimationController] that is set
/// directly from [overscrollNotifier] while dragging and animated back to
/// zero on release — no [setState] required.
class OverscrollIndicator extends StatefulWidget {
  const OverscrollIndicator({
    required this.overscrollNotifier,
    this.maxOverscroll = 70.0,
    super.key,
  });

  /// Raw overscroll amount in pixels (≥ 0). Emitted by the parent
  /// [NotificationListener] via a [ValueNotifier].
  final ValueListenable<double> overscrollNotifier;

  /// Pixel drag distance at which the indicator is considered "fully pulled".
  final double maxOverscroll;

  @override
  State<OverscrollIndicator> createState() => _OverscrollIndicatorState();
}

class _OverscrollIndicatorState extends State<OverscrollIndicator>
    with SingleTickerProviderStateMixin {
  // Single controller [0..1] drives height, arc, and checkmark.
  late final AnimationController _controller;

  static const double _maxHeight = 72.0;

  // Derived once — FadeTransition subscribes to this directly, avoiding a
  // per-frame Opacity rasterisation step.
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // Fade completes in the first third of the pull; the rest of the
    // animation is devoted to arc and checkmark progress.
    _fadeAnimation = _controller.drive(
      Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: const Interval(0.0, 0.33, curve: Curves.easeIn)),
      ),
    );
    widget.overscrollNotifier.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(OverscrollIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overscrollNotifier != widget.overscrollNotifier) {
      oldWidget.overscrollNotifier.removeListener(_onChanged);
      widget.overscrollNotifier.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.overscrollNotifier.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    final overscroll = widget.overscrollNotifier.value;

    if (overscroll > 0) {
      // During an active drag: track the finger directly with no interpolation
      // so the height feels physically attached to the scroll position.
      final t = (overscroll / widget.maxOverscroll).clamp(0.0, 1.0);
      _controller.value = t;
    } else {
      // Finger released or overscroll cleared: bounce back to zero.
      _controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    final onSurface = context.colorScheme.onSurface;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        // Height is directly proportional — no binary jump.
        final height = t * (_maxHeight + bottomPadding);

        // Arc fills during the first 55 % of the pull.
        final arcProgress = Curves.easeOutCubic.transform(
          (t / 0.55).clamp(0.0, 1.0),
        );

        // Checkmark draws during the remaining 45 %.
        final checkProgress = Curves.easeOut.transform(
          ((t - 0.55) / 0.45).clamp(0.0, 1.0),
        );

        return SizedBox(
          height: height,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                // FadeTransition composites on the GPU — avoids the
                // per-frame CPU rasterisation cost of Opacity.
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // willChange=true tells the engine to composite this
                      // layer separately — equivalent to RepaintBoundary but
                      // more idiomatic for a frequently-repainted painter.
                      CustomPaint(
                        size: const Size(28.0, 28.0),
                        willChange: true,
                        painter: _ProgressCheckPainter(
                          arcProgress: arcProgress,
                          checkProgress: checkProgress,
                          color: primary,
                          trackColor: primary.withValues(alpha: 0.18),
                          strokeWidth: 2.0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'youAreAllCaughtUp'.translate(context),
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Paints:
/// 1. A faint circular track.
/// 2. A coloured arc sweeping clockwise, driven by [arcProgress].
/// 3. A checkmark stroke drawn from left to right, driven by [checkProgress].
class _ProgressCheckPainter extends CustomPainter {
  const _ProgressCheckPainter({
    required this.arcProgress,
    required this.checkProgress,
    required this.color,
    required this.trackColor,
    this.strokeWidth = 2.5,
  });

  /// Fraction [0..1] of the arc that is drawn.
  final double arcProgress;

  /// Fraction [0..1] of the checkmark stroke that is drawn.
  final double checkProgress;

  final Color color;
  final Color trackColor;
  final double strokeWidth;

  static const double _startAngle = -math.pi / 2; // 12 o'clock

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── Track ────────────────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // ── Arc ──────────────────────────────────────────────────────────────
    if (arcProgress > 0) {
      canvas.drawArc(
        rect,
        _startAngle,
        2 * math.pi * arcProgress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── Checkmark ────────────────────────────────────────────────────────
    if (checkProgress > 0) {
      final w = size.width;
      final h = size.height;

      final path = Path()
        ..moveTo(w * 0.26, h * 0.51)
        ..lineTo(w * 0.44, h * 0.67)
        ..lineTo(w * 0.74, h * 0.35);

      final metric = path.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * checkProgress),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressCheckPainter old) =>
      old.arcProgress != arcProgress ||
      old.checkProgress != checkProgress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
