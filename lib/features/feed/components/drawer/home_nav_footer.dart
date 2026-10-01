import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom pinned logout and version footer in HomeNavDrawer (<110 lines).
class HomeNavFooter extends StatelessWidget {
  final bool isAuthenticated;
  final VoidCallback? onLogout;
  final VoidCallback? onAuthTap;

  const HomeNavFooter({
    super.key,
    required this.isAuthenticated,
    this.onLogout,
    this.onAuthTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Logout or Login Button
        if (isAuthenticated)
          _buildActionButton(
            label: 'Logout Akun',
            icon: CupertinoIcons.square_arrow_right,
            textColor: const Color(0xFFEF4444),
            bgColor: const Color(0x1AEF4444),
            borderColor: const Color(0x33EF4444),
            onTap: () => _confirmLogout(context),
          )
        else
          _buildActionButton(
            label: 'Masuk / Daftar Akun',
            icon: CupertinoIcons.arrow_right_square,
            textColor: const Color(0xFF38BDF8),
            bgColor: const Color(0x1A0284C7),
            borderColor: const Color(0x330284C7),
            onTap: onAuthTap,
          ),
        const SizedBox(height: 12.0),

        // 2. Version and School Ecosystem Branding
        const Text(
          'Snaps • Stable Version V 1.0.4\nSMKN 8 Semarang Ecosystem',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SFPro',
            fontSize: 10.0,
            color: Color(0xFF71717A),
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          height: 42.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.0, color: textColor),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161618),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text(
          'Keluar dari Snaps?',
          style: TextStyle(fontFamily: 'SFPro', fontSize: 16.5, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: const Text(
          'Anda harus masuk kembali untuk membuat postingan, pesan, dan berbelanja.',
          style: TextStyle(fontFamily: 'SFPro', fontSize: 13.5, color: Color(0xFFA1A1AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600, color: Color(0xFFA1A1AA))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onLogout?.call();
            },
            child: const Text('Logout', style: TextStyle(fontFamily: 'SFPro', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
