import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapan_market/core/services/theme_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/theme/snaps_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dark Mode & Threads WDS Tokens Compliance Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeService initializes properly and can switch modes', () async {
      final themeService = ThemeService.instance;
      await themeService.init();

      expect(themeService.themeMode, equals(AppThemeMode.system));

      await themeService.setThemeMode(AppThemeMode.dark);
      expect(themeService.themeMode, equals(AppThemeMode.dark));
      expect(themeService.materialThemeMode, equals(ThemeMode.dark));

      await themeService.setThemeMode(AppThemeMode.light);
      expect(themeService.themeMode, equals(AppThemeMode.light));
      expect(themeService.materialThemeMode, equals(ThemeMode.light));
    });

    test('SnapsTheme.darkTheme matches Meta Threads WDS specification', () {
      final dark = SnapsTheme.darkTheme;

      expect(dark.scaffoldBackgroundColor, equals(const Color(0xFF000000)));
      expect(dark.cardColor, equals(const Color(0xFF161717)));
      expect(dark.colorScheme.surface, equals(const Color(0xFF161717)));
      expect(dark.colorScheme.onSurface, equals(const Color(0xFFF8FAFC)));
      expect(dark.dividerTheme.color, equals(const Color(0x1AFFFFFF)));
    });

    testWidgets('AppColors adaptive tokens resolve correctly in light and dark contexts', (tester) async {
      Color? canvasLight;
      Color? surfaceLight;
      Color? textLight;
      Color? dividerLight;

      Color? canvasDark;
      Color? surfaceDark;
      Color? textDark;
      Color? dividerDark;

      await tester.pumpWidget(
        MaterialApp(
          theme: SnapsTheme.lightTheme,
          darkTheme: SnapsTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              canvasLight = AppColors.adaptiveCanvas(context);
              surfaceLight = AppColors.adaptiveSurface(context);
              textLight = AppColors.adaptiveText(context);
              dividerLight = AppColors.adaptiveDivider(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(canvasLight, equals(AppColors.canvas));
      expect(surfaceLight, equals(Colors.white));
      expect(textLight, equals(AppColors.ink));
      expect(dividerLight, equals(AppColors.separator));

      await tester.pumpWidget(
        MaterialApp(
          key: const ValueKey('dark'),
          theme: SnapsTheme.darkTheme,
          home: Builder(
            builder: (context) {
              canvasDark = AppColors.adaptiveCanvas(context);
              surfaceDark = AppColors.adaptiveSurface(context);
              textDark = AppColors.adaptiveText(context);
              dividerDark = AppColors.adaptiveDivider(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(canvasDark, equals(AppColors.darkCanvas));
      expect(surfaceDark, equals(AppColors.darkSurface));
      expect(textDark, equals(AppColors.darkTextPrimary));
      expect(dividerDark, equals(AppColors.darkDivider));
    });
  });
}
