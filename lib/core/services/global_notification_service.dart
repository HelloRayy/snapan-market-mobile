import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:snapan_market/core/components/update_info_bottom_sheet.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/navigation/navigation_service.dart';
import 'package:snapan_market/core/services/app_update_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/activity/models/activity_notification_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Top-level background action response handler for notifications
@pragma('vm:entry-point')
Future<void> _notificationTapBackgroundHandler(NotificationResponse details) async {
  try {
    final payload = details.payload;
    if (payload == null || payload.isEmpty) return;
    final json = jsonDecode(payload) as Map<String, dynamic>;
    final actionUrl = json['action_url']?.toString();

    if (details.actionId == 'open_url') {
      if (actionUrl != null && actionUrl.isNotEmpty) {
        final uri = Uri.tryParse(actionUrl);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  } catch (e) {
    debugPrint('Background notification tap error: $e');
  }
}

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final title = message.notification?.title ?? message.data['title'] ?? 'Pengumuman Resmi';
    final body = message.notification?.body ?? message.data['message'] ?? '';

    final localNotifs = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await localNotifs.initialize(
      settings: initSettings,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackgroundHandler,
    );

    final bigTextStyle = BigTextStyleInformation(
      body,
      contentTitle: title,
      summaryText: 'Snaps',
      htmlFormatContent: false,
      htmlFormatContentTitle: false,
    );

    final actionType = message.data['action_type']?.toString() ?? 'none';
    final actionUrl = message.data['action_url']?.toString() ?? '';
    final actionLabel = message.data['action_button_label']?.toString() ??
        (actionType == 'update_app'
            ? 'Perbarui Aplikasi'
            : actionType == 'post_link'
                ? 'Lihat Postingan'
                : 'Buka Tautan');

    List<AndroidNotificationAction>? actions;
    if (actionType == 'external_url' && actionUrl.isNotEmpty) {
      actions = [
        AndroidNotificationAction(
          'open_url',
          actionLabel,
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ];
    } else if (actionType == 'update_app') {
      actions = [
        AndroidNotificationAction(
          'update_app',
          actionLabel,
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ];
    } else if (actionType == 'post_link' && actionUrl.isNotEmpty) {
      actions = [
        AndroidNotificationAction(
          'post_link',
          actionLabel,
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ];
    }

    final androidDetails = AndroidNotificationDetails(
      'snaps_announcements',
      'Pengumuman & Notifikasi Snaps',
      channelDescription: 'Notifikasi broadcast pengumuman resmi dan aktivitas interaksi Snaps.',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigTextStyle,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      actions: actions,
    );

    await localNotifs.show(
      id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 100000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: jsonEncode(message.data),
    );
  } catch (e) {
    debugPrint('Background message handler notification error: $e');
  }
}

/// Global Notification Service (OS Status Bar, In-App Dynamic Banner & FCM Background Push)
/// - Registers Android High Importance Notification Channel (Unlocks OS Toggle)
/// - Dispatches system notifications to Android Status Bar with BigTextStyle (Full Open Text)
/// - Auto-opens Full Open Announcement Modal when tapped from notification tray
/// - Connects Firebase Cloud Messaging (FCM) so alerts penetrate when app is killed/background
class GlobalNotificationService {
  GlobalNotificationService._();
  static final GlobalNotificationService instance = GlobalNotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifs = FlutterLocalNotificationsPlugin();

  dynamic _realtimeChannel;
  final ValueNotifier<bool> hasUnreadActivity = ValueNotifier<bool>(false);
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  OverlayEntry? _currentBannerEntry;
  Timer? _dismissTimer;
  bool _isLocalNotifsInitialized = false;

  /// Initialize global realtime notification listener, FCM, & OS notification channel
  Future<void> init() async {
    // Jalankan local notification & Firebase FCM secara paralel agar tidak saling memblokir jika permission ditunggu
    unawaited(_initLocalNotifications());
    unawaited(_initFirebaseMessaging());
    _fetchInitialUnreadStatus();
    _subscribeRealtime();
  }

  /// Memaksa pengambilan token FCM dan pendaftaran ke Supabase secara langsung
  Future<String> syncFcmTokenNow() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw StateError('Anda belum login ke akun. Silakan masuk terlebih dahulu.');
    }

    final fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Gagal memperoleh token perangkat dari Google Play Services.');
    }

    debugPrint('[FCM] syncFcmTokenNow token: $token');
    await SupabaseService.instance.saveFcmToken(token);

    // Refresh status unread & subscription realtime untuk user ini
    _fetchInitialUnreadStatus();
    _subscribeRealtime();

    return token;
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final fcm = FirebaseMessaging.instance;

      // Ambil token sesegera mungkin di background
      fcm.getToken().then((token) async {
        if (token != null && token.isNotEmpty) {
          debugPrint('[FCM] Device FCM Token generated: $token');
          try {
            await SupabaseService.instance.saveFcmToken(token);
          } catch (_) {}
        }
      }).catchError((e) {
        debugPrint('[FCM] getToken error: $e');
      });

      // Request runtime notification permission (non-blocking)
      unawaited(fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      ));

      // Listen for token refresh
      fcm.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] Token refreshed: $newToken');
        SupabaseService.instance.saveFcmToken(newToken).catchError((_) {});
      });

      // Listen for Supabase Auth state changes to immediately associate token after login
      Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session?.user != null) {
          final currentToken = await fcm.getToken();
          if (currentToken != null && currentToken.isNotEmpty) {
            debugPrint('[FCM] Auth state changed, re-saving token for user: ${session!.user.id}');
            try {
              await SupabaseService.instance.saveFcmToken(currentToken);
            } catch (e) {
              debugPrint('[FCM] Error saving token on auth change: $e');
            }
          }
          // Segera perbarui unread count & koneksikan Realtime listener untuk user ini
          _fetchInitialUnreadStatus();
          _subscribeRealtime();
        } else {
          // User logout: bersihkan subscription realtime & reset badge
          _realtimeChannel?.unsubscribe();
          _realtimeChannel = null;
          unreadCount.value = 0;
          hasUnreadActivity.value = false;
        }
      });

      // When app is in foreground and FCM receives a message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? message.data['title'] ?? 'Pengumuman Baru';
        final body = message.notification?.body ?? message.data['message'] ?? '';
        final actionType = message.data['action_type'] ?? 'none';
        final actionUrl = message.data['action_url'] ?? '';
        final actionButtonLabel = message.data['action_button_label'] ?? 'Buka Tautan';

        final fakeNotif = ActivityNotification(
          id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          type: ActivityType.system,
          actorName: 'Snaps',
          actorUsername: 'snaps',
          actorAvatar: '',
          title: title,
          message: body,
          timeAgo: 'Baru saja',
          actionType: actionType,
          actionUrl: actionUrl,
          actionButtonLabel: actionButtonLabel,
          isRead: false,
        );

        _showOsNotification(
          title: title,
          message: body,
          payloadJson: jsonEncode(fakeNotif.toJson()),
        );

        showTopBanner(
          title: title,
          message: body,
          type: 'system',
          onTap: () {
            final ctx = NavigationService.currentContext;
            if (ctx != null) {
              executeNotificationAction(ctx, fakeNotif);
            }
          },
        );
      });

      // When user clicks notification while app is opened from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          _handleFcmMessageClick(message);
        }
      });

      // When user clicks notification while app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleFcmMessageClick(message);
      });
    } catch (e) {
      debugPrint('Firebase messaging initialization notice: $e');
    }
  }

  void _handleFcmMessageClick(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Pengumuman Resmi';
    final body = message.notification?.body ?? message.data['message'] ?? '';
    final actionType = message.data['action_type'] ?? 'none';
    final actionUrl = message.data['action_url'] ?? '';
    final actionButtonLabel = message.data['action_button_label'] ?? 'Buka Tautan';

    final notif = ActivityNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.system,
      actorName: 'Snaps',
      actorUsername: 'snaps',
      actorAvatar: '',
      title: title,
      message: body,
      timeAgo: 'Baru saja',
      actionType: actionType,
      actionUrl: actionUrl,
      actionButtonLabel: actionButtonLabel,
      isRead: false,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      final ctx = NavigationService.currentContext;
      if (ctx != null) {
        executeNotificationAction(ctx, notif);
      }
    });
  }

  /// Eksekusi langsung aksi dari notifikasi tanpa memunculkan modal pengumuman
  static Future<void> executeNotificationAction(BuildContext context, ActivityNotification notif) async {
    final actionType = notif.actionType ?? 'none';
    final actionUrl = notif.actionUrl ?? '';

    if (actionType == 'update_app') {
      try {
        final update = await AppUpdateService.instance.checkForUpdate(isManual: true);
        if (update != null && context.mounted) {
          final info = await AppUpdateService.instance.getPackageInfo();
          if (context.mounted) {
            UpdateInfoBottomSheet.show(context, update: update, currentVersionName: info.version);
          }
        }
      } catch (e) {
        debugPrint('Error triggering update from notification: $e');
      }
    } else if (actionType == 'external_url' && actionUrl.isNotEmpty) {
      final uri = Uri.tryParse(actionUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (actionType == 'post_link' && actionUrl.isNotEmpty) {
      try {
        final post = await SupabaseService.instance.fetchPostById(actionUrl);
        if (post != null && context.mounted) {
          Navigator.push(
            context,
            AppSlidePageRoute(
              builder: (_) => PostDetailScreen(post: post),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error navigating to post from notification: $e');
      }
    }
  }

  Future<void> _initLocalNotifications() async {
    if (_isLocalNotifsInitialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _localNotifs.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) async {
          final payload = details.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              final json = jsonDecode(payload) as Map<String, dynamic>;
              final notif = ActivityNotification.fromJson(json);

              // Eksekusi aksi jika ada (misal update_app, open_url, post_link)
              final ctx = NavigationService.currentContext;
              if (ctx != null) {
                if (details.actionId == 'open_url') {
                  final url = notif.actionUrl ?? json['action_url']?.toString();
                  if (url != null && url.isNotEmpty) {
                    final uri = Uri.tryParse(url);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                      return;
                    }
                  }
                } else if (details.actionId == 'update_app') {
                  final update = await AppUpdateService.instance.checkForUpdate(isManual: true);
                  if (update != null && ctx.mounted) {
                    final info = await AppUpdateService.instance.getPackageInfo();
                    if (ctx.mounted) {
                      UpdateInfoBottomSheet.show(ctx, update: update, currentVersionName: info.version);
                    }
                  }
                  return;
                } else if (details.actionId == 'post_link') {
                  final postId = notif.actionUrl ?? json['action_url']?.toString();
                  if (postId != null && postId.isNotEmpty) {
                    final post = await SupabaseService.instance.fetchPostById(postId);
                    if (post != null && ctx.mounted) {
                      Navigator.push(
                        ctx,
                        AppSlidePageRoute(
                          builder: (_) => PostDetailScreen(post: post),
                        ),
                      );
                      return;
                    }
                  }
                } else {
                  // User tap tray notifikasi secara keseluruhan: langsung jalankan aksinya
                  await executeNotificationAction(ctx, notif);
                  return;
                }
              }
            } catch (_) {}
          }
          NavigationService.popToRoot();
        },
        onDidReceiveBackgroundNotificationResponse: _notificationTapBackgroundHandler,
      );

      // Create Android Notification Channel (Required to enable notifications toggle on Android 8.0+)
      final androidPlatformPlugin = _localNotifs.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatformPlugin != null) {
        // Request runtime permission for Android 13+ (POST_NOTIFICATIONS)
        await androidPlatformPlugin.requestNotificationsPermission();

        const channel = AndroidNotificationChannel(
          'snaps_announcements', // id
          'Pengumuman & Notifikasi Snaps', // name
          description: 'Notifikasi broadcast pengumuman resmi dan aktivitas interaksi Snaps.',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
          showBadge: true,
        );

        await androidPlatformPlugin.createNotificationChannel(channel);
      }

      _isLocalNotifsInitialized = true;
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
    }
  }

  Future<void> _fetchInitialUnreadStatus() async {
    try {
      final unread = await SupabaseService.instance.getUnreadNotificationsCount();
      unreadCount.value = unread;
      hasUnreadActivity.value = unread > 0;
    } catch (e) {
      debugPrint('Error fetching unread notifications count: $e');
    }
  }

  void _subscribeRealtime() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('[Notification] _subscribeRealtime ditunda: Pengguna belum login.');
        return;
      }

      _realtimeChannel?.unsubscribe();
      _realtimeChannel = SupabaseService.instance.subscribeToNotifications((record) {
        // Increment unread count & turn on unread badge dot
        unreadCount.value += 1;
        hasUnreadActivity.value = true;

        // Trigger system haptic feedback
        HapticFeedback.vibrate();

        final title = record['title']?.toString() ?? 'Pengumuman Baru';
        final message = record['message']?.toString() ?? '';
        final type = record['type']?.toString() ?? 'system';

        // 1. Post notification to Android OS Status Bar with BigTextStyle
        _showOsNotification(
          title: title,
          message: message,
          payloadJson: jsonEncode(record),
        );

        // 2. Show floating in-app banner with direct tap action
        showTopBanner(
          title: title,
          message: message,
          type: type,
          onTap: () {
            final ctx = NavigationService.currentContext;
            if (ctx != null) {
              final notif = ActivityNotification.fromJson(record);
              executeNotificationAction(ctx, notif);
            }
          },
        );
      });
    } catch (e) {
      debugPrint('Error subscribing to global notifications: $e');
    }
  }

  Future<void> _showOsNotification({
    required String title,
    required String message,
    String? payloadJson,
  }) async {
    try {
      final bigTextStyle = BigTextStyleInformation(
        message,
        contentTitle: title,
        summaryText: 'Snaps',
        htmlFormatContent: false,
        htmlFormatContentTitle: false,
      );

      List<AndroidNotificationAction>? actions;
      if (payloadJson != null && payloadJson.isNotEmpty) {
        try {
          final map = jsonDecode(payloadJson) as Map<String, dynamic>;
          final actionType = map['action_type']?.toString();
          final actionUrl = map['action_url']?.toString();
          final actionLabel = map['action_button_label']?.toString() ??
              (actionType == 'update_app'
                  ? 'Perbarui Aplikasi'
                  : actionType == 'post_link'
                      ? 'Lihat Postingan'
                      : 'Buka Tautan');

          if (actionType == 'external_url' && actionUrl != null && actionUrl.isNotEmpty) {
            actions = [
              AndroidNotificationAction(
                'open_url',
                actionLabel,
                showsUserInterface: true,
                cancelNotification: true,
              ),
            ];
          } else if (actionType == 'update_app') {
            actions = [
              AndroidNotificationAction(
                'update_app',
                actionLabel,
                showsUserInterface: true,
                cancelNotification: true,
              ),
            ];
          } else if (actionType == 'post_link' && actionUrl != null && actionUrl.isNotEmpty) {
            actions = [
              AndroidNotificationAction(
                'post_link',
                actionLabel,
                showsUserInterface: true,
                cancelNotification: true,
              ),
            ];
          }
        } catch (_) {}
      }

      final androidDetails = AndroidNotificationDetails(
        'snaps_announcements',
        'Pengumuman & Notifikasi Snaps',
        channelDescription: 'Notifikasi broadcast pengumuman resmi dan aktivitas interaksi Snaps.',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigTextStyle,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        actions: actions,
      );

      final notifDetails = NotificationDetails(android: androidDetails);

      await _localNotifs.show(
        id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 100000,
        title: title,
        body: message,
        notificationDetails: notifDetails,
        payload: payloadJson,
      );
    } catch (e) {
      debugPrint('Error showing OS notification: $e');
    }
  }

  void markAllRead() {
    unreadCount.value = 0;
    hasUnreadActivity.value = false;
    SupabaseService.instance.markNotificationsAsRead();
  }

  /// Displays a floating top in-app banner
  void showTopBanner({
    required String title,
    required String message,
    required String type,
    VoidCallback? onTap,
  }) {
    final context = NavigationService.currentContext;
    if (context == null) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _dismissTimer?.cancel();
    _currentBannerEntry?.remove();
    _currentBannerEntry = null;

    final isSystem = type == 'system';

    _currentBannerEntry = OverlayEntry(
      builder: (ctx) => _FloatingNotificationBanner(
        title: title,
        message: message,
        isSystem: isSystem,
        onDismiss: () {
          _currentBannerEntry?.remove();
          _currentBannerEntry = null;
        },
        onTap: () {
          _currentBannerEntry?.remove();
          _currentBannerEntry = null;
          onTap?.call();
        },
      ),
    );

    overlay.insert(_currentBannerEntry!);

    // Auto dismiss after 4 seconds
    _dismissTimer = Timer(const Duration(milliseconds: 4000), () {
      _currentBannerEntry?.remove();
      _currentBannerEntry = null;
    });
  }

  void dispose() {
    _dismissTimer?.cancel();
    _currentBannerEntry?.remove();
    _realtimeChannel?.unsubscribe();
  }
}

