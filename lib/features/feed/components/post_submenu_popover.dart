import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/snaps_toast.dart';
import 'package:snapan_market/features/feed/components/post_submenu_item.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// 1:1 Popover Contextual Menu for Post Three-Dot ('...') Trigger
/// Matching PostSubmenuDropdown.tsx from Web Codebase
class PostSubmenuPopover extends StatefulWidget {
  final MarketPostModel post;
  final bool isSaved;
  final bool isOwner;
  final bool isAdmin;
  final VoidCallback onToggleSave;
  final VoidCallback? onHidePost;
  final VoidCallback? onMuteAuthor;
  final VoidCallback? onReport;
  final VoidCallback? onDeletePost;
  final VoidCallback? onClosePoll;

  const PostSubmenuPopover({
    super.key,
    required this.post,
    required this.isSaved,
    this.isOwner = false,
    this.isAdmin = false,
    required this.onToggleSave,
    this.onHidePost,
    this.onMuteAuthor,
    this.onReport,
    this.onDeletePost,
    this.onClosePoll,
  });

  /// Shows the popover anchored to the tap position with transparent background
  static Future<void> show({
    required BuildContext context,
    required MarketPostModel post,
    required bool isSaved,
    bool? isOwner,
    bool? isAdmin,
    required VoidCallback onToggleSave,
    VoidCallback? onHidePost,
    VoidCallback? onMuteAuthor,
    VoidCallback? onReport,
    VoidCallback? onDeletePost,
    VoidCallback? onClosePoll,
    Offset? position,
  }) {
    HapticFeedback.lightImpact();

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PostSubmenu',
      barrierColor: Colors.transparent, // Latar belakang bening tanpa overlay gelap
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (ctx, anim1, anim2) {
        final topOffset = position?.dy ?? 120.0;
        final rightOffset = 12.0;

        return Stack(
          children: [
            Positioned(
              top: (topOffset - 6.0).clamp(50.0, MediaQuery.of(ctx).size.height - 240.0),
              right: rightOffset,
              child: Material(
                color: Colors.transparent,
                child: PostSubmenuPopover(
                  post: post,
                  isSaved: isSaved,
                  isOwner: isOwner ?? false,
                  isAdmin: isAdmin ?? false,
                  onToggleSave: onToggleSave,
                  onHidePost: onHidePost,
                  onMuteAuthor: onMuteAuthor,
                  onReport: onReport,
                  onDeletePost: onDeletePost,
                  onClosePoll: onClosePoll,
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
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
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
    SnapsToast.show(context, message, hasBottomNav: true);
  }

  @override
  Widget build(BuildContext context) {
    final authorHandle = widget.post.seller.username != null
        ? '@${widget.post.seller.username!.replaceAll('@', '')}'
        : widget.post.seller.name;

    return Container(
      width: 216.0,
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24.0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Simpan ke Markah / Hapus
          PostSubmenuItem(
            icon: _isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
            iconColor: _isSaved ? AppColors.primary : const Color(0xFF334155),
            label: _isSaved ? 'Hapus Markah' : 'Simpan Markah',
            onTap: () {
              setState(() => _isSaved = !_isSaved);
              widget.onToggleSave();
              Navigator.pop(context);
              _showFeedback(_isSaved ? 'Disimpan ke markah' : 'Dihapus dari markah');
            },
          ),

          // 2. Salin Tautan
          PostSubmenuItem(
            icon: CupertinoIcons.link,
            label: 'Salin Tautan',
            onTap: () {
              Clipboard.setData(ClipboardData(text: 'https://snapan.id/post/${widget.post.id}'));
              Navigator.pop(context);
              _showFeedback('Tautan disalin ke papan klip');
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            child: Divider(height: 1.0, thickness: 0.6, color: Color(0xFFF1F5F9)),
          ),

          if (widget.isOwner) ...[
            if (widget.post.poll != null && !widget.post.poll!.isExpired) ...[
              PostSubmenuItem(
                icon: CupertinoIcons.stopwatch,
                iconColor: const Color(0xFFD97706),
                textColor: const Color(0xFFD97706),
                label: 'Tutup Polling',
                onTap: () {
                  Navigator.pop(context);
                  widget.onClosePoll?.call();
                },
              ),
            ],
            // 3. Hapus Postingan (Milik Sendiri)
            PostSubmenuItem(
              icon: CupertinoIcons.trash,
              iconColor: const Color(0xFFEF4444),
              textColor: const Color(0xFFEF4444),
              label: 'Hapus Postingan',
              onTap: () {
                Navigator.pop(context);
                widget.onDeletePost?.call();
              },
            ),
          ] else ...[
            // 3. Senyapkan User
            PostSubmenuItem(
              icon: CupertinoIcons.bell_slash,
              label: 'Senyapkan $authorHandle',
              onTap: () {
                widget.onMuteAuthor?.call();
                Navigator.pop(context);
                _showFeedback('Notifikasi $authorHandle disenyapkan');
              },
            ),

            // 4. Sembunyikan Postingan
            PostSubmenuItem(
              icon: CupertinoIcons.eye_slash,
              label: 'Sembunyikan Post',
              onTap: () {
                widget.onHidePost?.call();
                Navigator.pop(context);
                _showFeedback('Postingan disembunyikan');
              },
            ),

            if (widget.isAdmin) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                child: Divider(height: 1.0, thickness: 0.6, color: Color(0xFFF1F5F9)),
              ),
              PostSubmenuItem(
                icon: CupertinoIcons.trash,
                iconColor: const Color(0xFFEF4444),
                textColor: const Color(0xFFEF4444),
                label: 'Hapus Post (Admin)',
                onTap: () {
                  Navigator.pop(context);
                  widget.onDeletePost?.call();
                },
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
              child: Divider(height: 1.0, thickness: 0.6, color: Color(0xFFF1F5F9)),
            ),

            // 5. Laporkan Postingan (Destructive Red)
            PostSubmenuItem(
              icon: CupertinoIcons.flag,
              iconColor: const Color(0xFFEF4444),
              textColor: const Color(0xFFEF4444),
              label: 'Laporkan Post',
              onTap: () {
                widget.onReport?.call();
                Navigator.pop(context);
                _showFeedback('Laporan terkirim');
              },
            ),
          ],
        ],
      ),
    );
  }
}
