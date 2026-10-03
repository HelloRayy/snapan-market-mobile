import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:snapan_market/core/navigation/navigation_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/activity/components/broadcast_detail_modal.dart';
import 'package:snapan_market/features/activity/models/activity_notification_model.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    final title = message.notification?.title ?? message.data['title'] ?? 'Pengumuman Resmi';
    final body = message.notification?.body ?? message.data['message'] ?? '';

    final localNotifs = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await localNotifs.initialize(settings: initSettings);

    final bigTextStyle = BigTextStyleInformation(
      body,
      contentTitle: title,
      summaryText: 'SMKN 8 Semarang',
      htmlFormatContent: false,
      htmlFormatContentTitle: false,
    );

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
    await _initLocalNotifications();
    await _initFirebaseMessaging();
    _fetchInitialUnreadStatus();
    _subscribeRealtime();
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final fcm = FirebaseMessaging.instance;
      await fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM Token and save to Supabase
      final token = await fcm.getToken();
      if (token != null) {
        await SupabaseService.instance.saveFcmToken(token);
      }

      // Listen for token refresh
      fcm.onTokenRefresh.listen((newToken) {
        SupabaseService.instance.saveFcmToken(newToken);
      });

      // When app is in foreground and FCM receives a message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? message.data['title'] ?? 'Pengumuman Baru';
        final body = message.notification?.body ?? message.data['message'] ?? '';
        final actionType = message.data['action_type'] ?? 'none';
        final actionUrl = message.data['action_url'] ?? '';

        final fakeNotif = ActivityNotification(
          id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          type: ActivityType.system,
          actorName: 'Administrator',
          actorUsername: 'admin',
          actorAvatar: '',
          title: title,
          message: body,
          timeAgo: 'Baru saja',
          actionType: actionType,
          actionUrl: actionUrl,
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
              BroadcastDetailModal.show(ctx, fakeNotif);
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

    final notif = ActivityNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.system,
      actorName: 'Administrator',
      actorUsername: 'admin',
      actorAvatar: '',
      title: title,
      message: body,
      timeAgo: 'Baru saja',
      actionType: actionType,
      actionUrl: actionUrl,
      isRead: false,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      final ctx = NavigationService.currentContext;
      if (ctx != null) {
        BroadcastDetailModal.show(ctx, notif);
      }
    });
  }

  Future<void> _initLocalNotifications() async {
    if (_isLocalNotifsInitialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _localNotifs.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Ketika user tap notifikasi di status bar Android
          final payload = details.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              final json = jsonDecode(payload) as Map<String, dynamic>;
              final notif = ActivityNotification.fromJson(json);
              final ctx = NavigationService.currentContext;
              if (ctx != null) {
                BroadcastDetailModal.show(ctx, notif);
                return;
              }
            } catch (_) {}
          }
          NavigationService.popToRoot();
        },
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

        // 2. Show floating in-app banner with tap action
        showTopBanner(
          title: title,
          message: message,
          type: type,
          onTap: () {
            final ctx = NavigationService.currentContext;
            if (ctx != null) {
              final notif = ActivityNotification.fromJson(record);
              BroadcastDetailModal.show(ctx, notif);
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
        summaryText: 'SMKN 8 Semarang',
        htmlFormatContent: false,
        htmlFormatContentTitle: false,
      );

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
