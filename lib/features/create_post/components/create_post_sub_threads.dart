import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Sub-Thread Continuation Items & "+ Tambahkan ke utas" trigger
class CreatePostSubThreads extends StatelessWidget {
  final List<SubThreadItem> subThreads;
  final String currentUserAvatar;
  final VoidCallback onAddSubThread;
  final ValueChanged<int> onRemoveSubThread;

  const CreatePostSubThreads({
    super.key,
    required this.subThreads,
    required this.currentUserAvatar,
    required this.onAddSubThread,
    required this.onRemoveSubThread,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-Threads Chain List
        if (subThreads.isNotEmpty) ...[
          const SizedBox(height: 10.0),
          for (int i = 0; i < subThreads.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    currentUserAvatar,
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 24.0,
                      height: 24.0,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 14.0,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    minLines: 1,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Lanjutan utas...',
                      hintStyle: const TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => subThreads[i].caption = val,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 16.0,
                    color: AppColors.muted,
                  ),
                  onPressed: () => onRemoveSubThread(i),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
          ],
        ],

        // Sub-Thread Continuation Trigger ("Tambahkan ke utas")
        GestureDetector(
          onTap: onAddSubThread,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Image.network(
                    currentUserAvatar,
                    width: 24.0,
                    height: 24.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 24.0,
                      height: 24.0,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 14.0,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              const Text(
                'Tambahkan ke utas',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
