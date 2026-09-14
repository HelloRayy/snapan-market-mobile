import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/home_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/paper_plane_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/heart_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/user_nav_glyph.dart';

/// Enum representing the 4 main navigation tabs in the Center Bot Bar
enum HomeNavTab {
  home,
  messages,
  activity,
  profile;

  // Backward-compatible aliases
  static const HomeNavTab create = HomeNavTab.home;
  static const HomeNavTab post = HomeNavTab.home;

  String get label {
    switch (this) {
      case HomeNavTab.home:
        return 'Home';
      case HomeNavTab.messages:
        return 'Pesan';
      case HomeNavTab.activity:
        return 'Aktivitas';
      case HomeNavTab.profile:
        return 'Profil';
    }
  }
}

/// Center Bot Bar sliced from user layout sketch & pen.dev spec (`snaps-design.pen` node `HaFs1`)
///
/// Features:
/// - Single centered floating pill dock (`height: 62px, cornerRadius: 296`)
/// - Liquid frosted glass container (`Colors.white.withValues(alpha: 0.85)` + 20px blur)
/// - Diffuse 35px drop shadow from pen.dev (`#0000001f`, y=8)
/// - 4 symmetrical tabs (Home, Pesan, Aktivitas, Profil)
/// - Active selection capsule (`#EDEDED` fill, cornerRadius 100) with `#008BFF` azure icon & label
/// - Inactive tabs in `#1A1A1A` ink typography
class HomeBottomNavBar extends StatelessWidget {
  final HomeNavTab currentTab;
  final ValueChanged<HomeNavTab> onTabSelected;
  final VoidCallback? onSearchTap;
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
    this.onSearchTap,
    this.onPostTap,
    this.onCreateTap,
    this.hasUnreadMessages = false,
    this.unreadMessagesCount = 0,
    this.hasUnreadActivity = false,
    this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-detect virtual keyboard to prevent bottom nav from floating over inputs
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    if (bottomInset > 0) {
      return const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: bottomPadding > 0 ? bottomPadding + 8.0 : 18.0,
      ),
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360.0),
          child: Container(
            height: 62.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(31.0),
              boxShadow: const [
                // Diffuse Outer Shadow from pen.dev (#0000001f, y=8, blur=35)
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 35.0,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(31.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                child: Container(
                  height: 62.0,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(31.0),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.70),
                        Colors.white.withValues(alpha: 0.42),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tab 1: Home
                      _DockTabItem(
                        isActive: currentTab == HomeNavTab.home,
                        label: 'Home',
                        glyph: HomeNavGlyph(
                          isActive: currentTab == HomeNavTab.home,
                        ),
                        onTap: () => onTabSelected(HomeNavTab.home),
                      ),

                      // Tab 2: Pesan (Chats)
                      _DockTabItem(
                        isActive: currentTab == HomeNavTab.messages,
                        label: 'Pesan',
                        glyph: PaperPlaneNavGlyph(
                          isActive: currentTab == HomeNavTab.messages,
                          hasBadge: hasUnreadMessages,
                          badgeCount: unreadMessagesCount,
                        ),
                        onTap: () => onTabSelected(HomeNavTab.messages),
                      ),

                      // Tab 3: Aktivitas
                      _DockTabItem(
                        isActive: currentTab == HomeNavTab.activity,
                        label: 'Aktivitas',
                        glyph: HeartNavGlyph(
                          isActive: currentTab == HomeNavTab.activity,
                          hasBadge: hasUnreadActivity,
                        ),
                        onTap: () => onTabSelected(HomeNavTab.activity),
                      ),

                      // Tab 4: Profil
                      _DockTabItem(
                        isActive: currentTab == HomeNavTab.profile,
                        label: 'Profil',
                        glyph: UserNavGlyph(
                          isActive: currentTab == HomeNavTab.profile,
                          userAvatar: userAvatar,
                        ),
                        onTap: () => onTabSelected(HomeNavTab.profile),
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

/// Dock Tab Item with Selection Capsule (#EDEDED fill, cornerRadius 100)
class _DockTabItem extends StatefulWidget {
  final bool isActive;
  final String label;
  final Widget glyph;
  final VoidCallback onTap;

  const _DockTabItem({
    required this.isActive,
    required this.label,
    required this.glyph,
    required this.onTap,
  });

  @override
  State<_DockTabItem> createState() => _DockTabItemState();
}

class _DockTabItemState extends State<_DockTabItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF008BFF); // pen.dev #008BFF
    const inactiveColor = Color(0xFF1A1A1A); // pen.dev #1A1A1A
    const selectionFill = Color(0xFFEDEDED); // pen.dev Selection fill: #edededff

    return Expanded(
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
          scale: _isPressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 56.0,
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            decoration: BoxDecoration(
              // Translucent frosted glass capsule with subtle specular highlight rim
              color: widget.isActive
                  ? const Color(0xFFEDEDED).withValues(alpha: 0.72)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(28.0),
              border: widget.isActive
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.75),
                      width: 0.8,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon / Glyph
                SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: Center(child: widget.glyph),
                ),

                const SizedBox(height: 1.0),

                // Label Text (active #008BFF 700, inactive #1A1A1A 500)
                Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isActive ? activeColor : inactiveColor,
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
