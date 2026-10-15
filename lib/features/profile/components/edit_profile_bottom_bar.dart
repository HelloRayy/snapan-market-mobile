import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

class EditProfileBottomBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onDiscard;
  final VoidCallback onSave;

  const EditProfileBottomBar({
    super.key,
    required this.isSaving,
    required this.onDiscard,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCanvas(context),
        border: Border(top: BorderSide(color: AppColors.adaptiveBorder(context), width: 1.0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16.0,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46.0,
                child: OutlinedButton(
                  onPressed: isSaving ? null : onDiscard,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.adaptiveCanvas(context),
                    foregroundColor: AppColors.adaptiveText(context),
                    side: BorderSide(color: AppColors.adaptiveBorder(context), width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                  ),
                  child: Text(
                    'Discard',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.adaptiveText(context),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: SizedBox(
                height: 46.0,
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : const Text('Save Changes', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
