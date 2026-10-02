import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/app_dropdown_field.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/models/auth_constants.dart';
import 'package:snapan_market/features/profile/components/edit_profile_chips_editor.dart';

class FormRow extends StatelessWidget {
  final Widget child;
  final bool showDivider;

  const FormRow({
    super.key,
    required this.child,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0))
            : null,
      ),
      child: child,
    );
  }
}

/// Backward compatibility alias pointing to shared 1:1 AppDropdownField
typedef ProfileDropdownField = AppDropdownField;

class EditProfileFormFields extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController bioController;
  final TextEditingController linkController;
  final String? selectedGrade;
  final String? selectedMajor;
  final String? selectedClassNum;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onMajorChanged;
  final ValueChanged<String?> onClassNumChanged;
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final bool showSalesStats;
  final ValueChanged<bool> onToggleSalesStats;
  final bool showClassError;

  const EditProfileFormFields({
    super.key,
    required this.usernameController,
    required this.bioController,
    required this.linkController,
    required this.selectedGrade,
    required this.selectedMajor,
    required this.selectedClassNum,
    required this.onGradeChanged,
    required this.onMajorChanged,
    required this.onClassNumChanged,
    required this.tags,
    required this.onTagsChanged,
    required this.showSalesStats,
    required this.onToggleSalesStats,
    this.showClassError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username
        FormRow(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama pengguna', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.1)),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  const Text('@', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  const SizedBox(width: 2.0),
                  Expanded(
                    child: TextField(
                      controller: usernameController,
                      maxLength: 30,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
                        TextInputFormatter.withFunction((oldValue, newValue) => newValue.copyWith(text: newValue.text.toLowerCase())),
                      ],
                      style: const TextStyle(fontFamily: 'SFPro', fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                      decoration: const InputDecoration(hintText: 'username_kamu', hintStyle: TextStyle(fontFamily: 'SFPro'), border: InputBorder.none, isDense: true, counterText: '', contentPadding: EdgeInsets.zero),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Bio
        FormRow(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bio', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.1)),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: bioController,
                    builder: (context, value, _) => Text(
                      '${value.text.length}/150',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.lightMuted, fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              TextField(
                controller: bioController,
                maxLength: 150,
                maxLines: 3,
                minLines: 2,
                style: const TextStyle(fontFamily: 'SFPro', fontSize: 14.5, color: AppColors.ink, height: 1.35),
                decoration: const InputDecoration(hintText: 'Tulis bio singkat...', hintStyle: TextStyle(fontFamily: 'SFPro'), border: InputBorder.none, isDense: true, counterText: '', contentPadding: EdgeInsets.symmetric(vertical: 4.0)),
              ),
            ],
          ),
        ),
        // Class & Major
        FormRow(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kelas & Jurusan', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.1)),
                  if (selectedGrade != null && selectedMajor != null && selectedClassNum != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6.0)),
                      child: Text('$selectedGrade $selectedMajor $selectedClassNum', style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppDropdownField(
                      label: 'Kelas',
                      value: selectedGrade,
                      options: AuthConstants.gradeOptions,
                      hasError: showClassError && selectedGrade == null,
                      onChanged: onGradeChanged,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    flex: 4,
                    child: AppDropdownField(
                      label: 'Jurusan',
                      value: selectedMajor,
                      options: AuthConstants.majorOptions,
                      hasError: showClassError && selectedMajor == null,
                      onChanged: onMajorChanged,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    flex: 3,
                    child: AppDropdownField(
                      label: 'Ruang',
                      value: selectedClassNum,
                      options: AuthConstants.classNumOptions,
                      hasError: showClassError && selectedClassNum == null,
                      onChanged: onClassNumChanged,
                    ),
                  ),
                ],
              ),
              if (showClassError && (selectedGrade == null || selectedMajor == null || selectedClassNum == null))
                const Padding(
                  padding: EdgeInsets.only(top: 6.0, left: 4.0),
                  child: Text(
                    'Lengkapi data Kelas, Jurusan, dan Ruang',
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Interest Chips
        FormRow(
          child: EditProfileChipsEditor(tags: tags, onTagsChanged: onTagsChanged),
        ),
        // Link
        FormRow(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tautan', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.1)),
              const SizedBox(height: 4.0),
              TextField(
                controller: linkController,
                maxLength: 100,
                style: const TextStyle(fontFamily: 'SFPro', fontSize: 15.0, color: AppColors.ink),
                decoration: const InputDecoration(hintText: 'https://wa.me/... atau https://instagram.com/...', hintStyle: TextStyle(fontFamily: 'SFPro'), border: InputBorder.none, isDense: true, counterText: '', contentPadding: EdgeInsets.symmetric(vertical: 4.0)),
              ),
            ],
          ),
        ),
        // Toggle Sales Stats
        FormRow(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tampilkan statistik penjualan', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.1)),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggleSalesStats(!showSalesStats);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44.0,
                  height: 26.0,
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13.0),
                    color: showSalesStats ? AppColors.primary : const Color(0xFFCBD5E1),
                  ),
                  alignment: showSalesStats ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 22.0,
                    height: 22.0,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Privacy Row
        const FormRow(
          showDivider: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Privasi profil', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.1)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Publik', style: TextStyle(fontSize: 13.5, color: AppColors.lightMuted)),
                  SizedBox(width: 2.0),
                  Icon(Icons.chevron_right_rounded, size: 16.0, color: AppColors.lightMuted),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
