import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/components/google_logo.dart';
import 'package:snapan_market/features/auth/components/kumo_floating_field.dart';

enum AuthMode { login, register }

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Ambil hanya digit
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // 2. Hapus awalan 0 atau 62 jika ada
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    } else if (digits.startsWith('62')) {
      digits = digits.substring(2);
    }

    // 3. Batasi maksimal 11-12 digit lokal
    if (digits.length > 12) {
      digits = digits.substring(0, 12);
    }

    // 4. Format xxx-xxxx-xxxx
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
  final TextEditingController _loginEmailController =
      TextEditingController(text: 'rabbirezwan07@gmail.com');
  final TextEditingController _loginPasswordController =
      TextEditingController(text: 'password123');
  bool _showLoginPassword = false;
  bool _rememberMe = true;

  // --- REGISTER CONTROLLERS ---
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regRepeatPasswordController =
      TextEditingController();

  // SMKN 8 Options
  String _selectedGrade = 'X';
  String _selectedMajor = 'DKV';
  String _selectedClassNum = '1';

  bool _showRegPassword = false;
  bool _showRegRepeatPassword = false;

  final List<String> _gradeOptions = const ['X', 'XI', 'XII'];
  final List<String> _majorOptions = const [
    'DKV',
    'LK',
    'PPLG',
    'PS',
    'TJKT',
  ];
  final List<String> _classNumOptions = const ['1', '2', '3'];

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
    if (_authMode == AuthMode.register) {
      setState(() {
        _authMode = AuthMode.login;
      });
    } else {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.authGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- TOP HEADER AREA ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Floating White Circular Back Button
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0x10000000),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x20000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _handleBack,
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.ink,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title Text (Indonesian)
                    Center(
                      child: Text(
                        _authMode == AuthMode.login
                            ? 'Masuk\nke Akun Kamu'
                            : 'Daftar\nAkun Baru',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.25,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // --- BOTTOM WHITE CARD CONTAINER ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
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
    );
  }

  // ==========================================
  // --- LOGIN FORM (FLOATING LABELS) ---
  // ==========================================
  Widget _buildLoginForm() {
    return Column(
      children: [
        const SizedBox(height: 6),

        // 1. Email Floating Label Field
        KumoFloatingField(
          label: 'Email',
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 20),

        // 2. Password Floating Label Field
        KumoFloatingField(
          label: 'Kata Sandi',
          controller: _loginPasswordController,
          obscureText: !_showLoginPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onSuccess(),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _showLoginPassword = !_showLoginPassword;
              });
            },
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
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _rememberMe ? AppColors.ink : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: _rememberMe
                            ? AppColors.ink
                            : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: _rememberMe
                        ? const Icon(
                            Icons.check,
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

        // 4. Solid Black Log In Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.onSuccess,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text(
              'Masuk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // 5. Divider
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Atau masuk dengan',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightMuted,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.border)),
          ],
        ),

        const SizedBox(height: 20),

        // 6. Social Buttons Row (Apple & Google)
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                iconWidget: const Icon(Icons.apple, size: 24, color: AppColors.ink),
                label: 'Apple',
                onTap: widget.onSuccess,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildSocialButton(
                iconWidget: const GoogleLogo(size: 20),
                label: 'Google',
                onTap: widget.onSuccess,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // 7. Footer Register Link
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
                setState(() {
                  _authMode = AuthMode.register;
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
  // --- REGISTER FORM (FLOATING LABELS & DROPDOWN) ---
  // ==========================================
  Widget _buildRegisterForm() {
    return Column(
      children: [
        const SizedBox(height: 6),

        // 1. Full Name Floating Label Field
        KumoFloatingField(
          label: 'Nama Lengkap',
          controller: _fullNameController,
        ),

        const SizedBox(height: 18),

        // 2. Dropdown Grid 3 Kolom (Kelas, Jurusan, No. Kelas SMKN 8)
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _DropdownColumnBox(
                label: 'Kelas',
                selectedValue: _selectedGrade,
                options: _gradeOptions,
                onSelected: (val) => setState(() => _selectedGrade = val),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: _DropdownColumnBox(
                label: 'Jurusan',
                selectedValue: _selectedMajor,
                options: _majorOptions,
                onSelected: (val) => setState(() => _selectedMajor = val),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _DropdownColumnBox(
                label: 'No. Kelas',
                selectedValue: _selectedClassNum,
                options: _classNumOptions,
                onSelected: (val) => setState(() => _selectedClassNum = val),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 3. WhatsApp / Phone Number Floating Label Field (xxx-xxxx-xxxx)
        KumoFloatingField(
          label: 'Nomor WhatsApp / HP',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
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

        // 4. Password Floating Label Field
        KumoFloatingField(
          label: 'Kata Sandi',
          controller: _regPasswordController,
          obscureText: !_showRegPassword,
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _showRegPassword = !_showRegPassword;
              });
            },
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

        // 5. Repeat Password Floating Label Field
        KumoFloatingField(
          label: 'Ulangi Kata Sandi',
          controller: _regRepeatPasswordController,
          obscureText: !_showRegRepeatPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onSuccess(),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _showRegRepeatPassword = !_showRegRepeatPassword;
              });
            },
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

        // 6. Solid Black Register Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.onSuccess,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text(
              'Daftar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 7. Footer "Sudah punya akun? Masuk"
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
                setState(() {
                  _authMode = AuthMode.login;
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

  // --- SOCIAL AUTH BUTTON (Apple & Google) ---
  Widget _buildSocialButton({
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// --- 1-TAP DROPDOWN BOX WITH WIDE FLOATING MENU ---
// ==========================================
class _DropdownColumnBox extends StatelessWidget {
  final String label;
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _DropdownColumnBox({
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey boxKey = GlobalKey();

    return GestureDetector(
      key: boxKey,
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        HapticFeedback.selectionClick();
        final renderBox =
            boxKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final offset = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + size.height + 4,
            offset.dx + size.width + 60,
            offset.dy + size.height + 300,
          ),
          color: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
          menuPadding: const EdgeInsets.symmetric(vertical: 4),
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
          items: options.map((opt) {
            final isSelected = opt == selectedValue;
            return PopupMenuItem<String>(
              value: opt,
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    opt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                ],
              ),
            );
          }).toList(),
        );

        if (selected != null) {
          HapticFeedback.selectionClick();
          onSelected(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    selectedValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
