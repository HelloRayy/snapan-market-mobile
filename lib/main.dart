import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/constants/supabase_constants.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/screens/home_feed_screen.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/services/follow_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const SnapanMarketApp());
}

class SnapanMarketApp extends StatelessWidget {
  const SnapanMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snaps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SFPro',
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'SFPro',
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

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeFeedScreen(
      onLogout: () async {
        await SupabaseService.instance.signOut();
      },
    );
  }
}
