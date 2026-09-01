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

    return Container(
      padding: EdgeInsets.only(
        left: 14.0,
        right: 14.0,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? MediaQuery.of(context).viewInsets.bottom + 8.0
            : 14.0,
        top: 6.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Replying to User Pill Banner
          if (widget.replyToUser != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFF64748B),
                      ),
                      children: [
                        const TextSpan(text: 'Membalas '),
                        TextSpan(
                          text: '@${widget.replyToUser!.replaceAll('@', '')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onCancelReply?.call();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Main Bottom Input Bar Row (Dedicated Scrollable Text Bubble + Cloudflare Kumo UI Action Button)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1. Dedicated Text Input Bubble Container with Connected Scrollbar
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 44.0,
                    maxHeight: 116.0,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 8.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: RawScrollbar(
                    controller: _scrollController,
                    thumbColor: const Color(0xFF94A3B8),
                    radius: const Radius.circular(4.0),
                    thickness: 3.0,
                    thumbVisibility: true,
                    child: TextField(
                      controller: _textController,
                      scrollController: _scrollController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF0F172A),
                        height: 1.35,
                        letterSpacing: -0.1,
                      ),

                      decoration: InputDecoration(
                        hintText: placeholder,
                        hintStyle: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF94A3B8),
                          height: 1.35,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8.0),

              // 2. Separate External Circular Button (Cloudflare Kumo UI Button System 44x44)
              GestureDetector(
                onTapDown: _hasText
                    ? (_) {
                        setState(() => _isSendPressed = true);
                        HapticFeedback.selectionClick();
                      }
                    : null,
                onTapUp: _hasText ? (_) => setState(() => _isSendPressed = false) : null,
                onTapCancel: _hasText ? () => setState(() => _isSendPressed = false) : null,
                onTap: _hasText ? _handleSubmit : null,
                child: AnimatedScale(
                  scale: _isSendPressed ? 0.92 : 1.0,
                  duration: const Duration(milliseconds: 90),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasText ? const Color(0xFF1D64EC) : const Color(0xFFF3F4F6),
                      gradient: _hasText
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF3B82F6), // Kumo Blue 500
                                Color(0xFF1D64EC), // Kumo Primary Blue
                              ],
                            )
                          : null,
                      border: Border.all(
                        color: _hasText ? const Color(0xFF154EC1) : const Color(0xFFE5E7EB),
                        width: 1.0,
                      ),
                      boxShadow: [
                        if (_hasText)
                          BoxShadow(
                            color: const Color(0xFF1D64EC).withOpacity(0.35),
                            blurRadius: 10.0,
                            offset: const Offset(0, 3),
                          )
                        else
                          const BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 3.0,
                            offset: Offset(0, 1),
                          ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Exact Kumo Inset Top Shine Specular Highlight Shadow
                        if (_hasText)
                          Positioned(
                            top: 0,
                            left: 6.0,
                            right: 6.0,
                            height: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(1.0),
                              ),
                            ),
                          ),

                        // Center Icon (Upward Arrow icon matching screenshot)
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 20.0,
                          color: _hasText ? Colors.white : const Color(0xFF9CA3AF),
                        ),
                      ],
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


