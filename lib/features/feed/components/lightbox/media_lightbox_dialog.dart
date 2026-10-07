import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/feed/components/lightbox/lightbox_action_bar.dart';
import 'package:snapan_market/features/feed/components/lightbox/lightbox_image_viewer.dart';
import 'package:snapan_market/features/feed/components/lightbox/lightbox_nav_arrows.dart';
import 'package:snapan_market/features/feed/components/lightbox/lightbox_top_header.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Clean, Light-Themed Fullscreen Media Lightbox Dialog
///
/// Full-width edge-to-edge image presentation with pinch-to-zoom,
/// swipe navigation, and interactive social controls.
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
      child: Stack(
        children: [
          // 1. Edge-to-edge full width PageView with pinch-to-zoom (No padding / safearea restrictions)
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (context, index) {
                return LightboxImageViewer(
                  imageUrl: widget.images[index],
                  screenWidth: mediaQuery.size.width,
                );
              },
            ),
          ),

          // 2. Navigation Chevrons (web/desktop or quick tap)
          LightboxNavArrows(
            currentIndex: _currentIndex,
            totalImages: widget.images.length,
            onPrevious: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            ),
            onNext: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            ),
          ),

          // 3. Top Header Bar: Close Button + Counter Badge
          LightboxTopHeader(
            topPadding: topPadding,
            currentIndex: _currentIndex,
            totalImages: widget.images.length,
            onClose: () => Navigator.of(context).pop(),
          ),

          // 4. Bottom Action Bar: Like, Comment, Repost, Share
          if (widget.post != null)
            LightboxActionBar(
              post: widget.post!,
              bottomPadding: bottomPadding,
              isLiked: _isLiked,
              likesCount: _likesCount,
              isReposted: _isReposted,
              repostsCount: _repostsCount,
              likeScaleAnim: _likeScaleAnim,
              onLikeToggle: _handleLikeToggle,
              onCommentClick: () {
                Navigator.of(context).pop();
                widget.onPostClick?.call(widget.post!);
              },
              onRepostToggle: _handleRepostToggle,
              onShareClick: _handleShare,
            ),
        ],
      ),
    );
  }
}
