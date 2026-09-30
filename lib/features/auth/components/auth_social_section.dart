import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/auth/components/google_logo.dart';

class AuthSocialSection extends StatelessWidget {
  final String dividerText;
  final VoidCallback onGoogleAuth;

  const AuthSocialSection({
    super.key,
    required this.dividerText,
    required this.onGoogleAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDivider(dividerText),
        const SizedBox(height: 18.0),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: const GoogleLogo(size: 20.0),
                label: 'Google',
                onTap: onGoogleAuth,
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
        ),
      ],
    );
  }

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
}

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
