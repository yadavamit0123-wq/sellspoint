import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders plain text with tappable http/https and common web links.
class LinkText extends StatelessWidget {
  const LinkText({
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  static final _urlPattern = RegExp(
    r'(https?://[^\s<>"{}|\\^`\[\]]+|www\.[^\s<>"{}|\\^`\[\]]+|(?:play\.google\.com|apps\.apple\.com|bit\.ly|t\.co)/[^\s<>"{}|\\^`\[\]]+)',
    caseSensitive: false,
  );

  static Uri? _toLaunchUri(String raw) {
    final trimmed = raw.trim().replaceAll(RegExp(r'[.,;:!?)]+$'), '');
    if (trimmed.isEmpty) return null;

    final withScheme = trimmed.startsWith(RegExp(r'https?://', caseSensitive: false))
        ? trimmed
        : 'https://$trimmed';
    return Uri.tryParse(withScheme);
  }

  static Future<void> launchLink(String raw) async {
    final uri = _toLaunchUri(raw);
    if (uri == null) return;

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      // Ignore launch failures; link remains visible.
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? Theme.of(context).textTheme.bodySmall;
    final linkStyle = defaultStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );

    final spans = <TextSpan>[];
    var start = 0;
    for (final match in _urlPattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () => launchLink(url),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    if (spans.isEmpty) {
      return Text(
        text,
        style: defaultStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return Text.rich(
      TextSpan(style: defaultStyle, children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
