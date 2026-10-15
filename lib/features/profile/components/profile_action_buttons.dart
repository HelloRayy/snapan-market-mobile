import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
/// Action Buttons row for Profile Screen matching ProfilePage.tsx 1:1
/// - Own Profile: Full-width "Edit profil" button
/// - Other User: "Ikuti" / "Mengikuti" CTA + Direct Message icon button
class ProfileActionButtons extends StatelessWidget {
  final bool isOwnProfile;
  final bool isFollowing;
  final VoidCallback? onEditProfile;
  final VoidCallback? onToggleFollow;
  final VoidCallback? onDirectMessage;

  final bool isLoggedIn;
  final VoidCallback? onAuthTap;
  final bool hasIncompleteAvatar;

  const ProfileActionButtons({
    super.key,
    this.isOwnProfile = true,
    this.isFollowing = false,
    this.isLoggedIn = true,
    this.hasIncompleteAvatar = false,
    this.onEditProfile,
    this.onToggleFollow,
    this.onDirectMessage,
    this.onAuthTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: isOwnProfile
          ? _buildOwnProfileButton()
          : _buildOtherUserButtons(),
    );
  }

  Widget _buildOwnProfileButton() {
    if (!isLoggedIn) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onAuthTap?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 38.0,
          decoration: BoxDecoration(
            color: const Color(0xFF3D38F5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Masuk atau Daftar Akun',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.1,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onEditProfile?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 36.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Optical Center: Edit profil text NEVER shifts
            const Center(
              child: Text(
                'Edit profil',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.1,
                ),
              ),
            ),

            // Pinned Right Pill: [Lengkapi foto !]
            if (hasIncompleteAvatar)
              Positioned(
                right: 8.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7), // Warm amber background
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lengkapi foto',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(width: 3.0),
                      Text(
                        '!',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD97706),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherUserButtons() {
    return Row(
      children: [
        // Follow / Following Button (Threads Style 100% 1:1)
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onToggleFollow?.call();
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 36.0,
              decoration: BoxDecoration(
                color: isFollowing ? Colors.white : const Color(0xFF000000),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: isFollowing ? const Color(0xFFE2E8F0) : const Color(0xFF000000),
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                isFollowing ? 'Mengikuti' : 'Ikuti',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: isFollowing ? const Color(0xFF0F172A) : Colors.white,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10.0),

        // Message Button (50% width with 10px rounded border)
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onDirectMessage?.call();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 36.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Kirim pesan',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
