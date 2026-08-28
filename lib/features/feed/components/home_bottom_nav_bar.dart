import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Enum representing the 5 navigation tabs matching Snapan Market Kumo design
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
/// Compact In-Bar Composition with authentic Kumo UI visual styling:
/// - In-Bar Flush Layout: 50px fixed bar height with zero broken overflow lines
/// - Compact Center Grouping: 24px wide horizontal edge margin to cluster icons at center
/// - Balanced Visual Weight: 5 items evenly distributed with uniform vertical alignment
/// - Kumo UI Identity:
///   1. Home (Kumo active pill 42x72px #F1F5F9, 26px ink icon)
///   2. Pesan (26px Send icon with 8px #FF3040 red dot notification badge & white ring)
///   3. Center Action (40x40px Kumo Primary Blue squircle/pill, #3B82F6 -> #1D64EC gradient, #154EC1 border, white "+" icon)
///   4. Aktivitas (26px Heart icon with rose-500 #F43F5E active state)
///   5. Profil (26x26px circular avatar with subtle slate border)
/// - Touch target >= 44x44pt & tactile micro-tap scale (0.96)
class HomeBottomNavBar extends StatelessWidget {
  final HomeNavTab currentTab;
  final ValueChanged<HomeNavTab> onTabSelected;
  final VoidCallback? onCreateTap;
  final bool hasUnreadMessages;
  final bool hasUnreadActivity;
  final String? userAvatar;
  final bool showBlur;

