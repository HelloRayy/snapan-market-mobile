import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/custom_nav_tab_item.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/floating_kumo_fab.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/heart_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/home_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/paper_plane_nav_glyph.dart';
import 'package:snapan_market/features/feed/components/nav_glyphs/user_nav_glyph.dart';

/// Enum representing the 5 navigation tabs
enum HomeNavTab {
  home,
  messages,
  create,
  activity,
  profile;

  String get label {
    switch (this) {
      case HomeNavTab.home:
        return 'Home';
      case HomeNavTab.messages:
        return 'Pesan';
      case HomeNavTab.create:
        return 'Buat Postingan';
      case HomeNavTab.activity:
        return 'Aktivitas';
      case HomeNavTab.profile:
        return 'Profil';
    }
  }
}

/// Home Feed Bottom Navigation Bar (50px Frosted Glass Minimalist Bar)
class HomeBottomNavBar extends StatelessWidget {
  final HomeNavTab currentTab;
  final ValueChanged<HomeNavTab> onTabSelected;
  final VoidCallback? onCreateTap;
  final bool hasUnreadMessages;
  final int unreadMessagesCount;
  final bool hasUnreadActivity;
  final String? userAvatar;
  final bool showBlur;

  const HomeBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.onCreateTap,
    this.hasUnreadMessages = false,
    this.unreadMessagesCount = 1,
    this.hasUnreadActivity = false,
    this.userAvatar,
    this.showBlur = true,
  });

  @override
  Widget build(BuildContext context) {
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
            // Frosted Glass Background
            Positioned.fill(
              child: ClipRect(
                child: showBlur
                    ? BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            border: const Border(
                              top: BorderSide(
                                color: Color(0xFFF1F5F9),
                                width: 0.8,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFFF1F5F9),
                              width: 0.8,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            // Navigation Row Items
            Positioned.fill(
              child: SafeArea(
                top: false,
                bottom: true,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430.0),
                    child: SizedBox(
                      height: 50.0,
                      child: Row(
                        children: [
                          // Tab 1: Home
                          Expanded(
                            child: CustomNavTabItem(
                              tooltip: 'Home',
                              isActive: currentTab == HomeNavTab.home,
                              onTap: () => onTabSelected(HomeNavTab.home),
                              child: HomeNavGlyph(
                                isActive: currentTab == HomeNavTab.home,
                              ),
                            ),
                          ),

                          // Tab 2: Pesan
                          Expanded(
                            child: CustomNavTabItem(
                              tooltip: 'Pesan',
                              isActive: currentTab == HomeNavTab.messages,
                              onTap: () => onTabSelected(HomeNavTab.messages),
                              child: PaperPlaneNavGlyph(
                                isActive: currentTab == HomeNavTab.messages,
                                hasBadge: hasUnreadMessages,
                                badgeCount: unreadMessagesCount,
                              ),
                            ),
                          ),

                          // Tab 3: Center Floating Kumo Action Button (+) Elevated above Navbar
                          Expanded(
                            child: Center(
                              child: Transform.translate(
                                offset: const Offset(0, -10.0),
                                child: FloatingKumoFabButton(
                                  onTap: () {
                                    if (onCreateTap != null) {
                                      onCreateTap!();
                                    } else {
                                      onTabSelected(HomeNavTab.create);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Tab 4: Aktivitas
                          Expanded(
                            child: CustomNavTabItem(
                              tooltip: 'Aktivitas',
                              isActive: currentTab == HomeNavTab.activity,
                              onTap: () => onTabSelected(HomeNavTab.activity),
                              child: HeartNavGlyph(
                                isActive: currentTab == HomeNavTab.activity,
                                hasBadge: hasUnreadActivity,
                              ),
                            ),
                          ),

                          // Tab 5: Profil
                          Expanded(
                            child: CustomNavTabItem(
                              tooltip: 'Profil',
                              isActive: currentTab == HomeNavTab.profile,
                              onTap: () => onTabSelected(HomeNavTab.profile),
                              child: UserNavGlyph(
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
