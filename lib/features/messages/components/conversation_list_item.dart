import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';

/// Conversation Row item sliced 1:1 from pen.dev redesigned Row (`snaps-design.pen` node `bzgQS`)
///
/// Features:
/// - Exact 78px height (`height: 78.0`, padding: `[0, 16, 0, 10]`)
/// - Large 62x62 circular avatar (`borderRadius: 31.0`)
/// - 10x10 Online status indicator dot (`#34C759` with 2px white border at bottom-right)
/// - Middle content: Title (SF Pro 17px, font 500, `#000000`, letter-spacing -0.43) + Verified badge
/// - Message snippet: SF Pro 15px, `#3C3C4399` (`Color(0x993C3C43)`), letter-spacing -0.23, line-height 1.33
/// - Read status checkmark (✓✓) in `#008BFF`
/// - Trailing: Timestamp 14px at top right + Unread pill badge (20x20, fill `#008BFF`) at bottom right
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
    const secondaryInk = Color(0x993C3C43); // pen.dev #3c3c4399
    const azurePrimary = Color(0xFF008BFF); // pen.dev Accent #008BFF
    const onlineGreen = Color(0xFF34C759); // pen.dev #34c759ff
    const titleBlack = Color(0xFF000000); // pen.dev #000000ff

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        highlightColor: const Color(0xFFF2F4F7),
        splashColor: const Color(0xFFF2F4F7),
        child: Container(
          height: 78.0, // pen.dev bzgQS height: 78
          padding: const EdgeInsets.only(left: 10.0, right: 16.0), // pen.dev padding [0, 16, 0, 10]
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===============================================================
              // 1. AVATAR BLOCK (62x62) with Status Indicator Dot from bzgQS
              // ===============================================================
              Padding(
                padding: const EdgeInsets.only(right: 10.0), // pen.dev right: 10
                child: SizedBox(
                  width: 62.0,
                  height: 62.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Full 62x62 Circular Avatar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(31.0),
                        child: Container(
                          width: 62.0,
                          height: 62.0,
                          color: const Color(0xFFF1F5F9),
                          child: Image.network(
                            conversation.user.avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              color: AppColors.muted,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ),

                      // Status Dot (10x10 with 2px white border at x:48, y:48)
                      if (conversation.user.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              color: onlineGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ===============================================================
              // 2. CONTENTS: Title and Message (pen.dev F4iD9 height: 63)
              // ===============================================================
              Expanded(
                child: SizedBox(
                  height: 63.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Title (Name) + Badges (Verified / Class)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              conversation.user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17.0, // pen.dev aCEHd fontSize: 17
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                                color: titleBlack,
                                letterSpacing: -0.43,
                                height: 1.25,
                              ),
                            ),
                          ),
                          if (conversation.user.isVerified) ...[
                            const SizedBox(width: 4.0),
                            const Icon(
                              Icons.verified_rounded,
                              size: 14.0,
                              color: azurePrimary, // pen.dev CETdZ #008BFF
                            ),
                          ],
                          if (conversation.user.classGroup != null) ...[
                            const SizedBox(width: 5.0),
                            Text(
                              conversation.user.classGroup!,
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 3.0),

                      // Row 2: Message preview (pen.dev X5fgq fontSize: 15)
                      Row(
                        children: [
                          if (conversation.isSender) ...[
                            Icon(
                              Icons.done_all_rounded,
                              size: 15.0,
                              color: hasUnread ? const Color(0xFF94A3B8) : azurePrimary,
                            ),
                            const SizedBox(width: 4.0),
                          ],
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.0, // pen.dev X5fgq fontSize: 15
                                fontWeight: FontWeight.normal,
                                color: hasUnread ? const Color(0xFF1E293B) : secondaryInk,
                                letterSpacing: -0.23,
                                height: 1.33,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8.0),

              // ===============================================================
              // 3. TRAILING ACCESSORIES: Time & Unread Badge (pen.dev w7q4Fm)
              // ===============================================================
              SizedBox(
                height: 63.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Timestamp (pen.dev l9ChP7 fontSize: 14)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        conversation.timestamp,
                        style: TextStyle(
                          fontSize: 14.0, // pen.dev fontSize: 14
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          color: hasUnread ? azurePrimary : secondaryInk,
                          letterSpacing: -0.23,
                        ),
                      ),
                    ),

                    // Unread Pill Badge (pen.dev NHY1Z minWidth: 20, height: 20)
                    if (hasUnread)
                      Container(
                        margin: const EdgeInsets.only(bottom: 2.0),
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        constraints: const BoxConstraints(
                          minWidth: 20.0,
                          minHeight: 20.0,
                        ),
                        decoration: BoxDecoration(
                          color: azurePrimary,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${conversation.unreadCount}',
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
