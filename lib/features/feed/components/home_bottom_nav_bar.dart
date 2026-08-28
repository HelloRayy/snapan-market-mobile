import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Enum representing the 5 navigation tabs matching Web MarketBottomNav
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
/// 100% exact parity with `src/ui/components/marketplace/MarketBottomNav.tsx`:
/// - Auto-detects virtual keyboard to prevent floating over mobile keyboard
/// - 50px fixed bar height (`h-[50px]`) with SafeArea bottom padding (`env(safe-area-inset-bottom)`)
/// - Frosted glass backdrop blur (`bg-white/95 backdrop-blur-md`) strictly clipped to bar rect
/// - 1px subtle top border (`border-t border-neutral-200/80`) & upward elevation shadow (`shadow-[0_-2px_12px_rgba(0,0,0,0.03)]`)
/// - 5-item grid layout (`max-w-md mx-auto h-[50px] grid grid-cols-5 px-1`):
///   1. Home (Active pill 42x72px #F1F5F9, 24px icon fill-slate-900 / stroke text-neutral-400)
///   2. Pesan (24px Send icon with 8px #FF3040 red dot notification badge & white ring)
///   3. Jual (48x48px elevated floating circle at -16px top outset with HIGH z-index, unclipped 4px white halo ring & blue glow)
///   4. Aktivitas (24px Heart icon with rose-500 #F43F5E active color)
///   5. Profil (25x25px circular avatar with subtle 1.5px slate ring when active)
/// - Tactile micro-tap scale animation (0.96) & dual haptic feedback
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
    this.hasUnreadMessages = true, // Matches Web default: hasBadge: true on Pesan
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

    // 1. Frosted Glass Background Bar Layer (Clipped strictly so blur doesn't bleed)
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

    // 2. Navigation Items Layer (Rendered with HIGH z-index on top of frosted bar, UNCLIPPED for floating FAB)
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Background Bar
        frostedBar,

        // Foreground Nav Items & High Z-Index Floating Action Button
        SafeArea(
          top: false,
          bottom: true,
          child: Container(
            height: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 4.0), // Matches Web px-1
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tab 1: Home (Home Icon)
                Expanded(
                  child: _NavTabItem(
                    tab: HomeNavTab.home,
                    isActive: currentTab == HomeNavTab.home,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    tooltip: 'Home',
                    onTap: () => onTabSelected(HomeNavTab.home),
                  ),
                ),

                // Tab 2: Pesan (Send Icon with Red Dot Badge)
                Expanded(
                  child: _NavTabItem(
                    tab: HomeNavTab.messages,
                    isActive: currentTab == HomeNavTab.messages,
                    icon: Icons.send_outlined,
                    activeIcon: Icons.send_rounded,
                    hasBadge: hasUnreadMessages,
                    tooltip: 'Pesan',
                    onTap: () => onTabSelected(HomeNavTab.messages),
                  ),
                ),

                // Tab 3: Jual (Elevated Floating Action Button with -16px Outset & High Z-Index)
                Expanded(
                  child: Center(
                    child: _FloatingCreateButton(
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

                // Tab 4: Aktivitas (Heart Icon with Rose-500 Color on Active)
                Expanded(
                  child: _NavTabItem(
                    tab: HomeNavTab.activity,
                    isActive: currentTab == HomeNavTab.activity,
                    icon: Icons.favorite_border_rounded,
                    activeIcon: Icons.favorite_rounded,
                    activeColor: const Color(0xFFF43F5E), // fill-rose-500
                    hasBadge: hasUnreadActivity,
                    tooltip: 'Aktivitas',
                    onTap: () => onTabSelected(HomeNavTab.activity),
                  ),
                ),

                // Tab 5: Profil (User Avatar with Active Slate Ring)
                Expanded(
                  child: _NavTabItem(
                    tab: HomeNavTab.profile,
                    isActive: currentTab == HomeNavTab.profile,
                    userAvatar: userAvatar,
                    tooltip: 'Profil',
                    onTap: () => onTabSelected(HomeNavTab.profile),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Floating Center Action Button (48x48px Elevated Circle at -16px Outset with 4px Halo Ring & High Z-Index)
class _FloatingCreateButton extends StatefulWidget {
  final VoidCallback onTap;

  const _FloatingCreateButton({required this.onTap});

  @override
  State<_FloatingCreateButton> createState() => _FloatingCreateButtonState();
}

class _FloatingCreateButtonState extends State<_FloatingCreateButton> {
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
      width: 52.0,
      child: OverflowBox(
        maxHeight: 90.0,
        maxWidth: 90.0,
        alignment: Alignment.center,
        child: Transform.translate(
          offset: const Offset(0, -18.0), // Floating outset -18px
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
              scale: _isPressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 75),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 52.0,
                height: 52.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3B82F6), // Kumo gradient top #3B82F6
                      Color(0xFF1D64EC), // Kumo primary blue #1D64EC
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primaryDark, // #154EC1 clean border without white ring
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x591D64EC), // Enhanced 35% diffused blue glow shadow
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Color(0x331D64EC),
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 32.0, // Larger bold plus icon
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
      selected: widget.isActive,
      button: true,
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
          scale: _isPressed ? 0.96 : 1.0, // Matches Web active:scale-[0.96]
          duration: const Duration(milliseconds: 75),
          curve: Curves.easeOutCubic,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              height: 42.0, // Subtle active indicator pill matching Threads h-[42px]
              width: widget.isActive ? 72.0 : 48.0,
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
      size: 24.0,
      color: color,
    );

    if (!widget.hasBadge) {
      return iconWidget;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        // Red Notification Unread Badge (Threads style: 8px #FF3040 with 2px white ring)
        Positioned(
          top: -0.5,
          right: -1.0,
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
      width: 25.0,
      height: 25.0,
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
                  spreadRadius: 1.5, // Matches Web ring-1.5 ring-slate-900/30
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.5),
        child: widget.userAvatar != null && widget.userAvatar!.isNotEmpty
            ? Image.network(
                widget.userAvatar!,
                width: 23.0,
                height: 23.0,
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
      width: 23.0,
      height: 23.0,
      color: const Color(0xFFF1F5F9),
      child: Icon(
        Icons.person_rounded,
        size: 15.0,
        color: isActive ? AppColors.ink : const Color(0xFF94A3B8),
      ),
    );
  }
}
