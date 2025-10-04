import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ClickableText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> spans = _parseText(context);

    return Text.rich(
      TextSpan(children: spans, style: style),
      textAlign: textAlign ?? TextAlign.start,
    );
  }

  List<TextSpan> _parseText(BuildContext context) {
    final theme = Theme.of(context);
    final List<TextSpan> spans = [];
    final RegExp linkRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

    String remainingText = text;
    int lastIndex = 0;

    for (final Match match in linkRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(text: remainingText.substring(lastIndex, match.start)),
        );
      }

      final String linkText = match.group(1)!;
      final String linkUrl = match.group(2)!;

      spans.add(
        TextSpan(
          text: linkText,
          style: style?.copyWith(color: theme.colorScheme.primary),
          recognizer: TapGestureRecognizer()..onTap = () => _launchUrl(linkUrl),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < remainingText.length) {
      spans.add(TextSpan(text: remainingText.substring(lastIndex)));
    }

    return spans;
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
