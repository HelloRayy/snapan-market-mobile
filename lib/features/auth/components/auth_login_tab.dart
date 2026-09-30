import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/components/auth_text_field.dart';
import 'package:snapan_market/features/auth/components/auth_social_section.dart';

class AuthLoginTab extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final String? usernameError;
  final String? passwordError;
  final bool rememberMe;
  final VoidCallback onToggleRememberMe;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleAuth;

  const AuthLoginTab({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.showPassword,
    required this.onTogglePassword,
    this.usernameError,
    this.passwordError,
    required this.rememberMe,
    required this.onToggleRememberMe,
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
          label: 'Username',
          hint: '@username_kamu',
          prefixIcon: LucideIcons.atSign,
          controller: usernameController,
          errorText: usernameError,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._@]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(text: newValue.text.toLowerCase());
            }),
          ],
        ),
        const SizedBox(height: 16.0),
        AuthInputField(
          label: 'Kata Sandi',
          hint: 'Masukkan kata sandi Anda',
          prefixIcon: LucideIcons.lock,
          controller: passwordController,
          isPassword: true,
          showPassword: showPassword,
          onTogglePassword: onTogglePassword,
          errorText: passwordError,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 14.0),
        _buildLoginOptionsRow(context),
        const SizedBox(height: 22.0),
        PrimaryAuthButton(
          text: 'Masuk ke Akun',
          isLoading: isSubmitting,
          onPressed: onSubmit,
        ),
        const SizedBox(height: 22.0),
        AuthSocialSection(
          dividerText: 'atau masuk dengan',
          onGoogleAuth: onGoogleAuth,
        ),
      ],
    );
  }

  Widget _buildLoginOptionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggleRememberMe();
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 20.0,
                height: 20.0,
                decoration: BoxDecoration(
                  color: rememberMe ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: rememberMe ? AppColors.primary : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: rememberMe
                    ? const Icon(Icons.check_rounded, size: 14.0, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8.0),
              const Text(
                'Ingat saya di perangkat ini',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Silakan hubungi administrator sekolah untuk reset kata sandi'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Text(
            'Lupa kata sandi?',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
