import 'package:autometric_ai/auth/welcome_page.dart';
import 'package:autometric_ai/components/auth_web_spacing.dart';
import 'package:autometric_ai/pages/login_page.dart';
import 'package:autometric_ai/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(1200, 700),
    const Size(1658, 847),
    const Size(1920, 700),
  ]) {
    testWidgets('Login and register branding is visible at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final page in const <Widget>[
        Scaffold(body: WebLoginLayout(onTap: null)),
        Scaffold(body: WebRegisterLayout(onTap: null)),
      ]) {
        await tester.pumpWidget(MaterialApp(home: page));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final label in [
          'AutoMetric AI',
          'Smart Car Price Estimation',
          'AI-Powered Estimation',
          'Smart Car Maintenance Management',
          'Save Evaluations Efficiently',
        ]) {
          final rect = tester.getRect(find.text(label));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(size.height));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
        }
        final logo = tester.getRect(find.byType(Image).first);
        expect(logo.top, greaterThanOrEqualTo(0));
        expect(logo.bottom, lessThanOrEqualTo(size.height));
      }
    });
  }

  for (final width in [950.0, 1200.0, 1920.0]) {
    testWidgets('Auth web columns match welcome at $width pixels', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final previousErrorHandler = FlutterError.onError;
      String? errorDetails;
      FlutterError.onError = (details) {
        errorDetails = details.toString();
        previousErrorHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousErrorHandler);

      final cards = <Rect>[];
      for (final page in <Widget>[
        WelcomePage(onContinueAsGuest: () {}),
        const Scaffold(body: WebLoginLayout(onTap: null)),
        const Scaffold(body: WebRegisterLayout(onTap: null)),
      ]) {
        await tester.pumpWidget(MaterialApp(home: page));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: errorDetails);
        final card = find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.color == Colors.white &&
              decoration.borderRadius == BorderRadius.circular(32);
        });
        expect(card, findsOneWidget);
        cards.add(tester.getRect(card));
      }
      final expectedWidth = AuthWebSpacing.panelWidth(
        width,
        AuthWebSpacing.cardMaxWidth,
      );
      for (final card in cards) {
        expect(card.width, closeTo(expectedWidth, 0.01));
        expect(card.left, closeTo(cards.first.left, 0.01));
        expect(card.right, lessThanOrEqualTo(width - 64));
      }
    });
  }
}
