import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:snapan_market/features/feed/components/nav_glyphs/home_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/paper_plane_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/heart_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/user_nav_glyph.dart';

/// Enum representing the 5 primary navigation tabs
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

/// Home Feed Bottom Navigation Bar
///
/// Styling Specification:
/// - White Edge-to-Edge Bar (`bg-white/96 backdrop-blur-md border-t border-neutral-200/80`)
/// - Active Capsule Highlight: soft rounded pill background on active tab
/// - Cyan Badge Counter on Messages (matching reference image)
/// - Bottom Text Labels under every icon (Home, Pesan, Jual, Aktivitas, Profil)
/// - Center Elevated Kumo Floating Action Button (Jual / +)
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
    const barHeight = 58.0;
    final totalHeight = barHeight + bottomPadding;

    return RepaintBoundary(
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Frosted Glass White Background Bar
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFE2E8F0).withValues(alpha: 0.85),
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

            // 5-Column Navigation Items Row
            Positioned.fill(
              child: SafeArea(
                top: false,
                bottom: true,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448.0),
                    child: SizedBox(
                      height: barHeight,
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

                          // 3. Center Elevated Action Button (Jual / +)
                          Expanded(
                            child: _CenterActionFabItem(
                              label: 'Jual',
                              onTap: () {
                                if (_actionCallback != null) {
                                  _actionCallback!();
                                } else {
                                  onTabSelected(HomeNavTab.create);
                                }
                              },
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

/// Standard Nav Item with Active Capsule Highlight and Text Label
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
    const activeColor = Color(0xFF008BFF); // pen.dev Primary Azure (#008BFF)
    const inactiveColor = Color(0xFF1A1A1A); // pen.dev Ink Base (#1A1A1A)

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
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 75),
          curve: Curves.easeOutCubic,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
              decoration: BoxDecoration(
                // Active Capsule Highlight from pen.dev (#EDEDED fill, cornerRadius 100)
                color: widget.isActive ? const Color(0xFFEDEDED) : Colors.transparent,
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon / Glyph
                  SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: Center(child: widget.glyph),
                  ),

                  const SizedBox(height: 2.0),

                  // Text Label
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                      color: widget.isActive ? activeColor : inactiveColor,
                      letterSpacing: -0.2,
                      height: 1.1,
                    ),
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

/// Center Action Button with Floating Elevated FAB and "Jual" Label
class _CenterActionFabItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _CenterActionFabItem({
    required this.label,
    required this.onTap,
  });

  @override
  State<_CenterActionFabItem> createState() => _CenterActionFabItemState();
}

class _CenterActionFabItemState extends State<_CenterActionFabItem> {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Floating Elevated Circular Button
              Transform.translate(
                offset: const Offset(0, -10.0),
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Diffuse drop shadow from pen.dev (#0000001f, y: 8, blur: 35) + Azure glow
                      const BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 25.0,
                        offset: Offset(0, 6),
                      ),
                      BoxShadow(
                        color: const Color(0xFF008BFF).withValues(alpha: 0.40),
                        blurRadius: 12.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Crisp White Outer Ring
                      border: Border.all(
                        color: Colors.white,
                        width: 3.0,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF269DFF), // Light Azure Specular
                          Color(0xFF008BFF), // pen.dev Primary Accent
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Top Inset Rim Shine Highlight
                        Positioned(
                          top: 2.0,
                          left: 6.0,
                          right: 6.0,
                          height: 1.2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.45),
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

              Transform.translate(
                offset: const Offset(0, -6.0),
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF008BFF),
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
