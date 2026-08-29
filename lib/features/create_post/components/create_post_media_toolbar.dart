import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// 7-Icon Thumb-Friendly Media Toolbar with Quick Inline Emoji Scroller
class CreatePostMediaToolbar extends StatelessWidget {
  final bool showEmojiBar;
  final bool showPollBuilder;
  final VoidCallback onPickImage;
  final VoidCallback onPickGif;
  final VoidCallback onToggleEmoji;
  final ValueChanged<String> onInsertEmoji;
  final VoidCallback onTogglePoll;
  final VoidCallback onPickTopic;
  final VoidCallback onPickLocation;
  final VoidCallback onAudioTap;

  const CreatePostMediaToolbar({
    super.key,
    this.showEmojiBar = false,
    this.showPollBuilder = false,
    required this.onPickImage,
    required this.onPickGif,
    required this.onToggleEmoji,
    required this.onInsertEmoji,
    required this.onTogglePoll,
    required this.onPickTopic,
    required this.onPickLocation,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Quick Emoji Carousel Bar (Rendered Directly Above Toolbar when smiley clicked)
        if (showEmojiBar) ...[
          Builder(
            builder: (context) {
              final screenWidth = MediaQuery.sizeOf(context).width;
              return SizedBox(
                height: 38.0,
                child: Transform.translate(
                  offset: const Offset(-64.0, 0),
                  child: OverflowBox(
                    minWidth: screenWidth,
                    maxWidth: screenWidth,
                    minHeight: 38.0,
                    maxHeight: 38.0,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: screenWidth,
                      height: 38.0,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.only(left: 64.0, right: 16.0),
                        itemCount: kPresetEmojis.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 6.0),
                        itemBuilder: (context, idx) {
                          final emoji = kPresetEmojis[idx];
                          return _QuickEmojiPill(
                            emoji: emoji,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onInsertEmoji(emoji);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8.0),
        ],

        // 2. 7-Icon Media Action Bar
        Row(
          children: [
            // 1. Foto
            _MediaIconButton(
              icon: CupertinoIcons.photo,
              tooltip: 'Foto',
              onTap: onPickImage,
            ),
            const SizedBox(width: 2.0),

            // 2. GIF
            _MediaIconButton(
              icon: Icons.gif_box_outlined,
              tooltip: 'GIF',
              onTap: onPickGif,
            ),
            const SizedBox(width: 2.0),

            // 3. Emoji (Toggles Inline Emoji Scroller)
            _MediaIconButton(
              icon: CupertinoIcons.smiley,
              tooltip: 'Emoji',
              isActive: showEmojiBar,
              onTap: onToggleEmoji,
            ),
            const SizedBox(width: 2.0),

            // 4. Polling
            _MediaIconButton(
              icon: CupertinoIcons.chart_bar_square,
              tooltip: 'Polling',
              isActive: showPollBuilder,
              onTap: onTogglePoll,
            ),
            const SizedBox(width: 2.0),

            // 5. Topik
            _MediaIconButton(
              icon: Icons.scatter_plot_rounded,
              tooltip: 'Topik',
              onTap: onPickTopic,
            ),
            const SizedBox(width: 2.0),

            // 6. Lokasi COD
            _MediaIconButton(
              icon: CupertinoIcons.location,
              tooltip: 'Lokasi COD',
              onTap: onPickLocation,
            ),
            const SizedBox(width: 2.0),

            // 7. Audio
            _MediaIconButton(
              icon: CupertinoIcons.music_note_2,
              tooltip: 'Audio',
              onTap: onAudioTap,
            ),
          ],
        ),
      ],
    );
  }
}

/// Quick Emoji Pill Item with Micro-Tap Scale Physics
class _QuickEmojiPill extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;

  const _QuickEmojiPill({
    required this.emoji,
    required this.onTap,
  });

  @override
  State<_QuickEmojiPill> createState() => _QuickEmojiPillState();
}

class _QuickEmojiPillState extends State<_QuickEmojiPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 36.0,
          height: 36.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 4.0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.emoji,
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
        ),
      ),
    );
  }
}

/// Action Icon Button for Media Toolbar (Supports Active Highlight State)
class _MediaIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _MediaIconButton({
    required this.icon,
    required this.tooltip,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_MediaIconButton> createState() => _MediaIconButtonState();
}

class _MediaIconButtonState extends State<_MediaIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 36.0,
          height: 36.0,
          color: Colors.transparent,
          child: Center(
            child: Icon(
              widget.icon,
              size: 21.5,
              color: widget.isActive
                  ? AppColors.primary
                  : _isPressed
                      ? AppColors.ink
                      : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
