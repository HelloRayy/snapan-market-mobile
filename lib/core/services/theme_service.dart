import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Theme Mode Enum: system default, forced light, or forced dark.
enum AppThemeMode {
  system,
  light,
  dark,
}

/// Service managing dynamic Light & Dark themes across Snaps Mobile.
/// Persists user preference into SharedPreferences and provides smooth
/// global notifications to `MaterialApp` and theme-aware widgets.
class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const String _prefKey = 'snaps_theme_mode';

  AppThemeMode _currentMode = AppThemeMode.system;
  bool _isInitialized = false;

  AppThemeMode get themeMode => _currentMode;
  bool get isInitialized => _isInitialized;

  ThemeMode get materialThemeMode {
    switch (_currentMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Initialize theme mode from SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefKey);
      if (savedMode == 'light') {
        _currentMode = AppThemeMode.light;
      } else if (savedMode == 'dark') {
        _currentMode = AppThemeMode.dark;
      } else {
        _currentMode = AppThemeMode.system;
      }
    } catch (_) {
      _currentMode = AppThemeMode.system;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Update and persist theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_currentMode == mode) return;
    _currentMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String value = 'system';
      if (mode == AppThemeMode.light) value = 'light';
      if (mode == AppThemeMode.dark) value = 'dark';
      await prefs.setString(_prefKey, value);
    } catch (_) {}
  }

  /// Helper to check if currently dark based on context brightness
  bool isDark(BuildContext context) {
    if (_currentMode == AppThemeMode.dark) return true;
    if (_currentMode == AppThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }
}
