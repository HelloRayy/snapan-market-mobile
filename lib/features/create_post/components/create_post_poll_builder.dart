import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Threads-style Interactive Polling Builder Component (Matching Image #1)
class CreatePostPollBuilder extends StatelessWidget {
  final List<TextEditingController> controllers;
  final VoidCallback onAddOption;
  final ValueChanged<int> onRemoveOption;
  final VoidCallback onDismissPoll;

  const CreatePostPollBuilder({
    super.key,
    required this.controllers,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.onDismissPoll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8.0),

        // List of Option Input Cards
        for (int i = 0; i < controllers.length; i++) ...[
          Container(
            height: 48.0,
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllers[i],
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Opsi ${i + 1}...',
                      hintStyle: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      // Automatically add next option if typing in last field and < 4 options
                      if (i == controllers.length - 1 &&
                          val.trim().isNotEmpty &&
                          controllers.length < 4) {
                        onAddOption();
                      }
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onRemoveOption(i);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.0,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 4.0),

        // Footer: "Berakhir dalam 24 jam" --- "Hapus polling"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Berakhir dalam 24 jam',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onDismissPoll();
                },
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  'Hapus polling',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF43F5E), // Rose red
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