class _FloatingNotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final bool isSystem;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _FloatingNotificationBanner({
    required this.title,
    required this.message,
    required this.isSystem,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_FloatingNotificationBanner> createState() => _FloatingNotificationBannerState();
}

class _FloatingNotificationBannerState extends State<_FloatingNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _animController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPadding + 8.0,
      left: 16.0,
      right: 16.0,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Dismissible(
              key: const Key('global_notification_banner'),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismiss(),
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A), // Dark slate premium card
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0x33FFFFFF), width: 0.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 20.0,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Announcement / Notification Icon Badge
                      Container(
                        width: 38.0,
                        height: 38.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: widget.isSystem
                              ? const LinearGradient(
                                  colors: [Color(0xFF3D38F5), Color(0xFF6366F1)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                        ),
                        child: Icon(
                          widget.isSystem
                              ? CupertinoIcons.speaker_2_fill
                              : CupertinoIcons.bell_fill,
                          color: Colors.white,
                          size: 18.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),

                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: const Text(
                                    "BARU",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              widget.message,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 12.0,
                                height: 1.35,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.isSystem) ...[
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  Text(
                                    "Ketuk untuk buka pesan penuh",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Icon(
                                    CupertinoIcons.arrow_up_right_square,
                                    size: 11.0,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Close icon button
                      GestureDetector(
                        onTap: _handleDismiss,
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            CupertinoIcons.xmark,
                            color: Color(0xFF94A3B8),
                            size: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
