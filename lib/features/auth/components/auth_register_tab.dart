import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/components/auth_text_field.dart';
import 'package:snapan_market/features/auth/components/auth_class_picker.dart';
import 'package:snapan_market/features/auth/components/auth_social_section.dart';

class AuthRegisterTab extends StatelessWidget {
  final TextEditingController fullNameController;
  final String? fullNameError;
  final String? selectedGrade;
  final String? selectedMajor;
  final String? selectedClassNum;
  final String? classError;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onMajorChanged;
  final ValueChanged<String?> onClassNumChanged;
  final TextEditingController usernameController;
  final String? usernameError;
  final TextEditingController passwordController;
  final String? passwordError;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final bool agreedTerms;
  final VoidCallback onToggleAgreedTerms;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleAuth;

  const AuthRegisterTab({
    super.key,
    required this.fullNameController,
    this.fullNameError,
    required this.selectedGrade,
    required this.selectedMajor,
    required this.selectedClassNum,
    this.classError,
    required this.onGradeChanged,
    required this.onMajorChanged,
    required this.onClassNumChanged,
    required this.usernameController,
    this.usernameError,
    required this.passwordController,
    this.passwordError,
    required this.showPassword,
    required this.onTogglePassword,
    required this.agreedTerms,
    required this.onToggleAgreedTerms,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onGoogleAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthInputField(
          label: 'Nama Lengkap',
          hint: 'Masukkan nama anda',
          prefixIcon: LucideIcons.user,
          controller: fullNameController,
          errorText: fullNameError,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16.0),
        AuthClassPicker(
          selectedGrade: selectedGrade,
          selectedMajor: selectedMajor,
          selectedClassNum: selectedClassNum,
          classError: classError,
          onGradeChanged: onGradeChanged,
          onMajorChanged: onMajorChanged,
          onClassNumChanged: onClassNumChanged,
        ),
        const SizedBox(height: 16.0),
        AuthInputField(
          label: 'Username',
          hint: '@username_kamu',
          prefixIcon: LucideIcons.atSign,
          controller: usernameController,
          errorText: usernameError,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(text: newValue.text.toLowerCase());
            }),
          ],
        ),
        const SizedBox(height: 16.0),
        AuthInputField(
          label: 'Kata Sandi',
          hint: 'Minimal 6 karakter',
          prefixIcon: LucideIcons.lock,
          controller: passwordController,
          isPassword: true,
          showPassword: showPassword,
          onTogglePassword: onTogglePassword,
          errorText: passwordError,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 16.0),
        _buildRegisterTermsRow(),
        const SizedBox(height: 22.0),
        PrimaryAuthButton(
          text: 'Buat Akun Sekarang',
          isLoading: isSubmitting,
          onPressed: onSubmit,
        ),
        const SizedBox(height: 22.0),
        AuthSocialSection(
          dividerText: 'atau daftar dengan',
          onGoogleAuth: onGoogleAuth,
        ),
      ],
    );
  }

  Widget _buildRegisterTermsRow() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onToggleAgreedTerms();
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              color: agreedTerms ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: agreedTerms ? AppColors.primary : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: agreedTerms
                ? const Icon(Icons.check_rounded, size: 14.0, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10.0),
          const Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Saya menyetujui ',
                style: TextStyle(
                  fontSize: 13.0,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: 'Ketentuan Komunitas',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(text: ' dan '),
                  TextSpan(
                    text: 'Kebijakan Privasi SMKN 8',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
