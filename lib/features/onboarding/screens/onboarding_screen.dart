import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/onboarding/models/onboarding_slide.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final slide in onboardingSlides) {
      if (!slide.isSvg) {
        precacheImage(AssetImage(slide.assetPath), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _nextPage() {
    final current = _pageController.page?.round() ?? _currentPage;
    if (current < onboardingSlides.length) {
      _goToPage(current + 1);
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    _goToPage(onboardingSlides.length); // Jump directly to Auth Slide (index 4)
  }

  @override
  Widget build(BuildContext context) {
    final isAuthSlide = _currentPage >= onboardingSlides.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background PageView for All Slides
          PageView.builder(
            controller: _pageController,
            physics: isAuthSlide
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: onboardingSlides.length + 1, // 4 slides + 1 auth slide
            itemBuilder: (context, index) {
              if (index < onboardingSlides.length) {
                final slide = onboardingSlides[index];
                return _buildSlideContent(slide);
              } else {
                return AuthScreen(
                  onBack: () => _goToPage(onboardingSlides.length - 1),
                  onSuccess: widget.onComplete,
                );
              }
            },
          ),

          // Bottom Navigation Controls (Visible ONLY on Content Slides 0-3)
          if (!isAuthSlide)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingSlides.length,
                        (dotIndex) {
                          final isSelected = dotIndex == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 7,
                            width: isSelected ? 24 : 7,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1D64EC) // Kumo Blue
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Action CTA Buttons in Kumo UI Style
                    if (_currentPage < onboardingSlides.length - 1)
                      Row(
                        children: [
                          // Lewati (Skip) - Kumo Secondary Button
                          Expanded(
                            flex: 4,
                            child: KumoButton.secondary(
                              text: 'Lewati',
                              onPressed: _skip,
                              height: 50,
                              borderRadius: 16,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Lanjutkan (Next) - Kumo Primary Button
                          Expanded(
                            flex: 6,
                            child: KumoButton.primary(
                              text: 'Lanjutkan',
                              onPressed: _nextPage,
                              height: 50,
                              borderRadius: 16,
                              iconRight: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Slide 3: Full Width "Mulai Sekarang" Kumo Primary Button
                      KumoButton.primary(
                        text: 'Mulai Sekarang',
                        width: double.infinity,
                        height: 52,
                        borderRadius: 16,
                        onPressed: _nextPage,
                        iconRight: const Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- SLIDE CONTENT BUILDER (VERTICALLY CENTERED & LEFT-ALIGNED TEXT) ---
  Widget _buildSlideContent(OnboardingSlide slide) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxImgHeight = constraints.maxHeight * 0.44;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Visual Illustration Container (Centered)
                Center(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: maxImgHeight),
                    child: slide.isSvg
                        ? SvgPicture.asset(
                            slide.assetPath,
                            fit: BoxFit.contain,
                            height: maxImgHeight,
                          )
                        : Image.asset(
                            slide.assetPath,
                            fit: BoxFit.contain,
                            height: maxImgHeight,
                            cacheWidth: 600,
                            filterQuality: FilterQuality.medium,
                          ),
                  ),
                ),

                const SizedBox(height: 36),

                // 2. Title (Rata Kiri / Left Aligned)
                Text(
                  slide.title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Description (Rata Kiri / Left Aligned)
                Text(
                  slide.description,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.muted,
                    height: 1.55,
                  ),
                ),

                // Bottom Spacing for floating buttons
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
