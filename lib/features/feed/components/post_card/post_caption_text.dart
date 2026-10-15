import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final badgeBgColor = isDark ? const Color(0xFF242626) : const Color(0xFFF1F5F9);

    final baseStyle = TextStyle(
      fontFamily: 'SFPro',
      fontFamilyFallback: const ['AppleColorEmoji'],
      fontSize: 14.5,
      height: 1.35,
      fontWeight: FontWeight.normal,
      color: primaryTextColor,
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
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  '1/${item.totalThreadParts}',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
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
