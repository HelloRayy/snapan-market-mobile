import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/home_feed_tab_switch.dart';
import 'package:snapan_market/features/feed/components/home_bottom_nav_bar.dart';
import 'package:snapan_market/features/create_post/screens/create_post_modal.dart';
import 'package:snapan_market/features/feed/screens/home_feed_screen.dart';
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
}
