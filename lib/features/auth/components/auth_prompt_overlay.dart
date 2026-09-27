import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';

/// Authentic Threads Light UI Auth Popover Overlay
///
/// 100% Minimalist Structure matching Threads reference:
/// - Light theme (#FFFFFF Card, #111827 Headline, #6B7280 Subtitle)
/// - Title: "Katakan lebih banyak" \n "dengan [Snaps Logo SVG]"
/// - Subtitle: "Gabung ke Snapan Market untuk membagikan pemikiran, mencari tahu apa yang sedang terjadi, mengikuti orang-orang Anda, dan banyak lagi."
/// - Single Action Capsule: Squircle student icon + "Lanjutkan sebagai siswa" + chevron right
/// - Soft frosted backdrop blur (16px blur + 40% dim) covering the entire screen
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
          // 1. Fullscreen Frosted Backdrop (covers the entire screen including header)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                color: Colors.black.withOpacity(0.40),
              ),
            ),
          ),

          // 2. Centered Authentic Threads Light Card
          Center(
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
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 36.0,
                        offset: const Offset(0, 16),
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28.0, 38.0, 28.0, 34.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Headline: "Katakan lebih banyak" \n "dengan [Snaps SVG]"
                        const Text(
                          'Katakan lebih banyak',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.6,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'dengan ',
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                                letterSpacing: -0.6,
                                height: 1.2,
                              ),
                            ),
                            SnapsLogo(height: 26.0),
                          ],
                        ),

                        const SizedBox(height: 16.0),

                        // Subtitle
                        const Text(
                          'Gabung ke komunitas SMKN 8. Temukan obrolan seru, info tongkrongan kampus, dan karya terbaik warga delapan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                            letterSpacing: -0.2,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 32.0),

                        // 3. Threads-Style Interactive Action Capsule
                        _ThreadsActionCapsule(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            onNavigateToAuth();
                          },
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

/// Custom Capsule Button replicating the exact Threads Login Row in Light Theme
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.0,
            ),
            boxShadow: [
              if (!_isPressed)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              // SMKN 8 School Logo Squircle (matches Instagram icon squircle in Threads reference)
              Container(
                width: 44.0,
                height: 44.0,
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
                    size: 22.0,
                    color: Color(0xFF3D38F5),
                  ),
                ),
              ),

              const SizedBox(width: 14.0),

              // Title
              const Expanded(
                child: Text(
                  'Lanjutkan sebagai siswa',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
              ),

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
