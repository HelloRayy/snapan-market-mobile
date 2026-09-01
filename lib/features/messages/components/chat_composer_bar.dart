import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:snapan_market/core/theme/app_colors.dart";

/// Bar input composer chat bawah 1:1 matching ChatComposerBar.tsx
class ChatComposerBar extends StatefulWidget {
  final ValueChanged<String> onSendMessage;
  final String placeholder;

  const ChatComposerBar({
    super.key,
    required this.onSendMessage,
    this.placeholder = "Ketik pesan...",
  });

  @override
  State<ChatComposerBar> createState() => _ChatComposerBarState();
}

class _ChatComposerBarState extends State<ChatComposerBar> {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final canSend = _controller.text.trim().isNotEmpty;
      if (canSend != _canSend) {
        setState(() => _canSend = canSend);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    widget.onSendMessage(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        14.0,
        10.0,
        14.0,
        bottomPadding > 0 ? bottomPadding + 6.0 : 12.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text Input Pill
          Expanded(
            child: Container(
              height: 42.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(21.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                style: const TextStyle(
                  fontSize: 15.0,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10.0),

          // Circular Kumo Primary Blue Send Button
          GestureDetector(
            onTap: _canSend ? _handleSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _canSend
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF1D64EC),
                        ],
                      )
                    : null,
                color: _canSend ? null : const Color(0xFFE2E8F0),
                boxShadow: _canSend
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1D64EC).withValues(alpha: 0.35),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 19.0,
                color: _canSend ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
