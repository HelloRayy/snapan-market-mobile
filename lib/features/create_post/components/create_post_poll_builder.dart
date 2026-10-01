import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Threads-style Interactive Polling Builder Component with settings
class CreatePostPollBuilder extends StatelessWidget {
  final List<TextEditingController> controllers;
  final VoidCallback onAddOption;
  final ValueChanged<int> onRemoveOption;
  final VoidCallback onDismissPoll;
  final Duration deadlineDuration;
  final ValueChanged<Duration> onDurationChanged;
  final bool allowChangeVote;
  final ValueChanged<bool> onAllowChangeVoteChanged;
  final bool isMultipleChoice;
  final ValueChanged<bool> onMultipleChoiceChanged;

  const CreatePostPollBuilder({
    super.key,
    required this.controllers,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.onDismissPoll,
    required this.deadlineDuration,
    required this.onDurationChanged,
    required this.allowChangeVote,
    required this.onAllowChangeVoteChanged,
    required this.isMultipleChoice,
    required this.onMultipleChoiceChanged,
  });

  static const List<Duration> _durations = [
    Duration(hours: 1),
    Duration(hours: 6),
    Duration(hours: 24),
    Duration(days: 3),
    Duration(days: 7),
  ];

  String _formatDuration(Duration d) {
    if (d.inDays >= 1) return '${d.inDays} Hari';
    return '${d.inHours} Jam';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8.0),

        // 1. List of Option Input Cards
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

        const SizedBox(height: 6.0),

        // 2. Deadline Duration Selector
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Batas Waktu Polling',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _durations.map((d) {
              final isSelected = deadlineDuration == d;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onDurationChanged(d);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 6.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    _formatDuration(d),
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 10.0),

        // 3. Settings Toggles
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bolehkan ganti pilihan suara',
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                  ),
                  Switch.adaptive(
                    value: allowChangeVote,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      onAllowChangeVoteChanged(val);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const Divider(height: 1.0, color: Color(0xFFE2E8F0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilihan ganda (Multiple choice)',
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                  ),
                  Switch.adaptive(
                    value: isMultipleChoice,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      onMultipleChoiceChanged(val);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10.0),

        // 4. Footer: Hapus polling
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onDismissPoll();
            },
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Text(
                'Hapus polling',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF43F5E),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
