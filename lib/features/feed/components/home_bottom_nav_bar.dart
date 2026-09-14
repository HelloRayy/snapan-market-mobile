import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:snapan_market/features/feed/components/nav_glyphs/home_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/paper_plane_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/heart_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/user_nav_glyph.dart';

/// Enum representing the 5 primary navigation tabs (100% parity with Web MarketBottomNav)
enum HomeNavTab {
  home,
  messages,
  create,
  activity,
  profile;

  static const HomeNavTab post = HomeNavTab.create;

  String get label {
    switch (this) {
      case HomeNavTab.home:
        return 'Home';
      case HomeNavTab.messages:
        return 'Pesan';
      case HomeNavTab.create:
        return 'Jual';
      case HomeNavTab.activity:
        return 'Aktivitas';
      case HomeNavTab.profile:
        return 'Profil';
    }
  }
}

/// Sliced 1:1 with Web React MarketBottomNav.tsx
///
/// Features:
/// - 50px height edge-to-edge bar with safe-area bottom inset
/// - Frosted glass white container (`bg-white/95 backdrop-blur-md border-t border-neutral-200/80`)
/// - 5-column grid layout (Home, Pesan, Center FAB, Aktivitas, Profil)
/// - Center elevated Kumo Floating Action Button (48x48, -top-5, gradient, 3.5px white ring, shadow)
/// - Subtle active indicator pill (`bg-neutral-100/90 rounded-xl`)
/// - Red dot unread badge for Messages and Activity
class HomeBottomNavBar extends StatelessWidget {
  final HomeNavTab currentTab;
  final ValueChanged<HomeNavTab> onTabSelected;
  final VoidCallback? onPostTap;
  final VoidCallback? onCreateTap;
  final bool hasUnreadMessages;
  final int unreadMessagesCount;
  final bool hasUnreadActivity;
  final String? userAvatar;

  const HomeBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.onPostTap,
    this.onCreateTap,
    this.hasUnreadMessages = false,
    this.unreadMessagesCount = 0,
    this.hasUnreadActivity = false,
    this.userAvatar,
  });

  VoidCallback? get _actionCallback => onPostTap ?? onCreateTap;

  @override
  Widget build(BuildContext context) {
    // Auto-detect virtual keyboard to prevent bottom nav from floating over inputs
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    if (bottomInset > 0) {
      return const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final totalHeight = 50.0 + bottomPadding;

    return RepaintBoundary(
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Frosted Glass White Background Bar (50px + safe area)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFE2E8F0).withValues(alpha: 0.80),
                          width: 1.0,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12.0,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 5-Column Navigation Row Items
            Positioned.fill(
              child: SafeArea(
                top: false,
                bottom: true,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448.0),
                    child: SizedBox(
                      height: 50.0,
                      child: Row(
                        children: [
                          // 1. Home
                          Expanded(
                            child: _BottomNavItem(
                              isActive: currentTab == HomeNavTab.home,
                              label: 'Home',
                              onTap: () => onTabSelected(HomeNavTab.home),
                              glyph: HomeNavGlyph(
                                isActive: currentTab == HomeNavTab.home,
                              ),
                            ),
                          ),

                          // 2. Pesan
                          Expanded(
                            child: _BottomNavItem(
                              isActive: currentTab == HomeNavTab.messages,
                              label: 'Pesan',
                              onTap: () => onTabSelected(HomeNavTab.messages),
                              glyph: PaperPlaneNavGlyph(
                                isActive: currentTab == HomeNavTab.messages,
                                hasBadge: hasUnreadMessages,
                                badgeCount: unreadMessagesCount,
                              ),
                            ),
                          ),

                          // 3. Center Elevated Floating Action Button (Jual / +)
                          Expanded(
                            child: Center(
                              child: Transform.translate(
                                offset: const Offset(0, -14.0),
                                child: _CenterActionFab(
                                  onTap: () {
                                    if (_actionCallback != null) {
                                      _actionCallback!();
                                    } else {
                                      onTabSelected(HomeNavTab.create);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),

                          // 4. Aktivitas
                          Expanded(
                            child: _BottomNavItem(
                              isActive: currentTab == HomeNavTab.activity,
                              label: 'Aktivitas',
                              onTap: () => onTabSelected(HomeNavTab.activity),
                              glyph: HeartNavGlyph(
                                isActive: currentTab == HomeNavTab.activity,
                                hasBadge: hasUnreadActivity,
                              ),
                            ),
                          ),

                          // 5. Profil
                          Expanded(
                            child: _BottomNavItem(
                              isActive: currentTab == HomeNavTab.profile,
                              label: 'Profil',
                              onTap: () => onTabSelected(HomeNavTab.profile),
                              glyph: UserNavGlyph(
                                isActive: currentTab == HomeNavTab.profile,
                                userAvatar: userAvatar,
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
          ],
        ),
      ),
    );
  }
}

/// Standard Nav Item matching Web MarketBottomNav tab
class _BottomNavItem extends StatefulWidget {
  final bool isActive;
  final String label;
  final VoidCallback onTap;
  final Widget glyph;

  const _BottomNavItem({
    required this.isActive,
    required this.label,
    required this.onTap,
    required this.glyph,
  });

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      selected: widget.isActive,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.selectionClick();
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 75),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            height: 50.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle active indicator pill matching Threads h-[42px]
                if (widget.isActive)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),

                // Icon / Glyph
                Center(child: widget.glyph),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Center Elevated Floating Action Button (Jual / +)
/// Matches Web React:
/// - 48x48 rounded-full
/// - Kumo Indigo/Blue gradient [#3b82f6 -> #1d64ec]
/// - 3.5px white ring
/// - Soft blue elevation shadow
/// - Plus icon with smooth tap physics
class _CenterActionFab extends StatefulWidget {
  final VoidCallback onTap;

  const _CenterActionFab({required this.onTap});

  @override
  State<_CenterActionFab> createState() => _CenterActionFabState();
}

class _CenterActionFabState extends State<_CenterActionFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Jual Produk Baru',
      button: true,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.mediumImpact();
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 75),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Soft blue bloom shadow
                BoxShadow(
                  color: const Color(0xFF1D64EC).withValues(alpha: 0.35),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // 3.5px Crisp White Outer Ring
                border: Border.all(
                  color: Colors.white,
                  width: 3.5,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3B82F6), // Sky/Royal Blue
                    Color(0xFF1D64EC), // Electric Kumo Blue
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top Inset Rim Shine Highlight
                  Positioned(
                    top: 2.0,
                    left: 8.0,
                    right: 8.0,
                    height: 1.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),

                  // Plus Icon
                  const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
