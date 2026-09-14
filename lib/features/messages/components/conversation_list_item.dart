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
          height: 74.0, // pen.dev chaat-1 row height
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===============================================================
              // 1. AVATAR BLOCK with Story Outline Gradient from pen.dev chaat-1
              // ===============================================================
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 52.0,
                  height: 52.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Story Outline Gradient Ring (pen.dev chaat-1: #00C770 -> #00A6FA)
                      if (conversation.user.isOnline)
                        Container(
                          width: 52.0,
                          height: 52.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color(0xFF00C770), // pen.dev #00c770
                                Color(0xFF00A6FA), // pen.dev #00a6fa
                              ],
                            ),
                          ),
                        ),

                      // Inner Gap + Circular Avatar
                      Container(
                        width: conversation.user.isOnline ? 47.0 : 50.0,
                        height: conversation.user.isOnline ? 47.0 : 50.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(conversation.user.isOnline ? 1.5 : 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: Container(
                            color: const Color(0xFFF1F5F9),
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
                      ),
                    ],
                  ),
                ),
              ),

              // ===============================================================
              // 2. CONTENTS: Title and Message (pen.dev chaat-1 ihCZC)
              // ===============================================================
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Title (Name) + Badges (Verified only, NO school badge)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            conversation.user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17.0, // pen.dev chaat-1 UCIvl: SF Pro 17px
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
                            color: azurePrimary, // pen.dev syXho #008BFF
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 3.0),

                    // Row 2: Message preview (pen.dev chaat-1 azG1g: SF Pro 15px, #3C3C4399)
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
                            style: const TextStyle(
                              fontSize: 15.0, // pen.dev chaat-1 azG1g: 15px
                              fontWeight: FontWeight.normal,
                              color: secondaryInk, // pen.dev #3C3C4399
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

              const SizedBox(width: 8.0),

              // ===============================================================
              // 3. TRAILING ACCESSORIES: Time & Unread Badge (pen.dev chaat-1 GOi2J)
              // ===============================================================
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Timestamp (pen.dev chaat-1 mkRZg: SF Pro 14px, #3C3C4399)
                  Text(
                    conversation.timestamp,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                      color: hasUnread ? azurePrimary : secondaryInk,
                      letterSpacing: -0.23,
                    ),
                  ),

                  const SizedBox(height: 4.0),

                  // Unread Pill Badge (pen.dev chaat-1 c7IxLV: fill #008BFF)
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
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
            ],
          ),
        ),
      ),
    );
  }
}
