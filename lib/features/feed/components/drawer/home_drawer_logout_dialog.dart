import 'package:flutter/material.dart';

/// Confirmation dialog when logging out from the navigation drawer.
class HomeDrawerLogoutDialog {
  static void show(BuildContext context, VoidCallback? onLogoutAction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text(
          'Keluar dari Snaps?',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontSize: 17.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        content: const Text(
          'Anda harus masuk kembali untuk membuat postingan, pesan, dan berbelanja.',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontSize: 14.0,
            color: Color(0xFF64748B),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onLogoutAction?.call();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
