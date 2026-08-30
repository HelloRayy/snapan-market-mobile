import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/profile/models/mock_profile_data.dart';

/// Top section of Edit Profile with Name input, Circular Avatar with '+' badge,
/// and smooth collapsible 6-Preset Avatars carousel picker matching EditProfilePage.tsx
class EditProfileAvatarSection extends StatefulWidget {
  final TextEditingController nameController;
  final String currentAvatar;
  final ValueChanged<String> onAvatarChanged;

  const EditProfileAvatarSection({
    super.key,
    required this.nameController,
    required this.currentAvatar,
    required this.onAvatarChanged,
  });

  @override
  State<EditProfileAvatarSection> createState() => _EditProfileAvatarSectionState();
}

class _EditProfileAvatarSectionState extends State<EditProfileAvatarSection> {
  bool _showAvatarPicker = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Nama Input (Left) & Avatar with '+' badge (Right)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Nama Form Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    TextField(
                      controller: widget.nameController,
                      maxLength: 50,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Nama lengkap Anda',
                        hintStyle: TextStyle(
                          fontSize: 15.5,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14.0),

              // Right: Avatar with '+' badge (Clickable to toggle picker)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showAvatarPicker = !_showAvatarPicker);
                },
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52.0,
                      height: 52.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F5F9),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
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
                          widget.currentAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 26.0,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Black '+' badge on bottom right
                    Positioned(
                      bottom: -2.0,
                      right: -2.0,
                      child: Container(
                        width: 22.0,
                        height: 22.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF101010),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_rounded,
                            size: 13.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),

        // Row 1.5: Preset Avatars Accordion Trigger
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showAvatarPicker = !_showAvatarPicker);
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilihan avatar preset',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.1,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAvatarPicker ? 'Tutup' : 'Pilih',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 2.0),
                        AnimatedRotation(
                          turns: _showAvatarPicker ? 0.25 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 16.0,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Animated Horizontal Carousel of 6 Preset Avatars
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: kPresetAvatars.asMap().entries.map((entry) {
                        final avatarUrl = entry.value;
                        final isSelected = widget.currentAvatar == avatarUrl;

                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onAvatarChanged(avatarUrl);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 44.0,
                              height: 44.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF101010)
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2.5 : 1.0,
                                ),
                              ),
                              child: ClipOval(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                    ),
                                    if (isSelected)
                                      Container(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        child: const Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 20.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                crossFadeState: _showAvatarPicker
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
              ),
            ],
          ),
        ),

        const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}
