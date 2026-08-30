import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/profile/components/discard_changes_dialog.dart';
import 'package:snapan_market/features/profile/components/edit_profile_avatar_section.dart';
import 'package:snapan_market/features/profile/components/edit_profile_chips_editor.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';

/// Full Edit Profile Screen matching EditProfilePage.tsx 1:1
///
/// Features:
/// - Header Bar with Back navigation & Unsaved Changes Guard
/// - Name & Avatar Selector with 6-Preset Avatars Accordion
/// - @username, Bio with live x/150 counter, Class & Major fields
/// - Interactive Interest Chips Editor (add via enter/comma, remove via X)
/// - External Link, Sales Stats Toggle, and Profile Privacy info
/// - Permanently Fixed Dual Action CTA Bar (Discard & Save)
/// - Hardware / Gesture PopScope interception
class EditProfileScreen extends StatefulWidget {
  final ProfileUserModel initialUser;
  final ValueChanged<ProfileUserModel> onSave;

  const EditProfileScreen({
    super.key,
    required this.initialUser,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _classController;
  late TextEditingController _linkController;

  late String _avatar;
  late List<String> _tags;
  late bool _showSalesStats;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUser.name);
    _usernameController = TextEditingController(
      text: widget.initialUser.username.replaceAll('@', ''),
    );
    _bioController = TextEditingController(text: widget.initialUser.bio);
    _classController = TextEditingController(text: widget.initialUser.classGroup);
    _linkController = TextEditingController(
      text: widget.initialUser.link ?? 'https://instagram.com/${widget.initialUser.username.replaceAll('@', '')}',
    );
    _avatar = widget.initialUser.avatar;
    _tags = List<String>.from(widget.initialUser.tags);
    _showSalesStats = widget.initialUser.showSalesStats;

    _bioController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _classController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final cleanInitialUsername = widget.initialUser.username.replaceAll('@', '').toLowerCase();
    final cleanCurrentUsername = _usernameController.text.trim().toLowerCase();

    return _nameController.text.trim() != widget.initialUser.name.trim() ||
        cleanCurrentUsername != cleanInitialUsername ||
        _bioController.text.trim() != widget.initialUser.bio.trim() ||
        _classController.text.trim() != widget.initialUser.classGroup.trim() ||
        _linkController.text.trim() != (widget.initialUser.link ?? '').trim() ||
        _avatar != widget.initialUser.avatar ||
        _showSalesStats != widget.initialUser.showSalesStats ||
        _tags.join(',') != widget.initialUser.tags.join(',');
  }

  Future<void> _handleAttemptExit() async {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final shouldDiscard = await DiscardChangesDialog.show(context);
    if (shouldDiscard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleSave() {
    HapticFeedback.mediumImpact();

    final cleanName = _nameController.text.trim().isEmpty
        ? widget.initialUser.name
        : _nameController.text.trim();
    final cleanUsername = _usernameController.text.trim().isEmpty
        ? widget.initialUser.username
        : _usernameController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9._]'), '');
    final cleanClass = _classController.text.trim().isEmpty
        ? widget.initialUser.classGroup
        : _classController.text.trim();

    final updated = widget.initialUser.copyWith(
      name: cleanName,
      username: cleanUsername,
      bio: _bioController.text.trim(),
      classGroup: cleanClass,
      avatar: _avatar,
      tags: _tags,
      link: _linkController.text.trim(),
      showSalesStats: _showSalesStats,
    );

    widget.onSave(updated);
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleAttemptExit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 50.0,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFF1F5F9),
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back Button (40x40 circular tap area)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 22.0,
                        color: Color(0xFF0F172A),
                      ),
                      tooltip: 'Kembali',
                      onPressed: _handleAttemptExit,
                    ),

                    // Centered Title
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),

                    // Empty spacer for balance
                    const SizedBox(width: 48.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Scrollable Form Fields Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Nama & Avatar with 6 Preset Avatars Accordion
                    EditProfileAvatarSection(
                      nameController: _nameController,
                      currentAvatar: _avatar,
                      onAvatarChanged: (newAvatar) {
                        setState(() => _avatar = newAvatar);
                      },
                    ),

                    // Row 2: Nama Pengguna (@username)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nama pengguna',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              const Text(
                                '@',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 2.0),
                              Expanded(
                                child: TextField(
                                  controller: _usernameController,
                                  maxLength: 30,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'radityarayhannnn',
                                    hintStyle: TextStyle(
                                      fontSize: 15.5,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    counterText: '',
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),

                    // Row 3: Bio with live counter (max 150 chars)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Bio',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.1,
                                ),
                              ),
                              Text(
                                '${_bioController.text.length}/150',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF94A3B8),
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          TextField(
                            controller: _bioController,
                            maxLength: 150,
                            maxLines: 3,
                            minLines: 2,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Color(0xFF0F172A),
                              height: 1.35,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Tulis bio singkat tentang Anda...',
                              hintStyle: TextStyle(
                                fontSize: 14.5,
                                color: Color(0xFF94A3B8),
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

                    const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),

                    // Row 4: Kelas & Jurusan
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kelas & Jurusan',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          TextField(
                            controller: _classController,
                            maxLength: 40,
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Contoh: XII PPLG 1',
                              hintStyle: TextStyle(
                                fontSize: 15.5,
                                color: Color(0xFF94A3B8),
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

                    const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),

                    // Row 5: Minat Chips Editor
                    EditProfileChipsEditor(
                      tags: _tags,
                      onTagsChanged: (updatedTags) {
                        setState(() => _tags = updatedTags);
                      },
                    ),

                    const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),

                    // Row 6: Tautan (Link / Instagram / WA)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Tautan',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.1,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18.0,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          TextField(
                            controller: _linkController,
                            maxLength: 100,
                            style: const TextStyle(
                              fontSize: 15.0,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'https://instagram.com/... atau https://wa.me/...',
                              hintStyle: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFF94A3B8),
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

                    const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),

                    // Row 7: Toggle - Tampilkan statistik penjualan
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tampilkan statistik penjualan',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.1,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _showSalesStats = !_showSalesStats);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44.0,
                              height: 26.0,
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13.0),
                                color: _showSalesStats
                                    ? const Color(0xFF1D64EC)
                                    : const Color(0xFFCBD5E1),
                              ),
                              alignment: _showSalesStats
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 22.0,
                                height: 22.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1F000000),
                                      blurRadius: 2.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),

                    // Row 8: Privasi profil
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Privasi profil',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.1,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Publik',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(width: 2.0),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16.0,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Permanently Fixed Bottom Dual Action CTA Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFF1F5F9),
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 16.0,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Discard Button (Left)
                    Expanded(
                      child: SizedBox(
                        height: 46.0,
                        child: OutlinedButton(
                          onPressed: _handleAttemptExit,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          child: const Text(
                            'Discard',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12.0),

                    // Save Button (Right)
                    Expanded(
                      child: SizedBox(
                        height: 46.0,
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF101010),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
}
