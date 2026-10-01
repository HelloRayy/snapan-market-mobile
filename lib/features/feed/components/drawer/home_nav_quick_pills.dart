import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Two equal-width squircle action buttons (Disukai & Arsip) in HomeNavDrawer (<80 lines).
class HomeNavQuickPills extends StatelessWidget {
  final VoidCallback? onLikedTap;
  final VoidCallback? onArchiveTap;

  const HomeNavQuickPills({
    super.key,
    this.onLikedTap,
    this.onArchiveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Disukai (Liked) Pill
        Expanded(
          child: _buildPill(
            icon: CupertinoIcons.heart_fill,
            iconColor: const Color(0xFFF43F5E),
            label: 'Disukai',
            onTap: onLikedTap,
          ),
        ),
        const SizedBox(width: 8.0),

        // 2. Arsip (Archive / Saved) Pill
        Expanded(
          child: _buildPill(
            icon: CupertinoIcons.bookmark_fill,
            iconColor: const Color(0xFFF59E0B),
            label: 'Arsip',
            onTap: onArchiveTap,
          ),
        ),
      ],
    );
  }

  Widget _buildPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xFF161618),
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(12.0),
        splashColor: const Color(0xFF27272A),
        highlightColor: Colors.transparent,
        child: Container(
          height: 44.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFF27272A), width: 1.0),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.0, color: iconColor),
              const SizedBox(width: 7.0),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE4E4E7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
