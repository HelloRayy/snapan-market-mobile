import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/onboarding/models/onboarding_slide.dart';

class OnboardingSlideView extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingSlideView({
    super.key,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
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
                // 1. Top Visual Illustration (Centered)
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

                // 2. Title (Rata Kiri)
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

                // 3. Description (Rata Kiri)
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
