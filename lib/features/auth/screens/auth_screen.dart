import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/components/auth_header.dart';
import 'package:snapan_market/features/auth/components/dropdown_column_box.dart';
import 'package:snapan_market/features/auth/components/kumo_floating_field.dart';
import 'package:snapan_market/features/auth/components/social_auth_row.dart';
import 'package:snapan_market/features/auth/models/auth_constants.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

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
  final TextEditingController _loginUsernameController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _showLoginPassword = false;
  bool _rememberMe = true;

  // --- REGISTER CONTROLLERS ---
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _regUsernameController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regRepeatPasswordController = TextEditingController();

  // --- ERROR STATES ---
  String? _loginUsernameError;
  String? _loginPasswordError;
  String? _fullNameError;
  String? _regUsernameError;
  String? _regPasswordError;
  String? _regRepeatPasswordError;

  // --- SMKN 8 SELECTION STATE ---
  String _selectedGrade = AuthConstants.gradeOptions.first;
  String _selectedMajor = AuthConstants.majorOptions.first;
  String _selectedClassNum = AuthConstants.classNumOptions.first;

  bool _showRegPassword = false;
  bool _showRegRepeatPassword = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loginUsernameController.addListener(() => _clearError(() => _loginUsernameError = null));
    _loginPasswordController.addListener(() => _clearError(() => _loginPasswordError = null));
    _fullNameController.addListener(() => _clearError(() => _fullNameError = null));
    _regUsernameController.addListener(() => _clearError(() => _regUsernameError = null));
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
    _loginUsernameError = null;
    _loginPasswordError = null;
    _fullNameError = null;
    _regUsernameError = null;
    _regPasswordError = null;
    _regRepeatPasswordError = null;
  }

  @override
  void dispose() {
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _fullNameController.dispose();
    _regUsernameController.dispose();
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

  // --- GOOGLE OAUTH SIGN IN ---
  Future<void> _handleGoogleAuth() async {
    setState(() => _isSubmitting = true);
    try {
      final success = await SupabaseService.instance.signInWithGoogle();
      if (success && mounted) {
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Google gagal: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- SUBMIT LOGIN VALIDATION & SUPABASE CALL ---
  Future<void> _submitLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(_clearAllErrors);

    bool isValid = true;
    final usernameInput = _loginUsernameController.text.trim().toLowerCase().replaceAll('@', '');

    if (usernameInput.isEmpty) {
      _loginUsernameError = 'Masukkan username Anda';
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

    setState(() => _isSubmitting = true);

    try {
      final email = usernameInput.contains('@')
          ? usernameInput
          : '$usernameInput@snapan.id';

      final response = await SupabaseService.instance.client.auth.signInWithPassword(
        email: email,
        password: _loginPasswordController.text,
      );

      if (response.user != null && mounted) {
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('retryable') ||
            errStr.contains('xmlhttprequest') ||
            errStr.contains('failed host lookup') ||
            errStr.contains('socketexception') ||
            errStr.contains('connection')) {
          _loginPasswordError = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
        } else {
          _loginPasswordError = 'Username atau kata sandi tidak sesuai';
        }
        setState(() {});
        HapticFeedback.vibrate();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // --- SUBMIT REGISTER VALIDATION & SUPABASE CALL ---
  Future<void> _submitRegister() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(_clearAllErrors);

    bool isValid = true;

    // 1. Nama Lengkap
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      _fullNameError = 'Nama lengkap wajib diisi';
      isValid = false;
    }

    // 2. Username
    final rawUsername = _regUsernameController.text.trim().toLowerCase().replaceAll('@', '');
    final validUsernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');
    if (rawUsername.isEmpty) {
      _regUsernameError = 'Username wajib diisi';
      isValid = false;
    } else if (rawUsername.length < 3) {
      _regUsernameError = 'Username minimal 3 karakter';
      isValid = false;
    } else if (rawUsername.length > 20) {
      _regUsernameError = 'Username maksimal 20 karakter';
      isValid = false;
    } else if (!validUsernameRegex.hasMatch(rawUsername)) {
      _regUsernameError = 'Hanya huruf kecil (a-z), angka (0-9), dan underscore (_)';
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

    setState(() => _isSubmitting = true);

    try {
      // Cek ketersediaan username di database
      final isTaken = await SupabaseService.instance.isUsernameTaken(rawUsername);
      if (isTaken) {
        if (mounted) {
          setState(() {
            _regUsernameError = 'Username @$rawUsername sudah digunakan. Pilih username lain.';
            _isSubmitting = false;
          });
          HapticFeedback.vibrate();
        }
        return;
      }

      final email = '$rawUsername@snapan.id';
      final classGroup = '$_selectedGrade $_selectedMajor $_selectedClassNum';

      final response = await SupabaseService.instance.client.auth.signUp(
        email: email,
        password: pass,
        data: {
          'full_name': fullName,
          'username': rawUsername,
          'class_group': classGroup,
        },
      );

      if (response.user != null) {
        // Simpan / update profil
        await SupabaseService.instance.updateProfile(
          userId: response.user!.id,
          fullName: fullName,
          username: rawUsername,
          classGroup: classGroup,
        );

        if (mounted) {
          widget.onSuccess();
        }
      }
    } catch (e) {
      if (mounted) {
        String message = 'Pendaftaran gagal. Silakan coba lagi.';
        final errStr = e.toString().toLowerCase();

        if (errStr.contains('already registered') || errStr.contains('user_already_exists')) {
          message = 'Username sudah terdaftar. Silakan beralih ke tab Masuk.';
        } else if (errStr.contains('retryable') ||
            errStr.contains('xmlhttprequest') ||
            errStr.contains('failed host lookup') ||
            errStr.contains('socketexception') ||
            errStr.contains('connection')) {
          message = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
        } else if (errStr.contains('rate limit')) {
          message = 'Terlalu banyak percobaan. Silakan tunggu beberapa saat.';
        } else {
          message = 'Pendaftaran gagal: ${e.toString().replaceAll('Exception: ', '').replaceAll('AuthApiException: ', '')}';
        }

        setState(() {
          _regPasswordError = message;
        });
        HapticFeedback.vibrate();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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

        // 1. Username Field
        KumoFloatingField(
          label: 'Username',
          controller: _loginUsernameController,
          keyboardType: TextInputType.text,
          errorText: _loginUsernameError,
          prefixWidget: const Padding(
            padding: EdgeInsets.only(left: 4, right: 6),
            child: Text(
              '@',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
          ],
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
          text: _isSubmitting ? 'Memproses...' : 'Masuk',
          width: double.infinity,
          height: 52,
          borderRadius: 16,
          onPressed: _isSubmitting ? null : _submitLogin,
        ),

        const SizedBox(height: 22),

        // 5. Social Buttons
        SocialAuthRow(
          onAppleTap: () {},
          onGoogleTap: _handleGoogleAuth,
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

        // 2. Username Field
        KumoFloatingField(
          label: 'Username',
          controller: _regUsernameController,
          errorText: _regUsernameError,
          prefixWidget: const Padding(
            padding: EdgeInsets.only(left: 4, right: 6),
            child: Text(
              '@',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
            LengthLimitingTextInputFormatter(20),
          ],
        ),

        const SizedBox(height: 18),

        // 3. Dropdown Grid 3 Kolom (Kelas, Jurusan, No. Kelas)
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
          text: _isSubmitting ? 'Mendaftar...' : 'Daftar',
          width: double.infinity,
          height: 52,
          borderRadius: 16,
          onPressed: _isSubmitting ? null : _submitRegister,
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
