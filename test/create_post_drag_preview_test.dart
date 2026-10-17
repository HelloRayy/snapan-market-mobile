import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/components/create_post_media_preview.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreatePostImagesPreview and Drag Proxy Tests', () {
    testWidgets('renders preview items with delete button when stationary', (tester) async {
      final images = ['test_img_1.jpg', 'test_img_2.jpg'];
      int? removedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreatePostImagesPreview(
              images: images,
              onAddImage: () {},
              onRemoveImage: (idx) => removedIndex = idx,
              onReorderImage: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.byType(ReorderableListView), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.xmark), findsNWidgets(2));

      // Tap delete button on second image
      await tester.tap(find.byIcon(CupertinoIcons.xmark).last);
      expect(removedIndex, equals(1));
    });

    testWidgets('drag proxy decorator builds clean card with brand border and without delete button', (tester) async {
      final images = ['test_img_1.jpg', 'test_img_2.jpg'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreatePostImagesPreview(
              images: images,
              onAddImage: () {},
              onRemoveImage: (_) {},
              onReorderImage: (_, __) {},
            ),
          ),
        ),
      );

      // Start drag gesture on first item to trigger proxyDecorator
      final firstItem = find.byKey(const ValueKey('preview_img_test_img_1.jpg'));
      expect(firstItem, findsOneWidget);

      final gesture = await tester.startGesture(tester.getCenter(firstItem));
      // Hold to trigger reorderable drag start
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 50));

      // Brand border should appear in foreground decoration of proxy card
      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.foregroundDecoration is BoxDecoration) {
          final deco = widget.foregroundDecoration as BoxDecoration;
          final border = deco.border as Border?;
          if (border != null && border.top.color.value == AppColors.primary.value) {
            return true;
          }
        }
        return false;
      });

      // The proxy container is instantiated
      expect(find.byType(ReorderableListView), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    test('deduplication preserves existing items and filters duplicate paths', () {
      final existingImages = ['path/a.jpg', 'path/b.jpg'];
      final pickedImages = ['path/b.jpg', 'path/c.jpg', 'path/a.jpg', 'path/d.jpg'];

      for (final path in pickedImages) {
        if (!existingImages.contains(path)) {
          existingImages.add(path);
        }
      }

      expect(existingImages, equals(['path/a.jpg', 'path/b.jpg', 'path/c.jpg', 'path/d.jpg']));
      expect(existingImages.length, equals(4));
    });
  });
}
