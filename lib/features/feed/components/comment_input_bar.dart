import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';

/// CommentInputBar Widget
/// 100% Sliced 1:1 from Web React CommentInputBar.tsx
///
/// Features:
/// - Floating white capsule pill dock with backdrop shadow
/// - User profile avatar (32x32)
/// - Flexible text input field with contextual placeholder
/// - Send CTA Button (dark pill with tactile feedback)
/// - Replying-to status banner with "Batal" cancel action
class CommentInputBar extends StatefulWidget {
  final String? replyToUser;
  final String? targetAuthor;
  final String? userAvatar;
  final ValueChanged<String> onSubmitComment;
  final VoidCallback? onCancelReply;
  final ValueChanged<String>? onDraftChange;

  const CommentInputBar({
    super.key,
    this.replyToUser,
    this.targetAuthor,
    this.userAvatar,
    required this.onSubmitComment,
    this.onCancelReply,
    this.onDraftChange,
  });

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  bool _hasText = false;
  bool _isSendPressed = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _textController.addListener(_onTextChanged);

    if (widget.replyToUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant CommentInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.replyToUser != null && oldWidget.replyToUser != widget.replyToUser) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    final hasVal = text.trim().isNotEmpty;
    if (hasVal != _hasText) {
      setState(() {
        _hasText = hasVal;
      });
    }
    widget.onDraftChange?.call(text);
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    widget.onSubmitComment(text);
    _textController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final defaultAvatar = widget.userAvatar ??
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';

    final placeholder = widget.replyToUser != null
        ? 'Balas @${widget.replyToUser!.replaceAll('@', '')}...'
        : widget.targetAuthor != null
            ? 'Balas @${widget.targetAuthor!.replaceAll('@', '')}...'
            : 'Tulis balasan...';

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: bottomInset > 0
            ? bottomInset + 8.0
            : (bottomPadding > 0 ? bottomPadding + 6.0 : 12.0),
        top: 6.0,
      ),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===============================================================
          // 0. REPLY PREVIEW BANNER (pen.dev Frame 1 Reply node HvRsZ)
          // ===============================================================
          if (widget.replyToUser != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 20.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.75),
                          Colors.white.withValues(alpha: 0.48),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.90),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Vertical blue indicator line (pen.dev gFODz: width 2, height 38, fill #008BFF)
                        Container(
                          width: 2.5,
                          height: 24.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF008BFF),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: Color(0xFF999999),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Membalas ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: '@${widget.replyToUser!.replaceAll('@', '')}',
                                  style: const TextStyle(
                                    color: Color(0xFF008BFF), // pen.dev #008BFF
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onCancelReply?.call();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.0,
                              color: Color(0xFF999999), // pen.dev Close Symbol #999999
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ===============================================================
          // FRAME 1: Leading Button + Write Bar (pen.dev jXVwo)
          // ===============================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1. LEADING BUTTON (pen.dev jxdH0: 42x42 circle, frosted liquid glass + shadow)
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lampirkan foto atau dokumen 📎'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
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
                        child: Center(
                          child: widget.userAvatar != null && widget.userAvatar!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.network(
                                    widget.userAvatar!,
                                    width: 30.0,
                                    height: 30.0,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.attach_file_rounded,
                                      color: Color(0xFF1A1A1A),
                                      size: 20.0,
                                    ),
                                  ),
                                )
                              : const Icon(
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

              // 2. WRITE BAR (pen.dev cXg3A: cornerRadius 21, height 42, frosted liquid glass + shadow)
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
                          controller: _textController,
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSubmit(),
                          style: const TextStyle(
                            fontSize: 15.5,
                            color: Color(0xFF000000),
                            letterSpacing: -0.3,
                            height: 1.25,
                          ),
                          decoration: InputDecoration(
                            hintText: placeholder,
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
                      if (_hasText)
                        GestureDetector(
                          onTapDown: (_) => setState(() => _isSendPressed = true),
                          onTapUp: (_) => setState(() => _isSendPressed = false),
                          onTapCancel: () => setState(() => _isSendPressed = false),
                          onTap: _handleSubmit,
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
            ),
          ),
        ),
      ],
    ),
  ],
),
);
}
}


