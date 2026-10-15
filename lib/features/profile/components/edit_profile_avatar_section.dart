import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapan_market/core/components/mascot_flair_badge.dart';
import 'package:snapan_market/core/models/mascot_flair_model.dart';
import 'package:snapan_market/core/services/media_cropper_service.dart';
import 'package:snapan_market/core/services/media_upload_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/ui/oreo_avatar_helper.dart';

/// Top section of Edit Profile with Name input, Circular Avatar with '+' badge,
/// and Mascot bundle & emotion picker (SNAPS-13) replacing rigid presets for beta pilot.
class EditProfileAvatarSection extends StatefulWidget {
  final TextEditingController nameController;
  final String currentAvatar;
  final ValueChanged<String> onAvatarChanged;
  final MascotFlairModel? currentMascotFlair;
  final ValueChanged<MascotFlairModel?> onMascotFlairChanged;
  final bool isBetaPilotUser;

  const EditProfileAvatarSection({
    super.key,
    required this.nameController,
    required this.currentAvatar,
    required this.onAvatarChanged,
    this.currentMascotFlair,
    required this.onMascotFlairChanged,
    this.isBetaPilotUser = false,
  });

  @override
  State<EditProfileAvatarSection> createState() => _EditProfileAvatarSectionState();
}

class _EditProfileAvatarSectionState extends State<EditProfileAvatarSection> {
  bool _showAvatarPicker = false;
  bool _isUploadingAvatar = false;

