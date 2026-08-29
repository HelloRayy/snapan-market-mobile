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
        // 1. Bridge line connecting from Main Thread to Sub-Thread / Trigger
        SizedBox(
          width: 36.0,
          height: 8.0,
          child: Center(
            child: Container(
              width: 2.0,
              height: 8.0,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        ),

        // 2. Sub-Threads Chain List
        if (subThreads.isNotEmpty) ...[
          for (int i = 0; i < subThreads.length; i++) ...[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 36.0,
                    child: Column(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              currentUserAvatar,
                              width: 24.0,
                              height: 24.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
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
                        const SizedBox(height: 6.0),
                        Expanded(
                          child: Container(
                            width: 2.0,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.ink,
                        height: 1.35,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Lanjutan utas...',
                        hintStyle: TextStyle(
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
            ),
            SizedBox(
              width: 36.0,
              height: 8.0,
              child: Center(
                child: Container(
                  width: 2.0,
                  height: 8.0,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ),
          ],
        ],

        // 3. Sub-Thread Continuation Trigger ("Tambahkan ke utas")
        GestureDetector(
          onTap: onAddSubThread,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              SizedBox(
                width: 36.0,
                child: Center(
                  child: ClipRRect(
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
                ),
              ),
              const SizedBox(width: 12.0),
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
