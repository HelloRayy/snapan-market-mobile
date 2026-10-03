import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/profile/screens/profile_screen.dart';

/// Helper to parse text containing @mentions, #hashtags, and URLs
/// into rich clickable text spans with No-Background Pure Accent Style.
class MentionTextSpanHelper {
  MentionTextSpanHelper._();

  static final RegExp mentionRegex = RegExp(
    r'((?:@|#)[a-zA-Z0-9_.]+|https?:\/\/[^\s]+)',
  );

  /// Builds a list of [InlineSpan]s with styled mentions/hashtags/links.
  static List<InlineSpan> buildSpans({
    required BuildContext context,
    required String text,
    TextStyle? defaultStyle,
    ValueChanged<String>? onUserClick,
    Color accentColor = AppColors.primary,
  }) {
    if (text.isEmpty) return const [];

    final matches = mentionRegex.allMatches(text);
    if (matches.isEmpty) {
      return [TextSpan(text: text, style: defaultStyle)];
    }

    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: defaultStyle,
          ),
        );
      }

      final matchedText = match.group(0)!;
      final isUrl = matchedText.startsWith('http');
      final isMention = matchedText.startsWith('@');

      TapGestureRecognizer? recognizer;
      if (isMention) {
        final cleanUsername = matchedText.substring(1);
        recognizer = TapGestureRecognizer()
          ..onTap = () {
            if (onUserClick != null) {
              onUserClick(cleanUsername);
            } else {
              Navigator.push(
                context,
                AppSlidePageRoute(
                  builder: (_) => ProfileScreen(
                    username: cleanUsername,
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            }
          };
      }

      spans.add(
        TextSpan(
          text: matchedText,
          recognizer: recognizer,
          style: TextStyle(
            color: accentColor,
            fontWeight: isMention ? FontWeight.w600 : FontWeight.w500,
            decoration: isUrl ? TextDecoration.underline : TextDecoration.none,
            decorationColor: accentColor,
            letterSpacing: -0.1,
          ),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: defaultStyle,
        ),
      );
    }

    return spans;
  }
}
