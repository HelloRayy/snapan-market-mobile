import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:snapan_market/core/components/snaps_logo.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Threads-Style Blocking Auth Popover Overlay
///
/// Displayed over HomeFeedScreen when the user is unauthenticated.
/// Prompts the user to proceed to the Standalone Auth Page.
class AuthPromptOverlay extends StatelessWidget {
  final VoidCallback onNavigateToAuth;

  const AuthPromptOverlay({
    super.key,
    required this.onNavigateToAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Frosted Glass Backdrop Blur
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.52),
            ),
          ),
        ),

        // 2. Centered Elevated Card
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.0),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.08),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 36.0,
                      offset: const Offset(0, 16),
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Accent Indigo Gradient Bar
                    Container(
                      height: 5.0,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            Color(0xFF6366F1),
                            Color(0xFF38BDF8),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand Avatar Squircle
                          Container(
                            width: 58.0,
                            height: 58.0,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPastel,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1.2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const SnapsLogo(height: 24.0),
                          ),

                          const SizedBox(height: 14.0),

                          // Community Tag Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(1000.0),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.sparkles,
                                  size: 13.0,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  'SMKN 8 Jakarta Community',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18.0),

                          // Headline (Threads Style)
                          const Text(
                            'Katakan lebih banyak dengan Snapan Market',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slateInk,
                              letterSpacing: -0.6,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 10.0),

                          // Subtitle
                          const Text(
                            'Gabung ke Snapan Market untuk membagikan pemikiran, jual beli karya & preloved, berdiskusi dengan sesama siswa SMKN 8 Jakarta, dan banyak lagi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.muted,
                              letterSpacing: -0.2,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 24.0),

                          // Primary Action Button (Lanjutkan ke Masuk / Daftar)
                          SizedBox(
                            width: double.infinity,
                            height: 50.0,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                onNavigateToAuth();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1000.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Lanjutkan ke Masuk / Daftar',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Icon(
                                    LucideIcons.arrowRight,
                                    size: 17.0,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18.0),

                          // Fine-print Terms Disclaimer
                          const Text(
                            'Dengan melanjutkan, Anda menyetujui Ketentuan Komunitas dan Kebijakan Privasi SMKN 8 Jakarta.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.0,
                              color: Color(0xFF94A3B8),
                              height: 1.4,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
