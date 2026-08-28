import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/screens/home_feed_screen.dart';
import 'package:snapan_market/features/onboarding/screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SnapanMarketApp());
}

class SnapanMarketApp extends StatelessWidget {
  const SnapanMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snapan Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: '.SF Pro Text',
        fontFamilyFallback: const [
          '-apple-system',
          'SF Pro Display',
          'SF Pro Text',
          'San Francisco',
          'Helvetica Neue',
          'Roboto',
        ],
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _isOnboarded = false;

  @override
  Widget build(BuildContext context) {
    if (!_isOnboarded) {
      return OnboardingScreen(
        onComplete: () {
          setState(() {
            _isOnboarded = true;
          });
        },
      );
    }

    return HomeFeedScreen(
      onLogout: () {
        setState(() {
          _isOnboarded = false;
        });
      },
    );
  }
}
