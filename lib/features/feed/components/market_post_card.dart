import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';
import 'package:snapan_market/features/feed/components/post_submenu_popover.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';



/// Interactive Feed & Detail Card Component for Threads and Product Posts
///
/// Implements a 2-column layout matching the Web React design:
/// - Left column: 36x36px rounded author avatar with fallback
/// - Right column:
///   * Header row: Name, Verified Badge, Topic Tag (or Class), Timestamp, and Options (...)
///   * Caption with multi-thread indicator (`1/2`)
///   * Single Image (18px rounded, 4:5 ratio) or Edge-to-Edge Multi-Image Carousel
///   * COD Location Tag chip
///   * Action Bar (Interactive Like, Comment, Repost, Share) + Stock indicator pill
class MarketPostCard extends StatefulWidget {
  final MarketPostModel item;
  final ValueChanged<MarketPostModel>? onPostClick;
  final ValueChanged<MarketPostModel>? onLikeToggle;
  final ValueChanged<MarketPostModel>? onRepostToggle;
  final ValueChanged<MarketPostModel>? onShareClick;
  final ValueChanged<String>? onTopicClick;
  final ValueChanged<String>? onUserClick;
  final void Function(MarketPostModel item, int imageIndex)? onImageClick;
  final VoidCallback? onMoreOptionsClick;
  final String variant; // 'feed' | 'detail'

  const MarketPostCard({
    super.key,
    required this.item,
    this.onPostClick,
    this.onLikeToggle,
    this.onRepostToggle,
    this.onShareClick,
    this.onTopicClick,
    this.onUserClick,
    this.onImageClick,
    this.onMoreOptionsClick,
    this.variant = 'feed',
  });

  @override
  State<MarketPostCard> createState() => _MarketPostCardState();
}

