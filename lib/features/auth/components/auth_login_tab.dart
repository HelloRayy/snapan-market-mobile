import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/components/auth_text_field.dart';

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
  final Map<String, dynamic>? suspensionInfo;
  final VoidCallback? onDismissSuspension;

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
    this.suspensionInfo,
    this.onDismissSuspension,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (suspensionInfo != null) ...[
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        LucideIcons.triangleAlert,
                        size: 18.0,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'AKUN DITANGGUHKAN',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFBE123C),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (onDismissSuspension != null)
                                GestureDetector(
                                  onTap: onDismissSuspension,
                                  child: const Text(
                                    'Tutup',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF43F5E),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            suspensionInfo!['reason'] as String? ?? 'Pelanggaran terhadap tata tertib komunitas SMKN 8 Semarang.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF881337),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 14.0, color: Color(0xFF991B1B)),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Text(
                          suspensionInfo!['untilText'] as String? ?? 'Masa Penangguhan: Permanen',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
        ],
        AuthInputField(
          label: 'Username atau NIS',
          hint: '@username atau NIS kamu',
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
        ListenableBuilder(
          listenable: Listenable.merge([usernameController, passwordController]),
          builder: (context, _) {
            final bool isFormValid = usernameController.text.trim().isNotEmpty &&
                passwordController.text.isNotEmpty;

            return PrimaryAuthButton(
              text: 'Masuk ke Akun',
              isLoading: isSubmitting,
              isEnabled: isFormValid,
              onPressed: onSubmit,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoginOptionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
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
                const Flexible(
                  child: Text(
                    'Ingat saya',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12.0),
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
