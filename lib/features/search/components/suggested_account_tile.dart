import "package:flutter/material.dart";
import "package:snapan_market/core/components/kumo_button.dart";
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar (40x40px matching HomeFeed style)
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 3.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  account.avatar,
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40.0,
                    height: 40.0,
                    color: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.person, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),

            // User Info Column (Consistent spacing rhythm identical to HomeFeed)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Username + Verified Badge Row
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          account.username,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                            height: 1.15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (account.isVerified) ...[
                        const SizedBox(width: 4.0),
                        const Icon(
                          Icons.verified_rounded,
                          size: 15.0,
                          color: Color(0xFF1D64EC),
                        ),
                      ],
                    ],
                  ),

                  // 2. Full Name
                  const SizedBox(height: 1.5),
                  Text(
                    account.fullName,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                      height: 1.20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 3. Bio Description
                  if (account.bio.isNotEmpty) ...[
                    const SizedBox(height: 3.0),
                    Text(
                      account.bio,
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF334155),
                        height: 1.30,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // 4. Followers Count
                  const SizedBox(height: 4.0),
                  Text(
                    account.followersCount,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),

            // Follow Button (Kumo UI Black Button System - 78x30px)
            KumoButton(
              text: account.isFollowing ? "Mengikuti" : "Ikuti",
              variant: account.isFollowing ? KumoButtonVariant.secondary : KumoButtonVariant.black,
              width: 78.0,
              height: 30.0,
              borderRadius: 8.0,
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              onPressed: onFollowTap,
            ),
          ],
        ),
      ),
    );
  }
}
