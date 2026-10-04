import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/follow_service.dart';
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
        final bool followed = FollowService.instance.isLoaded
            ? FollowService.instance.isFollowing(seller.id, seller.username)
            : (FollowService.instance.isFollowing(seller.id, seller.username) || (isFollowed == true));

        return GestureDetector(
          onTap: onUserClick,
          child: SizedBox(
            width: 44.0,
            height: 44.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Circular Avatar Container (Threads standard: borderless, shadowless, pure image fill)
                SizedBox(
                  width: 42.0,
                  height: 42.0,
                  child: ClipOval(
                    child: Image.network(
                      seller.avatar,
                      width: 42.0,
                      height: 42.0,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => OreoAvatarPlaceholder(
                        seed: seller.username ?? seller.name,
                        displayName: seller.name,
                        size: 42.0,
                      ),
                    ),
                  ),
                ),

                // Thumb-friendly '+' Follow Badge:
                // Only shown if NOT followed AND NOT the current user!
                // Once followed, this badge immediately vanishes across all posts of this author!
                if (!isMe && !followed)
                  Positioned(
                    right: -6.0,
                    bottom: -6.0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final newStatus = await FollowService.instance.toggleFollow(
                            targetUserId: seller.id,
                            targetUsername: seller.username,
                          );
                          onFollowToggle?.call();
                          if (context.mounted && newStatus) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Mengikuti ${seller.name}'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
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
