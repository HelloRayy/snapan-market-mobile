import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Modal Dialog confirming unsaved changes discard matching ConfirmActionModal.tsx
class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const DiscardChangesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.adaptiveSurfaceElevated(context),
      elevation: 16.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Buang perubahan?',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: AppColors.adaptiveText(context),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 8.0),

            // Description
            Text(
              'Jika Anda keluar sekarang, perubahan profil yang baru saja diedit tidak akan disimpan.',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: AppColors.adaptiveMuted(context),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24.0),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button ("Batal")
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop(false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),

                const SizedBox(width: 8.0),

                // Destructive Discard Button ("Buang")
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Buang',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
