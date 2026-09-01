import "package:flutter/material.dart";
import "package:snapan_market/features/search/models/search_models.dart";

class SuggestedAccountTile extends StatelessWidget {
  final SuggestedAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;

  const SuggestedAccountTile({
    super.key,
    required this.account,
    this.onTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                account.avatar,
                width: 42.0,
                height: 42.0,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 42.0,
                  height: 42.0,
                  color: const Color(0xFFE2E8F0),
                  child: const Icon(Icons.person, color: Color(0xFF94A3B8)),
                ),
              ),
            ),
            const SizedBox(width: 12.0),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.username,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    account.fullName,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (account.bio.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      account.bio,
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF334155),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6.0),
                  Text(
                    account.followersCount,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),

            // Follow Button
            GestureDetector(
              onTap: onFollowTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                decoration: BoxDecoration(
                  color: account.isFollowing ? const Color(0xFFF8FAFC) : Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: account.isFollowing ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  account.isFollowing ? "Mengikuti" : "Ikuti",
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: account.isFollowing ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
