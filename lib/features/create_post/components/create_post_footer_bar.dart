import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Pinned Bottom Footer Bar: Privacy Selector Text + KumoButton.primary "Posting" + Upload Progress
class CreatePostFooterBar extends StatelessWidget {
  final String audiencePrivacy;
  final bool canSubmit;
  final bool isSubmitting;
  final double uploadProgress;
  final String? uploadStatusText;
  final VoidCallback onPrivacyTap;
  final VoidCallback onSubmit;

  const CreatePostFooterBar({
    super.key,
    required this.audiencePrivacy,
    required this.canSubmit,
    required this.isSubmitting,
    this.uploadProgress = 0.0,
    this.uploadStatusText,
    required this.onPrivacyTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adaptiveCanvas(context),
        border: Border(
          top: BorderSide(color: AppColors.adaptiveBorder(context), width: 1.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSubmitting && (uploadStatusText != null || uploadProgress > 0)) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      uploadStatusText ?? 'Mengunggah...',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (uploadProgress > 0)
                    Text(
                      '${(uploadProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: uploadProgress > 0 ? uploadProgress : null,
              minHeight: 2.5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                // Left: "Siapa pun dapat membalas & mengutip"
                Expanded(
                  child: GestureDetector(
                    onTap: onPrivacyTap,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      audiencePrivacy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Right: "Posting" Kumo UI Button
                KumoButton.primary(
                  text: 'Posting',
                  height: 38.0,
                  borderRadius: 19.0,
                  isLoading: isSubmitting,
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  onPressed: canSubmit ? onSubmit : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
