import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/components/google_logo.dart';
import 'package:snapan_market/features/auth/models/auth_constants.dart';

enum AuthMode { login, register }

/// Modern Login & Create Account Screen
/// Redesigned to 1:1 parity with the clean iOS card layout mockup:
/// - Rounded circular back button at top left
/// - Bold header hierarchy ("Login account / Welcome back!", "Create account / Sign up to continue")
/// - Clean card-style rounded input fields with icons
/// - Smooth keyboard handling with zero overflow on any device screen
/// - Electric Indigo brand primary CTA button
/// - Dotted divider & Google + Apple social buttons
/// - Bottom navigation switcher between Login and Register
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
  bool _showRegPassword = false;
  bool _agreedTerms = false;

  // --- SMKN 8 SELECTION STATE ---
  String? _selectedGrade;
  String? _selectedMajor;
  String? _selectedClassNum;

  // --- ERROR STATES ---
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
    _loginUsernameController.addListener(() => _clearError(() => _loginUsernameError = null));
    _loginPasswordController.addListener(() => _clearError(() => _loginPasswordError = null));
    _fullNameController.addListener(() => _clearError(() => _fullNameError = null));
    _regUsernameController.addListener(() => _clearError(() => _regUsernameError = null));
    _regPasswordController.addListener(() => _clearError(() => _regPasswordError = null));
  }

  void _clearError(VoidCallback update) {
    if (mounted) setState(update);
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

  // --- GOOGLE OAUTH SIGN IN ---
  Future<void> _handleGoogleAuth() async {
    HapticFeedback.selectionClick();
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

  // --- SUBMIT LOGIN ---
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
      _loginPasswordError = 'Masukkan kata sandi Anda';
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
          _loginPasswordError = 'Username atau kata sandi tidak cocok';
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

  // --- SUBMIT REGISTER ---
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

    // 2. Kelas & Jurusan SMKN 8
    if (_selectedGrade == null || _selectedMajor == null || _selectedClassNum == null) {
      _classError = 'Pilih kelas, jurusan, dan nomor ruang Anda';
      isValid = false;
    }

    // 3. Username
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

    // 4. Kata Sandi
    final pass = _regPasswordController.text;
    if (pass.isEmpty) {
      _regPasswordError = 'Kata sandi wajib diisi';
      isValid = false;
    } else if (pass.length < 6) {
      _regPasswordError = 'Kata sandi minimal 6 karakter';
      isValid = false;
    }

    // 5. Persetujuan Syarat
    if (!_agreedTerms) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Ketentuan Komunitas dan Kebijakan Privasi SMKN 8'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
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
            _regUsernameError = 'Username @$rawUsername sudah terdaftar. Gunakan username lain.';
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: true,
          bottom: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 24.0,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Top Circular Back Button
                        _buildBackButton(),

                        const SizedBox(height: 22.0),

                        // 2. Title & Subtitle Hierarchy
                        _buildHeader(
                          _authMode == AuthMode.login ? 'Masuk Akun' : 'Daftar Akun Baru',
                          _authMode == AuthMode.login
                              ? 'Selamat datang kembali, Snapanians!'
                              : 'Daftarkan akunmu untuk berjejaring dan belanja bareng Snapanians!',
                        ),

                        const SizedBox(height: 26.0),

                        // 3. Dynamic Form Fields
                        if (_authMode == AuthMode.login)
                          ..._buildLoginFields()
                        else
                          ..._buildRegisterFields(),

                        // 4. Flexible Spacer to anchor footer switcher at bottom
                        const Spacer(),
                        const SizedBox(height: 18.0),

                        // 5. Bottom Switcher Link
                        _buildFooterSwitcher(),
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

  // --- TOP CIRCULAR BACK BUTTON ---
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _handleBack,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
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
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 27.0,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  // --- LOGIN FORM FIELDS ---
  List<Widget> _buildLoginFields() {
    return [
      _AuthInputField(
        label: 'Username',
        hint: '@username_kamu',
        prefixIcon: LucideIcons.atSign,
        controller: _loginUsernameController,
        errorText: _loginUsernameError,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
        ],
      ),
      const SizedBox(height: 16.0),
      _AuthInputField(
        label: 'Kata Sandi',
        hint: 'Masukkan kata sandi Anda',
        prefixIcon: LucideIcons.lock,
        controller: _loginPasswordController,
        isPassword: true,
        showPassword: _showLoginPassword,
        onTogglePassword: () => setState(() => _showLoginPassword = !_showLoginPassword),
        errorText: _loginPasswordError,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submitLogin(),
      ),
      const SizedBox(height: 14.0),
      _buildLoginOptionsRow(),
      const SizedBox(height: 22.0),
      _PrimaryAuthButton(
        text: 'Masuk ke Akun',
        isLoading: _isSubmitting,
        onPressed: _submitLogin,
      ),
      const SizedBox(height: 22.0),
      _buildDivider('atau masuk dengan'),
      const SizedBox(height: 18.0),
      _buildSocialButtons(),
    ];
  }

  // --- REGISTER FORM FIELDS ---
  List<Widget> _buildRegisterFields() {
    return [
      _AuthInputField(
        label: 'Nama Lengkap',
        hint: 'Contoh: Raditya Rayhan',
        prefixIcon: LucideIcons.user,
        controller: _fullNameController,
        errorText: _fullNameError,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16.0),
      _buildClassSelector(),
      const SizedBox(height: 16.0),
      _AuthInputField(
        label: 'Username',
        hint: '@username_kamu',
        prefixIcon: LucideIcons.atSign,
        controller: _regUsernameController,
        errorText: _regUsernameError,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
        ],
      ),
      const SizedBox(height: 16.0),
      _AuthInputField(
        label: 'Kata Sandi',
        hint: 'Minimal 6 karakter',
        prefixIcon: LucideIcons.lock,
        controller: _regPasswordController,
        isPassword: true,
        showPassword: _showRegPassword,
        onTogglePassword: () => setState(() => _showRegPassword = !_showRegPassword),
        errorText: _regPasswordError,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submitRegister(),
      ),
      const SizedBox(height: 16.0),
      _buildRegisterTermsRow(),
      const SizedBox(height: 22.0),
      _PrimaryAuthButton(
        text: 'Buat Akun Sekarang',
        isLoading: _isSubmitting,
        onPressed: _submitRegister,
      ),
      const SizedBox(height: 22.0),
      _buildDivider('atau daftar dengan'),
      const SizedBox(height: 18.0),
      _buildSocialButtons(),
    ];
  }

  // --- LOGIN OPTIONS: REMEMBER ME & FORGOT PASSWORD ---
  Widget _buildLoginOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _rememberMe = !_rememberMe);
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
                  color: _rememberMe ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: _rememberMe ? AppColors.primary : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: _rememberMe
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

  // --- REGISTER TERMS CHECKBOX ---
  Widget _buildRegisterTermsRow() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _agreedTerms = !_agreedTerms);
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
              color: _agreedTerms ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: _agreedTerms ? AppColors.primary : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: _agreedTerms
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

  // --- CLASS & MAJOR SELECTOR ---
  Widget _buildClassSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _AuthDropdownField(
                label: 'Kelas',
                value: _selectedGrade,
                options: AuthConstants.gradeOptions,
                hasError: _classError != null && _selectedGrade == null,
                onChanged: (val) => setState(() {
                  _selectedGrade = val;
                  if (_selectedGrade != null && _selectedMajor != null && _selectedClassNum != null) {
                    _classError = null;
                  }
                }),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 4,
              child: _AuthDropdownField(
                label: 'Jurusan',
                value: _selectedMajor,
                options: AuthConstants.majorOptions,
                hasError: _classError != null && _selectedMajor == null,
                onChanged: (val) => setState(() {
                  _selectedMajor = val;
                  if (_selectedGrade != null && _selectedMajor != null && _selectedClassNum != null) {
                    _classError = null;
                  }
                }),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 3,
              child: _AuthDropdownField(
                label: 'Ruang',
                value: _selectedClassNum,
                options: AuthConstants.classNumOptions,
                hasError: _classError != null && _selectedClassNum == null,
                onChanged: (val) => setState(() {
                  _selectedClassNum = val;
                  if (_selectedGrade != null && _selectedMajor != null && _selectedClassNum != null) {
                    _classError = null;
                  }
                }),
              ),
            ),
          ],
        ),
        if (_classError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
            child: Text(
              _classError!,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  // --- DOTTED LINE DIVIDER ---
  Widget _buildDivider(String text) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.0,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4.0,
                height: 4.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                width: 4.0,
                height: 4.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1.0,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  // --- SOCIAL BUTTONS ROW ---
  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: const GoogleLogo(size: 20.0),
            label: 'Google',
            onTap: _handleGoogleAuth,
          ),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: _SocialButton(
            icon: const Icon(
              Icons.apple,
              size: 22.0,
              color: Color(0xFF0F172A),
            ),
            label: 'Apple',
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Apple Sign-In hanya tersedia pada perangkat iOS'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- BOTTOM SWITCHER FOOTER ---
  Widget _buildFooterSwitcher() {
    if (_authMode == AuthMode.login) {
      return Center(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _authMode = AuthMode.register;
              _clearAllErrors();
            });
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Text.rich(
              TextSpan(
                text: 'Belum punya akun? ',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF64748B),
                ),
                children: [
                  TextSpan(
                    text: 'Daftar sekarang',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _authMode = AuthMode.login;
              _clearAllErrors();
            });
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Text.rich(
              TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF64748B),
                ),
                children: [
                  TextSpan(
                    text: 'Masuk di sini',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

/// Material 3 Floating Dropdown Field for Classes & Majors
class _AuthDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final bool hasError;
  final ValueChanged<String?> onChanged;

  const _AuthDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    this.hasError = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      value: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
      elevation: 4,
      menuMaxHeight: 260.0,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF64748B),
        size: 18.0,
      ),
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(
          fontSize: 13.5,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: hasError ? AppColors.error : AppColors.primary,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
            width: hasError ? 1.4 : 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
      items: options.map((opt) {
        return DropdownMenuItem<String>(
          value: opt,
          child: Text(
            opt,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        );
      }).toList(),
      onChanged: (val) {
        HapticFeedback.selectionClick();
        onChanged(val);
      },
    );
  }
}

/// Material 3 Floating Label Input Field with animated outline borders
class _AuthInputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? errorText;
  final bool isPassword;
  final bool showPassword;
  final VoidCallback? onTogglePassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  const _AuthInputField({
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.errorText,
    this.isPassword = false,
    this.showPassword = false,
    this.onTogglePassword,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.inputFormatters,
  });

  @override
  State<_AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<_AuthInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return TextField(
      focusNode: _focusNode,
      controller: widget.controller,
      obscureText: widget.isPassword && !widget.showPassword,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      cursorColor: AppColors.primary,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(
          fontSize: 14.0,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: hasError
              ? AppColors.error
              : _isFocused
                  ? AppColors.primary
                  : const Color(0xFF64748B),
        ),
        hintText: widget.hint,
        hintStyle: const TextStyle(
          fontSize: 13.5,
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          size: 19.5,
          color: hasError
              ? AppColors.error
              : _isFocused
                  ? AppColors.primary
                  : const Color(0xFF64748B),
        ),
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: widget.onTogglePassword,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: Icon(
                    widget.showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 19.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40.0,
          minHeight: 20.0,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(
            color: hasError ? AppColors.error : const Color(0xFFE2E8F0),
            width: hasError ? 1.4 : 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
        errorText: widget.errorText,
        errorStyle: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: AppColors.error,
        ),
      ),
    );
  }
}

/// Primary CTA Button with micro-tap physics & loading state
class _PrimaryAuthButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryAuthButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_PrimaryAuthButton> createState() => _PrimaryAuthButtonState();
}

class _PrimaryAuthButtonState extends State<_PrimaryAuthButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.isLoading ? null : () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          height: 52.0,
          decoration: BoxDecoration(
            color: widget.isLoading
                ? AppColors.primary.withValues(alpha: 0.7)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 10.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22.0,
                    height: 22.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Social Button (Google / Apple) matching reference mockup
class _SocialButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 4.0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 9.0),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
