import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final TextStyle? readMoreButtonStyle;
  final TextAlign textAlign;
  final Duration animationDuration;

  const ExpandableText({
    super.key,
    required this.text,
    required this.maxLines,
    this.style,
    this.readMoreButtonStyle,
    this.textAlign = TextAlign.start,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle =
        widget.style ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: effectiveStyle),
          maxLines: widget.maxLines,
          textAlign: widget.textAlign,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final bool isOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: widget.animationDuration,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: effectiveStyle,
                maxLines: isExpanded ? null : widget.maxLines,
                textAlign: widget.textAlign,
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
            if (isOverflowing)
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: widget.readMoreButtonStyle,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: Colors.transparent,
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded
                      ? "readLessLbl".translate(context)
                      : "readMoreLbl".translate(context),
                ),
              ),
          ],
        );
      },
    );
  }
}
