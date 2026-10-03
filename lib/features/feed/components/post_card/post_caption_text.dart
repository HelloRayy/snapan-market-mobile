import 'package:flutter/material.dart';
import 'package:snapan_market/core/utils/mention_text_span_helper.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Caption text with multi-thread indicator badge and Pure Accent Blue mentions/hashtags
class PostCaptionText extends StatelessWidget {
  final MarketPostModel item;
  final ValueChanged<String>? onUserClick;

  const PostCaptionText({
    super.key,
    required this.item,
    this.onUserClick,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultiThread =
        item.totalThreadParts != null && item.totalThreadParts! > 1;

    const baseStyle = TextStyle(
      fontFamily: 'SFPro',
      fontFamilyFallback: ['AppleColorEmoji'],
      fontSize: 14.5,
      height: 1.35,
      fontWeight: FontWeight.normal,
      color: Color(0xFF0F172A),
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          ...MentionTextSpanHelper.buildSpans(
            context: context,
            text: item.caption,
            defaultStyle: baseStyle,
            onUserClick: onUserClick,
          ),
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
    );
  }
}
