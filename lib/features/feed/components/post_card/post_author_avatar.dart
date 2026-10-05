import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/ui/oreo_avatar_helper.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// 42x42px circular author avatar with thumb-friendly '+' follow badge (Threads standard)
class PostAuthorAvatar extends StatelessWidget {
  final SellerModel seller;
  final bool? isFollowed;
  final VoidCallback? onFollowToggle;
  final VoidCallback? onUserClick;

  const PostAuthorAvatar({
    super.key,
    required this.seller,
    this.isFollowed,
    this.onFollowToggle,
    this.onUserClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FollowService.instance,
      builder: (context, _) {
        final bool isMe = FollowService.instance.isCurrentUser(seller.id, seller.username);
        final bool followed = FollowService.instance.isFollowing(seller.id, seller.username) ||
            (isFollowed == true && !FollowService.instance.isLoaded);

        return GestureDetector(
          onTap: onUserClick,
          child: SizedBox(
            width: 46.0,
            height: 46.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Circular Avatar Container (Threads standard: borderless, shadowless, pure image fill)
                Positioned(
                  left: 0,
                  top: 0,
                  child: SizedBox(
                    width: 42.0,
                    height: 42.0,
                    child: AppAvatar(
                      avatarUrl: seller.avatar,
                      size: 42.0,
                    ),
                  ),
                ),

                // Thumb-friendly '+' Follow Badge:
                // Only shown if NOT followed AND NOT the current user!
                // Once followed, this badge immediately vanishes across all posts of this author!
                if (!isMe && !followed)
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          if (!SupabaseService.instance.isAuthenticated) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Silakan masuk untuk mengikuti akun ini.'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                            return;
                          }

                          final newStatus = await FollowService.instance.toggleFollow(
                            targetUserId: seller.id,
                            targetUsername: seller.username,
                          );
                          if (context.mounted) {
                            onFollowToggle?.call();
                            if (newStatus) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Mengikuti ${seller.name}'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          color: Colors.transparent,
                          child: Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF000000), // Threads Ink Black #000000
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_rounded,
                                size: 14.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
