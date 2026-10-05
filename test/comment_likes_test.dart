import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

void main() {
  group('PostCommentModel and Likes Tests', () {
    test('PostCommentModel preserves and updates isLiked and likesCount', () {
      final user = CommentUserModel(
        id: 'user_1',
        name: 'Rayhan',
        username: 'rayhan',
        avatar: '',
      );

      final comment = PostCommentModel(
        id: 'c1',
        postId: 'post_1',
        user: user,
        content: 'Mantap banget!',
        timestamp: 'Baru saja',
        likesCount: 0,
        isLiked: false,
      );

      expect(comment.isLiked, isFalse);
      expect(comment.likesCount, 0);

      // Simulate liking
      final likedComment = comment.copyWith(
        isLiked: true,
        likesCount: comment.likesCount + 1,
      );

      expect(likedComment.isLiked, isTrue);
      expect(likedComment.likesCount, 1);

      // Simulate unliking
      final unlikedComment = likedComment.copyWith(
        isLiked: false,
        likesCount: (likedComment.likesCount - 1).clamp(0, 999999),
      );

      expect(unlikedComment.isLiked, isFalse);
      expect(unlikedComment.likesCount, 0);
    });

    test('PostCommentModel.assembleTree preserves like attributes across root and nested replies', () {
      final user = CommentUserModel(
        id: 'user_1',
        name: 'Rayhan',
        username: 'rayhan',
        avatar: '',
      );

      final flatComments = [
        PostCommentModel(
          id: 'c1',
          postId: 'post_1',
          user: user,
          content: 'Parent comment',
          timestamp: '1j',
          likesCount: 5,
          isLiked: true,
        ),
        PostCommentModel(
          id: 'c2',
          postId: 'post_1',
          parentCommentId: 'c1',
          user: user,
          content: 'Reply comment',
          timestamp: '30m',
          likesCount: 2,
          isLiked: true,
        ),
      ];

      final tree = PostCommentModel.assembleTree(flatComments);

      expect(tree.length, 1);
      expect(tree.first.id, 'c1');
      expect(tree.first.isLiked, isTrue);
      expect(tree.first.likesCount, 5);
      expect(tree.first.replies.length, 1);
      expect(tree.first.replies.first.id, 'c2');
      expect(tree.first.replies.first.isLiked, isTrue);
      expect(tree.first.replies.first.likesCount, 2);
    });
  });
}
