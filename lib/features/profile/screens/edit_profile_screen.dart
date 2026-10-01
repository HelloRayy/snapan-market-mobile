import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/models/auth_constants.dart';
import 'package:snapan_market/features/profile/components/discard_changes_dialog.dart';
import 'package:snapan_market/features/profile/components/edit_profile_avatar_section.dart';
import 'package:snapan_market/features/profile/components/edit_profile_bottom_bar.dart';
import 'package:snapan_market/features/profile/components/edit_profile_form_fields.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';

/// Full Edit Profile Screen (<250 lines orchestrator).
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
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _linkController;

  String? _selectedGrade;
  String? _selectedMajor;
  String? _selectedClassNum;

  late String _avatar;
  late List<String> _tags;
  late bool _showSalesStats;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUser.name);
    _usernameController = TextEditingController(text: widget.initialUser.username.replaceAll('@', ''));
    _bioController = TextEditingController(text: widget.initialUser.bio);
    _linkController = TextEditingController(text: widget.initialUser.link ?? '');

    final parts = widget.initialUser.classGroup.trim().split(RegExp(r'\s+'));
    for (final p in parts) {
      if (AuthConstants.gradeOptions.contains(p)) _selectedGrade = p;
      if (AuthConstants.majorOptions.contains(p)) _selectedMajor = p;
      if (AuthConstants.classNumOptions.contains(p)) _selectedClassNum = p;
    }

    _avatar = widget.initialUser.avatar;
    _tags = List<String>.from(widget.initialUser.tags);
    _showSalesStats = widget.initialUser.showSalesStats;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  String get _currentClassGroup {
    if (_selectedGrade != null && _selectedMajor != null && _selectedClassNum != null) {
      return '$_selectedGrade $_selectedMajor $_selectedClassNum';
    }
    return widget.initialUser.classGroup;
  }

  bool get _hasChanges {
    final cleanInitialUsername = widget.initialUser.username.replaceAll('@', '').toLowerCase();
    final cleanCurrentUsername = _usernameController.text.trim().toLowerCase();

    return _nameController.text.trim() != widget.initialUser.name.trim() ||
        cleanCurrentUsername != cleanInitialUsername ||
        _bioController.text.trim() != widget.initialUser.bio.trim() ||
        _currentClassGroup.trim() != widget.initialUser.classGroup.trim() ||
        _linkController.text.trim() != (widget.initialUser.link ?? '').trim() ||
        _avatar != widget.initialUser.avatar ||
        _showSalesStats != widget.initialUser.showSalesStats ||
        _tags.join(',') != widget.initialUser.tags.join(',');
  }

  Future<void> _handleAttemptExit() async {
    if (_isSaving) return;
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final shouldDiscard = await DiscardChangesDialog.show(context);
    if (shouldDiscard == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    HapticFeedback.mediumImpact();

    final cleanName = _nameController.text.trim().isEmpty ? widget.initialUser.name : _nameController.text.trim();
    final cleanUsername = _usernameController.text.trim().isEmpty
        ? widget.initialUser.username
        : _usernameController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9._]'), '');
    final cleanClass = _currentClassGroup.isEmpty ? widget.initialUser.classGroup : _currentClassGroup;
    final cleanInitialUsername = widget.initialUser.username.replaceAll('@', '').toLowerCase();

    setState(() => _isSaving = true);

    try {
      if (cleanUsername != cleanInitialUsername) {
        final isTaken = await SupabaseService.instance.isUsernameTaken(cleanUsername);
        if (isTaken) {
          if (mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Username @$cleanUsername sudah digunakan oleh akun lain.'),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      String finalAvatarUrl = _avatar;
      if (!finalAvatarUrl.startsWith('http://') &&
          !finalAvatarUrl.startsWith('https://') &&
          !finalAvatarUrl.startsWith('assets/')) {
        final file = File(finalAvatarUrl);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final fileName = finalAvatarUrl.split(Platform.pathSeparator).last;
          final uploaded = await SupabaseService.instance.uploadImage(
            bytes: bytes,
            fileName: fileName,
            bucket: 'avatars',
          );
          if (uploaded != null) finalAvatarUrl = uploaded;
        }
      }

      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser != null) {
        await SupabaseService.instance.updateProfile(
          userId: currentUser.id,
          fullName: cleanName,
          username: cleanUsername,
          classGroup: cleanClass,
          avatarUrl: finalAvatarUrl,
          bio: _bioController.text.trim(),
          tags: _tags,
          link: _linkController.text.trim(),
        );
      }

      final updated = widget.initialUser.copyWith(
        name: cleanName,
        username: cleanUsername,
        avatar: finalAvatarUrl,
        bio: _bioController.text.trim(),
        classGroup: cleanClass,
        link: _linkController.text.trim(),
        tags: _tags,
        showSalesStats: _showSalesStats,
      );

      widget.onSave(updated);

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan profil: $e'), backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return PopScope(
      canPop: !_hasChanges && !_isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleAttemptExit();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.chevron_back, color: AppColors.ink),
            onPressed: _handleAttemptExit,
          ),
          title: const Text('Edit Profil', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: AppColors.ink)),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isSaving ? null : _handleSave,
                child: _isSaving
                    ? const SizedBox(width: 16.0, height: 16.0, child: CircularProgressIndicator(strokeWidth: 2.0, color: AppColors.primary))
                    : const Text('Simpan', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditProfileAvatarSection(
                      nameController: _nameController,
                      currentAvatar: _avatar,
                      onAvatarChanged: (newAvatar) => setState(() => _avatar = newAvatar),
                    ),
                    EditProfileFormFields(
                      usernameController: _usernameController,
                      bioController: _bioController,
                      linkController: _linkController,
                      selectedGrade: _selectedGrade,
                      selectedMajor: _selectedMajor,
                      selectedClassNum: _selectedClassNum,
                      onGradeChanged: (val) => setState(() => _selectedGrade = val),
                      onMajorChanged: (val) => setState(() => _selectedMajor = val),
                      onClassNumChanged: (val) => setState(() => _selectedClassNum = val),
                      tags: _tags,
                      onTagsChanged: (t) => setState(() => _tags = t),
                      showSalesStats: _showSalesStats,
                      onToggleSalesStats: (v) => setState(() => _showSalesStats = v),
                    ),
                  ],
                ),
              ),
            ),
            if (!isKeyboardOpen)
              EditProfileBottomBar(
                isSaving: _isSaving,
                onDiscard: _handleAttemptExit,
                onSave: _handleSave,
              ),
          ],
        ),
      ),
    );
  }
}
