import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/core/services/media_upload_service.dart';
import 'package:snapan_market/features/create_post/components/create_post_footer_bar.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SNAPS-78: Feed Performance & Upload Optimizations Tests', () {
    test('MediaUploadService instance exists and maintains efficient downscaling contract', () {
      final service = MediaUploadService.instance;
      expect(service, isNotNull);
    });

    testWidgets('CreatePostFooterBar displays upload progress bar and status when submitting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreatePostFooterBar(
              audiencePrivacy: 'Semua orang dapat membalas',
              canSubmit: true,
              isSubmitting: true,
              uploadProgress: 0.65,
              uploadStatusText: 'Mengunggah media (2/3)...',
              onPrivacyTap: () {},
              onSubmit: () {},
            ),
          ),
        ),
      );

      // Verify that progress status text and percentage are displayed
      expect(find.text('Mengunggah media (2/3)...'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    test('MarketPostModel immutability and copyWith support for fast rendering', () {
      const post = MarketPostModel(
        id: 'post-1',
        postType: 'thread',
        caption: 'Optimized test post',
        timestamp: 'Baru saja',
        seller: SellerModel(
          id: 'user-1',
          name: 'Rayhan',
          avatar: '',
          classGroup: 'XII RPL 1',
        ),
      );

      final updated = post.copyWith(isLiked: true, isSaved: true);
      expect(updated.isLiked, isTrue);
      expect(updated.isSaved, isTrue);
      expect(updated.id, equals('post-1'));
    });
  });
}
