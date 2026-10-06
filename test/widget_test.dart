import 'package:autometric_ai/auth/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome page offers authentication and guest access', (
    WidgetTester tester,
  ) async {
    var continuedAsGuest = false;

    await tester.pumpWidget(
      MaterialApp(
        home: WelcomePage(onContinueAsGuest: () => continuedAsGuest = true),
      ),
    );

    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Continue without an account'), findsOneWidget);

    final guestAction = find.text('Continue without an account');
    await tester.ensureVisible(guestAction);
    await tester.tap(guestAction);
    expect(continuedAsGuest, isTrue);
  });
}
