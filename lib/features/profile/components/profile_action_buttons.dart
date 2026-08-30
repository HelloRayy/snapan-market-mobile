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

  const ProfileActionButtons({
    super.key,
    this.isOwnProfile = true,
    this.isFollowing = false,
    this.onEditProfile,
    this.onToggleFollow,
    this.onDirectMessage,
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onEditProfile?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 40.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'Edit profil',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildOtherUserButtons() {
    return Row(
      children: [
        // Follow / Following Button
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onToggleFollow?.call();
            },
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                color: isFollowing ? Colors.white : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isFollowing ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                  width: 1.0,
                ),
                boxShadow: isFollowing
                    ? const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 4.0,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFollowing ? Icons.how_to_reg_rounded : Icons.person_add_alt_1_rounded,
                    size: 17.0,
                    color: isFollowing ? const Color(0xFF0F172A) : Colors.white,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    isFollowing ? 'Mengikuti' : 'Ikuti',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: isFollowing ? const Color(0xFF0F172A) : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 8.0),

        // Message Button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onDirectMessage?.call();
          },
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18.0,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
