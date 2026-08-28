import 'package:flutter/material.dart';
import 'package:snapan_market/core/components/kumo_button.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/onboarding/components/onboarding_dot_indicators.dart';
import 'package:snapan_market/features/onboarding/components/onboarding_slide_view.dart';
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
            itemCount: onboardingSlides.length + 1, // 4 content slides + 1 auth slide
            itemBuilder: (context, index) {
              if (index < onboardingSlides.length) {
                return OnboardingSlideView(slide: onboardingSlides[index]);
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
                    OnboardingDotIndicators(
                      count: onboardingSlides.length,
                      activeIndex: _currentPage,
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
}
