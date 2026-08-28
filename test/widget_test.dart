// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:snapan_market/main.dart';

void main() {
  testWidgets('Hello World screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SnapanMarketApp());

    expect(find.text('Hello World!'), findsOneWidget);
    expect(find.text('Snapan Market'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Tap Me to Test (+1)'));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
