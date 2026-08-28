import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/kumo_button.dart';

/// Pinned Bottom Footer Bar: Privacy Selector Text + KumoButton.primary "Posting"
class CreatePostFooterBar extends StatelessWidget {
  final String audiencePrivacy;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onPrivacyTap;
  final VoidCallback onSubmit;

  const CreatePostFooterBar({
    super.key,
    required this.audiencePrivacy,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onPrivacyTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
        ),
      ),
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
    );
  }
}
