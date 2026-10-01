import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controller for programmatic and gesture control of HomePushDrawerLayout.
class HomePushDrawerController extends ChangeNotifier {
  AnimationController? _animController;

  void attach(AnimationController controller) {
    _animController = controller;
    _animController!.addListener(notifyListeners);
  }

  void detach() {
    _animController?.removeListener(notifyListeners);
    _animController = null;
  }

  bool get isOpen => (_animController?.value ?? 0.0) > 0.5;
  double get progress => _animController?.value ?? 0.0;

  void open() {
    HapticFeedback.lightImpact();
    _animController?.animateTo(1.0, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  void close() {
    HapticFeedback.lightImpact();
    _animController?.animateTo(0.0, duration: const Duration(milliseconds: 240), curve: Curves.easeInCubic);
  }

  void toggle() {
    if (isOpen) {
      close();
    } else {
      open();
    }
  }
}

/// Interactive Push Drawer Layout for Home Feed Screen (<220 lines).
///
/// Smoothly translates and scales the main content card to the right (~260dp, scale 0.90, radius 20px),
/// providing a modern iOS / Threads style push drawer experience with hybrid gestures.
class HomePushDrawerLayout extends StatefulWidget {
  final HomePushDrawerController controller;
  final Widget drawer;
  final Widget content;
  final double drawerWidth;
  final double pushDistance;
  final double scale;
  final double borderRadius;

  const HomePushDrawerLayout({
    super.key,
    required this.controller,
    required this.drawer,
    required this.content,
    this.drawerWidth = 280.0,
    this.pushDistance = 260.0,
    this.scale = 0.90,
    this.borderRadius = 20.0,
  });

  @override
  State<HomePushDrawerLayout> createState() => _HomePushDrawerLayoutState();
}

class _HomePushDrawerLayoutState extends State<HomePushDrawerLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    widget.controller.attach(_animController);
  }

  @override
  void dispose() {
    widget.controller.detach();
    _animController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0.0;
    _animController.value = (_animController.value + delta / widget.pushDistance).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    if (velocity < -300) {
      widget.controller.close();
    } else if (velocity > 300) {
      widget.controller.open();
    } else if (_animController.value > 0.45) {
      widget.controller.open();
    } else {
      widget.controller.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = Theme.of(context).scaffoldBackgroundColor;

    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (context, _) {
        final progress = _curvedAnimation.value;
        final bool isPartiallyOpen = progress > 0.005;

        return PopScope(
          canPop: !widget.controller.isOpen,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && widget.controller.isOpen) {
              widget.controller.close();
            }
          },
          child: Container(
            color: themeBg,
            child: Stack(
              children: [
                // 1. Left Drawer Content with subtle parallax slide
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: widget.drawerWidth,
                  child: Transform.translate(
                    offset: Offset(-36.0 * (1.0 - progress), 0.0),
                    child: Opacity(
                      opacity: (0.35 + 0.65 * progress).clamp(0.0, 1.0),
                      child: widget.drawer,
                    ),
                  ),
                ),

                // 2. Main Content Card (Translated, Scaled, Rounded with Elevation Shadow)
                Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..translate(widget.pushDistance * progress, 0.0)
                    ..scale(1.0 - ((1.0 - widget.scale) * progress)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(widget.borderRadius * progress),
                      boxShadow: isPartiallyOpen
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12 * progress),
                                blurRadius: 28.0,
                                spreadRadius: 1.0,
                                offset: const Offset(-6.0, 4.0),
                              ),
                            ]
                          : null,
                    ),
                    clipBehavior: isPartiallyOpen ? Clip.antiAlias : Clip.none,
                    child: widget.content,
                  ),
                ),

                // 3. Tap & Drag Dismissal Barrier over shifted card
                if (isPartiallyOpen)
                  Positioned(
                    left: widget.pushDistance * progress,
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.controller.close,
                      onHorizontalDragUpdate: _handleDragUpdate,
                      onHorizontalDragEnd: _handleDragEnd,
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),

                // 4. Edge Swipe detector when closed (left edge 28dp)
                if (!isPartiallyOpen)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 28.0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: _handleDragUpdate,
                      onHorizontalDragEnd: _handleDragEnd,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