  Future<void> _handlePickAvatar() async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkSurfaceElevated : Colors.white;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.ink;
    final itemTitleColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final itemSubColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final handleColor = isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1);

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ganti Foto Profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Buka Galeri HP', style: TextStyle(fontWeight: FontWeight.w600, color: itemTitleColor)),
                subtitle: Text('Pilih foto profil dari galeri (Kompres 1080p)', style: TextStyle(color: itemSubColor)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('Ambil Foto Kamera', style: TextStyle(fontWeight: FontWeight.w600, color: itemTitleColor)),
                subtitle: Text('Ambil selfie atau foto baru langsung', style: TextStyle(color: itemSubColor)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await MediaUploadService.instance.pickSingleImage(source: source);
    if (picked == null || !mounted) return;

    // 1. In-App Pure Flutter Image Crop Modal (Pan, Pinch-to-Zoom, 1:1 Circle Mask)
    final cropped = await MediaCropperService.instance.cropAvatar(
      picked.path,
      context: context,
    );
    if (cropped == null || !mounted) return; // User cancelled cropping

    setState(() => _isUploadingAvatar = true);

    try {
      final bytes = await cropped.readAsBytes();
      final uploadedUrl = await SupabaseService.instance.uploadImage(
        bytes: bytes,
        fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        bucket: 'avatars',
      );

      if (mounted) {
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          widget.onAvatarChanged(uploadedUrl);
        } else {
          // Fallback to local path if storage upload is not available
          widget.onAvatarChanged(cropped.path);
        }
      }
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      if (mounted) {
        widget.onAvatarChanged(cropped.path);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8);
    final avatarBg = isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9);
    final badgeBorderColor = isDark ? AppColors.darkSurface : Colors.white;
    final dividerColor = AppColors.adaptiveDivider(context);

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
                    Text(
                      'Display Name',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    TextField(
                      controller: widget.nameController,
                      maxLength: 50,
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 15.5,
                        fontWeight: FontWeight.normal,
                        color: primaryTextColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nama tampilan kamu',
                        hintStyle: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 15.5,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14.0),

              // Right: Avatar with '+' badge (Clickable to change photo)
              GestureDetector(
                onTap: _handlePickAvatar,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52.0,
                      height: 52.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: avatarBg,
                      ),
                      child: ClipOval(
                        child: _isUploadingAvatar
                            ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : AppAvatar(
                                avatarUrl: widget.currentAvatar,
                                size: 52.0,
                              ),
                      ),
                    ),

                    // Black '+' badge on bottom right (borderless cutout, no shadow)
                    Positioned(
                      bottom: -2.0,
                      right: -2.0,
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF101010),
                          border: Border.all(
                            color: badgeBorderColor,
                            width: 1.5,
                          ),
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

        Divider(height: 1.0, thickness: 0.8, color: dividerColor),

        // Row 1.5: Mascot Bundle Picker (SNAPS-13 for beta pilot) OR Preset Avatars Accordion
        if (widget.isBetaPilotUser)
          _buildMascotSection()
        else
          _buildPresetAvatarSection(),

        Divider(height: 1.0, thickness: 0.8, color: dividerColor),
      ],
    );
  }

  Widget _buildMascotSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBundle = widget.currentMascotFlair?.bundle ?? MascotBundle.koala;
    final curatedEmotions = [
      MascotEmotion.delighted, // Happy 😊
      MascotEmotion.heart,     // Love 😍
      MascotEmotion.sparkle,   // Sparkle ✨
      MascotEmotion.wink,      // Wink 😉
      MascotEmotion.surprised, // Surprised 😲
      MascotEmotion.sleepy,    // Sleepy 😴
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Pilihan Maskot Bundle',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkPrimaryPastel : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Text(
                      'BETA',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.currentMascotFlair != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onMascotFlairChanged(null);
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Segmented Bundle Switcher (Koala / Fox) - Hugged centered icon-first pills matching CreatePost
          Center(
            child: Container(
              height: 36.0,
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: MascotBundle.values.map((bundle) {
                  final isSelected = activeBundle == bundle;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onMascotFlairChanged(
                        MascotFlairModel(
                          bundle: bundle,
                          emotion: widget.currentMascotFlair?.emotion ?? MascotEmotion.delighted,
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.symmetric(horizontal: 22.0),
                      decoration: BoxDecoration(
                        color: isSelected ? (isDark ? AppColors.darkSurface : Colors.white) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x0E000000),
                                  blurRadius: 4.0,
                                  offset: Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: MascotFlairBadge(
                        flair: MascotFlairModel(bundle: bundle, emotion: MascotEmotion.delighted),
                        size: 22.0,
                        enableGradientFade: false,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12.0),

          // Responsive Curated 3x2 Emotions Grid (Pure white cards with large touch targets)
          Center(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: curatedEmotions.map((emotion) {
                final isEmotionSelected = widget.currentMascotFlair != null &&
                    widget.currentMascotFlair!.bundle == activeBundle &&
                    widget.currentMascotFlair!.emotion == emotion;
                final itemFlair = MascotFlairModel(bundle: activeBundle, emotion: emotion);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onMascotFlairChanged(itemFlair);
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    splashColor: AppColors.primary.withValues(alpha: 0.12),
                    highlightColor: AppColors.primary.withValues(alpha: 0.06),
                    child: Container(
                      width: 84.0,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isEmotionSelected
                            ? (isDark ? AppColors.darkPrimaryPastel : const Color(0xFFEFF6FF))
                            : (isDark ? AppColors.darkSurface : Colors.white),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: isEmotionSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                          width: isEmotionSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 4.0,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MascotFlairBadge(
                            flair: itemFlair,
                            size: 34.0,
                            enableGradientFade: false,
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            emotion.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: isEmotionSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isEmotionSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkTextSecondary : const Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetAvatarSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
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
                Text(
                  'Pilihan avatar preset',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
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
                  children: [
                    // Upload custom photo from Camera/Gallery
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: GestureDetector(
                        onTap: _handlePickAvatar,
                        child: Container(
                          width: 44.0,
                          height: 44.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_a_photo_outlined,
                              size: 19.0,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...kOreoGradientPresets.map((preset) {
                      final presetVal = 'preset:${preset.id}';
                      final isSelected = widget.currentAvatar == presetVal;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onAvatarChanged(presetVal);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 44.0,
                            height: 44.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: preset.colors,
                                begin: preset.begin,
                                end: preset.end,
                              ),
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
                                  Center(
                                    child: Text(
                                      widget.nameController.text.trim().isNotEmpty
                                          ? widget.nameController.text.trim()[0].toUpperCase()
                                          : 'S',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                        color: (preset.id == 'aurora-pink' || preset.id == 'violet-peach')
                                            ? Colors.white.withValues(alpha: 0.95)
                                            : const Color(0xFF1E293B).withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.3),
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
                    }),
                  ],
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
    );
  }
}
