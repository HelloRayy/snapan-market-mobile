import "package:flutter/material.dart";

class TrendingTagTile extends StatelessWidget {
  final int rank;
  final String tag;
  final String postCount;
  final VoidCallback? onTap;

  const TrendingTagTile({
    super.key,
    required this.rank,
    required this.tag,
    required this.postCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
        child: Row(
          children: [
            // Rank Number
            SizedBox(
              width: 24.0,
              child: Text(
                "$rank",
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Tag Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#$tag",
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    postCount,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, size: 18.0, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
