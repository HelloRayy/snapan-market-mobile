import 'package:flutter/material.dart';
import 'package:snapan_market/core/utils/string_utils.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';



/// Profile Info Header matching ProfilePage.tsx 1:1
/// Displays:
/// - Row 1: Name, Verified Badge, @handle & Class Group on Left vs 60x60 Avatar on Right
/// - Row 2: Bio Description Text
/// - Row 3: 3-Avatar Stacked Followers Count + Seller Sold Stats & Rating ⭐
/// - Row 4: Minat & Bakat Badges (Pills) with + Action
class ProfileInfoHeader extends StatelessWidget {
  final ProfileUserModel user;
  final bool isOwnProfile;
  final VoidCallback? onEditInterests;

  const ProfileInfoHeader({
    super.key,
    required this.user,
    this.isOwnProfile = true,
    this.onEditInterests,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name + Handle on Left vs Avatar on Right (60x60px)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.4,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 4.5),
                          const Icon(
                            Icons.verified_rounded,
                            size: 19.0,
                            color: Color(0xFF1D64EC),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2.5),
                    Text(
                      '@${user.username.replaceAll('@', '')} · ${user.classGroup}',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF64748B),
                        letterSpacing: -0.1,
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(width: 14.0),

              // Right Avatar (60x60px Apple HIG Standard)
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    user.avatar,
                    width: 60.0,
                    height: 60.0,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFEEF0FF),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3D38F5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // Row 2: Bio Text
          Text(
            user.bio,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.normal,
              color: Color(0xFF0F172A),
              height: 1.35,
              letterSpacing: -0.1,
            ),
          ),

          const SizedBox(height: 10.0),

          // Row 3: Follower & Market Stats
          Row(
            children: [
              // 3-Avatar Overlapping Stack (20x20px with white ring border)
              SizedBox(
                width: 44.0,
                height: 20.0,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: _buildMiniAvatar('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=60&q=80'),
                    ),
                    Positioned(
                      left: 12.0,
                      child: _buildMiniAvatar('https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=60&q=80'),
                    ),
                    Positioned(
                      left: 24.0,
                      child: _buildMiniAvatar('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=60&q=80'),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4.0),

              // Followers Count
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF64748B),
                  ),
                  children: [
                    TextSpan(
                      text: '${user.followersCount} ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const TextSpan(text: 'pengikut'),
                  ],
                ),
              ),

              // Sold & Rating stats if applicable
              if (user.soldCount > 0) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text('·', style: TextStyle(color: Color(0xFFCBD5E1))),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFF64748B),
                    ),
                    children: [
                      TextSpan(
                        text: '${user.soldCount} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const TextSpan(text: 'terjual'),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text('·', style: TextStyle(color: Color(0xFFCBD5E1))),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16.0,
                      color: Color(0xFFEAB308),
                    ),
                    const SizedBox(width: 2.0),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFF64748B),
                        ),
                        children: [
                          TextSpan(
                            text: '${user.rating} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          TextSpan(text: '(${user.reviewsCount})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),


          const SizedBox(height: 12.0),

          // Row 4: Bakat & Minat Badges (Chips)
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: [
              ...user.tags.map((rawTag) {
                final tag = StringUtils.cleanTag(rawTag);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: const Color(0xFFE4E4E7), width: 0.8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                );
              }),

              if (isOwnProfile)
                GestureDetector(
                  onTap: onEditInterests,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: const Color(0xFFE4E4E7), width: 0.8),
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
            ],
          ),


        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String url) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        color: const Color(0xFFE2E8F0),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          width: 20.0,
          height: 20.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
