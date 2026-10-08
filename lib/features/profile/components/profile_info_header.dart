import 'package:flutter/cupertino.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/ui/default_profile_avatar.dart';
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
  final VoidCallback? onAvatarTap;

  const ProfileInfoHeader({
    super.key,
    required this.user,
    this.isOwnProfile = true,
    this.onEditInterests,
    this.onAvatarTap,
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 4.5),
                          const Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: 19.0,
                            color: AppColors.verifiedBlue,
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

              // Right Avatar (60x60px Apple HIG Standard with Zoom Viewer)
              GestureDetector(
                onTap: onAvatarTap,
                child: SizedBox(
                  width: 60.0,
                  height: 60.0,
                  child: AppAvatar(
                    avatarUrl: user.avatar,
                    size: 60.0,
                  ),
                ),
              ),
            ],
          ),

          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 10.0),
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
          ] else if (isOwnProfile) ...[
            const SizedBox(height: 8.0),
            const Text(
              'Ketuk Edit Profil untuk menambahkan bio Anda...',
              style: TextStyle(
                fontSize: 13.5,
                fontStyle: FontStyle.italic,
                color: Color(0xFF94A3B8),
                height: 1.35,
              ),
            ),
          ],

          const SizedBox(height: 10.0),

          // Row 3: Follower & Market Stats
          Row(
            children: [
              Text(
                '${user.followersCount} pengikut',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.normal,
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
                      CupertinoIcons.star_fill,
                      size: 15.0,
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
}
