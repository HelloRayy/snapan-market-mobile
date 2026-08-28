import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

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

  // --- LOGIN FORM CONTROLLERS ---
  final TextEditingController _loginEmailController =
      TextEditingController(text: 'rabbirezwan07@gmail.com');
  final TextEditingController _loginPasswordController =
      TextEditingController(text: 'password123');
  bool _showLoginPassword = false;
  bool _rememberMe = true;

  // --- REGISTER FORM CONTROLLERS ---
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regRepeatPasswordController =
      TextEditingController();

  String _selectedGrade = 'X';
  String _selectedMajor = 'PPLG';
  String _selectedClassNum = '1';

  bool _showRegPassword = false;
  bool _showRegRepeatPassword = false;

  final List<String> _gradeOptions = const ['X', 'XI', 'XII'];
  final List<String> _majorOptions = const [
    'PPLG',
    'DKV',
    'AKL',
    'MPLB',
    'KLN',
    'HTL',
    'ULW',
    'TBS'
  ];
  final List<String> _classNumOptions = const ['1', '2', '3', '4'];

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

                    // Title Text
                    Center(
                      child: Text(
                        _authMode == AuthMode.login
                            ? 'Sign in\nto your Account'
                            : 'Sign up\nto your Account',
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
  // --- LOGIN FORM WIDGET ---
  // ==========================================
  Widget _buildLoginForm() {
    return Column(
      children: [
        // 1. Email Field Box
        _buildInputContainer(
          label: 'Email',
          child: TextField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'rabbirezwan07@gmail.com',
              hintStyle: TextStyle(
                fontSize: 15,
                color: AppColors.lightMuted,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Password Field Box
        _buildInputContainer(
          label: 'Password',
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _loginPasswordController,
                  obscureText: !_showLoginPassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => widget.onSuccess(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: '••••••••',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: AppColors.lightMuted,
                    ),
                  ),
                ),
              ),
              GestureDetector(
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
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 3. Remember Me & Forget Password Row
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
                    'Remember Me',
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
                'Forget Password',
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

        // 4. Solid Black Log in Button
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
              'Log in',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // 5. Or log in with Divider
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Or log in with',
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
                icon: Icons.apple,
                label: 'Apple',
                onTap: widget.onSuccess,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Google',
                onTap: widget.onSuccess,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // 7. Bottom Register Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Don’t have account? ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _authMode = AuthMode.register;
                });
              },
              child: const Text(
                'Register',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.linkBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // --- REGISTER FORM WIDGET ---
  // ==========================================
  Widget _buildRegisterForm() {
    return Column(
      children: [
        // 1. Full Name Box
        _buildInputContainer(
          label: 'Full Name',
          child: TextField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'Rayhan Muhammad',
              hintStyle: TextStyle(
                fontSize: 15,
                color: AppColors.lightMuted,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Dropdown Grid 3 Kolom (Kelas, Jurusan, No. Kelas SMKN 8)
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildDropdownSelector(
                label: 'Kelas',
                selectedValue: _selectedGrade,
                options: _gradeOptions,
                onSelected: (val) => setState(() => _selectedGrade = val),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: _buildDropdownSelector(
                label: 'Jurusan',
                selectedValue: _selectedMajor,
                options: _majorOptions,
                onSelected: (val) => setState(() => _selectedMajor = val),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _buildDropdownSelector(
                label: 'No. Kelas',
                selectedValue: _selectedClassNum,
                options: _classNumOptions,
                onSelected: (val) => setState(() => _selectedClassNum = val),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. WhatsApp / Phone Number Box with Country Badge
        _buildInputContainer(
          label: 'WhatsApp / Phone Number',
          child: Row(
            children: [
              // Badge 🇮🇩 +62
              Container(
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
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: '812-3456-7890',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: AppColors.lightMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. Password Field Box
        _buildInputContainer(
          label: 'Password',
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _regPasswordController,
                  obscureText: !_showRegPassword,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Minimal 6 karakter',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.lightMuted,
                    ),
                  ),
                ),
              ),
              GestureDetector(
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 5. Repeat Password Field Box
        _buildInputContainer(
          label: 'Repeat Password',
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _regRepeatPasswordController,
                  obscureText: !_showRegRepeatPassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => widget.onSuccess(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Ulangi kata sandi',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.lightMuted,
                    ),
                  ),
                ),
              ),
              GestureDetector(
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
            ],
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
              'Register',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 7. Footer "I have account? Log in"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'I have account? ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _authMode = AuthMode.login;
                });
              },
              child: const Text(
                'Log in',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.linkBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- HELPER CONTAINERS ---
  Widget _buildInputContainer({
    required String label,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.slateInk,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String label,
    required String selectedValue,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) {
        return options.map((opt) {
          final isSelected = opt == selectedValue;
          return PopupMenuItem<String>(
            value: opt,
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.ink,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.muted,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: const BorderSide(color: AppColors.border),
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
              Icon(icon, size: 22, color: AppColors.ink),
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
