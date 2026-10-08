import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/services/student_registry_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/components/auth_text_field.dart';
import 'package:snapan_market/features/auth/components/student_nis_combobox.dart';

class AuthRegisterTab extends StatelessWidget {
  final TextEditingController nisController;
  final String? nisError;
  final RegisteredStudent? verifiedStudent;
  final ValueChanged<RegisteredStudent?> onStudentSelected;

  final TextEditingController displayNameController;
  final String? displayNameError;
  final TextEditingController usernameController;
  final String? usernameError;
  final TextEditingController passwordController;
  final String? passwordError;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final bool agreedTerms;
  final VoidCallback onToggleAgreedTerms;
  final bool isSubmitting;
  final bool isGeneratingUsername;
  final VoidCallback onSubmit;

  const AuthRegisterTab({
    super.key,
    required this.nisController,
    this.nisError,
    this.verifiedStudent,
    required this.onStudentSelected,
    required this.displayNameController,
    this.displayNameError,
    required this.usernameController,
    this.usernameError,
    required this.passwordController,
    this.passwordError,
    required this.showPassword,
    required this.onTogglePassword,
    required this.agreedTerms,
    required this.onToggleAgreedTerms,
    required this.isSubmitting,
    this.isGeneratingUsername = false,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. COMBOBOX NIS SISWA DENGAN FLOATING OVERLAY & BORDER HIJAU DINAMIS
        StudentNisCombobox(
          controller: nisController,
          errorText: nisError,
          verifiedStudent: verifiedStudent,
          onStudentSelected: onStudentSelected,
        ),
        const SizedBox(height: 16.0),

        // 2. NAMA TAMPILAN / BRAND (OPSIONAL, MAX 20 KARAKTER)
        AuthInputField(
          label: 'Nama Tampilan / Brand (Opsional)',
          hint: 'Contoh: Budi Studio, Dhea Craft',
          prefixIcon: LucideIcons.user,
          controller: displayNameController,
          errorText: displayNameError,
          maxLength: 20,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
          ],
        ),
        const SizedBox(height: 16.0),

        // 3. USERNAME @ (AUTO SUGGEST DARI NAMA DEPAN + TENGAH DENGAN LOADING SPINNER)
        AuthInputField(
          label: isGeneratingUsername ? 'Memilih username...' : 'Username',
          hint: isGeneratingUsername ? 'Menyiapkan rekomendasi...' : '@username',
          prefixIcon: LucideIcons.atSign,
          controller: usernameController,
          errorText: usernameError,
          customSuffixIcon: isGeneratingUsername
              ? const Padding(
                  padding: EdgeInsets.only(right: 14.0),
                  child: SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                )
              : null,
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

        // 4. KATA SANDI
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

        // 5. PERSETUJUAN KETENTUAN
        _buildRegisterTermsRow(),
        const SizedBox(height: 22.0),

        // 6. TOMBOL AKSI (Disable abu-abu jika belum lengkap atau belum setuju S&K)
        ListenableBuilder(
          listenable: Listenable.merge([nisController, usernameController, passwordController]),
          builder: (context, _) {
            final bool isFormComplete = nisController.text.trim().isNotEmpty &&
                usernameController.text.trim().isNotEmpty &&
                passwordController.text.isNotEmpty &&
                agreedTerms;

            return PrimaryAuthButton(
              text: 'Aktifkan Akun & Masuk',
              isLoading: isSubmitting,
              isEnabled: isFormComplete,
              onPressed: onSubmit,
            );
          },
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
                    text: 'Ketentuan Komunitas & Privasi SMKN 8',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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
