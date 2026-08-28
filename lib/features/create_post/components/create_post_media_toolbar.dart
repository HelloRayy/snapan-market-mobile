import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// 7-Icon Thumb-Friendly Media Toolbar for Create Post
class CreatePostMediaToolbar extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickGif;
  final VoidCallback onPickEmoji;
  final VoidCallback onTogglePoll;
  final VoidCallback onPickTopic;
  final VoidCallback onPickLocation;
  final VoidCallback onAudioTap;

  const CreatePostMediaToolbar({
    super.key,
    required this.onPickImage,
    required this.onPickGif,
    required this.onPickEmoji,
    required this.onTogglePoll,
    required this.onPickTopic,
    required this.onPickLocation,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MediaIconButton(
          icon: CupertinoIcons.photo,
          tooltip: 'Foto',
          onTap: onPickImage,
        ),
        const SizedBox(width: 2.0),
        _MediaIconButton(
          icon: Icons.gif_box_outlined,
          tooltip: 'GIF',
          onTap: onPickGif,
        ),
        const SizedBox(width: 2.0),
        _MediaIconButton(
          icon: CupertinoIcons.smiley,
          tooltip: 'Emoji',
          onTap: onPickEmoji,
        ),
        const SizedBox(width: 2.0),
        _MediaIconButton(
          icon: CupertinoIcons.chart_bar_square,
          tooltip: 'Polling',
          onTap: onTogglePoll,
        ),
        const SizedBox(width: 2.0),
        _MediaIconButton(
          icon: Icons.scatter_plot_rounded,
          tooltip: 'Topik',
          onTap: onPickTopic,
        ),
        const SizedBox(width: 2.0),
        _MediaIconButton(
          icon: CupertinoIcons.location,
          tooltip: 'Lokasi COD',
          onTap: onPickLocation,
        ),
        const SizedBox(width: 2.0),
        _MediaIconButton(
          icon: CupertinoIcons.music_note_2,
          tooltip: 'Audio',
          onTap: onAudioTap,
        ),
      ],
    );
  }
}

class _MediaIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MediaIconButton({
    required this.icon,
    required this.tooltip,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 36.0,
          height: 36.0,
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0x0F000000) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 21.5,
              color: _isPressed ? AppColors.ink : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
