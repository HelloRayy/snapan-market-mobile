import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Caption text with multi-thread indicator badge and Meta Blue mentions/hashtags
class PostCaptionText extends StatelessWidget {
  final MarketPostModel item;

  const PostCaptionText({
    super.key,
    required this.item,
  });

  List<InlineSpan> _buildFormattedSpans(String text) {
    final regex = RegExp(r'((?:@|#)[a-zA-Z0-9_.]+|https?:\/\/[^\s]+)');
    final matches = regex.allMatches(text);
    if (matches.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      final matchedText = match.group(0)!;
      final isUrl = matchedText.startsWith('http');
      final isMention = matchedText.startsWith('@');

      spans.add(
        TextSpan(
          text: matchedText,
          style: TextStyle(
            color: AppColors.metaBlue,
            fontWeight: isMention ? FontWeight.w600 : FontWeight.w500,
            decoration: isUrl ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppColors.metaBlue,
          ),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiThread =
        item.totalThreadParts != null && item.totalThreadParts! > 1;

    return Text.rich(
      TextSpan(
        children: [
          ..._buildFormattedSpans(item.caption),
          if (hasMultiThread) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                margin: const EdgeInsets.only(left: 6.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  '1/${item.totalThreadParts}',
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      style: const TextStyle(
        fontFamily: 'SFPro',
        fontFamilyFallback: ['AppleColorEmoji'],
        fontSize: 14.5,
        height: 1.35,
        fontWeight: FontWeight.normal,
        color: Color(0xFF0F172A),
      ),
    );
  }
}
