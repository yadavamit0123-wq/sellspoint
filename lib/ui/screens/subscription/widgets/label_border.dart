import 'dart:math';

import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';

enum LabelAlignment {left, center}

class LabeledBorder extends BoxBorder {
  const LabeledBorder({
    required this.label,
    required this.textStyle,
    this.borderWidth = 2,
    this.radius = 12,
    this.horizontalPadding = 12,
    this.capSpacing = 20,
    this.color = ThemeColors.borderColor,
    this.alignment = LabelAlignment.center,
  });

  final String label;
  final TextStyle textStyle;
  final double borderWidth;
  final double radius;
  final double horizontalPadding;
  final double capSpacing;
  final Color color;
  final LabelAlignment alignment;

  BorderSide get _side => BorderSide(color: color, width: borderWidth);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

  @override
  bool get isUniform => true;

  @override
  BorderSide get top => _side;

  @override
  BorderSide get bottom => _side;

  @override
  ShapeBorder scale(double t) {
    return LabeledBorder(
      label: label,
      textStyle: textStyle,
      borderWidth: borderWidth * t,
      radius: radius * t,
      horizontalPadding: horizontalPadding * t,
      capSpacing: capSpacing * t,
      alignment: alignment,
      color: color
    );
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final strokePaint = _side.toPaint()
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final direction = textDirection ?? TextDirection.ltr;

    final layout = _LabelLayout.calculate(
      rect: rect,
      label: label,
      style: textStyle,
      horizontalPadding: horizontalPadding,
      textDirection: direction,
      capSpacing: capSpacing,
      alignment: alignment
    );

    // Border
    final borderRRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(borderRRect, strokePaint);

    _WaveCapPainter.paint(
      canvas: canvas,
      rect: rect,
      layout: layout,
      fillPaint: fillPaint,
      strokePaint: strokePaint,
    );
  }
}

class _LabelLayout {
  final TextPainter textPainter;
  final double capWidth;
  final double capHeight;
  final double capLeft;
  final double capRight;
  final double wavePeakY;
  final double capSpacing;

  _LabelLayout._({
    required this.textPainter,
    required this.capWidth,
    required this.capHeight,
    required this.capLeft,
    required this.capRight,
    required this.wavePeakY,
    required this.capSpacing,
  });

  factory _LabelLayout.calculate({
    required Rect rect,
    required String label,
    required TextStyle style,
    required double horizontalPadding,
    required TextDirection textDirection,
    required double capSpacing,
    required LabelAlignment alignment
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: style),
      textAlign: TextAlign.center,
      textDirection: textDirection,
      maxLines: 1,
    )..layout(maxWidth: rect.width - capSpacing * 2);

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;
    final capWidth = min(
      textWidth + horizontalPadding * 2,
      rect.width - capSpacing * 2,
    );
    final capHeight = textHeight + 2;

    final capLeft = switch(alignment){
      LabelAlignment.center => rect.left + (rect.width - capWidth) / 2,
      LabelAlignment.left => rect.left + horizontalPadding + capSpacing,
    };
    final capRight = capLeft + capWidth;

    final wavePeakY = rect.top - capHeight;

    return _LabelLayout._(
      textPainter: textPainter,
      capWidth: capWidth,
      capHeight: capHeight,
      capLeft: capLeft,
      capRight: capRight,
      wavePeakY: wavePeakY,
      capSpacing: capSpacing,
    );
  }
}

class _WaveCapPainter {
  static void paint({
    required Canvas canvas,
    required Rect rect,
    required _LabelLayout layout,
    required Paint fillPaint,
    required Paint strokePaint,
  }) {
    final baseTop = rect.top;

    final capPath = Path();

    capPath.moveTo(layout.capLeft - 20, baseTop);

    capPath.cubicTo(
      layout.capLeft - 10,
      baseTop,
      layout.capLeft - 10,
      layout.wavePeakY,
      layout.capLeft,
      layout.wavePeakY,
    );

    capPath.lineTo(layout.capRight, layout.wavePeakY);

    capPath.cubicTo(
      layout.capRight + 10,
      layout.wavePeakY,
      layout.capRight + 10,
      baseTop,
      layout.capRight + 20,
      baseTop,
    );

    capPath.close();

    canvas.drawPath(capPath, fillPaint);
    canvas.drawPath(capPath, strokePaint);

    layout.textPainter.paint(
      canvas,
      Offset(
        layout.capLeft + (layout.capWidth - layout.textPainter.width) / 2,
        layout.wavePeakY + (layout.capHeight - layout.textPainter.height) / 2,
      ),
    );
  }
}
