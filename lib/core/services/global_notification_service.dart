import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/navigation/navigation_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Global In-App Floating Notification Banner Service
/// Listens to incoming realtime notifications and displays a premium iOS/Dynamic Island style
/// top banner with haptic feedback anywhere across the app.
class GlobalNotificationService {
  GlobalNotificationService._();
  static final GlobalNotificationService instance = GlobalNotificationService._();

  dynamic _realtimeChannel;
  final ValueNotifier<bool> hasUnreadActivity = ValueNotifier<bool>(false);
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  OverlayEntry? _currentBannerEntry;
  Timer? _dismissTimer;

  /// Initialize global realtime notification listener
  void init() {
    _fetchInitialUnreadStatus();
    _subscribeRealtime();
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

        // Show floating in-app banner
        final title = record['title']?.toString() ?? 'Pengumuman Baru';
        final message = record['message']?.toString() ?? '';
        final type = record['type']?.toString() ?? 'system';

        showTopBanner(title: title, message: message, type: type);
      });
    } catch (e) {
      debugPrint('Error subscribing to global notifications: $e');
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
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
