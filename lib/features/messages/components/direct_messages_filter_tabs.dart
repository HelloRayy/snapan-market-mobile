import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';

/// Horizontal carousel filter chips ("Obrolan", "Pembeli", "Belum Dibaca") for Direct Messages.
class DirectMessagesFilterTabs extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onSelectFilter;

  const DirectMessagesFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onSelectFilter,
  });

  @override
  Widget build(BuildContext context) {
    final allConversations = DirectMessagesService.instance.conversations;
    final buyerUnreadCount = allConversations
        .where((c) => c.isRequest == true && c.unreadCount > 0)
        .fold<int>(0, (acc, c) => acc + c.unreadCount);

    final totalUnreadCount = allConversations
        .where((c) => c.unreadCount > 0)
        .fold<int>(0, (acc, c) => acc + c.unreadCount);

    final tabs = [
      (key: 'inbox', label: 'Obrolan', count: null),
      (key: 'requests', label: 'Pembeli', count: buyerUnreadCount > 0 ? buyerUnreadCount : null),
      (key: 'unread', label: 'Belum Dibaca', count: totalUnreadCount > 0 ? totalUnreadCount : null),
    ];

    return SizedBox(
      height: 40.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isActive = activeFilter == tab.key;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelectFilter(tab.key);
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 36.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFF1F5F9) : Colors.transparent,
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(
                  color: isActive ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14.0,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (tab.count != null && tab.count! > 0) ...[
                    const SizedBox(width: 6.0),
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 18.0,
                        minHeight: 18.0,
                      ),
                      height: 18.0,
                      padding: tab.count! > 9 ? const EdgeInsets.symmetric(horizontal: 4.0) : EdgeInsets.zero,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF008BFF),
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: Text(
                        tab.count! > 99 ? '99+' : tab.count.toString(),
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
