import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Centralized Theme Configuration for Snaps Mobile
/// Implements Meta Threads (Project Barcelona WDS) Dark and Light Themes.
class SnapsTheme {
  SnapsTheme._();

  // ---------------------------------------------------------------------------
  // LIGHT THEME (Clean Scandinavian Minimalist White)
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'SFPro',
      fontFamilyFallback: const ['AppleColorEmoji'],
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'SFPro',
        fontFamilyFallback: const ['AppleColorEmoji'],
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
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
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.canvas,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
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
    );
  }

  // ---------------------------------------------------------------------------
  // DARK THEME (Meta Threads Barcelona WDS OLED Pure Black + Layered Charcoal)
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'SFPro',
      fontFamilyFallback: const ['AppleColorEmoji'],
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'SFPro',
        fontFamilyFallback: const ['AppleColorEmoji'],
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      primaryTextTheme: ThemeData.dark().primaryTextTheme.apply(
        fontFamily: 'SFPro',
        fontFamilyFallback: const ['AppleColorEmoji'],
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(
          fontFamily: 'SFPro',
          fontFamilyFallback: ['AppleColorEmoji'],
          color: AppColors.darkTextDisabled,
        ),
        labelStyle: TextStyle(
          fontFamily: 'SFPro',
          fontFamilyFallback: ['AppleColorEmoji'],
          color: AppColors.darkTextSecondary,
        ),
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.darkPrimary,
        onSecondary: Colors.white,
        error: Color(0xFFFB5061),
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkCanvas,
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.darkCanvas,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.darkCanvas,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 96.0),
        backgroundColor: AppColors.darkSurfaceElevated,
        contentTextStyle: const TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 0.8,
        space: 1.0,
      ),
    );
  }
}
