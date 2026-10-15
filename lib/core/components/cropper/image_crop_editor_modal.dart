import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Pure Flutter In-App Image Cropper Modal (SNAPS-81)
///
/// Menggantikan tampilan native uCrop Android yang kaku/aneh dengan UI in-app
/// modern khas Snaps (Image 2 style):
/// - Immersive Cinema Dark canvas (`#0B0F17`)
/// - Circular / Square Mask Overlay dengan rule-of-thirds grid saat disentuh
/// - Fluid Pan & Pinch-to-zoom (1.0x - 4.0x) via `InteractiveViewer`
/// - Quick Adjustments: Rotate 90°, Flip Horizontal, Reset
/// - Bottom Floating Controls: Batal (`✕`) & Simpan (`✓` pill primary Snaps)
/// - Zero native dependencies / 100% pure Flutter rendering
class ImageCropEditorModal extends StatefulWidget {
  final File imageFile;
  final String title;
  final bool isCircle;
  final double cropSize;

  const ImageCropEditorModal({
    super.key,
    required this.imageFile,
    this.title = 'Sesuaikan Foto Profil',
    this.isCircle = true,
    this.cropSize = 280.0,
  });

  /// Static helper to display the modal and return CroppedFile or null
  static Future<CroppedFile?> open({
    required BuildContext context,
    required String imagePath,
    String title = 'Sesuaikan Foto Profil',
    bool isCircle = true,
  }) async {
    final file = File(imagePath);
    if (!file.existsSync()) return null;

    final result = await Navigator.of(context).push<CroppedFile>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.85),
        pageBuilder: (context, anim, secAnim) => ImageCropEditorModal(
          imageFile: file,
          title: title,
          isCircle: isCircle,
        ),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            child: child,
          );
        },
      ),
    );

    return result;
  }

  @override
  State<ImageCropEditorModal> createState() => _ImageCropEditorModalState();
}

class _ImageCropEditorModalState extends State<ImageCropEditorModal> {
  final GlobalKey _repaintKey = GlobalKey();
  final TransformationController _transformController = TransformationController();

  int _quarterTurns = 0; // 0, 1, 2, 3 for 0°, 90°, 180°, 270°
  bool _isFlippedHorizontally = false;
  bool _isInteracting = false;
  bool _isExporting = false;

  void _rotateClockwise() {
    HapticFeedback.selectionClick();
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  void _flipHorizontal() {
    HapticFeedback.selectionClick();
    setState(() {
      _isFlippedHorizontally = !_isFlippedHorizontally;
    });
  }

  void _resetTransform() {
    HapticFeedback.lightImpact();
    setState(() {
      _quarterTurns = 0;
      _isFlippedHorizontally = false;
      _transformController.value = Matrix4.identity();
    });
  }

  Future<void> _exportAndFinish() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    HapticFeedback.mediumImpact();

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) Navigator.pop(context, null);
        return;
      }

      // Capture at high pixel ratio for sharp 720p output
      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) Navigator.pop(context, null);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final croppedFile = File(targetPath);
      await croppedFile.writeAsBytes(pngBytes);

      if (mounted) {
        Navigator.pop(context, CroppedFile(croppedFile.path));
      }
    } catch (e) {
      debugPrint('[ImageCropEditorModal] Export error: $e');
      if (mounted) Navigator.pop(context, null);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cropBoxSize = (screenSize.width * 0.72).clamp(240.0, 320.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17), // Snaps Dark Cinema
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Bar
            _buildTopHeader(),

            // 2. Interactive Image Crop Area
            Expanded(
              child: Center(
                child: SizedBox(
                  width: cropBoxSize,
                  height: cropBoxSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // RepaintBoundary for high-res snapshot
                      RepaintBoundary(
                        key: _repaintKey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            widget.isCircle ? cropBoxSize / 2 : 16,
                          ),
                          child: Container(
                            color: Colors.black,
                            width: cropBoxSize,
                            height: cropBoxSize,
                            child: InteractiveViewer(
                              transformationController: _transformController,
                              minScale: 1.0,
                              maxScale: 4.5,
                              clipBehavior: Clip.none,
                              onInteractionStart: (_) =>
                                  setState(() => _isInteracting = true),
                              onInteractionEnd: (_) =>
                                  setState(() => _isInteracting = false),
                              child: RotatedBox(
                                quarterTurns: _quarterTurns,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.diagonal3Values(
                                    _isFlippedHorizontally ? -1.0 : 1.0,
                                    1.0,
                                    1.0,
                                  ),
                                  child: Image.file(
                                    widget.imageFile,
                                    fit: BoxFit.cover,
                                    width: cropBoxSize,
                                    height: cropBoxSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Outer Vignette & Rule-of-Thirds Grid Overlay (Non-interactive)
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size(cropBoxSize, cropBoxSize),
                          painter: _CropOverlayPainter(
                            isCircle: widget.isCircle,
                            showGrid: _isInteracting,
                            borderColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Quick Tools Toolbar (Rotate, Flip, Reset)
            _buildQuickTools(),

            const SizedBox(height: 12),

            // 4. Bottom Floating Action Buttons (Image 2 style)
            _buildBottomActionBar(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context, null),
            tooltip: 'Batal',
          ),
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          TextButton(
            onPressed: _resetTransform,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTools() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ToolButton(
            icon: Icons.rotate_right_rounded,
            label: 'Putar 90°',
            onTap: _rotateClockwise,
          ),
          const SizedBox(width: 24),
          _ToolButton(
            icon: Icons.flip_rounded,
            label: 'Cermin',
            onTap: _flipHorizontal,
          ),
          const SizedBox(width: 24),
          _ToolButton(
            icon: Icons.restart_alt_rounded,
            label: 'Semula',
            onTap: _resetTransform,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cancel Circular Pill
          InkWell(
            onTap: () => Navigator.pop(context, null),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF334155), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm Pill Button (Image 2 style with AppColors.primary / blue)
          InkWell(
            onTap: _isExporting ? null : _exportAndFinish,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0284C7), // Light Blue
                    AppColors.primary,  // Electric Indigo
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_isExporting) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Memotong...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      'Simpan Foto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF334155), width: 1),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for circular/square crop border and interactive rule-of-thirds grid
class _CropOverlayPainter extends CustomPainter {
  final bool isCircle;
  final bool showGrid;
  final Color borderColor;

  _CropOverlayPainter({
    required this.isCircle,
    required this.showGrid,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Offset.zero & size;

    if (isCircle) {
      canvas.drawCircle(rect.center, size.width / 2, borderPaint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
        borderPaint,
      );
    }

    // Draw subtle 3x3 rule-of-thirds grid when user is dragging/zooming
    if (showGrid) {
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final w = size.width;
      final h = size.height;

      // Vertical lines
      canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), gridPaint);
      canvas.drawLine(Offset(2 * w / 3, 0), Offset(2 * w / 3, h), gridPaint);

      // Horizontal lines
      canvas.drawLine(Offset(0, h / 3), Offset(w, h / 3), gridPaint);
      canvas.drawLine(Offset(0, 2 * h / 3), Offset(w, 2 * h / 3), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.showGrid != showGrid ||
        oldDelegate.isCircle != isCircle ||
        oldDelegate.borderColor != borderColor;
  }
}
