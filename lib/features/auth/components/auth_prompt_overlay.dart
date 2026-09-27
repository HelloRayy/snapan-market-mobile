import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Authentic Threads Dark UI Auth Popover Overlay
///
/// Pure #101010 Dark Aesthetic matching Threads Web/Mobile specification:
/// - Dark background (#101010)
/// - Off-white typography (#F3F5F7)
/// - Muted gray subtitles (#9E9E9E)
/// - 20px rounded action capsule with subtle border and chevron
/// - Fullscreen frosted glass backdrop blur that darkens the entire interface including headers
class AuthPromptOverlay extends StatelessWidget {
  final VoidCallback onNavigateToAuth;

  const AuthPromptOverlay({
    super.key,
    required this.onNavigateToAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fullscreen Dark Frosted Backdrop
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                color: Colors.black.withOpacity(0.68),
              ),
            ),
          ),

          // 2. Centered Authentic Threads Dark Card (#101010)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: const Color(0xFFF3F5F7).withOpacity(0.12),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.55),
                        blurRadius: 48.0,
                        offset: const Offset(0, 20),
                        spreadRadius: 4.0,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28.0, 36.0, 28.0, 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand Icon Container
                        Container(
                          width: 58.0,
                          height: 58.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: const Color(0xFFF3F5F7).withOpacity(0.14),
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const SnapsLogo(height: 24.0),
                        ),

                        const SizedBox(height: 16.0),

                        // Community Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(1000.0),
                            border: Border.all(
                              color: const Color(0xFFF3F5F7).withOpacity(0.10),
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: 13.0,
                                color: Color(0xFF818CF8),
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                'SMKN 8 Jakarta Community',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD1D5DB),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20.0),

                        // Headline (Threads Style)
                        const Text(
                          'Katakan lebih banyak dengan Snapan Market',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 23.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFF3F5F7),
                            letterSpacing: -0.6,
                            height: 1.22,
                          ),
                        ),

                        const SizedBox(height: 12.0),

                        // Subtitle
                        const Text(
                          'Gabung ke Snapan Market untuk membagikan pemikiran, mencari tahu apa yang sedang terjadi di sekolah, dan jual-beli karya siswa.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9E9E9E),
                            letterSpacing: -0.2,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 28.0),

                        // 3. Threads-Style Interactive Action Capsule
                        _ThreadsActionCapsule(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            onNavigateToAuth();
                          },
                        ),

                        const SizedBox(height: 24.0),

                        // Fine-print Terms Disclaimer
                        const Text(
                          'Dengan melanjutkan, Anda menyetujui Ketentuan Komunitas dan Kebijakan Privasi SMKN 8 Jakarta.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.0,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                            letterSpacing: -0.1,
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

/// Custom Capsule Button replicating the exact Threads Login Row
class _ThreadsActionCapsule extends StatefulWidget {
  final VoidCallback onTap;

  const _ThreadsActionCapsule({required this.onTap});

  @override
  State<_ThreadsActionCapsule> createState() => _ThreadsActionCapsuleState();
}

class _ThreadsActionCapsuleState extends State<_ThreadsActionCapsule> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFF242428) : const Color(0xFF141416),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: const Color(0xFFF3F5F7).withOpacity(_isPressed ? 0.28 : 0.16),
              width: 1.0,
            ),
            boxShadow: [
              if (!_isPressed)
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              // Branded Glyph Squircle
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3D38F5),
                      Color(0xFF6366F1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3D38F5).withOpacity(0.35),
                      blurRadius: 10.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.userCheck,
                  size: 20.0,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 14.0),

              // Title & Subtitle Stack
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lanjutkan ke Masuk / Daftar',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF3F5F7),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      'Akun Siswa SMKN 8 atau Google',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9E9E9E),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing Chevron
              const Icon(
                LucideIcons.chevronRight,
                size: 20.0,
                color: Color(0xFF9E9E9E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
