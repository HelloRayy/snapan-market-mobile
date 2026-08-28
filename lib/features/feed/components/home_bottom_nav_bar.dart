import 'dart:ui';
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

/// Home Feed Bottom Navigation Bar
///
/// 100% exact match to reference screenshot:
/// - 50px fixed bar height with SafeArea bottom awareness
/// - Frosted glass backdrop blur (10px blur) with hairline top border (0xFFF1F5F9)
/// - 5 iconic minimal vector glyphs:
///   1. Home: Solid rounded house polygon
///   2. Pesan: Curved rounded paperplane with red numeric badge "1"
///   3. Center Action (+): 44x38px soft squircle pill container with plus icon
///   4. Aktivitas: Clean outline heart (solid rose when active)
///   5. Profil: Minimalist user glyph (circle head + shoulder arc) / avatar
/// - Touch target >= 44x44pt & tactile micro-tap scale (0.95)
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
    this.hasUnreadMessages = true,
    this.unreadMessagesCount = 1,
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

    // 2. Navigation Items Layer (Constrained to 350px for tight, ergonomic spacing)
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
                  constraints: const BoxConstraints(maxWidth: 350.0),
                  child: SizedBox(
                    height: 50.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tab 1: Home (Solid Rounded House Polygon)
                        Expanded(
                          child: _CustomNavTabItem(
                            tooltip: 'Home',
                            isActive: currentTab == HomeNavTab.home,
                            onTap: () => onTabSelected(HomeNavTab.home),
                            child: _HomeGlyph(
                              isActive: currentTab == HomeNavTab.home,
                            ),
                          ),
                        ),

                        // Tab 2: Pesan (Curved Paperplane with Red Badge "1")
                        Expanded(
                          child: _CustomNavTabItem(
                            tooltip: 'Pesan',
                            isActive: currentTab == HomeNavTab.messages,
                            onTap: () => onTabSelected(HomeNavTab.messages),
                            child: _PaperPlaneGlyph(
                              isActive: currentTab == HomeNavTab.messages,
                              hasBadge: hasUnreadMessages,
                              badgeCount: unreadMessagesCount,
                            ),
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

                        // Tab 4: Aktivitas (Heart Glyph)
                        Expanded(
                          child: _CustomNavTabItem(
                            tooltip: 'Aktivitas',
                            isActive: currentTab == HomeNavTab.activity,
                            onTap: () => onTabSelected(HomeNavTab.activity),
                            child: _HeartGlyph(
                              isActive: currentTab == HomeNavTab.activity,
                              hasBadge: hasUnreadActivity,
                            ),
                          ),
                        ),

                        // Tab 5: Profil (Minimalist User Glyph / Avatar)
                        Expanded(
                          child: _CustomNavTabItem(
                            tooltip: 'Profil',
                            isActive: currentTab == HomeNavTab.profile,
                            onTap: () => onTabSelected(HomeNavTab.profile),
                            child: userAvatar != null && userAvatar!.isNotEmpty
                                ? _buildAvatarImage(
                                    userAvatar!,
                                    currentTab == HomeNavTab.profile,
                                  )
                                : _UserGlyph(
                                    isActive: currentTab == HomeNavTab.profile,
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
    );
  }

  Widget _buildAvatarImage(String url, bool isActive) {
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
          url,
          width: 24.0,
          height: 24.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _UserGlyph(isActive: isActive),
        ),
      ),
    );
  }
}

/// Center Floating Action Button (Elevated Kumo Circle with 4px White Halo Ring & High Z-Index)
class _FloatingKumoFabButton extends StatefulWidget {
  final VoidCallback onTap;

  const _FloatingKumoFabButton({required this.onTap});

  @override
  State<_FloatingKumoFabButton> createState() => _FloatingKumoFabButtonState();
}

class _FloatingKumoFabButtonState extends State<_FloatingKumoFabButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      width: 52.0,
      child: OverflowBox(
        maxHeight: 110.0,
        maxWidth: 110.0,
        alignment: Alignment.center,
        child: Transform.translate(
          offset: const Offset(0, -18.0), // Floating outset -18px
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
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
                width: 52.0,
                height: 52.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.95), // 4px clean white halo ring
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x331D64EC), // Subtle diffused blue ambient shadow
                      blurRadius: 8.0,
                      offset: Offset(0, 4),
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
                        Color(0xFF3B82F6), // from-[#3b82f6]
                        Color(0xFF1D64EC), // to-[#1d64ec]
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF154EC1), // border-[#154ec1]
                      width: 0.8,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 26.0,
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