  const HomeBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.onCreateTap,
    this.hasUnreadMessages = true,
    this.hasUnreadActivity = false,
    this.userAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
    this.showBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-detect virtual keyboard to prevent floating over keyboard
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (isKeyboardOpen) {
      return const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    // 1. Frosted Glass Background Bar Layer (Clean horizontal flush line)
    Widget frostedBar = Container(
      height: 50.0 + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9), // border-neutral-200/80
            width: 1.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000), // shadow-[0_-2px_12px_rgba(0,0,0,0.03)]
            blurRadius: 12.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
    );

    if (showBlur) {
      frostedBar = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: frostedBar,
        ),
      );
    }

    // 2. Navigation Items Layer (Constrained to exact 50px + bottomPadding height)
    return SizedBox(
      height: 50.0 + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Background Bar
          Positioned.fill(
            child: frostedBar,
          ),

          // 2. Foreground Nav Items Layer
          Positioned.fill(
            child: SafeArea(
              top: false,
              bottom: true,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350.0), // Apple HIG compact container
                  child: SizedBox(
                    height: 50.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tab 1: Home (Kumo Active Pill)
                        Expanded(
                          child: _NavTabItem(
                            tab: HomeNavTab.home,
                            isActive: currentTab == HomeNavTab.home,
                            icon: CupertinoIcons.house,
                            activeIcon: CupertinoIcons.house_fill,
                            tooltip: 'Home',
                            onTap: () => onTabSelected(HomeNavTab.home),
                          ),
                        ),

                        // Tab 2: Pesan (Send Icon with Red Dot Badge)
                        Expanded(
                          child: _NavTabItem(
                            tab: HomeNavTab.messages,
                            isActive: currentTab == HomeNavTab.messages,
                            icon: CupertinoIcons.paperplane,
                            activeIcon: CupertinoIcons.paperplane_fill,
                            hasBadge: hasUnreadMessages,
                            tooltip: 'Pesan',
                            onTap: () => onTabSelected(HomeNavTab.messages),
                          ),
                        ),

                        // Tab 3: Center Action (Floating Kumo FAB with High Z-Index)
                        Expanded(
                          child: Center(
                            child: _FloatingKumoFabButton(
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

                        // Tab 4: Aktivitas (Heart Icon)
                        Expanded(
                          child: _NavTabItem(
                            tab: HomeNavTab.activity,
                            isActive: currentTab == HomeNavTab.activity,
                            icon: CupertinoIcons.heart,
                            activeIcon: CupertinoIcons.heart_fill,
                            activeColor: const Color(0xFFF43F5E), // rose-500
                            hasBadge: hasUnreadActivity,
                            tooltip: 'Aktivitas',
                            onTap: () => onTabSelected(HomeNavTab.activity),
                          ),
                        ),

                        // Tab 5: Profil (User Avatar with Outline/Solid transition)
                        Expanded(
                          child: _NavTabItem(
                            tab: HomeNavTab.profile,
                            isActive: currentTab == HomeNavTab.profile,
                            icon: CupertinoIcons.person,
                            activeIcon: CupertinoIcons.person_fill,
                            userAvatar: userAvatar,
                            tooltip: 'Profil',
                            onTap: () => onTabSelected(HomeNavTab.profile),
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
    );
  }
}

/// Center Floating Action Button (56x56px Elevated Kumo Circle with 4px White Halo Ring & High Z-Index)
class _FloatingKumoFabButton extends StatefulWidget {
  final VoidCallback onTap;

  const _FloatingKumoFabButton({required this.onTap});

  @override
  State<_FloatingKumoFabButton> createState() => _FloatingKumoFabButtonState();
}

class _FloatingKumoFabButtonState extends State<_FloatingKumoFabButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      width: 56.0,
      child: OverflowBox(
        maxHeight: 110.0,
        maxWidth: 110.0,
        alignment: Alignment.center,
        child: Transform.translate(
          offset: const Offset(0, -20.0), // Floating outset -20px above bar line
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onTap();
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedScale(
              scale: _isPressed ? 0.95 : 1.0, // active:scale-95
              duration: const Duration(milliseconds: 75),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.95), // 4px clean white halo ring
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x331D64EC), // Subtle diffused blue ambient shadow
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Color(0x14000000), // Depth shadow
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3.5), // The exact clean 4px white halo ring
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF3B82F6), // Kumo Blue 500
                        Color(0xFF1D64EC), // Kumo Primary Blue
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF154EC1), // border-[#154ec1]
                      width: 0.8,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.add,
                      color: Colors.white,
                      size: 28.0, // Enlarged bold plus icon
                    ),
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

/// Regular Nav Tab Item with Active Pill, Notification Badge, and Avatar support
class _NavTabItem extends StatefulWidget {
  final HomeNavTab tab;
  final bool isActive;
  final IconData? icon;
  final IconData? activeIcon;
  final Color? activeColor;
  final bool hasBadge;
  final String? userAvatar;
  final String tooltip;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.tab,
    required this.isActive,
    this.icon,
    this.activeIcon,
    this.activeColor,
    this.hasBadge = false,
    this.userAvatar,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_NavTabItem> createState() => _NavTabItemState();
}

class _NavTabItemState extends State<_NavTabItem> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = widget.isActive
        ? (widget.activeIcon ?? widget.icon)
        : widget.icon;

    final effectiveColor = widget.isActive
        ? (widget.activeColor ?? AppColors.ink)
        : const Color(0xFF94A3B8); // stroke-[1.8] text-neutral-400

    return Semantics(
      label: widget.tooltip,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 75),
          curve: Curves.easeOutCubic,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              height: 40.0,
              width: widget.isActive ? 62.0 : 44.0, // Balanced compact active pill
              decoration: BoxDecoration(
                color: widget.isActive
                    ? const Color(0xFFF1F5F9) // bg-neutral-100/90
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.0), // rounded-xl
              ),
              child: Center(
                child: widget.tab == HomeNavTab.profile
                    ? _buildProfileAvatar(widget.isActive)
                    : _buildIconWithBadge(effectiveIcon, effectiveColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(IconData? iconData, Color color) {
    if (iconData == null) return const SizedBox.shrink();

    final iconWidget = Icon(
      iconData,
      size: 24.0, // 24px icon matching h-[23.99px]
      color: color,
    );

    if (!widget.hasBadge) {
      return iconWidget;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        // Red Notification Unread Badge (8px #FF3040 with 2px white ring)
        Positioned(
          top: -1.0,
          right: -2.0,
          child: Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3040),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.0, // 2px white ring
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(bool isActive) {
    return Container(
      width: 26.0,
      height: 26.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.ink : const Color(0xFFCBD5E1),
          width: 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.15),
                  spreadRadius: 1.5,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.0),
        child: widget.userAvatar != null && widget.userAvatar!.isNotEmpty
            ? Image.network(
                widget.userAvatar!,
                width: 24.0,
                height: 24.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarFallback(isActive),
              )
            : _buildAvatarFallback(isActive),
      ),
    );
  }

  Widget _buildAvatarFallback(bool isActive) {
    return Container(
      width: 24.0,
      height: 24.0,
      color: const Color(0xFFF1F5F9),
      child: Icon(
        isActive ? CupertinoIcons.person_fill : CupertinoIcons.person,
        size: 16.0,
        color: isActive ? AppColors.ink : const Color(0xFF94A3B8),
      ),
    );
  }
}
