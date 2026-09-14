import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ChatComposerBar sliced 1:1 from pen.dev Frame 1 (`snaps-design.pen` node `jXVwo`)
///
/// Structure:
/// - Height: 42.0 (expands dynamically for multiline input)
/// - Gap: 6.0
/// - Leading Button: 42x42 circle (frosted glass, shadow blur 35, offset 0, 8) with attachment icon
/// - Write Bar: Pill capsule (cornerRadius 21, frosted glass, shadow blur 35, offset 0, 8)
///   - Message TextField: SF Pro / Inter font, hint #999999
///   - Trailing:
///     - Empty: Symbol (Sticker/Emoji #727272)
///     - Active: Circular Send Button (36x36, Azure Blue #008BFF with arrow up)
class ChatComposerBar extends StatefulWidget {
  final ValueChanged<String> onSendMessage;
  final VoidCallback? onAttachmentTap;
  final String placeholder;

  const ChatComposerBar({
    super.key,
    required this.onSendMessage,
    this.onAttachmentTap,
    this.placeholder = 'Message',
  });

  @override
  State<ChatComposerBar> createState() => _ChatComposerBarState();
}

class _ChatComposerBarState extends State<ChatComposerBar> {
  late final TextEditingController _controller;
  bool _canSend = false;
  bool _isSendPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    final canSend = _controller.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ===============================================================
          // 1. LEADING BUTTON (pen.dev jxdH0: 42x42 circle, frosted liquid glass + shadow)
          // ===============================================================
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (widget.onAttachmentTap != null) {
                widget.onAttachmentTap!();
              } else {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lampirkan foto atau dokumen 📎'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              width: 42.0,
              height: 42.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 35.0,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                  child: Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.72),
                          Colors.white.withValues(alpha: 0.45),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.90),
                        width: 1.2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.attach_file_rounded,
                        color: Color(0xFF1A1A1A), // pen.dev #1A1A1A
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 6.0), // pen.dev gap: 6

          // ===============================================================
          // 2. WRITE BAR (pen.dev cXg3A: cornerRadius 21, height 42, frosted liquid glass + shadow)
          // ===============================================================
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 42.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21.0),
                boxShadow: const [
                  // Diffuse outer shadow from pen.dev Frame 1 (#0000001f, y=8, blur=35)
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 35.0,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 42.0),
                    padding: const EdgeInsets.fromLTRB(14.0, 3.0, 3.0, 3.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21.0),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.72),
                          Colors.white.withValues(alpha: 0.45),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.90),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text Input
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _handleSend(),
                            minLines: 1,
                            maxLines: 4,
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: Color(0xFF000000),
                              letterSpacing: -0.3,
                              height: 1.25,
                            ),
                            decoration: InputDecoration(
                              hintText: widget.placeholder,
                              hintStyle: const TextStyle(
                                fontSize: 15.5,
                                color: Color(0xFF999999), // pen.dev #999999
                                letterSpacing: -0.3,
                                height: 1.25,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 7.0),
                            ),
                          ),
                        ),

                  const SizedBox(width: 4.0),

                  // Trailing Action: Send Button when text exists, or Sticker/Emoji Symbol when empty
                  if (_canSend)
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isSendPressed = true),
                      onTapUp: (_) => setState(() => _isSendPressed = false),
                      onTapCancel: () => setState(() => _isSendPressed = false),
                      onTap: _handleSend,
                      child: AnimatedScale(
                        scale: _isSendPressed ? 0.90 : 1.0,
                        duration: const Duration(milliseconds: 90),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          width: 36.0,
                          height: 36.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFF008BFF), // pen.dev Azure Blue #008BFF
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_upward_rounded,
                              size: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      width: 36.0,
                      height: 36.0,
                      child: Center(
                        child: Icon(
                          Icons.sentiment_satisfied_rounded,
                          color: Color(0xFF727272), // pen.dev #727272
                          size: 22.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