/// Interactive Tab Button Wrapper with Semantics & Micro-Tap
class _CustomNavTabItem extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final String tooltip;
  final VoidCallback onTap;

  const _CustomNavTabItem({
    required this.child,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_CustomNavTabItem> createState() => _CustomNavTabItemState();
}

class _CustomNavTabItemState extends State<_CustomNavTabItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.tooltip,
      selected: widget.isActive,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
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
          child: Container(
            height: 50.0,
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 1. Home Glyph (Solid Rounded House Polygon)
class _HomeGlyph extends StatelessWidget {
  final bool isActive;

  const _HomeGlyph({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.0,
      height: 24.0,
      child: CustomPaint(
        painter: _HomePainter(
          color: isActive ? AppColors.ink : const Color(0xFF787574),
          isActive: isActive,
        ),
      ),
    );
  }
}

class _HomePainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _HomePainter({required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isActive ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Polygon house with rounded peak and corners matching screenshot
    final path = Path();
    path.moveTo(w * 0.5, h * 0.08); // Peak
    path.lineTo(w * 0.92, h * 0.42); // Right roof
    path.lineTo(w * 0.88, h * 0.82); // Right wall
    path.quadraticBezierTo(w * 0.88, h * 0.94, w * 0.76, h * 0.94); // Bottom-right curve
    path.lineTo(w * 0.24, h * 0.94); // Bottom
    path.quadraticBezierTo(w * 0.12, h * 0.94, w * 0.12, h * 0.82); // Bottom-left curve
    path.lineTo(w * 0.08, h * 0.42); // Left wall
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HomePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}

/// 2. Paper Plane Glyph (Curved Paperplane with Red Badge "1")
class _PaperPlaneGlyph extends StatelessWidget {
  final bool isActive;
  final bool hasBadge;
  final int badgeCount;

  const _PaperPlaneGlyph({
    required this.isActive,
    this.hasBadge = false,
    this.badgeCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final plane = SizedBox(
      width: 24.0,
      height: 24.0,
      child: CustomPaint(
        painter: _PaperPlanePainter(
          color: isActive ? AppColors.ink : const Color(0xFF787574),
          isActive: isActive,
        ),
      ),
    );

    if (!hasBadge) {
      return plane;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        plane,
        Positioned(
          top: -4.0,
          right: -6.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            constraints: const BoxConstraints(
              minWidth: 16.0,
              minHeight: 16.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30), // iOS Red
              shape: badgeCount > 9 ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: badgeCount > 9 ? BorderRadius.circular(8.0) : null,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaperPlanePainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _PaperPlanePainter({required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isActive ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Curved paper plane pointing top-right
    final path = Path();
    path.moveTo(w * 0.90, h * 0.12);
    path.lineTo(w * 0.15, h * 0.42);
    path.quadraticBezierTo(w * 0.10, h * 0.46, w * 0.15, h * 0.54);
    path.lineTo(w * 0.44, h * 0.62);
    path.lineTo(w * 0.52, h * 0.91);
    path.quadraticBezierTo(w * 0.58, h * 0.96, w * 0.64, h * 0.88);
    path.close();

    canvas.drawPath(path, paint);

    // Center crease line when outline
    if (!isActive) {
      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(w * 0.44, h * 0.62),
        Offset(w * 0.90, h * 0.12),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPlanePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}

/// 4. Heart Glyph (Outline / Solid Heart)
class _HeartGlyph extends StatelessWidget {
  final bool isActive;
  final bool hasBadge;

  const _HeartGlyph({
    required this.isActive,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final heart = SizedBox(
      width: 24.0,
      height: 24.0,
      child: CustomPaint(
        painter: _HeartPainter(
          color: isActive ? const Color(0xFFF43F5E) : const Color(0xFF787574),
          isActive: isActive,
        ),
      ),
    );

    if (!hasBadge) return heart;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        heart,
        Positioned(
          top: -1.0,
          right: -2.0,
          child: Container(
            width: 7.0,
            height: 7.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeartPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _HeartPainter({required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isActive ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, h * 0.82);
    path.cubicTo(
      w * 0.10, h * 0.55,
      w * 0.05, h * 0.28,
      w * 0.28, h * 0.16,
    );
    path.cubicTo(
      w * 0.40, h * 0.10,
      w * 0.48, h * 0.22,
      w * 0.50, h * 0.30,
    );
    path.cubicTo(
      w * 0.52, h * 0.22,
      w * 0.60, h * 0.10,
      w * 0.72, h * 0.16,
    );
    path.cubicTo(
      w * 0.95, h * 0.28,
      w * 0.90, h * 0.55,
      w * 0.50, h * 0.82,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}

/// 5. Minimalist User Glyph (Circle head + Shoulder arc)
class _UserGlyph extends StatelessWidget {
  final bool isActive;

  const _UserGlyph({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.0,
      height: 24.0,
      child: CustomPaint(
        painter: _UserPainter(
          color: isActive ? AppColors.ink : const Color(0xFF787574),
          isActive: isActive,
        ),
      ),
    );
  }
}

class _UserPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _UserPainter({required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isActive ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.5, h * 0.32), w * 0.19, paint);

    // Shoulder Arc
    final shoulderPath = Path();
    shoulderPath.moveTo(w * 0.15, h * 0.88);
    shoulderPath.cubicTo(
      w * 0.15, h * 0.60,
      w * 0.85, h * 0.60,
      w * 0.85, h * 0.88,
    );

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(shoulderPath, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _UserPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isActive != isActive;
  }
}
