import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/core/constants/app_constants.dart';
import 'package:snapan_market/core/theme/app_animations.dart';
import 'package:snapan_market/features/feed/components/home_feed_scrollable_list.dart';
import 'package:snapan_market/features/feed/components/lightbox/media_lightbox_dialog.dart';
import 'package:snapan_market/features/feed/components/navigation/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/profile/components/profile_tab_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SNAPS-26: Motion & Animations Tokens Tests', () {
    test('AppAnimations defines optimal tab durations, curves and edge drag', () {
      expect(AppAnimations.tabDuration.inMilliseconds, equals(280));
      expect(AppAnimations.quick.inMilliseconds, equals(160));
      expect(AppAnimations.drawerEdgeDragWidth, equals(28.0));
      expect(AppAnimations.tabCurve, isA<Cubic>());
    });
  });

  group('SNAPS-26: HomeFeedTabSwitch Threads-Style Tests', () {
    testWidgets('Tapping tab triggers callback and updates active indicator', (tester) async {
      FeedTab currentTab = FeedTab.forYou;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HomeFeedTabSwitch(
                  activeTab: currentTab,
                  onTabChanged: (newTab) {
                    setState(() {
                      currentTab = newTab;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Untuk Anda'), findsOneWidget);
      expect(find.text('Jualan'), findsOneWidget);

      // Tap "Jualan" tab
      await tester.tap(find.text('Jualan'));
      await tester.pumpAndSettle();

      expect(currentTab, equals(FeedTab.market));
    });
  });

  group('SNAPS-26: HomeFeedScrollableList Threads-Style Tab Switch Tests', () {
    final samplePosts = <MarketPostModel>[
      const MarketPostModel(
        id: 'post-thread-1',
        caption: 'Halo teman-teman SMKN 8!',
        timestamp: 'Baru saja',
        postType: 'thread',
        seller: SellerModel(
          id: 'user-1',
          name: 'Rayhan',
          avatar: '',
          classGroup: 'XII RPL 1',
        ),
      ),
      const MarketPostModel(
        id: 'post-product-1',
        caption: 'Risol Mayo Spesial Renyah',
        timestamp: '5m lalu',
        postType: 'product',
        price: 3000,
        seller: SellerModel(
          id: 'user-2',
          name: 'Kantin 8',
          avatar: '',
          classGroup: 'Kantin',
        ),
      ),
    ];

    testWidgets('Tapping tab switches view between Untuk Anda and Jualan safely without horizontal drift', (tester) async {
      FeedTab activeTab = FeedTab.forYou;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HomeFeedScrollableList(
                  activeTab: activeTab,
                  onTabChanged: (t) {
                    setState(() {
                      activeTab = t;
                    });
                  },
                  isLoading: false,
                  hasError: false,
                  errorMessage: '',
                  allPosts: samplePosts,
                  onRefresh: () async {},
                  onRetry: () {},
                  onScrollToTop: () {},
                  onShowFab: () {},
                  onHideFab: () {},
                  onLikeToggle: (_) {},
                  onRepostToggle: (_) {},
                  onPostClick: (_) {},
                  onTopicClick: (_) {},
                  onUserClick: (_) {},
                  onImageClick: (_, _) {},
                  onDeletePost: (_) {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on "Untuk Anda" - should show the thread post
      expect(find.text('Halo teman-teman SMKN 8!'), findsOneWidget);

      if (AppConstants.enableCommerceMode) {
        // Tap "Jualan" in header switch bar
        await tester.tap(find.text('Jualan'));
        await tester.pumpAndSettle();

        // After tap, activeTab switched to market
        expect(activeTab, equals(FeedTab.market));

        // In Jualan tab, product post should be visible
        expect(find.text('Risol Mayo Spesial Renyah'), findsOneWidget);
      }
    });
  });

  group('UX Gold Standard: Profile Tab Swipe Tests', () {
    testWidgets('ProfileTabBar and PageView swipe smoothly across Utas, Balasan, and Media', (tester) async {
      final pageController = PageController();
      ProfileTab currentTab = ProfileTab.threads;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ProfileTabBar(
                      activeTab: currentTab,
                      pageController: pageController,
                      onTabChanged: (tab) {
                        setState(() => currentTab = tab);
                      },
                    ),
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (idx) {
                          setState(() => currentTab = ProfileTab.values[idx]);
                        },
                        children: const [
                          Center(child: Text('Konten Utas')),
                          Center(child: Text('Konten Balasan')),
                          Center(child: Text('Konten Media')),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Utas'), findsOneWidget);
      expect(find.text('Balasan'), findsOneWidget);
      expect(find.text('Media'), findsOneWidget);
      expect(find.text('Konten Utas'), findsOneWidget);

      // Swipe left to go to Balasan
      await tester.fling(find.text('Konten Utas'), const Offset(-600.0, 0.0), 1000.0);
      await tester.pumpAndSettle();

      expect(currentTab, equals(ProfileTab.replies));
      expect(find.text('Konten Balasan'), findsOneWidget);

      // Swipe left again to go to Media
      await tester.fling(find.text('Konten Balasan'), const Offset(-600.0, 0.0), 1000.0);
      await tester.pumpAndSettle();

      expect(currentTab, equals(ProfileTab.media));
      expect(find.text('Konten Media'), findsOneWidget);
    });
  });

  group('UX Gold Standard: Lightbox Swipe-Down-To-Dismiss Tests', () {
    testWidgets('Dragging down on lightbox dialog dismisses modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    MediaLightboxDialog.show(
                      context: context,
                      images: const ['https://example.com/test.jpg'],
                      initialIndex: 0,
                    );
                  },
                  child: const Text('Buka Lightbox'),
                ),
              );
            },
          ),
        ),
      );

      // Open lightbox
      await tester.tap(find.text('Buka Lightbox'));
      await tester.pumpAndSettle();

      expect(find.byType(MediaLightboxDialog), findsOneWidget);

      // Fling down to dismiss
      await tester.fling(find.byType(MediaLightboxDialog), const Offset(0.0, 500.0), 1000.0);
      await tester.pumpAndSettle();

      // Lightbox should now be dismissed
      expect(find.byType(MediaLightboxDialog), findsNothing);
    });
  });
}
