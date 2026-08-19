import 'package:flutter/material.dart';

class AutoSizeText extends StatelessWidget {
  const AutoSizeText({
    required this.text,
    required this.maxLines,
    required this.style,
    this.textAlign = TextAlign.start,
    this.minimumFontSize = 18.0,
    this.overflow = TextOverflow.clip,
    super.key,
  });

  final String text;
  final int maxLines;
  final TextStyle style;
  final TextAlign textAlign;
  final double minimumFontSize;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var fontSize = style.fontSize ?? minimumFontSize;

        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: maxLines,
          textDirection: Directionality.of(context),
        );

        while (true) {
          textPainter.layout(maxWidth: constraints.maxWidth);
          if (!textPainter.didExceedMaxLines) break;
          fontSize -= 1;
          if (fontSize < minimumFontSize) break;
          textPainter.text = TextSpan(
            text: text,
            style: style.copyWith(fontSize: fontSize),
          );
        }

        return Text(
          text,
          style: style.copyWith(fontSize: fontSize),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
