import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/poll_sync_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/services/suspension_service.dart';
import 'package:snapan_market/features/feed/components/delete_post_bottom_sheet.dart';
import 'package:snapan_market/features/feed/components/post_submenu_popover.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Controller managing comments fetching, adding, post deletion, and submenu actions.
class PostDetailController extends ChangeNotifier {
  MarketPostModel post;
  List<PostCommentModel> comments;
  bool isLoadingComments = true;
  String? replyToUser;
  String? replyToCommentId;
  bool isCommentingActive = false;

  PostDetailController({
    required this.post,
  }) : comments = List<PostCommentModel>.from(post.comments) {
    post = PollSyncService.instance.syncPost(post);
    PollSyncService.instance.addListener(_onPollSyncUpdate);
    isLoadingComments = comments.isEmpty;
    loadLiveComments();
  }

  void _onPollSyncUpdate() {
    if (post.poll == null) return;
    final synced = PollSyncService.instance.syncPost(post);
    if (synced != post) {
      post = synced;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    PollSyncService.instance.removeListener(_onPollSyncUpdate);
    super.dispose();
  }

  Future<void> loadLiveComments() async {
    try {
      final live = await SupabaseService.instance.fetchPostComments(post.id);
      if (live.isNotEmpty) {
        comments = PostCommentModel.assembleTree(live);
        post = post.copyWith(
          comments: comments,
          commentsCount: live.length,
        );
      } else {
        comments = [];
        post = post.copyWith(
          comments: [],
          commentsCount: 0,
        );
      }
      isLoadingComments = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadLiveComments: $e');
      isLoadingComments = false;
      notifyListeners();
    }
  }

  void setReply(String username, [String? commentId]) {
    replyToUser = username;
    replyToCommentId = commentId;
    isCommentingActive = true;
    notifyListeners();
  }

  void cancelReply(bool isProductMode) {
    replyToUser = null;
    replyToCommentId = null;
    if (isProductMode) isCommentingActive = false;
    notifyListeners();
  }

  void openCommentField() {
    isCommentingActive = true;
    notifyListeners();
  }

  Future<bool> addComment(BuildContext context, String content, bool isProductMode) async {
    if (content.trim().isEmpty) return false;
    HapticFeedback.mediumImpact();

    if (!SupabaseService.instance.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masuk akun terlebih dahulu untuk berkomentar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    // Proactively check if account got suspended (SNAPS-16)
    final isSuspended = await SuspensionService.instance.checkStatus();
    if (isSuspended) return false;

    try {
      final liveComment = await SupabaseService.instance.addComment(
        postId: post.id,
        content: content.trim(),
        parentCommentId: replyToCommentId,
      );

      if (replyToCommentId != null) {
        comments = comments.map((c) {
          if (c.id == replyToCommentId || c.replies.any((r) => r.id == replyToCommentId)) {
            return c.copyWith(replies: [...c.replies, liveComment]);
          }
          return c;
        }).toList();
      } else {
        comments.insert(0, liveComment);
      }
      post = post.copyWith(
        commentsCount: post.commentsCount + 1,
        comments: comments,
      );
      replyToUser = null;
      replyToCommentId = null;
      if (isProductMode) isCommentingActive = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggapan berhasil dikirim!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');

      // Check if error is due to suspension RLS policy
      final isNowSuspended = await SuspensionService.instance.checkStatus();
      if (isNowSuspended) return false;

      final user = SupabaseService.instance.currentUser;
      final fallbackComment = PostCommentModel(
        id: 'comment-local-${DateTime.now().millisecondsSinceEpoch}',
        postId: post.id,
        user: CommentUserModel(
          id: user?.id ?? 'user-current',
          name: 'Akun Anda',
          avatar: '',
        ),
        content: content.trim(),
        timestamp: 'Baru saja',
      );

      comments.insert(0, fallbackComment);
      replyToUser = null;
      replyToCommentId = null;
      notifyListeners();
      return false;
    }
  }

  /// Delete a comment with optimistic UI update and error rollback
  Future<bool> deleteComment(BuildContext context, String commentId) async {
    HapticFeedback.mediumImpact();

    int removedCount = 1;
    final topComment = comments.where((c) => c.id == commentId).firstOrNull;
    if (topComment != null) {
      removedCount = 1 + topComment.replies.length;
    }

    final previousComments = List<PostCommentModel>.from(comments);
    final previousCount = post.commentsCount;

    comments = comments.where((c) => c.id != commentId).map((c) {
      if (c.replies.any((r) => r.id == commentId)) {
        return c.copyWith(
          replies: c.replies.where((r) => r.id != commentId).toList(),
        );
      }
      return c;
    }).toList();

    post = post.copyWith(
      commentsCount: (post.commentsCount - removedCount).clamp(0, 999999),
    );
    notifyListeners();

    try {
      await SupabaseService.instance.deleteComment(commentId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Komentar berhasil dihapus'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      comments = previousComments;
      post = post.copyWith(commentsCount: previousCount);
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus komentar. Coba lagi.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  /// Toggle comment or reply like with optimistic UI update and remote persistence
  Future<void> toggleCommentLike(PostCommentModel updated) async {
    HapticFeedback.lightImpact();
    final wasLiked = !updated.isLiked;

    // Optimistic local update
    comments = comments.map((c) {
      if (c.id == updated.id) {
        return updated.copyWith(replies: c.replies);
      }
      if (c.replies.any((r) => r.id == updated.id)) {
        final newReplies = c.replies.map((r) => r.id == updated.id ? updated : r).toList();
        return c.copyWith(replies: newReplies);
      }
      return c;
    }).toList();
    notifyListeners();

    try {
      await SupabaseService.instance.toggleCommentLike(updated.id, wasLiked);
    } catch (e) {
      debugPrint('Error toggleCommentLike: $e');
      // Rollback
      final rollback = updated.copyWith(
        isLiked: wasLiked,
        likesCount: wasLiked ? updated.likesCount + 1 : (updated.likesCount - 1).clamp(0, 999999),
      );
      comments = comments.map((c) {
        if (c.id == rollback.id) {
          return rollback.copyWith(replies: c.replies);
        }
        if (c.replies.any((r) => r.id == rollback.id)) {
          final rollbackReplies = c.replies.map((r) => r.id == rollback.id ? rollback : r).toList();
          return c.copyWith(replies: rollbackReplies);
        }
        return c;
      }).toList();
      notifyListeners();
    }
  }

  /// Vote in a poll with instantaneous optimistic UI update & debounced network call
  void votePoll(List<String> optionIds) {
    if (post.poll == null) return;

    PollSyncService.instance.castVote(
      postId: post.id,
      optionIds: optionIds,
      currentPoll: post.poll!,
      remoteCaller: (pId, oIds) => SupabaseService.instance.votePoll(
        postId: pId,
        optionIds: oIds,
      ),
      onError: (e) {
        debugPrint('[PostDetailController] Error votePoll detail: $e');
      },
    );
  }

  Future<void> showSubmenu({
    required BuildContext context,
    required ValueChanged<MarketPostModel>? onBookmarkToggle,
    required ValueChanged<MarketPostModel>? onDeletePost,
  }) async {
    HapticFeedback.lightImpact();
    final currentUser = SupabaseService.instance.currentUser;
    final bool isOwner = currentUser != null && (currentUser.id == post.seller.id);
    final bool isAdmin = await SupabaseService.instance.isCurrentUserAdmin();

    if (!context.mounted) return;

    PostSubmenuPopover.show(
      context: context,
      post: post,
      isSaved: post.isSaved,
      isOwner: isOwner,
      isAdmin: isAdmin,
      onToggleSave: () {
        final nextSaved = !post.isSaved;
        post = post.copyWith(isSaved: nextSaved);
        notifyListeners();
        SupabaseService.instance.togglePostBookmark(post.id, !nextSaved);
        onBookmarkToggle?.call(post);
      },
      onDeletePost: () async {
        final confirmed = await DeletePostBottomSheet.show(
          context,
          post: post,
          isAdmin: isAdmin && !isOwner,
        );

        if (confirmed == true && context.mounted) {
          onDeletePost?.call(post);
          Navigator.of(context).pop({'deleted': true, 'postId': post.id});

          try {
            await SupabaseService.instance.deletePost(post.id, asAdmin: isAdmin && !isOwner);
          } catch (e) {
            debugPrint('Error deleting post: $e');
          }
        }
      },
      onClosePoll: () async {
        if (post.poll != null) {
          final updated = post.copyWith(poll: post.poll!.copyWith(isClosed: true));
          post = updated;
          notifyListeners();
          try {
            final serverPoll = await SupabaseService.instance.closePoll(post.id);
            post = post.copyWith(poll: serverPoll);
            notifyListeners();
          } catch (e) {
            debugPrint('Error closePoll: $e');
          }
        }
      },
    );
  }
}
