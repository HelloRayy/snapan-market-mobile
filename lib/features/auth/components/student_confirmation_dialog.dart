import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';
import 'package:snapan_market/core/services/student_registry_service.dart';

/// Threads-Style Student Identity Confirmation Popover Overlay
///
/// Features:
/// - Soft frosted backdrop blur (16px blur + 40% dim)
/// - Left-aligned header ("Konfirmasi Akun" \n "untuk gabung di [Logo Snaps]")
/// - No clutter: no extra badge or long description text
/// - Action capsule with Heading (Full Name) & Desc (Class & NIS)
/// - Clean regular-weight cancel button below ("Bukan saya, ganti NIS")
class StudentConfirmationDialog extends StatelessWidget {
  final RegisteredStudent student;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const StudentConfirmationDialog({
    super.key,
    required this.student,
    required this.onConfirm,
    required this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required RegisteredStudent student,
  }) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Confirmation',
      barrierColor: Colors.black.withValues(alpha: 0.40),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, anim1, anim2) {
        return StudentConfirmationDialog(
          student: student,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16.0 * curve.value,
            sigmaY: 16.0 * curve.value,
          ),
          child: FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(curve),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 36.0,
                    offset: const Offset(0, 16),
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26.0, 24.0, 26.0, 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Headline Row: Title on the left, [x] button aligned on the top-right
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Konfirmasi Akun',
                                style: TextStyle(
                                  fontFamily: 'SFPro',
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.6,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 3.0),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'untuk gabung di ',
                                    style: TextStyle(
                                      fontFamily: 'SFPro',
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                      letterSpacing: -0.6,
                                      height: 1.2,
                                    ),
                                  ),
                                  SnapsLogo(height: 32.0),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onCancel();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.x,
                              size: 16.0,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),

                    // 2. Compact 1-line Description
                    const Text(
                      'Pastikan data siswa di bawah ini benar milikmu.',
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22.0),

                    // 3. Rich Action Capsule: Heading = Full Name, Desc = Class & NIS
                    _StudentConfirmationCapsule(
                      student: student,
                      onTap: onConfirm,
                    ),
                    const SizedBox(height: 16.0),

                    // 4. Cancel Action (Left-aligned, regular font weight)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onCancel();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Bukan saya, ganti NIS',
                          style: TextStyle(
                            fontFamily: 'SFPro',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                          ),
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
    );
  }
}

/// Custom Interactive Capsule replicating the Threads Action Row
class _StudentConfirmationCapsule extends StatefulWidget {
  final RegisteredStudent student;
  final VoidCallback onTap;

  const _StudentConfirmationCapsule({
    required this.student,
    required this.onTap,
  });

  @override
  State<_StudentConfirmationCapsule> createState() => _StudentConfirmationCapsuleState();
}

class _StudentConfirmationCapsuleState extends State<_StudentConfirmationCapsule> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.2,
            ),
            boxShadow: [
              if (!_isPressed)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            children: [
              // SMKN 8 School Logo Squircle
              Container(
                width: 46.0,
                height: 46.0,
                padding: const EdgeInsets.all(5.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/logo/smk8.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    LucideIcons.graduationCap,
                    size: 24.0,
                    color: Color(0xFF3D38F5),
                  ),
                ),
              ),

              const SizedBox(width: 14.0),

              // Heading: Full Name, Desc: Class & NIS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.student.name,
                      style: const TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      '${widget.student.classGroup} \u2022 NIS ${widget.student.nis}',
                      style: const TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // Trailing Chevron
              const Icon(
                LucideIcons.chevronRight,
                size: 20.0,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
