import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:snapan_market/core/constants/supabase_constants.dart';
import 'package:snapan_market/core/navigation/navigation_service.dart';
import 'package:snapan_market/core/services/app_update_service.dart';
import 'package:snapan_market/core/services/global_notification_service.dart';
import 'package:snapan_market/core/services/suspension_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/screens/home_feed_screen.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/features/splash/screens/splash_screen.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase.initializeApp warning: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  if (Supabase.instance.client.auth.currentUser != null) {
    FollowService.instance.loadFollowings();
  }

  // Initialize global notification service & FCM token immediately
  unawaited(GlobalNotificationService.instance.init());

  // Initialize background suspension listeners (SNAPS-16)
  SuspensionService.instance.init();

  // Initialize isolated direct messages cache & account-switch listener (SNAPS-42)
  DirectMessagesService.instance.init();

  // Clean obsolete OTA APK installers in background to reclaim disk space (SNAPS-36)
  unawaited(AppUpdateService.instance.cleanObsoleteInstallers());

  runApp(const SnapanMarketApp());
}

class SnapanMarketApp extends StatelessWidget {
  const SnapanMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Snaps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SFPro',
        fontFamilyFallback: const ['AppleColorEmoji'],
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'SFPro',
          fontFamilyFallback: const ['AppleColorEmoji'],
        ),
        primaryTextTheme: ThemeData.light().primaryTextTheme.apply(
          fontFamily: 'SFPro',
          fontFamilyFallback: const ['AppleColorEmoji'],
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(
            fontFamily: 'SFPro',
            fontFamilyFallback: ['AppleColorEmoji'],
            color: Color(0xFF64748B),
          ),
          labelStyle: TextStyle(
            fontFamily: 'SFPro',
            fontFamilyFallback: ['AppleColorEmoji'],
            color: Color(0xFF64748B),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          insetPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 96.0),
          backgroundColor: const Color(0xFF1E293B),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0x14FFFFFF), width: 0.8),
          ),
        ),
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

class _AppRootState extends State<AppRoot> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleSplashCompleted() {
    _fadeController.forward().then((_) {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: SuspensionService.instance.suspensionNotifier,
      builder: (context, suspensionInfo, child) {
        if (suspensionInfo != null) {
          return AuthScreen(
            initialSuspensionInfo: suspensionInfo,
            onBack: () {
              SuspensionService.instance.clear();
            },
            onSuccess: () {
              SuspensionService.instance.clear();
            },
          );
        }

        return Stack(
          children: [
            HomeFeedScreen(
              onLogout: () async {
                await SupabaseService.instance.signOut();
              },
            ),
            if (_showSplash)
              FadeTransition(
                opacity: _fadeAnimation,
                child: SplashScreen(
                  onCompleted: _handleSplashCompleted,
                ),
              ),
          ],
        );
      },
    );
  }
}
