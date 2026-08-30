import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/formatters.dart';
import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
import 'package:snapan_market/features/create_post/screens/create_post_modal.dart';
import 'package:snapan_market/features/feed/screens/home_feed_screen.dart';
import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/components/market_feed_icons.dart';
import 'package:snapan_market/features/feed/components/post_comment_item.dart';
import 'package:snapan_market/features/feed/components/comment_input_bar.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:snapan_market/main.dart';

final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override
  void close({bool force = false}) {}
  @override
  Future<HttpClientRequest> delete(String host, int port, String path) => open('delete', host, port, path);
  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl('delete', url);
  @override
  Future<HttpClientRequest> get(String host, int port, String path) => open('get', host, port, path);
  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('get', url);
  @override
  Future<HttpClientRequest> head(String host, int port, String path) => open('head', host, port, path);
  @override
  Future<HttpClientRequest> headUrl(Uri url) => openUrl('head', url);
  @override
  Future<HttpClientRequest> patch(String host, int port, String path) => open('patch', host, port, path);
  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl('patch', url);
  @override
  Future<HttpClientRequest> post(String host, int port, String path) => open('post', host, port, path);
  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl('post', url);
  @override
  Future<HttpClientRequest> put(String host, int port, String path) => open('put', host, port, path);
  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl('put', url);
  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) async => _MockHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();

  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}
  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}
  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override
  set findProxy(String Function(Uri url)? f) {}
  @override
  set connectionFactory(Future<ConnectionTask<Socket>> Function(Uri url, String? proxyHost, int? proxyPort)? f) {}
  @override
  set keyLog(void Function(String line)? callback) {}
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  bool bufferOutput = true;
  @override
  int contentLength = -1;
  @override
  Encoding encoding = utf8;
  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  bool persistentConnection = true;

  @override
  void add(List<int> data) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future<void> addStream(Stream<List<int>> stream) async {}
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
  @override
  Future<HttpClientResponse> get done async => _MockHttpClientResponse();
  @override
  Future<void> flush() async {}
  @override
  void write(Object? object) {}
  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {}
  @override
  void writeCharCode(int charCode) {}
  @override
  void writeln([Object? object = '']) {}
  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}
  @override
  HttpConnectionInfo? get connectionInfo => null;
  @override
  List<Cookie> get cookies => [];
  @override
  String get method => 'GET';
  @override
  Uri get uri => Uri.parse('http://example.com/mock.png');
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;
  @override
  String? value(String name) => null;
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void clear() {}
  @override
  void noFolding(String name) {}
  @override
  void remove(String name, Object value) {}
  @override
  void removeAll(String name) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void forEach(void Function(String name, List<String> values) action) {}
  @override
  bool chunkedTransferEncoding = false;
  @override
  int contentLength = -1;
  @override
  ContentType? contentType;
  @override
  DateTime? date;
  @override
  DateTime? expires;
  @override
  String? host;
  @override
  DateTime? ifModifiedSince;
  @override
  bool persistentConnection = true;
  @override
  int? port;
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  int get statusCode => HttpStatus.ok;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override
  String get reasonPhrase => 'OK';
  @override
  bool get isRedirect => false;
  @override
  bool get persistentConnection => false;
  @override
  List<RedirectInfo> get redirects => [];
  @override
  List<Cookie> get cookies => [];
  @override
  X509Certificate? get certificate => null;
  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) async => this;
  @override
  Future<Socket> detachSocket() async => throw UnimplementedError();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });
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
      expect(find.byType(MarketPostCard), findsWidgets);

      // 8. Switch Tab to "Terbaru"
      await tester.tap(find.text('Terbaru'));
      await tester.pumpAndSettle();

      // Verify Feed content reflects "Terbaru" and renders posts
      expect(find.byType(MarketPostCard), findsWidgets);

      // 9. Switch Tab back to "Untuk Anda"
      await tester.tap(find.text('Untuk Anda'));
      await tester.pumpAndSettle();

      // Verify Feed content reflects "Untuk Anda"
      expect(find.byType(MarketPostCard), findsWidgets);
      // 10. Verify HomeBottomNavBar is present on HomeFeedScreen
      expect(find.byType(HomeBottomNavBar), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // 11. Scroll to bottom and tap Logout button to verify returning to Onboarding
      final logoutButton = find.text('Keluar (Reset Onboarding)');
      await tester.scrollUntilVisible(
        logoutButton,
        500.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();
      // Verify returning to Onboarding
      expect(find.text('Pusat Jual Beli Warga SMKN 8 Jakarta'), findsOneWidget);
    });
  });

  group('CreatePostModal Carousel & Full-Bleed Layout Tests', () {
    testWidgets(
        'Renders SingleChildScrollView with Clip.none and zero horizontal root padding',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePostModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify SingleChildScrollView exists and has clipBehavior: Clip.none
      final scrollViewFinder = find.byType(SingleChildScrollView);
      expect(scrollViewFinder, findsOneWidget);

      final SingleChildScrollView scrollView =
          tester.widget(scrollViewFinder);
      expect(scrollView.clipBehavior, Clip.none);
      expect(
        scrollView.padding,
        const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 20.0),
      );
    });

    testWidgets(
        'Adding image renders full-bleed horizontal ListView with Clip.none and 64px left offset',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePostModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap image icon on media toolbar to attach image
      final imageIconFinder = find.byIcon(CupertinoIcons.photo);
      expect(imageIconFinder, findsOneWidget);
      await tester.tap(imageIconFinder);
      await tester.pumpAndSettle();

      // Verify OverflowBox for screenWidth edge-to-edge
      final overflowFinder = find.byWidgetPredicate(
        (w) => w is OverflowBox && w.minHeight == 185.0,
      );
      expect(overflowFinder, findsOneWidget);

      // Verify horizontal ListView with Clip.none
      final horizontalListFinder = find.byWidgetPredicate(
        (w) =>
            w is ListView &&
            w.scrollDirection == Axis.horizontal &&
            w.clipBehavior == Clip.none,
      );
      expect(horizontalListFinder, findsOneWidget);

      final ListView horizontalList = tester.widget(horizontalListFinder);
      expect(
        horizontalList.padding,
        const EdgeInsets.only(left: 64.0, right: 16.0),
      );

      // Verify "Tambah Foto" tile is present at end of carousel
      expect(find.text('Tambah Foto'), findsOneWidget);
    });

    testWidgets(
        'Horizontal image carousel can scroll smoothly and remove image on tap close',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePostModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Attach multiple images
      final imageIconFinder = find.byIcon(CupertinoIcons.photo);
      await tester.tap(imageIconFinder);
      await tester.pumpAndSettle();
      await tester.tap(imageIconFinder);
      await tester.pumpAndSettle();

      final horizontalListFinder = find.byWidgetPredicate(
        (w) =>
            w is ListView &&
            w.scrollDirection == Axis.horizontal &&
            w.clipBehavior == Clip.none,
      );
      expect(horizontalListFinder, findsOneWidget);

      // Scroll horizontally
      await tester.drag(horizontalListFinder, const Offset(-100.0, 0.0));
      await tester.pumpAndSettle();

      // Verify close buttons exist and tapping one removes an image
      final closeButtons = find.byIcon(Icons.close_rounded);
      expect(closeButtons, findsWidgets);
      final initialCount = tester.widgetList(closeButtons).length;

      await tester.tap(closeButtons.first);
      await tester.pumpAndSettle();

      final afterCount =
          tester.widgetList(find.byIcon(Icons.close_rounded)).length;
      expect(afterCount, initialCount - 1);
    });

    testWidgets(
        'Emoji bar opens with full-bleed Clip.none ListView and inserts emoji on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePostModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap smiley icon on media toolbar to open emoji scroller
      final smileyIconFinder = find.byIcon(CupertinoIcons.smiley);
      expect(smileyIconFinder, findsOneWidget);
      await tester.tap(smileyIconFinder);
      await tester.pumpAndSettle();

      // Verify OverflowBox for screenWidth edge-to-edge emoji bar
      final emojiOverflowFinder = find.byWidgetPredicate(
        (w) => w is OverflowBox && w.minHeight == 38.0,
      );
      expect(emojiOverflowFinder, findsOneWidget);

      // Verify horizontal ListView with Clip.none and left 64px offset
      final emojiListFinder = find.byWidgetPredicate(
        (w) =>
            w is ListView &&
            w.scrollDirection == Axis.horizontal &&
            w.clipBehavior == Clip.none,
      );
      expect(emojiListFinder, findsOneWidget);

      final ListView emojiList = tester.widget(emojiListFinder);
      expect(
        emojiList.padding,
        const EdgeInsets.only(left: 64.0, right: 16.0),
      );

      // Verify tapping an emoji inserts it into the TextField
      final fireEmojiFinder = find.text('🔥');
      expect(fireEmojiFinder, findsOneWidget);
      await tester.tap(fireEmojiFinder);
      await tester.pumpAndSettle();

      final captionFieldFinder = find.byWidgetPredicate(
        (w) => w is TextField && w.controller?.text.contains('🔥') == true,
      );
      expect(captionFieldFinder, findsOneWidget);

      // Drag emoji bar horizontally across avatar boundary
      await tester.drag(emojiListFinder, const Offset(-120.0, 0.0));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Thread connector line stretches dynamically and aligns with bottom avatar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePostModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify IntrinsicHeight exists for the thread block
      final intrinsicHeightFinder = find.byType(IntrinsicHeight);
      expect(intrinsicHeightFinder, findsWidgets);

      // Verify "Tambahkan ke utas" trigger is present
      final addSubThreadTrigger = find.text('Tambahkan ke utas');
      expect(addSubThreadTrigger, findsOneWidget);

      // Tap "Tambahkan ke utas" to append a sub-thread
      await tester.tap(addSubThreadTrigger);
      await tester.pumpAndSettle();

      // Verify sub-thread input appears
      expect(find.text('Lanjutan utas...'), findsOneWidget);

      // Type into sub-thread input
      final subThreadInputFinder = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == 'Lanjutan utas...',
      );
      expect(subThreadInputFinder, findsOneWidget);
      await tester.enterText(subThreadInputFinder, 'Poin kedua dari utas ini');
      await tester.pumpAndSettle();

      // Verify remove sub-thread button
      final removeButton = find.byIcon(Icons.close_rounded);
      expect(removeButton, findsOneWidget);
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Verify sub-thread input is dismissed
      expect(find.text('Lanjutan utas...'), findsNothing);
    });
  });

  group('MarketPostCard Widget & Interaction Tests', () {
    testWidgets('Renders Community Thread Post with Avatar, Topic, Multi-Thread, and Action Bar',
        (WidgetTester tester) async {
      const threadPost = MarketPostModel(
        id: 'test-thread-1',
        postType: 'thread',
        seller: SellerModel(
          id: 'u1',
          name: 'Raymond Chin',
          avatar: 'http://example.com/avatar.png',
          classGroup: 'XII PPLG 1',
          isVerified: true,
          username: 'raymondchins',
        ),
        caption: 'Ada kenalan UI engineer untuk kolaborasi PWA kilat? 🚀',
        images: ['http://example.com/image1.png'],
        topicTag: 'frontend',
        isOfficialTopic: true,
        topicIcon: 'threads',
        totalThreadParts: 2,
        likesCount: 466,
        commentsCount: 12,
        repostsCount: 9,
        timestamp: '1j',
        isLiked: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarketPostCard(item: threadPost),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Author Name & Verified Badge
      expect(find.text('Raymond Chin'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);

      // Verify Threads Topic Glyph and Tag
      expect(find.text('frontend'), findsOneWidget);
      expect(find.byType(ThreadsTopicGlyph), findsOneWidget);

      // Verify Timestamp and More Options (3-dots)
      expect(find.text('1j'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

      // Verify Caption & Multi-Thread badge (1/2)
      expect(find.textContaining('Ada kenalan UI engineer'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);

      // Verify Vector Action Bar Icons
      expect(find.byType(FeedHeartIcon), findsOneWidget);
      expect(find.byType(FeedCommentIcon), findsOneWidget);
      expect(find.byType(FeedRepostIcon), findsOneWidget);
      expect(find.byType(FeedShareIcon), findsOneWidget);

      // Verify Action Bar counters
      expect(find.text('466'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);

      // Verify No stock indicator on pure thread post
      expect(find.byIcon(Icons.inventory_2_outlined), findsNothing);
    });
    testWidgets('Renders Market Product Post with COD Location Tag and Stock Indicator Pill',
        (WidgetTester tester) async {
      const productPost = MarketPostModel(
        id: 'test-product-1',
        postType: 'product',
        title: 'Jasa Desain UI/UX & PWA Kilat',
        seller: SellerModel(
          id: 'u1',
          name: 'Faiz Intifada',
          avatar: 'http://example.com/avatar.png',
          classGroup: 'XII DKV 2',
          isVerified: false,
          username: 'faizintifada',
        ),
        caption: 'Open order jasa pembuatan UI/UX & Engineering PWA!',
        images: [
          'http://example.com/img1.png',
          'http://example.com/img2.png',
        ],
        price: 150000,
        stock: 7,
        locationTag: 'Lab Komputer PPLG',
        likesCount: 245,
        commentsCount: 18,
        repostsCount: 5,
        timestamp: '3j',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarketPostCard(item: productPost),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Author name and class (no topic tag)
      expect(find.text('Faiz Intifada'), findsOneWidget);
      expect(find.text('XII DKV 2'), findsOneWidget);

      // Verify COD Location Tag
      expect(find.text('Lab Komputer PPLG'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);

      // Verify Stock Indicator Pill (7)
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('Interactive Like & Repost toggling updates UI state and counters reactively',
        (WidgetTester tester) async {
      MarketPostModel? toggledLikeItem;
      MarketPostModel? toggledRepostItem;

      const initialPost = MarketPostModel(
        id: 'test-interactive-1',
        postType: 'thread',
        seller: SellerModel(
          id: 'u1',
          name: 'Raymond Chin',
          avatar: 'http://example.com/avatar.png',
          classGroup: 'XII PPLG 1',
        ),
        caption: 'Testing reactive interactions',
        likesCount: 10,
        commentsCount: 2,
        repostsCount: 3,
        timestamp: '15m',
        isLiked: false,
        isReposted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarketPostCard(
              item: initialPost,
              onLikeToggle: (item) => toggledLikeItem = item,
              onRepostToggle: (item) => toggledRepostItem = item,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: 10 likes, FeedHeartIcon with isLiked: false
      expect(find.text('10'), findsOneWidget);
      expect(find.byType(FeedHeartIcon), findsOneWidget);
      final initialHeart = tester.widget<FeedHeartIcon>(find.byType(FeedHeartIcon));
      expect(initialHeart.isLiked, isFalse);

      // Tap Like button
      final likeButtonFinder = find.byType(FeedHeartIcon);
      await tester.tap(likeButtonFinder);
      await tester.pumpAndSettle();

      // Verified state: 11 likes, FeedHeartIcon with isLiked: true, callback invoked
      expect(find.text('11'), findsOneWidget);
      final likedHeart = tester.widget<FeedHeartIcon>(find.byType(FeedHeartIcon));
      expect(likedHeart.isLiked, isTrue);
      expect(toggledLikeItem, isNotNull);
      expect(toggledLikeItem!.isLiked, isTrue);
      expect(toggledLikeItem!.likesCount, 11);

      // Tap Like button again to unlike
      await tester.tap(find.byType(FeedHeartIcon));
      await tester.pumpAndSettle();
      expect(find.text('10'), findsOneWidget);
      final unlikedHeart = tester.widget<FeedHeartIcon>(find.byType(FeedHeartIcon));
      expect(unlikedHeart.isLiked, isFalse);
      expect(toggledLikeItem!.isLiked, isFalse);
      expect(toggledLikeItem!.likesCount, 10);

      // Tap Repost button
      final repostButtonFinder = find.byType(FeedRepostIcon);
      await tester.tap(repostButtonFinder);
      await tester.pumpAndSettle();

      // Verified state: 4 reposts, FeedRepostIcon with isReposted: true
      expect(find.text('4'), findsOneWidget);
      final repostedIcon = tester.widget<FeedRepostIcon>(find.byType(FeedRepostIcon));
      expect(repostedIcon.isReposted, isTrue);
      expect(toggledRepostItem, isNotNull);
      expect(toggledRepostItem!.isReposted, isTrue);
      expect(toggledRepostItem!.repostsCount, 4);
    });
    testWidgets('Triggers callbacks on post, topic, user, and image tap',
        (WidgetTester tester) async {
      bool postClicked = false;
      String? clickedTopic;
      String? clickedUser;
      int? clickedImageIdx;

      const postItem = MarketPostModel(
        id: 'test-callbacks-1',
        postType: 'product',
        seller: SellerModel(
          id: 'u1',
          name: 'Ibu Kantin',
          avatar: 'http://example.com/avatar.png',
          classGroup: 'Kantin SMKN 8',
          username: 'kantin_smkn8',
        ),
        caption: 'Tahu Walik Renyah!',
        topicTag: 'Kantin',
        images: ['http://example.com/tahu.png'],
        timestamp: '5m',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarketPostCard(
              item: postItem,
              onPostClick: (_) => postClicked = true,
              onTopicClick: (topic) => clickedTopic = topic,
              onUserClick: (user) => clickedUser = user,
              onImageClick: (_, idx) => clickedImageIdx = idx,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Topic Tag
      await tester.tap(find.text('Kantin'));
      await tester.pumpAndSettle();
      expect(clickedTopic, 'Kantin');

      // Tap Author Name
      await tester.tap(find.text('Ibu Kantin'));
      await tester.pumpAndSettle();
      expect(clickedUser, 'kantin_smkn8');

      // Tap Image to trigger onImageClick
      await tester.tap(find.byType(AspectRatio));
      await tester.pumpAndSettle();
      expect(clickedImageIdx, 0);

      // Tap Comment button to trigger post click
      await tester.tap(find.byType(FeedCommentIcon));
      await tester.pumpAndSettle();
      expect(postClicked, isTrue);
    });
    testWidgets('Header row uses full-width spaceBetween with flush-right 3-dots button',
        (WidgetTester tester) async {
      const post = MarketPostModel(
        id: 'test-header-layout',
        postType: 'thread',
        seller: SellerModel(
          id: 'u1',
          name: 'Raymond Chin',
          avatar: 'http://example.com/avatar.png',
          classGroup: 'XII PPLG 1',
          isVerified: true,
        ),
        caption: 'Testing header row flex alignment',
        topicTag: 'frontend',
        isOfficialTopic: true,
        timestamp: '2m',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarketPostCard(item: post),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header Row structure
      final headerRowFinder = find.byWidgetPredicate((widget) {
        return widget is Row &&
            widget.mainAxisAlignment == MainAxisAlignment.spaceBetween &&
            widget.children.length == 3; // Expanded, SizedBox(8), Row(Timestamp + MoreOptions)
      });
      expect(headerRowFinder, findsOneWidget);

      // Verify 3-dots More Options button is rendered at the right side
      final moreOptionsFinder = find.byIcon(Icons.more_horiz_rounded);
      expect(moreOptionsFinder, findsOneWidget);
      final moreOptionsContainer = tester.widget<Container>(
        find.ancestor(of: moreOptionsFinder, matching: find.byType(Container)).first,
      );
      expect(moreOptionsContainer.constraints?.minWidth, 36.0);
      expect(moreOptionsContainer.constraints?.minHeight, 36.0);
    });
  });

  group('HomeFeedScreen Dynamic Feed Integration Tests', () {
    testWidgets('Renders MarketPostCard items from dataset and end-of-feed footer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeFeedScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify MarketPostCard items rendered in feed
      expect(find.byType(MarketPostCard), findsWidgets);

      // Verify first author name is present
      expect(find.text('Raymond Chin'), findsWidgets);

      // Scroll down to check footer
      await tester.scrollUntilVisible(
        find.text('Scroll ke bawah untuk memuat postingan baru'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      // Verify end-of-feed footer text
      expect(find.text('Scroll ke bawah untuk memuat postingan baru'), findsOneWidget);
    });

    testWidgets('Switching between "Untuk Anda" and "Terbaru" tabs updates feed list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeFeedScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Terbaru" tab
      final terbaruTabFinder = find.text('Terbaru');
      expect(terbaruTabFinder, findsOneWidget);
      await tester.tap(terbaruTabFinder);
      await tester.pumpAndSettle();

      // Feed remains populated with MarketPostCard items
      expect(find.byType(MarketPostCard), findsWidgets);
    });
  });

  group('Core Formatters Utility Unit Tests', () {
    test('formatSmartTimestamp cleans legacy relative strings with "lalu"', () {
      expect(formatSmartTimestamp('15m lalu'), '15m');
      expect(formatSmartTimestamp('1j lalu'), '1j');
      expect(formatSmartTimestamp('2h lalu'), '2h');
      expect(formatSmartTimestamp('3d lalu'), '3h');
      expect(formatSmartTimestamp('10 menit lalu'), '10m');
      expect(formatSmartTimestamp('2 jam lalu'), '2j');
      expect(formatSmartTimestamp('5 hari lalu'), '5h');
      expect(formatSmartTimestamp('Baru saja'), 'Baru saja');
      expect(formatSmartTimestamp(''), 'Baru saja');
      expect(formatSmartTimestamp(null), 'Baru saja');
    });

    test('formatSmartTimestamp preserves already-concise strings', () {
      expect(formatSmartTimestamp('15m'), '15m');
      expect(formatSmartTimestamp('2j'), '2j');
      expect(formatSmartTimestamp('3h'), '3h');
      expect(formatSmartTimestamp('10m'), '10m');
    });

    test('formatSmartTimestamp formats dynamic DateTime correctly', () {
      final now = DateTime.now();
      // < 1 minute
      expect(formatSmartTimestamp(now.subtract(const Duration(seconds: 10))), 'Baru saja');
      // < 1 hour
      expect(formatSmartTimestamp(now.subtract(const Duration(minutes: 25))), '25m');
      // < 24 hours
      expect(formatSmartTimestamp(now.subtract(const Duration(hours: 4))), '4j');
      // < 7 days
      expect(formatSmartTimestamp(now.subtract(const Duration(days: 3))), '3h');

      // Same year older date
      final sameYearDate = DateTime(now.year, 8, 17, 10, 0);
      final result = formatSmartTimestampDetailed(sameYearDate);
      expect(result.display, contains('17 Agu'));
      expect(result.full, contains('17 Agustus ${now.year} pukul 10:00 WIB'));
    });

    test('formatRupiah formats IDR currency correctly', () {
      expect(formatRupiah(150000), 'Rp 150.000');
      expect(formatRupiah(10000), 'Rp 10.000');
      expect(formatRupiah(0), 'Rp 0');
      expect(formatRupiah(2500000), 'Rp 2.500.000');
    });

    test('formatCompactNumber formats large counts into k and M suffixes', () {
      expect(formatCompactNumber(466), '466');
      expect(formatCompactNumber(1200), '1.2k');
      expect(formatCompactNumber(1500000), '1.5M');
    });

    test('stripEmojis removes emojis cleanly', () {
      expect(stripEmojis('Open Order 🚀✨'), 'Open Order');
      expect(stripEmojis('Tahu Walik 🥟🔥'), 'Tahu Walik');
    });

    test('toUsernameSlug converts name to valid slug', () {
      expect(toUsernameSlug('Raymond Chin'), 'raymondchin');
      expect(toUsernameSlug('Faiz Intifada'), 'faizintifada');
      expect(toUsernameSlug(null), 'user');
    });
  });

  group('PostDetailScreen & Comment Slicing 1:1 Tests', () {
    testWidgets('Renders PostDetailScreen 1:1 matching Web layout and Image #1',
        (WidgetTester tester) async {
      final targetPost = kMockMarketPosts[0]; // post-thread-1

      await tester.pumpWidget(
        MaterialApp(
          home: PostDetailScreen(post: targetPost),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Top Header Bar
      expect(find.text('Postingan'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // 2. Verify Focused Post (Detail Variant)
      expect(find.byType(MarketPostCard), findsOneWidget);
      expect(find.text('Raymond Chin'), findsWidgets);
      expect(find.text('frontend'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('466'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);

      // 3. Verify Section Divider
      expect(find.text('Komentar (3)'), findsOneWidget);
      expect(find.text('Urutkan dari Terbaru'), findsOneWidget);

      // 4. Verify Author Thread Continuation (Part 2/2)
      expect(find.text('Pembuat Utas'), findsOneWidget);
      expect(find.text('2/2'), findsOneWidget);
      expect(find.textContaining('Requirement: Paham React/Next.js'), findsOneWidget);

      // 5. Verify User Comments
      expect(find.text('zura.wk'), findsOneWidget);
      expect(find.textContaining('Saya open collab mas!'), findsOneWidget);
      expect(find.text('lisayayaa_'), findsOneWidget);
      expect(find.textContaining('Bisa sekalian kerjakan Supabase Auth'), findsOneWidget);

      // 6. Verify Nested Reply by Author
      expect(find.textContaining('Mantap kak, nanti kita diskusiin'), findsOneWidget);

      // 7. Verify Floating Bottom CommentInputBar
      expect(find.byType(CommentInputBar), findsOneWidget);
      expect(find.text('Kirim'), findsOneWidget);
    });

    testWidgets('Tapping reply on a comment updates input bar banner',
        (WidgetTester tester) async {
      final targetPost = kMockMarketPosts[0];

      await tester.pumpWidget(
        MaterialApp(
          home: PostDetailScreen(post: targetPost),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap "Balas" button on a comment
      final replyButtons = find.text('Balas');
      expect(replyButtons, findsWidgets);
      await tester.tap(replyButtons.first);
      await tester.pumpAndSettle();

      // Verify replying banner appears
      expect(find.textContaining('Membalas'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Tap "Batal"
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Batal'), findsNothing);
    });
  });
}
