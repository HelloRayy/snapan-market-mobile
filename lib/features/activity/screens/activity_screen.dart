import "package:flutter/material.dart";
import "package:snapan_market/core/components/snaps_skeleton.dart";
import "package:snapan_market/core/navigation/app_slide_page_route.dart";
import "package:snapan_market/core/services/global_notification_service.dart";
import "package:snapan_market/core/services/supabase_service.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/features/activity/components/activity_empty_state.dart";
import "package:snapan_market/features/activity/components/activity_header_bar.dart";
import "package:snapan_market/features/activity/components/activity_item_tile.dart";
import "package:snapan_market/features/activity/components/broadcast_detail_modal.dart";
import "package:snapan_market/features/activity/models/activity_list_item.dart";
import "package:snapan_market/features/activity/models/activity_notification_model.dart";
import "package:snapan_market/features/feed/screens/post_detail_screen.dart";

/// Screen orchestrator for the Activity & Notifications module.
/// Manages live data subscriptions, category filtering, and timeline grouping.
class ActivityScreen extends StatefulWidget {
  final bool showAppBar;
  const ActivityScreen({super.key, this.showAppBar = true});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _activeTabIndex = 0; // 0: Semua, 1: Pengumuman, 2: Interaksi, 3: Pesanan COD
  late List<ActivityNotification> _notifications;
  bool _isLoading = true;
  dynamic _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _notifications = [];
    _loadLiveNotifications();
    _setupRealtimeNotifications();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtimeNotifications() {
    try {
      _realtimeChannel = SupabaseService.instance.subscribeToNotifications((newRecord) {
        if (!mounted) return;
        final newNotif = ActivityNotification.fromJson(newRecord);
        setState(() {
          _notifications.removeWhere((n) => n.id == newNotif.id);
          _notifications.insert(0, newNotif);
        });
      });
    } catch (e) {
      debugPrint('Realtime notification sub error: $e');
    }
  }

  Future<void> _loadLiveNotifications() async {
    try {
      final data = await SupabaseService.instance.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = data.map((n) => ActivityNotification.fromJson(n)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error _loadLiveNotifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ActivityNotification> get _filteredNotifications {
    switch (_activeTabIndex) {
      case 1:
        return _notifications.where((n) => n.type == ActivityType.system).toList();
      case 2:
        return _notifications.where((n) =>
          n.type == ActivityType.like ||
          n.type == ActivityType.comment ||
          n.type == ActivityType.mention ||
          n.type == ActivityType.follow
        ).toList();
      case 3:
        return _notifications.where((n) => n.type == ActivityType.order).toList();
      default:
        return _notifications;
    }
  }

  List<ActivityListItem> get _flattenedItems {
    final list = <ActivityListItem>[];
    final items = _filteredNotifications;
    if (items.isEmpty) return list;

    final Map<ActivityTimelineGroup, List<ActivityNotification>> grouped = {};
    for (final notif in items) {
      grouped.putIfAbsent(notif.timelineGroup, () => []).add(notif);
    }

    for (final group in ActivityTimelineGroup.values) {
      final notifs = grouped[group];
      if (notifs != null && notifs.isNotEmpty) {
        list.add(ActivityHeaderItem(group.label));
        for (final notif in notifs) {
          list.add(ActivityTileItem(notif));
        }
      }
    }
    return list;
  }

  void _markSingleAsRead(ActivityNotification notif) {
    if (notif.isRead) return;
    setState(() {
      final i = _notifications.indexWhere((n) => n.id == notif.id);
      if (i != -1) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
    SupabaseService.instance.markSingleNotificationAsRead(notif.id);
  }

  Future<void> _navigateToPost(String postId) async {
    try {
      final post = await SupabaseService.instance.fetchPostById(postId);
      if (post != null && mounted) {
        Navigator.push(
          context,
          AppSlidePageRoute(
            builder: (_) => PostDetailScreen(post: post),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error navigating to post from activity: $e');
    }
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    SupabaseService.instance.markNotificationsAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Semua notifikasi ditandai sudah dibaca"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyContent = Column(
      children: [
        ActivityHeaderBar(
          showAppBar: widget.showAppBar,
          activeTabIndex: _activeTabIndex,
          onTabChanged: (index) => setState(() => _activeTabIndex = index),
          onMarkAllAsRead: _markAllAsRead,
        ),
        Expanded(
          child: _isLoading
              ? const SingleChildScrollView(
                  child: ActivityListSkeleton(itemCount: 6),
                )
              : RefreshIndicator(
                  onRefresh: _loadLiveNotifications,
                  color: AppColors.primary,
                  child: _filteredNotifications.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                            const ActivityEmptyState(),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 120.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _flattenedItems.length,
                          itemBuilder: (context, idx) {
                            final item = _flattenedItems[idx];
                            if (item is ActivityHeaderItem) {
                              return Container(
                                padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 6.0),
                                color: AppColors.adaptiveCanvas(context),
                                child: Text(
                                  item.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                                  ),
                                ),
                              );
                            } else if (item is ActivityTileItem) {
                              final notif = item.notification;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ActivityItemTile(
                                    notification: notif,
                                    onTap: () {
                                      _markSingleAsRead(notif);
                                      final isAnnouncement = notif.type == ActivityType.system ||
                                          notif.actorName.toLowerCase().startsWith('admin');
                                      if (isAnnouncement) {
                                        BroadcastDetailModal.show(context, notif);
                                      } else if (notif.postId != null && notif.postId!.isNotEmpty) {
                                        _navigateToPost(notif.postId!);
                                      }
                                    },
                                    onActionTap: () {
                                      _markSingleAsRead(notif);
                                      GlobalNotificationService.executeNotificationAction(context, notif);
                                    },
                                  ),
                                  Divider(
                                    color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
                                    height: 1.0,
                                    thickness: 0.5,
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                ),
        ),
      ],
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: AppColors.adaptiveCanvas(context),
        body: SafeArea(
          bottom: false,
          child: bodyContent,
        ),
      );
    }

    return Container(
      color: AppColors.adaptiveCanvas(context),
      child: bodyContent,
    );
  }
}
