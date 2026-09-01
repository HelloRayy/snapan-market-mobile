import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/main.dart';

void main() {
  testWidgets('SnapanMarketApp uses SFPro font family in theme', (WidgetTester tester) async {
    await tester.pumpWidget(const SnapanMarketApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    final ThemeData theme = app.theme!;

    expect(theme.textTheme.bodyMedium?.fontFamily, 'SFPro');
    expect(theme.textTheme.titleLarge?.fontFamily, 'SFPro');
    expect(theme.textTheme.labelMedium?.fontFamily, 'SFPro');
  });
}
