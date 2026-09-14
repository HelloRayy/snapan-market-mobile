import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/features/activity/components/activity_item_tile.dart";
import "package:snapan_market/features/activity/models/activity_notification_model.dart";

class ActivityScreen extends StatefulWidget {
  final bool showAppBar;
  const ActivityScreen({super.key, this.showAppBar = true});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _activeTabIndex = 0; // 0: Semua, 1: Pesanan, 2: Interaksi
  late List<ActivityNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(kMockNotifications);
  }

  List<ActivityNotification> get _filteredNotifications {
    if (_activeTabIndex == 1) {
      return _notifications.where((n) => n.type == ActivityType.order).toList();
    } else if (_activeTabIndex == 2) {
      return _notifications.where((n) => n.type == ActivityType.like || n.type == ActivityType.comment).toList();
    }
    return _notifications;
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Semua notifikasi ditandai sudah dibaca"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 12.0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.8)),
          ),
          child: Column(
            children: [
              if (widget.showAppBar) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Aktivitas & Notifikasi",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    IconButton(
                      onPressed: _markAllAsRead,
                      icon: const Icon(Icons.done_all_rounded, size: 20.0, color: Color(0xFF64748B)),
                      tooltip: "Tandai semua dibaca",
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
              ],

                  // Category Chips
                  Row(
                    children: [
                      _FilterChip(
                        label: "Semua",
                        isActive: _activeTabIndex == 0,
                        onTap: () => setState(() => _activeTabIndex = 0),
                      ),
                      _FilterChip(
                        label: "Pesanan COD",
                        isActive: _activeTabIndex == 1,
                        onTap: () => setState(() => _activeTabIndex = 1),
                      ),
                      _FilterChip(
                        label: "Interaksi",
                        isActive: _activeTabIndex == 2,
                        onTap: () => setState(() => _activeTabIndex = 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Notification List
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64.0,
                            height: 64.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 28.0,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          const Text(
                            "Belum ada aktivitas baru",
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            "Notifikasi pesanan dan interaksi akan muncul di sini.",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 120.0),
                      itemCount: _filteredNotifications.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: Color(0xFFF1F5F9),
                        height: 1.0,
                        thickness: 0.5,
                      ),
                      itemBuilder: (_, idx) {
                        final notif = _filteredNotifications[idx];
                        return ActivityItemTile(
                          notification: notif,
                          onTap: () {
                            setState(() {
                              final i = _notifications.indexWhere((n) => n.id == notif.id);
                              if (i != -1) {
                                _notifications[i] = _notifications[i].copyWith(isRead: true);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: bodyContent,
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: bodyContent,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isActive ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : const Color(0xFF475569),
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
