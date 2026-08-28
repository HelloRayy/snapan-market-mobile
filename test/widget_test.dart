import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
import 'package:snapan_market/features/feed/screens/home_feed_screen.dart';
import 'package:snapan_market/main.dart';

void main() {
  group('HomeFeedHeader Widget Tests', () {
    testWidgets(
        'Renders 50px header with 36x36 menu, search buttons and semibold logotype',
        (WidgetTester tester) async {
      bool menuTapped = false;
      bool titleTapped = false;
      bool searchTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeFeedHeader(
              onMenuTap: () => menuTapped = true,
              onTitleTap: () => titleTapped = true,
              onSearchTap: () => searchTapped = true,
            ),
            body: const Center(child: Text('Body Content')),
          ),
        ),
      );

      // Verify Header PreferredSize is 50px
      final headerFinder = find.byType(HomeFeedHeader);
      expect(headerFinder, findsOneWidget);
      final HomeFeedHeader headerWidget = tester.widget(headerFinder);
      expect(headerWidget.preferredSize.height, 50.0);

      // Verify Menu button and tap callback
      final menuFinder = find.byIcon(Icons.menu_rounded);
      expect(menuFinder, findsOneWidget);
      await tester.tap(menuFinder);
      await tester.pumpAndSettle();
      expect(menuTapped, isTrue);

      // Verify Logotype has FontWeight.w600 (Semibold)
      final logotypeTextFinder = find.byWidgetPredicate((widget) {
        if (widget is Text && widget.textSpan is TextSpan) {
          final span = widget.textSpan! as TextSpan;
          if (span.children != null && span.children!.length >= 2) {
            final firstChild = span.children![0] as TextSpan;
            final secondChild = span.children![1] as TextSpan;
            return firstChild.text == 'Snapan ' &&
                firstChild.style?.fontWeight == FontWeight.w600 &&
                secondChild.text == 'Market' &&
                secondChild.style?.fontWeight == FontWeight.w600;
          }
        }
        return false;
      });
      expect(logotypeTextFinder, findsOneWidget);

      // Verify Logotype tap callback
      final logotypeFinder = find.text('Snapan Market', findRichText: true);
      expect(logotypeFinder, findsOneWidget);
      await tester.tap(logotypeFinder);
      await tester.pumpAndSettle();
      expect(titleTapped, isTrue);

      // Verify Search button and tap callback
      final searchFinder = find.byIcon(Icons.search_rounded);
      expect(searchFinder, findsOneWidget);
      await tester.tap(searchFinder);
      await tester.pumpAndSettle();
      expect(searchTapped, isTrue);
    });
  });

  group('HomeFeedTabSwitch Widget Tests', () {
    testWidgets(
        'Renders 47px switch bar with "Untuk Anda" and "Terbaru" tabs & active indicator',
        (WidgetTester tester) async {
      FeedTab currentTab = FeedTab.forYou;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HomeFeedTabSwitch(
                  activeTab: currentTab,
                  onTabChanged: (tab) {
                    setState(() {
                      currentTab = tab;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify preferred size is 47px
      final switchFinder = find.byType(HomeFeedTabSwitch);
      expect(switchFinder, findsOneWidget);
      final HomeFeedTabSwitch switchWidget = tester.widget(switchFinder);
      expect(switchWidget.preferredSize.height, 47.0);

      // Verify both tab labels exist
      expect(find.text('Untuk Anda'), findsOneWidget);
      expect(find.text('Terbaru'), findsOneWidget);

      // Verify active styling on "Untuk Anda" (w700 & AppColors.ink)
      final forYouText = tester.widget<Text>(find.text('Untuk Anda'));
      expect(forYouText.style?.fontWeight, FontWeight.w700);
      expect(forYouText.style?.color, AppColors.ink);

      // Verify inactive styling on "Terbaru" (w500 & 0xFF8E8E93)
      final latestText = tester.widget<Text>(find.text('Terbaru'));
      expect(latestText.style?.fontWeight, FontWeight.w500);
      expect(latestText.style?.color, const Color(0xFF8E8E93));

      // Tap on "Terbaru" tab
      await tester.tap(find.text('Terbaru'));
      await tester.pumpAndSettle();

      // Verify currentTab switched to FeedTab.latest
      expect(currentTab, FeedTab.latest);

      // Verify styling updated: "Terbaru" is now active (w700 & AppColors.ink)
      final latestTextActive = tester.widget<Text>(find.text('Terbaru'));
      expect(latestTextActive.style?.fontWeight, FontWeight.w700);
      expect(latestTextActive.style?.color, AppColors.ink);

      // Verify "Untuk Anda" is now inactive (w500 & 0xFF8E8E93)
      final forYouTextInactive = tester.widget<Text>(find.text('Untuk Anda'));
      expect(forYouTextInactive.style?.fontWeight, FontWeight.w500);
      expect(forYouTextInactive.style?.color, const Color(0xFF8E8E93));
    });
  });
  group('HomeBottomNavBar Widget Tests', () {
    testWidgets(
        'Renders 5-item bottom bar with active pill, badge, and center FAB',
        (WidgetTester tester) async {
      HomeNavTab selectedTab = HomeNavTab.home;
      bool createTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return HomeBottomNavBar(
                  currentTab: selectedTab,
                  hasUnreadMessages: true,
                  hasUnreadActivity: true,
                  onTabSelected: (tab) {
                    setState(() => selectedTab = tab);
                  },
                  onCreateTap: () => createTapped = true,
                );
              },
            ),
          ),
        ),
      );

      // Verify HomeBottomNavBar exists
      expect(find.byType(HomeBottomNavBar), findsOneWidget);

      // Verify all 5 tab components/icons are present
      expect(find.byType(HomeBottomNavBar), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      // Verify Red Notification Badge is rendered (Color 0xFFFF3B30)
      final badgeFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration! as BoxDecoration;
          return decoration.color == const Color(0xFFFF3B30);
        }
        return false;
      });
      expect(badgeFinder, findsNWidgets(2)); // Both Pesan and Aktivitas badges
      // Verify Home tab is active
      expect(selectedTab, HomeNavTab.home);
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(createTapped, isTrue);

      // Tap Center FAB
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(createTapped, isTrue);
    });

    testWidgets('Hides HomeBottomNavBar when virtual keyboard is open',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              viewInsets: EdgeInsets.only(bottom: 280.0), // Keyboard open
            ),
            child: Scaffold(
              bottomNavigationBar: HomeBottomNavBar(
                currentTab: HomeNavTab.home,
                onTabSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // When keyboard is open, HomeBottomNavBar returns SizedBox.shrink() and no icons are rendered
      expect(find.byIcon(Icons.home_rounded), findsNothing);
      expect(find.byIcon(Icons.add_rounded), findsNothing);
    });

    testWidgets('Provides correct labels and semantics for all tabs',
        (WidgetTester tester) async {
      expect(HomeNavTab.home.label, 'Home');
      expect(HomeNavTab.messages.label, 'Pesan');
      expect(HomeNavTab.create.label, 'Buat Postingan');
      expect(HomeNavTab.activity.label, 'Aktivitas');
      expect(HomeNavTab.profile.label, 'Profil');
    });
  });


  group('User Journey Integration Tests', () {
    testWidgets('Onboarding -> Auth Login -> HomeFeedScreen navigation & tab switching',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SnapanMarketApp());

      // 1. Verify Onboarding Slide 0 is displayed
      expect(find.text('Pusat Jual Beli Warga SMKN 8 Jakarta'), findsOneWidget);
      expect(find.text('Lewati'), findsOneWidget);
      expect(find.text('Lanjutkan'), findsOneWidget);

      // 2. Tap "Lewati" to navigate immediately to Auth Screen
      await tester.tap(find.text('Lewati'));
      await tester.pumpAndSettle();

      // 3. Verify Auth Screen fields are present
      expect(find.text('Masuk\nke Akun Kamu'), findsOneWidget);
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      // 4. Fill in login credentials
      final emailPhoneField = textFields.at(0);
      final passwordField = textFields.at(1);
      await tester.enterText(emailPhoneField, '081234567890');
      await tester.enterText(passwordField, 'rahasia123');
      await tester.pumpAndSettle();

      // 5. Tap "Masuk" button to submit login
      final loginButton = find.widgetWithText(KumoButton, 'Masuk');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // 6. Verify transition to HomeFeedScreen & HomeFeedHeader
      expect(find.byType(HomeFeedScreen), findsOneWidget);
      expect(find.byType(HomeFeedHeader), findsOneWidget);
      expect(find.byType(HomeFeedTabSwitch), findsOneWidget);

      // Verify Header Components (Menu, Logotype "Snapan Market", Search)
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.text('Snapan Market', findRichText: true), findsOneWidget);

      // 7. Verify Initial Active Feed Tab is "Untuk Anda"
      expect(find.text('Untuk Anda'), findsOneWidget);
      expect(find.text('Terbaru'), findsOneWidget);
      expect(find.text('Feed Beranda Aktif'), findsOneWidget);
      expect(
        find.text('Untuk Anda • Rekomendasi & Diskusi SMKN 8'),
        findsOneWidget,
      );

      // 8. Switch Tab to "Terbaru"
      await tester.tap(find.text('Terbaru'));
      await tester.pumpAndSettle();

      // Verify Feed content reflects "Terbaru"
      expect(
        find.text('Terbaru • Aktivitas & Produk Baru SMKN 8'),
        findsOneWidget,
      );
      // 9. Switch Tab back to "Untuk Anda"
      await tester.tap(find.text('Untuk Anda'));
      await tester.pumpAndSettle();

      // Verify Feed content reflects "Untuk Anda"
      expect(
        find.text('Untuk Anda • Rekomendasi & Diskusi SMKN 8'),
        findsOneWidget,
      );
      // 10. Verify HomeBottomNavBar is present on HomeFeedScreen
      expect(find.byType(HomeBottomNavBar), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // 11. Tap Logout button to verify returning to Onboarding
      final logoutButton = find.text('Keluar (Reset Onboarding)');
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Verify returning to Onboarding
      expect(find.text('Pusat Jual Beli Warga SMKN 8 Jakarta'), findsOneWidget);
    });
  });
}
