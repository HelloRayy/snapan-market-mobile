import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snapan_market/features/onboarding/models/onboarding_slide.dart';

class OnboardingHeroVisual extends StatelessWidget {
  final OnboardingSlide slide;
  final double maxHeight;

  const OnboardingHeroVisual({
    super.key,
    required this.slide,
    this.maxHeight = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      width: double.infinity,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 4 / 3.8,
        child: slide.isSvg
            ? SvgPicture.asset(
                slide.assetPath,
                fit: BoxFit.contain,
              )
            : Image.asset(
                slide.assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
      ),
    );
  }
}
