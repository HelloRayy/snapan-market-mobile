import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snapan_market/core/services/app_update_service.dart';

/// Pinned footer branding and version display for navigation drawer.
class HomeDrawerFooter extends StatelessWidget {
  final Color borderColor;
  final Color inkColor;
  final Color mutedColor;

  const HomeDrawerFooter({
    super.key,
    required this.borderColor,
    required this.inkColor,
    required this.mutedColor,
  });

  Future<String> _fetchDisplayVersion() async {
    try {
      // Selalu tampilkan versi riil binary lokal aplikasi yang terpasang di HP
      final info = await AppUpdateService.instance.getPackageInfo();
      return 'V ${info.version}';
    } catch (_) {
      try {
        final info = await PackageInfo.fromPlatform();
        return 'V ${info.version}';
      } catch (_) {
        return 'V 1.0.0';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: _fetchDisplayVersion(),
            builder: (context, snapshot) {
              final versionStr = snapshot.data ?? 'V 1.0.5';
              return Text(
                'Snaps - Stable Version $versionStr',
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: inkColor,
                ),
              );
            },
          ),
          const SizedBox(height: 2.0),
          Text(
            'E-Commerce & Social Feed • SMKN 8 Semarang',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 10.5,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}
