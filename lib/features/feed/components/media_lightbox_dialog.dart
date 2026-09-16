import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Clean, Light-Themed Fullscreen Media Lightbox Dialog
///
/// Matches Web React `MediaLightboxModal.tsx` 1:1:
/// - Light canvas background (`Colors.white`)
/// - Circular light close button at top-left
/// - Multi-image counter pill at top-right (`1 / N`)
/// - Multi-image swipeable PageView with pinch-to-zoom (InteractiveViewer)
/// - Left/right floating chevron buttons for web/desktop
/// - Bottom floating white glass capsule with social actions (Like, Comment, Repost, Share)
class MediaLightboxDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final MarketPostModel? post;
  final ValueChanged<MarketPostModel>? onLikeToggle;
  final ValueChanged<MarketPostModel>? onRepostToggle;
  final ValueChanged<MarketPostModel>? onPostClick;

  const MediaLightboxDialog({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.post,
    this.onLikeToggle,
    this.onRepostToggle,
    this.onPostClick,
  });

  static Future<void> show({
    required BuildContext context,
    required List<String> images,
    int initialIndex = 0,
    MarketPostModel? post,
    ValueChanged<MarketPostModel>? onLikeToggle,
    ValueChanged<MarketPostModel>? onRepostToggle,
    ValueChanged<MarketPostModel>? onPostClick,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Media Lightbox',
      barrierColor: Colors.white.withValues(alpha: 0.98),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, anim1, anim2) {
        return MediaLightboxDialog(
          images: images,
          initialIndex: initialIndex,
          post: post,
          onLikeToggle: onLikeToggle,
          onRepostToggle: onRepostToggle,
          onPostClick: onPostClick,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<MediaLightboxDialog> createState() => _MediaLightboxDialogState();
}

class _MediaLightboxDialogState extends State<MediaLightboxDialog>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;

  // Social action states (if post is provided)
  bool _isLiked = false;
  int _likesCount = 0;
  bool _isReposted = false;
  int _repostsCount = 0;

  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    if (widget.post != null) {
      _isLiked = widget.post!.isLiked;
      _likesCount = widget.post!.likesCount;
      _isReposted = widget.post!.isReposted;
      _repostsCount = widget.post!.repostsCount;
    }

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _likeAnimController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleLikeToggle() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likesCount = (_likesCount - 1).clamp(0, 999999);
      } else {
        _isLiked = true;
        _likesCount += 1;
        _likeAnimController.forward(from: 0.0);
      }
    });

    if (widget.post != null) {
      final updated = widget.post!.copyWith(
        isLiked: _isLiked,
        likesCount: _likesCount,
      );
      widget.onLikeToggle?.call(updated);
    }
  }

  void _handleRepostToggle() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isReposted) {
        _isReposted = false;
        _repostsCount = (_repostsCount - 1).clamp(0, 999999);
      } else {
        _isReposted = true;
        _repostsCount += 1;
      }
    });

    if (widget.post != null) {
      final updated = widget.post!.copyWith(
        isReposted: _isReposted,
        repostsCount: _repostsCount,
      );
      widget.onRepostToggle?.call(updated);
    }
  }

  void _handleShare() {
    HapticFeedback.lightImpact();
    final postId = widget.post?.id ?? 'preview';
    Clipboard.setData(ClipboardData(text: 'https://snapan.id/post/$postId'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tautan disalin ke papan klip'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // 1. Center Image Gallery with PageView and InteractiveViewer (Zero crop)
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (idx) {
                  setState(() {
                    _currentIndex = idx;
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2.0,
                              color: const Color(0xFF008BFF),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 48.0,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Left Floating Arrow Button (For web/desktop or quick tap)
            if (widget.images.length > 1 && _currentIndex > 0)
              Positioned(
                left: 16.0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 24.0,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. Right Floating Arrow Button (For web/desktop or quick tap)
            if (widget.images.length > 1 && _currentIndex < widget.images.length - 1)
              Positioned(
                right: 16.0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          size: 24.0,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 4. Top Header Bar: Clean Light Circular Close Button + Counter Badge
            Positioned(
              top: topPadding + 12.0,
              left: 16.0,
              right: 16.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top-Left: Light Circular Close Button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10000000),
                              blurRadius: 6.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20.0,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),

                  // Top-Right: Counter Badge for Multi-Image [ 1 / 3 ]
                  if (widget.images.length > 1)
                    Container(
                      height: 32.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
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
                      child: Text(
                        '${_currentIndex + 1} / ${widget.images.length}',
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                          fontFeatures: [FontFeature.tabularFigures()],
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 5. Bottom Floating Glass Capsule Bar (With Social Actions)
            if (widget.post != null)
              Positioned(
                bottom: bottomPadding + 20.0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Like Button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _handleLikeToggle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ScaleTransition(
                                    scale: _likeScaleAnim,
                                    child: FeedHeartIcon(
                                      isLiked: _isLiked,
                                      size: 19.0,
                                      activeColor: const Color(0xFFE11D48),
                                      inactiveColor: const Color(0xFF334155),
                                    ),
                                  ),
                                  if (_likesCount > 0) ...[
                                    const SizedBox(width: 5.0),
                                    Text(
                                      formatCompactNumber(_likesCount),
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: _isLiked ? FontWeight.w600 : FontWeight.w400,
                                        color: _isLiked
                                            ? const Color(0xFFE11D48)
                                            : const Color(0xFF475569),
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8.0),

                        // Comment Button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onPostClick?.call(widget.post!);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const FeedCommentIcon(
                                    size: 18.0,
                                    color: Color(0xFF334155),
                                  ),
                                  if (widget.post!.commentsCount > 0) ...[
                                    const SizedBox(width: 5.0),
                                    Text(
                                      formatCompactNumber(widget.post!.commentsCount),
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF475569),
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8.0),

                        // Repost Button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _handleRepostToggle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FeedRepostIcon(
                                    isReposted: _isReposted,
                                    size: 19.0,
                                    activeColor: const Color(0xFF10B981),
                                    inactiveColor: const Color(0xFF334155),
                                  ),
                                  if (_repostsCount > 0) ...[
                                    const SizedBox(width: 5.0),
                                    Text(
                                      formatCompactNumber(_repostsCount),
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: _isReposted ? FontWeight.w600 : FontWeight.w400,
                                        color: _isReposted
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF475569),
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8.0),

                        // Share Button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _handleShare,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: FeedShareIcon(
                                size: 18.0,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
