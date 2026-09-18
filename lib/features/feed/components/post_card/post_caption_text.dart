import 'package:flutter/material.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Caption text with multi-thread indicator badge and optional location tag
class PostCaptionText extends StatelessWidget {
  final MarketPostModel item;

  const PostCaptionText({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultiThread = item.totalThreadParts != null && item.totalThreadParts! > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: item.caption,
            children: [
              if (hasMultiThread) ...[
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.only(left: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
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
            fontSize: 14.5,
            height: 1.25,
            fontWeight: FontWeight.normal,
            color: Color(0xFF0F172A),
          ),
        ),

        // Optional Location Tag (Campus COD spot)
        if (item.locationTag != null && item.locationTag!.isNotEmpty) ...[
          const SizedBox(height: 6.0),
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              item.locationTag!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                letterSpacing: -0.1,
                height: 1.25,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
