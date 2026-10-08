import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/update_info_bottom_sheet.dart';
import 'package:snapan_market/core/services/app_update_service.dart';
import 'package:snapan_market/core/services/global_notification_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';
import 'package:snapan_market/features/auth/components/auth_login_tab.dart';
import 'package:snapan_market/features/auth/components/auth_register_tab.dart';
import 'package:snapan_market/features/auth/components/auth_footer_switcher.dart';
import 'package:snapan_market/features/auth/controllers/auth_controller.dart';
import 'package:snapan_market/features/auth/components/student_confirmation_dialog.dart';

import 'package:snapan_market/core/services/student_registry_service.dart';

enum AuthMode { login, register }

/// Modern Login & Create Account Screen
/// Clean orchestrator following feature-first modular architecture (<250 lines).
class AuthScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSuccess;
  final Map<String, dynamic>? initialSuspensionInfo;
  final bool initialAccountDeletedNotice;

  const AuthScreen({
    super.key,
    required this.onBack,
    required this.onSuccess,
    this.initialSuspensionInfo,
    this.initialAccountDeletedNotice = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.login;
  Map<String, dynamic>? _suspensionInfo;
  bool _showAccountDeletedNotice = false;

  // Controllers
  final TextEditingController _loginUsernameController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _showLoginPassword = false;
  bool _rememberMe = true;

  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _regDisplayNameController = TextEditingController();
  final TextEditingController _regUsernameController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  RegisteredStudent? _verifiedStudent;
  bool _showRegPassword = false;
  bool _agreedTerms = false;
  bool _isGeneratingUsername = false;

  // Error States
  String? _loginUsernameError;
  String? _loginPasswordError;
  String? _nisError;
  String? _fullNameError;
  String? _regDisplayNameError;
  String? _regUsernameError;
  String? _regPasswordError;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _suspensionInfo = widget.initialSuspensionInfo;
    _showAccountDeletedNotice = widget.initialAccountDeletedNotice;
    if (_showAccountDeletedNotice) {
      _authMode = AuthMode.register;
    }
    for (final c in [_loginUsernameController, _loginPasswordController, _nisController, _fullNameController, _regDisplayNameController, _regUsernameController, _regPasswordController]) {
      c.addListener(() {
        if (mounted && (_loginUsernameError != null || _loginPasswordError != null || _nisError != null || _fullNameError != null || _regDisplayNameError != null || _regUsernameError != null || _regPasswordError != null)) {
          setState(_clearAllErrors);
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdate();
    });
  }

  Future<void> _checkForAppUpdate() async {
    try {
      final update = await AppUpdateService.instance.checkForUpdate(isManual: false);
      if (update != null && mounted) {
        final info = await AppUpdateService.instance.getPackageInfo();
        if (!mounted) return;
        UpdateInfoBottomSheet.show(context, update: update, currentVersionName: info.version);
      }
    } catch (e) {
      debugPrint('Update check error in AuthScreen: $e');
    }
  }

  void _clearAllErrors() {
    _loginUsernameError = null;
    _loginPasswordError = null;
    _nisError = null;
    _fullNameError = null;
    _regDisplayNameError = null;
    _regUsernameError = null;
    _regPasswordError = null;
  }

  Future<void> _handleStudentSelected(RegisteredStudent? student) async {
    if (student == null) {
      setState(() {
        _verifiedStudent = null;
        _fullNameController.clear();
        _regDisplayNameController.clear();
      });
      return;
    }

    // Dismiss active keyboard for clean presentation
    FocusManager.instance.primaryFocus?.unfocus();

    // Show clean horizontal confirmation popup: "Apakah Anda {Nama Lengkap}?"
    final confirmed = await StudentConfirmationDialog.show(
      context,
      student: student,
    );

    if (confirmed != true) {
      // User cancelled or pressed "Bukan Saya"
      setState(() {
        _verifiedStudent = null;
        _nisController.clear();
        _fullNameController.clear();
        _regDisplayNameController.clear();
        _regUsernameController.clear();
      });
      return;
    }

    // User confirmed: Lock student identity & set green border
    setState(() {
      _nisController.text = student.nis;
      _verifiedStudent = student;
      _fullNameController.text = student.name;
      _regDisplayNameController.clear(); // Keep empty by default as per UX specification
      _nisError = null;
      _isGeneratingUsername = true;
    });

    // Auto generate username: [nama depan + nama tengah]
    final baseUsername = StudentRegistryService.generateSuggestedUsername(student.name);
    String targetUsername = baseUsername;

    // Check if username already taken, if taken add random number
    try {
      final isTaken = await SupabaseService.instance.isUsernameTaken(targetUsername);
      if (isTaken) {
        final rand = (DateTime.now().millisecondsSinceEpoch % 899) + 100;
        targetUsername = '${baseUsername}_$rand';
      }
    } catch (_) {
      // Offline fallback
    }

    if (mounted) {
      setState(() {
        _regUsernameController.text = targetUsername;
        _isGeneratingUsername = false;
      });
    }
  }

  @override
  void dispose() {
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _nisController.dispose();
    _fullNameController.dispose();
    _regDisplayNameController.dispose();
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

    final rawNis = _nisController.text.trim();
    if (rawNis.isEmpty) {
      setState(() => _nisError = 'NIS siswa wajib diisi');
      return;
    }

    if (_verifiedStudent == null) {
      final student = StudentRegistryService.instance.findByNis(rawNis);
      if (student == null) {
        setState(() => _nisError = 'NIS belum terdaftar sebagai siswa SMKN 8');
        return;
      }
      _verifiedStudent = student;
      _fullNameController.text = student.name;
    }

    final fullName = _verifiedStudent!.name;
    final classGroup = _verifiedStudent!.classGroup;

    final rawDisplayName = _regDisplayNameController.text.trim();
    if (rawDisplayName.isNotEmpty && rawDisplayName.length > 20) {
      setState(() => _regDisplayNameError = 'Nama tampilan maksimal 20 karakter');
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
      displayName: rawDisplayName.isNotEmpty ? rawDisplayName : null,
      rawUsername: rawUsername,
      classGroup: classGroup,
      nis: rawNis,
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
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 100;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        // If soft keyboard is visible, swipe back gesture should ONLY close keyboard (SNAPS-48)
        if (isKeyboardOpen || (FocusManager.instance.primaryFocus?.hasFocus ?? false)) {
          FocusManager.instance.primaryFocus?.unfocus();
          return;
        }

        // If keyboard is already closed and we are in register mode, return to login tab
        if (_authMode == AuthMode.register) {
          setState(() {
            _authMode = AuthMode.login;
            _clearAllErrors();
          });
          return;
        }

        // Otherwise delegate to onBack handler
        widget.onBack();
      },
      child: GestureDetector(
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 16.0,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. TOP BAR: Back button
                          GestureDetector(
                            onTap: _handleBack,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 38.0,
                              height: 38.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x08000000),
                                    blurRadius: 4.0,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 24.0,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),

                          // Equal top spacer pushes central block to optical center
                          const Spacer(flex: 1),
                          const SizedBox(height: 12.0),

                          // 2. CENTRAL CONTENT BLOCK (Logo + Header + Form tightly grouped)
                          const Center(
                            child: SnapsLogo(height: 44.0),
                          ),
                          const SizedBox(height: 20.0),

                          // Headline & Subtitle center-aligned directly attached to inputs
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _authMode == AuthMode.login ? 'Masuk Akun' : 'Daftar Akun Baru',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                Text(
                                  _authMode == AuthMode.login
                                      ? 'Selamat datang kembali, Snapanians!'
                                      : 'Daftarkan akunmu untuk berjejaring dan belanja bareng!',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF64748B),
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24.0), // Gap rapat & presisi ke form input

                          // Banner Notifikasi: Akun Direset / Dihapus oleh Admin
                          if (_showAccountDeletedNotice) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 20.0),
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: const Icon(
                                      Icons.person_off_outlined,
                                      size: 18.0,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'AKUN TELAH DIRESET',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.4,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => setState(() => _showAccountDeletedNotice = false),
                                              behavior: HitTestBehavior.opaque,
                                              child: const Padding(
                                                padding: EdgeInsets.only(left: 6.0),
                                                child: Icon(
                                                  Icons.close_rounded,
                                                  size: 16.0,
                                                  color: Color(0xFFB45309),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4.0),
                                        const Text(
                                          'Akun kamu sebelumnya tidak lagi terdaftar di sistem Snaps. NIS kamu sudah dibebaskan dan siap didaftarkan kembali sebagai akun baru di bawah ini.',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            height: 1.4,
                                            color: Color(0xFF78350F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Form Tab (Login / Register)
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
                              suspensionInfo: _suspensionInfo,
                              onDismissSuspension: () => setState(() => _suspensionInfo = null),
                            )
                          else
                            AuthRegisterTab(
                              nisController: _nisController,
                              nisError: _nisError,
                              verifiedStudent: _verifiedStudent,
                              onStudentSelected: _handleStudentSelected,
                              displayNameController: _regDisplayNameController,
                              displayNameError: _regDisplayNameError,
                              usernameController: _regUsernameController,
                              usernameError: _regUsernameError,
                              passwordController: _regPasswordController,
                              passwordError: _regPasswordError,
                              showPassword: _showRegPassword,
                              onTogglePassword: () => setState(() => _showRegPassword = !_showRegPassword),
                              agreedTerms: _agreedTerms,
                              onToggleAgreedTerms: () => setState(() => _agreedTerms = !_agreedTerms),
                              isSubmitting: _isSubmitting,
                              isGeneratingUsername: _isGeneratingUsername,
                              onSubmit: _submitRegister,
                            ),

                          // Equal bottom spacer
                          const Spacer(flex: 1),
                          const SizedBox(height: 16.0),

                          // 3. FOOTER SWITCHER
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
      ),
    );
  }
}
