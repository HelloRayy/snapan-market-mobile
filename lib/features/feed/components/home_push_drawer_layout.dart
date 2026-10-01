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
    _animController?.animateTo(1.0, duration: const Duration(milliseconds: 320), curve: const Cubic(0.16, 1.0, 0.3, 1.0));
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
/// Smoothly translates and scales the main content card to the right (~285dp, scale 1.0, radius 0px),
/// providing a modern iOS / Threads style push drawer experience with hybrid gestures.
class HomePushDrawerLayout extends StatefulWidget {
  final HomePushDrawerController? controller;
  final Widget drawer;
  final Widget content;
  final double drawerWidth;
  final double pushDistance;
  final double scale;
  final double borderRadius;
  final double scrimOpacity;

  const HomePushDrawerLayout({
    super.key,
    this.controller,
    required this.drawer,
    required this.content,
    this.drawerWidth = 285.0,
    this.pushDistance = 285.0,
    this.scale = 1.0,
    this.borderRadius = 0.0,
    this.scrimOpacity = 0.05,
  });

  @override
  State<HomePushDrawerLayout> createState() => _HomePushDrawerLayoutState();
}

class _HomePushDrawerLayoutState extends State<HomePushDrawerLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _curvedAnimation;
  HomePushDrawerController? _internalController;
  HomePushDrawerController get _effectiveController => widget.controller ?? (_internalController ??= HomePushDrawerController());

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
      reverseCurve: Curves.easeInCubic,
    );
    _effectiveController.attach(_animController);
  }

  @override
  void didUpdateWidget(HomePushDrawerLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _effectiveController.attach(_animController);
    }
  }

  @override
  void dispose() {
    _effectiveController.detach();
    _internalController?.dispose();
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
      _effectiveController.close();
    } else if (velocity > 300) {
      _effectiveController.open();
    } else if (_animController.value > 0.45) {
      _effectiveController.open();
    } else {
      _effectiveController.close();
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
          canPop: !_effectiveController.isOpen,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _effectiveController.isOpen) {
              _effectiveController.close();
            }
          },
          child: Container(
            color: themeBg,
            child: Stack(
              children: [
                // 1. Left Drawer Content with slide and fade-in (0.0 -> 1.0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: widget.drawerWidth,
                  child: Transform.translate(
                    offset: Offset(-35.0 * (1.0 - progress), 0.0),
                    child: Opacity(
                      opacity: progress.clamp(0.0, 1.0),
                      child: widget.drawer,
                    ),
                  ),
                ),

                // 2. Main Content Card (Pure Translation, Scale 1.0, Subtle Dimming)
                Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..translate(widget.pushDistance * progress, 0.0)
                    ..scale(widget.scale == 1.0 ? 1.0 : 1.0 - ((1.0 - widget.scale) * progress)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: widget.borderRadius > 0 ? BorderRadius.circular(widget.borderRadius * progress) : null,
                      boxShadow: isPartiallyOpen
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45 * progress),
                                blurRadius: 36.0,
                                spreadRadius: 0.0,
                                offset: const Offset(-14.0, 0.0),
                              ),
                            ]
                          : null,
                    ),
                    clipBehavior: widget.borderRadius > 0 ? Clip.antiAlias : Clip.none,
                    child: Stack(
                      children: [
                        widget.content,
                        // 2a. Subtle dimming overlay over shifted feed screen (5%)
                        if (isPartiallyOpen)
                          Positioned.fill(
                            child: ColoredBox(
                              color: Colors.black.withValues(alpha: widget.scrimOpacity * progress),
                            ),
                          ),
                      ],
                    ),
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
                      onTap: _effectiveController.close,
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
