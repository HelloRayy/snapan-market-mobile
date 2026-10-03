import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/global_notification_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/auth/components/auth_brand_header.dart';
import 'package:snapan_market/features/auth/components/auth_login_tab.dart';
import 'package:snapan_market/features/auth/components/auth_register_tab.dart';
import 'package:snapan_market/features/auth/components/auth_footer_switcher.dart';
import 'package:snapan_market/features/auth/controllers/auth_controller.dart';

enum AuthMode { login, register }

/// Modern Login & Create Account Screen
/// Clean orchestrator following feature-first modular architecture (<250 lines).
class AuthScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSuccess;
  final Map<String, dynamic>? initialSuspensionInfo;

  const AuthScreen({
    super.key,
    required this.onBack,
    required this.onSuccess,
    this.initialSuspensionInfo,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.login;
  Map<String, dynamic>? _suspensionInfo;

  // Controllers
  final TextEditingController _loginUsernameController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _showLoginPassword = false;
  bool _rememberMe = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _regUsernameController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  bool _showRegPassword = false;
  bool _agreedTerms = false;

  // Grade & Class Selection
  String? _selectedGrade;
  String? _selectedMajor;
  String? _selectedClassNum;

  // Error States
  String? _loginUsernameError;
  String? _loginPasswordError;
  String? _fullNameError;
  String? _regUsernameError;
  String? _regPasswordError;
  String? _classError;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _suspensionInfo = widget.initialSuspensionInfo;
    for (final c in [_loginUsernameController, _loginPasswordController, _fullNameController, _regUsernameController, _regPasswordController]) {
      c.addListener(() {
        if (mounted && (_loginUsernameError != null || _loginPasswordError != null || _fullNameError != null || _regUsernameError != null || _regPasswordError != null)) {
          setState(_clearAllErrors);
        }
      });
    }
  }

  void _clearAllErrors() {
    _loginUsernameError = null;
    _loginPasswordError = null;
    _fullNameError = null;
    _regUsernameError = null;
    _regPasswordError = null;
    _classError = null;
  }

  @override
  void dispose() {
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _fullNameController.dispose();
    _regUsernameController.dispose();
    _regPasswordController.dispose();
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

  Future<void> _handleGoogleAuth() async {
    HapticFeedback.selectionClick();
    setState(() => _isSubmitting = true);
    try {
      final success = await SupabaseService.instance.signInWithGoogle();
      if (success && mounted) {
        // Cek apakah akun berstatus ditangguhkan (suspended) (SNAPS-16)
        final suspension = await SupabaseService.instance.auth.getCurrentUserSuspensionStatus();
        if (suspension != null) {
          await SupabaseService.instance.signOut();
          final reason = suspension['suspend_reason'] as String? ??
              'Pelanggaran terhadap tata tertib komunitas SMKN 8 Semarang.';
          final untilStr = suspension['suspended_until'] as String?;
          final until = untilStr != null ? DateTime.tryParse(untilStr) : null;
          final untilFormatted = until == null
              ? 'Permanen (Tanpa Batas Waktu)'
              : 'Berlaku hingga ${until.day}/${until.month}/${until.year} ${until.hour.toString().padLeft(2, '0')}:${until.minute.toString().padLeft(2, '0')} WIB';
          setState(() {
            _suspensionInfo = {
              'reason': reason,
              'untilText': untilFormatted,
            };
          });
          return;
        }
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

  Future<void> _submitLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(_clearAllErrors);

    final username = _loginUsernameController.text.trim().toLowerCase().replaceAll('@', '');
    if (username.isEmpty) {
      setState(() => _loginUsernameError = 'Masukkan username Anda');
      return;
    }
    if (_loginPasswordController.text.isEmpty) {
      setState(() => _loginPasswordError = 'Masukkan kata sandi Anda');
      return;
    }

    setState(() => _isSubmitting = true);
    final error = await AuthController.submitLogin(
      username: username,
      password: _loginPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == null) {
      setState(() => _suspensionInfo = null);
      unawaited(GlobalNotificationService.instance.syncFcmTokenNow());
      widget.onSuccess();
    } else if (error.startsWith('ACCOUNT_SUSPENDED::')) {
      final parts = error.split('::');
      setState(() {
        _suspensionInfo = {
          'reason': parts.length > 1 ? parts[1] : 'Pelanggaran terhadap tata tertib komunitas SMKN 8 Semarang.',
          'untilText': parts.length > 2 ? parts[2] : 'Permanen',
        };
      });
      HapticFeedback.vibrate();
    } else {
      setState(() => _loginPasswordError = error);
      HapticFeedback.vibrate();
    }
  }

  Future<void> _submitRegister() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(_clearAllErrors);

    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      setState(() => _fullNameError = 'Nama lengkap wajib diisi');
      return;
    }

    if (_selectedGrade == null || _selectedMajor == null || _selectedClassNum == null) {
      setState(() => _classError = 'Pilih kelas, jurusan, dan nomor ruang Anda');
      return;
    }

    final rawUsername = _regUsernameController.text.trim().toLowerCase().replaceAll('@', '');
    if (rawUsername.length < 3 || rawUsername.length > 20) {
      setState(() => _regUsernameError = 'Username harus 3-20 karakter');
      return;
    }

    final pass = _regPasswordController.text;
    if (pass.length < 6) {
      setState(() => _regPasswordError = 'Kata sandi minimal 6 karakter');
      return;
    }

    if (!_agreedTerms) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Ketentuan Komunitas & Privasi SMKN 8'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final error = await AuthController.submitRegister(
      fullName: fullName,
      rawUsername: rawUsername,
      grade: _selectedGrade!,
      major: _selectedMajor!,
      classNum: _selectedClassNum!,
      password: pass,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == null) {
      unawaited(GlobalNotificationService.instance.syncFcmTokenNow());
      widget.onSuccess();
    } else {
      setState(() => _regPasswordError = error);
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 24.0),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthBrandHeader(
                          onBack: _handleBack,
                          title: _authMode == AuthMode.login ? 'Masuk Akun' : 'Daftar Akun Baru',
                          subtitle: _authMode == AuthMode.login
                              ? 'Selamat datang kembali, Snapanians!'
                              : 'Daftarkan akunmu untuk berjejaring dan belanja bareng!',
                        ),
                        const SizedBox(height: 26.0),
                        if (_authMode == AuthMode.login)
                          AuthLoginTab(
                            usernameController: _loginUsernameController,
                            passwordController: _loginPasswordController,
                            showPassword: _showLoginPassword,
                            onTogglePassword: () => setState(() => _showLoginPassword = !_showLoginPassword),
                            usernameError: _loginUsernameError,
                            passwordError: _loginPasswordError,
                            rememberMe: _rememberMe,
                            onToggleRememberMe: () => setState(() => _rememberMe = !_rememberMe),
                            isSubmitting: _isSubmitting,
                            onSubmit: _submitLogin,
                            onGoogleAuth: _handleGoogleAuth,
                            suspensionInfo: _suspensionInfo,
                            onDismissSuspension: () => setState(() => _suspensionInfo = null),
                          )
                        else
                          AuthRegisterTab(
                            fullNameController: _fullNameController,
                            fullNameError: _fullNameError,
                            selectedGrade: _selectedGrade,
                            selectedMajor: _selectedMajor,
                            selectedClassNum: _selectedClassNum,
                            classError: _classError,
                            onGradeChanged: (val) => setState(() => _selectedGrade = val),
                            onMajorChanged: (val) => setState(() => _selectedMajor = val),
                            onClassNumChanged: (val) => setState(() => _selectedClassNum = val),
                            usernameController: _regUsernameController,
                            usernameError: _regUsernameError,
                            passwordController: _regPasswordController,
                            passwordError: _regPasswordError,
                            showPassword: _showRegPassword,
                            onTogglePassword: () => setState(() => _showRegPassword = !_showRegPassword),
                            agreedTerms: _agreedTerms,
                            onToggleAgreedTerms: () => setState(() => _agreedTerms = !_agreedTerms),
                            isSubmitting: _isSubmitting,
                            onSubmit: _submitRegister,
                            onGoogleAuth: _handleGoogleAuth,
                          ),
                        const Spacer(),
                        const SizedBox(height: 18.0),
                        AuthFooterSwitcher(
                          isLogin: _authMode == AuthMode.login,
                          onSwitch: () => setState(() {
                            _authMode = _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
                            _clearAllErrors();
                          }),
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
