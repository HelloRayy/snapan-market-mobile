import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          account.username,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (account.isVerified) ...[
                        const SizedBox(width: 4.0),
                        const Icon(Icons.verified, size: 14.0, color: AppColors.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    account.fullName,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (account.bio.isNotEmpty) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      account.bio,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF475569),
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2.0),
                  Text(
                    account.followersCount,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),

            // Follow Button
            GestureDetector(
              onTap: onFollowTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: account.isFollowing ? Colors.white : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: account.isFollowing ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  account.isFollowing ? "Mengikuti" : "Ikuti",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: account.isFollowing ? const Color(0xFF0F172A) : Colors.white,
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
