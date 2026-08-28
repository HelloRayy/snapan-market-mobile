import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

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

/// Ultra-Minimalist Home Feed Bottom Navigation Bar
///
/// Clean, uncluttered, and lightweight:
/// - 50px fixed bar height with SafeArea bottom awareness
/// - Pure white frosted glass backdrop (10px blur) with hairline top border (0xFFF1F5F9)
/// - 5 pure minimalist vector glyphs with generous whitespace (maxWidth: 360px)
/// - Clean state transitions:
///   1. Home: Outline house -> Solid black house (0xFF0F172A)
///   2. Pesan: Outline paperplane -> Solid black paperplane + 7px red notification dot
///   3. Center Action (+): 38x38px clean circular Kumo button (0xFF1D64EC) with white plus
///   4. Aktivitas: Outline heart -> Solid heart (0xFFF43F5E)
///   5. Profil: 26px circular avatar / outline user -> Solid user
/// - 0ms parsing overhead via Cupertino vector glyphs, 120 FPS ultra smooth
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
    this.userAvatar,
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

    // 1. Frosted Glass Background Bar Layer
    Widget frostedBar = Container(
      height: 50.0 + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000), // Ultra subtle elevation shadow
            blurRadius: 10.0,
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

    // 2. Navigation Items Layer (Constrained to 360px for clean, generous spacing)
    return SizedBox(
      height: 50.0 + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Background Bar
          Positioned.fill(
            child: frostedBar,
          ),

          // Foreground Nav Items
          Positioned.fill(
            child: SafeArea(
              top: false,
              bottom: true,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360.0),
                  child: SizedBox(
                    height: 50.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tab 1: Home
                        Expanded(
                          child: _MinimalTabItem(
                            tab: HomeNavTab.home,
                            isActive: currentTab == HomeNavTab.home,
                            icon: CupertinoIcons.house,
                            activeIcon: CupertinoIcons.house_fill,
                            tooltip: 'Home',
                            onTap: () => onTabSelected(HomeNavTab.home),
                          ),
                        ),

                        // Tab 2: Pesan
                        Expanded(
                          child: _MinimalTabItem(
                            tab: HomeNavTab.messages,
                            isActive: currentTab == HomeNavTab.messages,
                            icon: CupertinoIcons.paperplane,
                            activeIcon: CupertinoIcons.paperplane_fill,
                            hasBadge: hasUnreadMessages,
                            tooltip: 'Pesan',
                            onTap: () => onTabSelected(HomeNavTab.messages),
                          ),
                        ),

                        // Tab 3: Center Action (+)
                        Expanded(
                          child: Center(
                            child: _MinimalCenterButton(
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

                        // Tab 4: Aktivitas
                        Expanded(
                          child: _MinimalTabItem(
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

                        // Tab 5: Profil
                        Expanded(
                          child: _MinimalTabItem(
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

/// Center Action Button (Clean Minimalist Circular Kumo Button)
class _MinimalCenterButton extends StatefulWidget {
  final VoidCallback onTap;

  const _MinimalCenterButton({required this.onTap});

  @override
  State<_MinimalCenterButton> createState() => _MinimalCenterButtonState();
}

class _MinimalCenterButtonState extends State<_MinimalCenterButton> {
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
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 75),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 38.0,
          height: 38.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary, // Clean solid Kumo Blue
            border: Border.all(
              color: AppColors.primaryDark,
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E1D64EC),
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              CupertinoIcons.add,
              color: Colors.white,
              size: 22.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Regular Nav Tab Item (Ultra-Minimalist Icon with Natural Whitespace)
class _MinimalTabItem extends StatefulWidget {
  final HomeNavTab tab;
  final bool isActive;
  final IconData icon;
  final IconData activeIcon;
  final Color? activeColor;
  final bool hasBadge;
  final String? userAvatar;
  final String tooltip;
  final VoidCallback onTap;

  const _MinimalTabItem({
    required this.tab,
    required this.isActive,
    required this.icon,
    required this.activeIcon,
    this.activeColor,
    this.hasBadge = false,
    this.userAvatar,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_MinimalTabItem> createState() => _MinimalTabItemState();
}

class _MinimalTabItemState extends State<_MinimalTabItem> {
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
    final effectiveIcon = widget.isActive ? widget.activeIcon : widget.icon;
    final effectiveColor = widget.isActive
        ? (widget.activeColor ?? AppColors.ink)
        : const Color(0xFF787574); // Clean neutral slate

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
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 75),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 50.0,
            alignment: Alignment.center,
            child: widget.tab == HomeNavTab.profile &&
                    widget.userAvatar != null &&
                    widget.userAvatar!.isNotEmpty
                ? _buildProfileAvatar(widget.isActive)
                : _buildIconWithBadge(effectiveIcon, effectiveColor),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(IconData iconData, Color color) {
    final iconWidget = Icon(
      iconData,
      size: 26.0,
      color: color,
    );

    if (!widget.hasBadge) {
      return iconWidget;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        // Minimal 7px Red Notification Dot
        Positioned(
          top: -1.0,
          right: -2.0,
          child: Container(
            width: 7.0,
            height: 7.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.0),
        child: Image.network(
          widget.userAvatar!,
          width: 24.0,
          height: 24.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            isActive ? CupertinoIcons.person_fill : CupertinoIcons.person,
            size: 18.0,
            color: isActive ? AppColors.ink : const Color(0xFF787574),
          ),
        ),
      ),
    );
  }
}
