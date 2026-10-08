import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/features/auth/components/auth_register_tab.dart';
import 'package:snapan_market/features/auth/components/auth_text_field.dart';

void main() {
  testWidgets('AuthRegisterTab displays Display Name (Opsional) label and hint', (tester) async {
    final nisController = TextEditingController();
    final displayNameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AuthRegisterTab(
              nisController: nisController,
              onStudentSelected: (_) {},
              displayNameController: displayNameController,
              usernameController: usernameController,
              passwordController: passwordController,
              showPassword: false,
              onTogglePassword: () {},
              agreedTerms: false,
              onToggleAgreedTerms: () {},
              isSubmitting: false,
              onSubmit: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Display Name (Opsional)'), findsOneWidget);
    final displayNameField = tester.widget<AuthInputField>(
      find.ancestor(
        of: find.text('Display Name (Opsional)'),
        matching: find.byType(AuthInputField),
      ),
    );
    expect(displayNameField.hint, 'Masukkan nama tampilan kamu');
  });
}
