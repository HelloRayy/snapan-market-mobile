import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Top Header Bar for Create Post Modal: "Batal" | "Utas Baru" | Drafts & More ("...")
class CreatePostHeaderBar extends StatelessWidget {
  final PostMode postMode;
  final VoidCallback onCancel;
  final VoidCallback onDraftsTap;
  final VoidCallback onMoreOptionsTap;

  const CreatePostHeaderBar({
    super.key,
    required this.postMode,
    required this.onCancel,
    required this.onDraftsTap,
    required this.onMoreOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCanvas(context),
        border: Border(
          bottom: BorderSide(color: AppColors.adaptiveDivider(context), width: 1.0),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left: "Batal"
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onCancel();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: AppColors.adaptiveText(context),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),

          // Center: Absolute Centered Title ("Utas Baru" / "Jual Produk")
          Text(
            postMode == PostMode.thread ? 'Utas Baru' : 'Jual Produk',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: AppColors.adaptiveText(context),
              letterSpacing: -0.3,
            ),
          ),

          // Right: Drafts Document Icon + More Options ("...")
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDraftsTap();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      CupertinoIcons.doc_text,
                      size: 20.0,
                      color: AppColors.adaptiveMuted(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onMoreOptionsTap();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      size: 20.0,
                      color: AppColors.adaptiveMuted(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
