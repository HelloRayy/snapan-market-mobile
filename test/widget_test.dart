import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/main.dart';

void main() {
  testWidgets('Onboarding and Auth smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SnapanMarketApp());

    // Verify Onboarding Slide 0 displays
    expect(find.text('Pusat Jual Beli Warga SMKN 8 Jakarta'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
    expect(find.text('Lanjutkan'), findsOneWidget);

    // Tap Lewati to jump to Auth Screen
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    // Verify Auth Screen displays in Indonesian
    expect(find.text('Masuk\nke Akun Kamu'), findsOneWidget);
    expect(find.text('Nomor WhatsApp / Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
