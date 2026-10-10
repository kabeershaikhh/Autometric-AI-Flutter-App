import 'dart:convert';
import 'dart:ui' as ui;
import 'package:autometric_ai/components/car_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('bundled car SVG contains decodable logo artwork', () async {
    final svg = await rootBundle.loadString('assets/Car.svg');
    final encoded = RegExp(
      r'data:image/png;base64,([^"\s]+)',
    ).firstMatch(svg)!.group(1)!;
    final codec = await ui.instantiateImageCodec(base64Decode(encoded));
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 100);
    expect(frame.image.height, 100);
    final pixels = (await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    var visiblePixels = 0;
    for (var i = 3; i < pixels.lengthInBytes; i += 4) {
      if (pixels.getUint8(i) > 0) visiblePixels++;
    }
    expect(visiblePixels, greaterThan(0));
    frame.image.dispose();
    codec.dispose();
  });
  testWidgets('car logo renders an image instead of an empty tile', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CarLogo())));
    expect(find.byType(Image), findsOneWidget);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
