import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';

/// Conversation Row item sliced 1:1 from pen.dev "Content Area" (`snaps-design.pen` node `b0J5Ze`)
///
/// Features:
/// - Sleek 54px content height with comfortable touch target (height: 58.0)
/// - 42x42 Avatar block with optional cyan/green gradient Story Outline (`#00C770` to `#00A6FA`)
/// - 7x7 Online indicator dot (`#34C759` with 1.5px white border)
/// - SF Pro / Inter typography: Title 16.0px (500/600), letter-spacing -0.43, ink black `#000000`
/// - Secondary subtitle: 13.0px, `#3C3C4399` (`Color(0x993C3C43)`), letter-spacing -0.08
/// - Verified badge in Azure Blue `#008BFF`
/// - Trailing timestamp (13.0px) and Azure Blue pill unread badge (`#008BFF`)
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

    final hasStory = conversation.user.isVerified || conversation.user.isOnline;

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
          height: 58.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===============================================================
              // 1. AVATAR BLOCK (42x42) with optional Story Outline & Status Dot
              // ===============================================================
              SizedBox(
                width: 42.0,
                height: 42.0,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Story Outline (Gradient #00c770 to #00a6fa, 40x40)
                    if (hasStory)
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF00C770), // pen.dev #00c770ff
                              Color(0xFF00A6FA), // pen.dev #00a6faff
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 37.0,
                            height: 37.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    // Avatar Image (34x34 with story ring, or 38x38 standard)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(hasStory ? 17.0 : 19.0),
                      child: Container(
                        width: hasStory ? 34.0 : 38.0,
                        height: hasStory ? 34.0 : 38.0,
                        color: const Color(0xFFF1F5F9),
                        child: Image.network(
                          conversation.user.avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            color: AppColors.muted,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),

                    // Online Status Indicator Dot (7x7 with 1.5px white border)
                    if (conversation.user.isOnline)
                      Positioned(
                        right: 1.0,
                        bottom: 1.0,
                        child: Container(
                          width: 8.5,
                          height: 8.5,
                          decoration: BoxDecoration(
                            color: onlineGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12.0),

              // ===============================================================
              // 2. CONTENTS: Title + Badges and Subtitle (pen.dev Title and Detail)
              // ===============================================================
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Title (Name) + Badges (Verified/Class)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            conversation.user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.0,
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
                            size: 13.5,
                            color: azurePrimary, // pen.dev #008BFF
                          ),
                        ],
                        if (conversation.user.classGroup != null) ...[
                          const SizedBox(width: 5.0),
                          Text(
                            conversation.user.classGroup!,
                            style: const TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 2.0),

                    // Row 2: Subtitle (Sent checks + Last Message Preview)
                    Row(
                      children: [
                        if (conversation.isSender) ...[
                          Icon(
                            Icons.done_all_rounded,
                            size: 13.5,
                            color: hasUnread ? const Color(0xFF94A3B8) : azurePrimary,
                          ),
                          const SizedBox(width: 3.5),
                        ],
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                              color: hasUnread ? const Color(0xFF1E293B) : secondaryInk,
                              letterSpacing: -0.08,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10.0),

              // ===============================================================
              // 3. TRAILING ACCESSORIES: Timestamp and Unread Pill Badge
              // ===============================================================
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Timestamp
                  Text(
                    conversation.timestamp,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                      color: hasUnread ? azurePrimary : secondaryInk,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 3.0),

                  // Unread Count Capsule Badge (pen.dev Azure #008BFF)
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                      constraints: const BoxConstraints(
                        minWidth: 18.0,
                        minHeight: 18.0,
                      ),
                      decoration: BoxDecoration(
                        color: azurePrimary,
                        borderRadius: BorderRadius.circular(9.0),
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
                    )
                  else
                    const SizedBox(height: 18.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
