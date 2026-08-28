import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/phone_number_formatter.dart';
import 'package:snapan_market/features/auth/components/auth_header.dart';
import 'package:snapan_market/features/auth/components/dropdown_column_box.dart';
import 'package:snapan_market/features/auth/components/kumo_floating_field.dart';
import 'package:snapan_market/features/auth/components/social_auth_row.dart';
import 'package:snapan_market/features/auth/models/auth_constants.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const AuthScreen({
    super.key,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.login;

  // --- LOGIN CONTROLLERS ---
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _showLoginPassword = false;
  bool _rememberMe = true;

  // --- REGISTER CONTROLLERS ---
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regRepeatPasswordController = TextEditingController();

  // --- ERROR STATES ---
  String? _loginEmailError;
  String? _loginPasswordError;
  String? _fullNameError;
  String? _phoneError;
  String? _regPasswordError;
  String? _regRepeatPasswordError;

  // --- SMKN 8 SELECTION STATE ---
  String _selectedGrade = AuthConstants.gradeOptions.first;
  String _selectedMajor = AuthConstants.majorOptions.first;
  String _selectedClassNum = AuthConstants.classNumOptions.first;

  bool _showRegPassword = false;
  bool _showRegRepeatPassword = false;

  @override
  void initState() {
    super.initState();
    _loginEmailController.addListener(() => _clearError(() => _loginEmailError = null));
    _loginPasswordController.addListener(() => _clearError(() => _loginPasswordError = null));
    _fullNameController.addListener(() => _clearError(() => _fullNameError = null));
    _phoneController.addListener(() => _clearError(() => _phoneError = null));
    _regPasswordController.addListener(() => _clearError(() {
      _regPasswordError = null;
      _regRepeatPasswordError = null;
    }));
    _regRepeatPasswordController.addListener(() => _clearError(() => _regRepeatPasswordError = null));
  }

  void _clearError(VoidCallback update) {
    setState(update);
  }

  void _clearAllErrors() {
    _loginEmailError = null;
    _loginPasswordError = null;
    _fullNameError = null;
    _phoneError = null;
    _regPasswordError = null;
    _regRepeatPasswordError = null;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _regPasswordController.dispose();
    _regRepeatPasswordController.dispose();
    super.dispose();
  }

  void _handleBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_authMode == AuthMode.register) {
      setState(() {
        _authMode = AuthMode.login;
        _clearAllErrors();
      });
    } else {
      widget.onBack();
    }
  }

  // --- SUBMIT LOGIN VALIDATION ---
  void _submitLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(_clearAllErrors);

    bool isValid = true;

    if (_loginEmailController.text.trim().isEmpty) {
      _loginEmailError = 'Masukkan nomor WhatsApp atau email';
      isValid = false;
    }
    if (_loginPasswordController.text.isEmpty) {
      _loginPasswordError = 'Masukkan kata sandi';
      isValid = false;
    }

    if (!isValid) {
      HapticFeedback.vibrate();
      setState(() {});
      return;
    }

    widget.onSuccess();
  }

  // --- SUBMIT REGISTER VALIDATION ---
  void _submitRegister() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(_clearAllErrors);

    bool isValid = true;

    // 1. Nama Lengkap
    if (_fullNameController.text.trim().isEmpty) {
      _fullNameError = 'Nama lengkap wajib diisi';
      isValid = false;
    }

    // 2. Nomor WhatsApp
    final rawPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (rawPhone.isEmpty) {
      _phoneError = 'Nomor WhatsApp wajib diisi';
      isValid = false;
    } else if (rawPhone.length < 8) {
      _phoneError = 'Nomor WhatsApp minimal 8 angka';
      isValid = false;
    }

    // 3. Kata Sandi
    final pass = _regPasswordController.text;
    final repeatPass = _regRepeatPasswordController.text;

    if (pass.isEmpty) {
      _regPasswordError = 'Kata sandi wajib diisi';
      isValid = false;
    } else if (pass.length < 6) {
      _regPasswordError = 'Kata sandi minimal 6 karakter';
      isValid = false;
    }

    // 4. Kesamaan Kata Sandi
    if (repeatPass.isEmpty) {
      _regRepeatPasswordError = 'Ulangi kata sandi wajib diisi';
      isValid = false;
    } else if (pass != repeatPass) {
      _regRepeatPasswordError = 'Kata sandi tidak sama. Pastikan kedua kata sandi cocok.';
      isValid = false;
    }

    if (!isValid) {
      HapticFeedback.vibrate();
      setState(() {});
      return;
    }

    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.authGradient,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Header with Title & Back Button
                AuthHeader(
                  title: _authMode == AuthMode.login
                      ? 'Masuk\nke Akun Kamu'
                      : 'Daftar\nAkun Baru',
                  onBack: _handleBack,
                ),

                // Bottom Form Card (Styled like a modern Bottom Sheet)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag Handle / Pill Indicator
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 38,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Scrollable Form Content
                        Expanded(
                          child: RepaintBoundary(
                            child: SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                12,
                                24,
                                28,
                              ),
                              child: _authMode == AuthMode.login
                                  ? _buildLoginForm()
                                  : _buildRegisterForm(),
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
        ),
      ),
    );
  }

  // ==========================================
  // --- LOGIN FORM ---
  // ==========================================
  Widget _buildLoginForm() {
    return Column(
      children: [
        const SizedBox(height: 6),

        // 1. WhatsApp / Email Field
        KumoFloatingField(
          label: 'Nomor WhatsApp / Email',
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          errorText: _loginEmailError,
        ),

        const SizedBox(height: 20),

        // 2. Password Field
        KumoFloatingField(
          label: 'Kata Sandi',
          controller: _loginPasswordController,
          obscureText: !_showLoginPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitLogin(),
          errorText: _loginPasswordError,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _showLoginPassword = !_showLoginPassword),
            child: Icon(
              _showLoginPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.muted,
              size: 20,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Remember Me & Forgot Password Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _rememberMe ? const Color(0xFF1D64EC) : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: _rememberMe
                            ? const Color(0xFF1D64EC)
                            : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: _rememberMe
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 13,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ingat Saya',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.linkBlue,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 4. Kumo Primary Button
        KumoButton.primary(
          text: 'Masuk',
          width: double.infinity,
          height: 52,
          borderRadius: 16,
          onPressed: _submitLogin,
        ),

        const SizedBox(height: 22),

        // 5. Social Buttons
        SocialAuthRow(
          onAppleTap: widget.onSuccess,
          onGoogleTap: widget.onSuccess,
        ),

        const SizedBox(height: 28),

        // 6. Footer Register Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Belum punya akun? ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  _authMode = AuthMode.register;
                  _clearAllErrors();
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  'Daftar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.linkBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // --- REGISTER FORM ---
  // ==========================================
  Widget _buildRegisterForm() {
    return Column(
      children: [
        const SizedBox(height: 6),

        // 1. Full Name Field
        KumoFloatingField(
          label: 'Nama Lengkap',
          controller: _fullNameController,
          errorText: _fullNameError,
        ),

        const SizedBox(height: 18),

        // 2. Dropdown Grid 3 Kolom
        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownColumnBox(
                label: 'Kelas',
                selectedValue: _selectedGrade,
                options: AuthConstants.gradeOptions,
                onSelected: (val) => setState(() => _selectedGrade = val),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: DropdownColumnBox(
                label: 'Jurusan',
                selectedValue: _selectedMajor,
                options: AuthConstants.majorOptions,
                onSelected: (val) => setState(() => _selectedMajor = val),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: DropdownColumnBox(
                label: 'No. Kelas',
                selectedValue: _selectedClassNum,
                options: AuthConstants.classNumOptions,
                onSelected: (val) => setState(() => _selectedClassNum = val),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 3. WhatsApp / Phone Number Field
        KumoFloatingField(
          label: 'Nomor WhatsApp / HP',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          errorText: _phoneError,
          inputFormatters: [
            PhoneNumberFormatter(),
          ],
          prefixWidget: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇮🇩', style: TextStyle(fontSize: 13)),
                SizedBox(width: 4),
                Text(
                  '+62',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // 4. Password Field
        KumoFloatingField(
          label: 'Kata Sandi',
          controller: _regPasswordController,
          obscureText: !_showRegPassword,
          errorText: _regPasswordError,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _showRegPassword = !_showRegPassword),
            child: Icon(
              _showRegPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.muted,
              size: 20,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // 5. Repeat Password Field
        KumoFloatingField(
          label: 'Ulangi Kata Sandi',
          controller: _regRepeatPasswordController,
          obscureText: !_showRegRepeatPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitRegister(),
          errorText: _regRepeatPasswordError,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _showRegRepeatPassword = !_showRegRepeatPassword),
            child: Icon(
              _showRegRepeatPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.muted,
              size: 20,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 6. Kumo Primary Button
        KumoButton.primary(
          text: 'Daftar',
          width: double.infinity,
          height: 52,
          borderRadius: 16,
          onPressed: _submitRegister,
        ),

        const SizedBox(height: 24),

        // 7. Footer Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sudah punya akun? ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  _authMode = AuthMode.login;
                  _clearAllErrors();
                });
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.linkBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
