import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';

/// Item baris percakapan 1:1 matching DirectMessagesPage.tsx:240-337
class ConversationListItem extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 76.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Kolom Avatar 50x50 dengan Indikator Online Hijau
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: Image.network(
                      conversation.user.avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.muted,
                        size: 26.0,
                      ),
                    ),
                  ),
                ),

                // Titik Online Hijau di Sudut Kanan Atas
                if (conversation.user.isOnline)
                  Positioned(
                    top: -1.0,
                    right: -1.0,
                    child: Container(
                      width: 13.5,
                      height: 13.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF31A24C),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14.0),

            // 2. Konten Teks (2 Baris Seimbang)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BARIS 1: Nama Pengguna + Badge Verified di Kiri vs Timestamp di Kanan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                conversation.user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                  color: hasUnread ? AppColors.ink : const Color(0xFF1E293B),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (conversation.user.isVerified) ...[
                              const SizedBox(width: 4.0),
                              const Icon(
                                Icons.verified_rounded,
                                size: 14.5,
                                color: Color(0xFF1D64EC),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 8.0),

                      // Timestamp
                      Text(
                        conversation.timestamp,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          color: hasUnread ? AppColors.primary : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3.5),

                  // BARIS 2: Status Terkirim (✓✓) + Cuplikan Pesan di Kiri vs Unread Badge di Kanan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (conversation.isSender) ...[
                              const Icon(
                                Icons.done_all_rounded,
                                size: 14.0,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4.0),
                            ],
                            Expanded(
                              child: Text(
                                conversation.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                                  color: hasUnread ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (hasUnread) ...[
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          constraints: const BoxConstraints(
                            minWidth: 20.0,
                            minHeight: 20.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
