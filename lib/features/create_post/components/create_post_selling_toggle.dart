import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// "Saya ingin Berjualan" Clean Bare Switch Toggle (Flush Left, No BG / No Border)
class CreatePostSellingToggle extends StatelessWidget {
  final bool isProductMode;
  final ValueChanged<bool> onToggle;

  const CreatePostSellingToggle({
    super.key,
    required this.isProductMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onToggle(!isProductMode);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36.0,
            height: 22.0,
            child: FittedBox(
              fit: BoxFit.fill,
              child: CupertinoSwitch(
                value: isProductMode,
                activeTrackColor: AppColors.primary,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  onToggle(val);
                },
              ),
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            'Saya ingin Berjualan',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: isProductMode ? FontWeight.w700 : FontWeight.w600,
              color: isProductMode ? AppColors.primary : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
