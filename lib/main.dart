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
import 'package:snapan_market/core/services/theme_service.dart';
import 'package:snapan_market/core/theme/snaps_theme.dart';
import 'package:snapan_market/features/feed/screens/home_feed_screen.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/features/splash/screens/splash_screen.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';
import 'package:snapan_market/core/services/student_registry_service.dart';

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

  // Initialize student registry dataset for demo NIS lookup
  unawaited(StudentRegistryService.instance.init());

  // Initialize isolated direct messages cache & account-switch listener (SNAPS-42)
  DirectMessagesService.instance.init();

  // Clean obsolete OTA APK installers in background to reclaim disk space (SNAPS-36)
  unawaited(AppUpdateService.instance.cleanObsoleteInstallers());

  // Initialize theme service from persistent storage
  await ThemeService.instance.init();

  runApp(const SnapanMarketApp());
}

class SnapanMarketApp extends StatelessWidget {
  const SnapanMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          title: 'Snaps',
          debugShowCheckedModeBanner: false,
          theme: SnapsTheme.lightTheme,
          darkTheme: SnapsTheme.darkTheme,
          themeMode: ThemeService.instance.materialThemeMode,
          home: const AppRoot(),
        );
      },
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
    return ValueListenableBuilder<bool>(
      valueListenable: SuspensionService.instance.accountDeletedNotifier,
      builder: (context, isAccountDeleted, _) {
        if (isAccountDeleted) {
          return AuthScreen(
            initialAccountDeletedNotice: true,
            onBack: () {
              SuspensionService.instance.clearAccountDeleted();
            },
            onSuccess: () {
              SuspensionService.instance.clearAccountDeleted();
            },
          );
        }

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
      },
    );
  }
}