class _MarketPostCardState extends State<MarketPostCard>
    with TickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  late bool _isReposted;
  late int _repostsCount;

  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  late AnimationController _repostAnimController;
  late Animation<double> _repostRotateAnim;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.item.isLiked;
    _likesCount = widget.item.likesCount;
    _isReposted = widget.item.isReposted;
    _repostsCount = widget.item.repostsCount;

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

    _repostAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _repostRotateAnim = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _repostAnimController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(covariant MarketPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.likesCount != widget.item.likesCount ||
        oldWidget.item.isLiked != widget.item.isLiked ||
        oldWidget.item.isReposted != widget.item.isReposted ||
        oldWidget.item.repostsCount != widget.item.repostsCount) {
      _isLiked = widget.item.isLiked;
      _likesCount = widget.item.likesCount;
      _isReposted = widget.item.isReposted;
      _repostsCount = widget.item.repostsCount;
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    _repostAnimController.dispose();
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

    final updated = widget.item.copyWith(
      isLiked: _isLiked,
      likesCount: _likesCount,
    );
    widget.onLikeToggle?.call(updated);
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
        _repostAnimController.forward(from: 0.0);
      }
    });

    final updated = widget.item.copyWith(
      isReposted: _isReposted,
      repostsCount: _repostsCount,
    );
    widget.onRepostToggle?.call(updated);
  }

  void _showOptionsMenu(BuildContext context, [Offset? tapPosition]) {
    if (widget.onMoreOptionsClick != null) {
      widget.onMoreOptionsClick!();
      return;
    }

    PostSubmenuPopover.show(
      context: context,
      post: widget.item,
      isSaved: widget.item.isSaved,
      position: tapPosition,
      onToggleSave: () {
        final updated = widget.item.copyWith(isSaved: !widget.item.isSaved);
        widget.onPostClick?.call(updated);
      },
      onHidePost: () {},
      onMuteAuthor: () {},
      onReport: () {},
    );
  }


  @override
  Widget build(BuildContext context) {
    if (widget.variant == 'detail') {
      return _buildDetailCard(context);
    }
    return _buildFeedCard(context);
  }

  /// DETAIL VARIANT: Single column full-width layout matching Web React 1:1
  Widget _buildDetailCard(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.only(
          left: 14.0,
          right: 14.0,
          top: 12.0,
          bottom: 14.0,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Row: 36x36 Avatar, Author Name, Verified Badge, Chevron ›, Topic Tag / Class, Timestamp, 3-dots
            _buildDetailHeaderRow(context),

            const SizedBox(height: 6.0),

            // Full Width Caption Text with Multi-Thread indicator badge
            _buildCaptionText(),

            // Media Section (Single Image or Multi-Image Carousel)
            if (widget.item.images.isNotEmpty) ...[
              const SizedBox(height: 10.0),
              _buildMediaSection(context, isDetail: true),
            ],

            // Location Tag (if product post with location)
            if (widget.item.locationTag != null && widget.item.locationTag!.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              _buildLocationTag(),
            ],

            const SizedBox(height: 10.0),

            // Action Bar (Full width)
            _buildActionBar(context),
          ],
        ),
      ),
    );
  }

  /// FEED VARIANT: Two-column layout with left Avatar and right Content Column
  Widget _buildFeedCard(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => widget.onPostClick?.call(widget.item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
            ),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: 36x36px Circular Avatar
              _buildAuthorAvatar(context),

              const SizedBox(width: 12.0),

              // Right Column: Content, Media, Location, and Action Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Line (Author Name, Verified, Topic/Class, Timestamp, Options)
                    _buildHeaderRow(context),

                    const SizedBox(height: 2.0),

                    // Caption Text with Multi-Thread indicator badge
                    _buildCaptionText(),

                    // Media (Single Image or Multi-Image Horizontal Carousel)
                    if (widget.item.images.isNotEmpty) ...[
                      const SizedBox(height: 10.0),
                      _buildMediaSection(context),
                    ],

                    // Location Tag (for COD school spot)
                    if (widget.item.locationTag != null && widget.item.locationTag!.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      _buildLocationTag(),
                    ],

                    const SizedBox(height: 8.0),

                    // Bottom Action Bar (Like, Comment, Repost, Share + Stock pill)
                    _buildActionBar(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 42x42px circular avatar with subtle border, shadow, and '+' follow badge
  Widget _buildAuthorAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onUserClick?.call(widget.item.seller.username ?? widget.item.seller.name);
      },
      child: SizedBox(
        width: 44.0,
        height: 44.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.item.seller.avatar,
                  width: 42.0,
                  height: 42.0,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.primaryPastel,
                    child: Center(
                      child: Text(
                        widget.item.seller.name.isNotEmpty
                            ? widget.item.seller.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 17.5,
                height: 17.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3B82F6), // Kumo Blue 500
                      Color(0xFF1D64EC), // Kumo Primary Blue
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D64EC).withValues(alpha: 0.25),
                      blurRadius: 3.0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 11.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header row containing Name, Verified Badge, Topic Tag / Class, Timestamp, and More Options (...)
  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side: Expanded flex container for author, badge, topic/class
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Author Name (Primary Priority - Takes natural width without being truncated by topic)
              GestureDetector(
                onTap: () {
                  widget.onUserClick?.call(widget.item.seller.username ?? widget.item.seller.name);
                },
                child: Text(
                  widget.item.seller.name,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                ),
              ),

              // Verified Checkmark Badge (Always attached to Name)
              if (widget.item.seller.isVerified) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.verified_rounded,
                  size: 15.5,
                  color: Color(0xFF1D64EC),
                ),
              ],

              // 2. Secondary Priority: Topic Tag (If exists -> class removed; topic takes remaining width and truncates)
              if (widget.item.topicTag != null) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14.0,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4.0),
                if (widget.item.isOfficialTopic) ...[
                  if (widget.item.topicIcon == 'presentation' || widget.item.topicIcon == 'party-popper')
                    const Icon(
                      Icons.celebration_rounded,
                      size: 13.5,
                      color: Color(0xFF1D64EC),
                    )
                  else
                    const ThreadsTopicGlyph(
                      size: 13.5,
                      color: Color(0xFF1D64EC),
                    ),
                  const SizedBox(width: 4.0),
                ],
                Flexible(
                  child: GestureDetector(
                    onTap: () => widget.onTopicClick?.call(widget.item.topicTag!),
                    child: Text(
                      widget.item.topicTag!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: widget.item.isOfficialTopic
                            ? const Color(0xFF1D64EC)
                            : const Color(0xFF0F172A),
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ] else if (widget.item.seller.name.length <= 14 && widget.item.seller.classGroup.isNotEmpty) ...[
                // 3. Last Priority: Class Group (Only when NO topic AND name is short <= 14 chars)
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    widget.item.seller.classGroup,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF94A3B8),
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 8.0),

        // Right Side: Timestamp + 3-dots button (Flush right to card boundary)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formatSmartTimestamp(widget.item.timestamp),
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.normal,
                color: Color(0xFF94A3B8),
                height: 1.15,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4.0),
            GestureDetector(
              onTapDown: (details) => _showOptionsMenu(context, details.globalPosition),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 16.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Detail Variant Header row containing Profile Picture + Name + Verified Badge + Chevron › + Topic Tag / Class + Timestamp + 3-dots
  Widget _buildDetailHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Side: Avatar + Name + Verified Badge + Chevron › + Topic Tag / Class
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAuthorAvatar(context),
              const SizedBox(width: 10.0),

              // 1. Author Name (Primary Priority - Takes natural width)
              GestureDetector(
                onTap: () {
                  widget.onUserClick?.call(widget.item.seller.username ?? widget.item.seller.name);
                },
                child: Text(
                  widget.item.seller.name,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                ),
              ),

              // Verified Checkmark Badge (Always attached to Name)
              if (widget.item.seller.isVerified) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.verified_rounded,
                  size: 15.0,
                  color: AppColors.primary,
                ),
              ],

              // 2. Secondary Priority: Topic Tag (If exists -> class removed; topic takes remaining width and truncates)
              if (widget.item.topicTag != null) ...[
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14.0,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4.0),
                if (widget.item.isOfficialTopic) ...[
                  if (widget.item.topicIcon == 'presentation')
                    const PresentationTopicGlyph()
                  else
                    const ThreadsTopicGlyph(),
                  const SizedBox(width: 4.0),
                ],
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      widget.onTopicClick?.call(widget.item.topicTag!);
                    },
                    child: Text(
                      widget.item.topicTag!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: widget.item.isOfficialTopic
                            ? AppColors.primary
                            : const Color(0xFF0F172A),
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ] else if (widget.item.seller.name.length <= 14 && widget.item.seller.classGroup.isNotEmpty) ...[
                // 3. Last Priority: Class Group (Only when NO topic AND name is short <= 14 chars)
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    widget.item.seller.classGroup,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF94A3B8),
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 8.0),

        // Right Side: Timestamp + 3-dots button
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formatSmartTimestamp(widget.item.timestamp),
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.normal,
                color: Color(0xFF94A3B8),
                height: 1.15,
              ),
            ),
            const SizedBox(width: 4.0),
            GestureDetector(
              onTapDown: (details) => _showOptionsMenu(context, details.globalPosition),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 16.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  /// Caption text with multi-thread badge (e.g. `1/2`)
  Widget _buildCaptionText() {
    final hasMultiThread = widget.item.totalThreadParts != null && widget.item.totalThreadParts! > 1;

    return Text.rich(
      TextSpan(
        text: widget.item.caption,
        children: [
          if (hasMultiThread) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                margin: const EdgeInsets.only(left: 6.0),
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  '1/${widget.item.totalThreadParts}',
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      style: const TextStyle(
        fontSize: 14.5,
        height: 1.25,
        fontWeight: FontWeight.normal,
        color: Color(0xFF0F172A),
      ),
    );
  }


  /// Media section: Single image 18px rounded (4:5 or 16:10) OR Multi-image horizontal carousel
  Widget _buildMediaSection(BuildContext context, {bool isDetail = false}) {
    if (widget.item.images.length == 1) {
      return GestureDetector(
        onTap: () => widget.onImageClick?.call(widget.item, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.0),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 380.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(color: const Color(0x14000000), width: 1.0),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Image.network(
                widget.item.images.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 40.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Multi-Image Carousel (2+ photos)
    return SizedBox(
      height: isDetail ? 260.0 : 240.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.item.images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10.0),
        itemBuilder: (context, idx) {
          final imgUrl = widget.item.images[idx];
          return GestureDetector(
            onTap: () => widget.onImageClick?.call(widget.item, idx),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.0),
              child: Container(
                width: MediaQuery.of(context).size.width * (isDetail ? 0.78 : 0.72),
                height: isDetail ? 260.0 : 240.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: const Color(0x14000000), width: 1.0),
                ),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 36.0),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Location Tag (Placed under media for optimal UX flow matching Web React 1:1)
  /// Equivalent to:
  /// <div className="pt-1 flex items-center gap-1.5 text-[12px] sm:text-[12.5px] text-slate-600 font-medium leading-snug">
  ///   <MapPin className="w-3.5 h-3.5 text-slate-500 stroke-[2] shrink-0" />
  ///   <span className="truncate">{item.locationTag}</span>
  /// </div>
  Widget _buildLocationTag() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 14.0,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 5.0),
          Flexible(
            child: Text(
              widget.item.locationTag!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// Action bar with Like, Comment, Repost, Share, and Stock pill
  Widget _buildActionBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Action buttons (Left)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Like Button
            _buildLikeButton(),

            const SizedBox(width: 4.0),

            // 2. Comment Button
            _buildCommentButton(),

            const SizedBox(width: 4.0),

            // 3. Repost Button
            _buildRepostButton(),

            const SizedBox(width: 4.0),

            // 4. Share Button
            _buildShareButton(),
          ],
        ),

        // 5. Stock Indicator Pill (for products with stock > 0)
        if (widget.item.isProduct && widget.item.stock != null && widget.item.stock! > 0)
          _buildStockPill(),
      ],
    );
  }

  /// Like button with animated scale and reactive counter
  Widget _buildLikeButton() {
    return InkWell(
      onTap: _handleLikeToggle,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
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
              const SizedBox(width: 4.5),
              Text(
                '$_likesCount',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: _isLiked ? FontWeight.w700 : FontWeight.w500,
                  color: _isLiked ? const Color(0xFFE11D48) : const Color(0xFF334155),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Comment button with counter
  Widget _buildCommentButton() {
    return InkWell(
      onTap: () => widget.onPostClick?.call(widget.item),
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FeedCommentIcon(
              size: 18.0,
              color: Color(0xFF334155),
            ),
            if (widget.item.commentsCount > 0) ...[
              const SizedBox(width: 4.5),
              Text(
                '${widget.item.commentsCount}',
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Repost button with animated rotation and counter
  Widget _buildRepostButton() {
    return InkWell(
      onTap: _handleRepostToggle,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _repostRotateAnim,
              child: FeedRepostIcon(
                isReposted: _isReposted,
                size: 19.0,
                activeColor: const Color(0xFF10B981),
                inactiveColor: const Color(0xFF334155),
              ),
            ),
            if (_repostsCount > 0) ...[
              const SizedBox(width: 4.5),
              Text(
                '$_repostsCount',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: _isReposted ? FontWeight.w700 : FontWeight.w500,
                  color: _isReposted ? const Color(0xFF10B981) : const Color(0xFF334155),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Share button
  Widget _buildShareButton() {
    return InkWell(
      onTap: () {
        if (widget.onShareClick != null) {
          widget.onShareClick!(widget.item);
        } else {
          Clipboard.setData(ClipboardData(text: 'https://snapan.id/post/${widget.item.id}'));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tautan disalin ke papan klip')),
          );
        }
      },
      borderRadius: BorderRadius.circular(20.0),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: FeedShareIcon(
          size: 18.0,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  /// Compact stock indicator pill: [ 📦 5 ] (1:1 Web React Lucide Box & styling)
  Widget _buildStockPill() {
    return Container(
      constraints: const BoxConstraints(minHeight: 26.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.9),
        borderRadius: BorderRadius.circular(13.0),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.8), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FeedBoxIcon(
            size: 14.0,
            color: Color(0xFF71717A),
            strokeWidth: 1.8,
          ),
          const SizedBox(width: 4.5),
          Text(
            '${widget.item.stock}',
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

