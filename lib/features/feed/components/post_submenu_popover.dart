import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// 1:1 Popover Contextual Menu for Post Three-Dot ('...') Trigger
/// Matching PostSubmenuDropdown.tsx from Web Codebase
class PostSubmenuPopover extends StatefulWidget {
  final MarketPostModel post;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback? onHidePost;
  final VoidCallback? onMuteAuthor;
  final VoidCallback? onReport;

  const PostSubmenuPopover({
    super.key,
    required this.post,
    required this.isSaved,
    required this.onToggleSave,
    this.onHidePost,
    this.onMuteAuthor,
    this.onReport,
  });

  /// Shows the popover anchored to the tap position or top right
  static Future<void> show({
    required BuildContext context,
    required MarketPostModel post,
    required bool isSaved,
    required VoidCallback onToggleSave,
    VoidCallback? onHidePost,
    VoidCallback? onMuteAuthor,
    VoidCallback? onReport,
    Offset? position,
  }) {
    HapticFeedback.lightImpact();

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PostSubmenu',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, anim1, anim2) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final topOffset = position?.dy ?? 120.0;
        final rightOffset = 16.0;

        return Stack(
          children: [
            Positioned(
              top: (topOffset - 10.0).clamp(60.0, MediaQuery.of(ctx).size.height - 280.0),
              right: rightOffset,
              child: Material(
                color: Colors.transparent,
                child: PostSubmenuPopover(
                  post: post,
                  isSaved: isSaved,
                  onToggleSave: onToggleSave,
                  onHidePost: onHidePost,
                  onMuteAuthor: onMuteAuthor,
                  onReport: onReport,
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<PostSubmenuPopover> createState() => _PostSubmenuPopoverState();
}

class _PostSubmenuPopoverState extends State<PostSubmenuPopover> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authorHandle = widget.post.seller.username != null
        ? '@${widget.post.seller.username!.replaceAll('@', '')}'
        : widget.post.seller.name;

    return Container(
      width: 230.0,
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 32.0,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Simpan ke Markah / Hapus
          _PopoverItem(
            icon: _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            iconColor: _isSaved ? AppColors.primary : AppColors.slateInk,
            label: _isSaved ? 'Hapus dari Markah' : 'Simpan ke Markah',
            onTap: () {
              setState(() => _isSaved = !_isSaved);
              widget.onToggleSave();
              Navigator.pop(context);
              _showFeedback(_isSaved ? 'Disimpan ke markah tersimpan ✨' : 'Dihapus dari markah');
            },
          ),

          // 2. Salin Tautan
          _PopoverItem(
            icon: Icons.link_rounded,
            label: 'Salin Tautan',
            onTap: () {
              Clipboard.setData(ClipboardData(text: 'https://snapan.id/post/${widget.post.id}'));
              Navigator.pop(context);
              _showFeedback('Tautan berhasil disalin ke papan klip 🔗');
            },
          ),

          const Divider(height: 9.0, thickness: 0.7, color: Color(0xFFF1F5F9)),

          // 3. Senyapkan User
          _PopoverItem(
            icon: Icons.notifications_off_outlined,
            label: 'Senyapkan $authorHandle',
            onTap: () {
              widget.onMuteAuthor?.call();
              Navigator.pop(context);
              _showFeedback('Notifikasi dari $authorHandle disenyapkan 🔕');
            },
          ),

          // 4. Sembunyikan Postingan
          _PopoverItem(
            icon: Icons.visibility_off_outlined,
            label: 'Sembunyikan Postingan',
            onTap: () {
              widget.onHidePost?.call();
              Navigator.pop(context);
              _showFeedback('Postingan disembunyikan dari feed Anda 👁️');
            },
          ),

          const Divider(height: 9.0, thickness: 0.7, color: Color(0xFFF1F5F9)),

          // 5. Laporkan Postingan (Destructive)
          _PopoverItem(
            icon: Icons.flag_outlined,
            iconColor: const Color(0xFFDC2626),
            textColor: const Color(0xFFDC2626),
            label: 'Laporkan Postingan',
            onTap: () {
              widget.onReport?.call();
              Navigator.pop(context);
              _showFeedback('Laporan terkirim, terima kasih atas masukan Anda 🚩');
            },
          ),
        ],
      ),
    );
  }
}

class _PopoverItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _PopoverItem({
    required this.icon,
    required this.label,
    this.iconColor,
    this.textColor,
    required this.onTap,
  });

  @override
  State<_PopoverItem> createState() => _PopoverItemState();
}

class _PopoverItemState extends State<_PopoverItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: _isPressed ? const Color(0xFFF8FAFC) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 17.5,
              color: widget.iconColor ?? AppColors.slateInk,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: widget.textColor ?? AppColors.ink,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
