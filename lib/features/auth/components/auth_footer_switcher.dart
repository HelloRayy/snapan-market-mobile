import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthFooterSwitcher extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onSwitch;

  const AuthFooterSwitcher({
    super.key,
    required this.isLogin,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onSwitch();
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text.rich(
            TextSpan(
              text: isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
              style: const TextStyle(
                fontSize: 14.0,
                color: Color(0xFF64748B),
              ),
              children: [
                TextSpan(
                  text: isLogin ? 'Daftar sekarang' : 'Masuk di sini',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3D38F5),
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
