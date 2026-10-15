import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Confirmation dialog when logging out from the navigation drawer.
class HomeDrawerLogoutDialog {
  static void show(BuildContext context, VoidCallback? onLogoutAction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.adaptiveSurfaceElevated(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          'Keluar dari Snaps?',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontSize: 17.0,
            fontWeight: FontWeight.w700,
            color: AppColors.adaptiveText(context),
          ),
        ),
        content: Text(
          'Anda harus masuk kembali untuk membuat postingan, pesan, dan berbelanja.',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontSize: 14.0,
            color: AppColors.adaptiveMuted(context),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.adaptiveMuted(context),
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
