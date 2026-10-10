import 'package:autometric_ai/components/web_feature_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('web page heroes share dimensions and content alignment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const headers = [
      WebFeatureHeader(
        badge: 'AI Market Valuation',
        badgeIcon: Icons.auto_awesome,
        title: 'Predict Vehicle Market Price',
        subtitle:
            'Enter specification parameters to generate accurate price estimates using Machine Learning models.',
        icon: Icons.analytics_rounded,
      ),
      WebFeatureHeader(
        badge: 'Saved Predictions',
        badgeIcon: Icons.history_edu,
        title: 'Evaluation History',
        subtitle:
            'View and manage your saved car market valuation predictions.',
        icon: Icons.history_rounded,
      ),
      WebFeatureHeader(
        badge: 'Vehicle Care',
        badgeIcon: Icons.build_rounded,
        title: 'Your garage, under control',
        subtitle: 'Track services, plan ahead and keep every car cared for.',
        icon: Icons.build_outlined,
      ),
    ];
    Size? expectedSize;
    Offset? expectedTitlePosition;
    for (final header in headers) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: 920, child: header),
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byType(WebFeatureHeader));
      final position = tester.getTopLeft(find.text(header.title));
      expectedSize ??= size;
      expectedTitlePosition ??= position;
      expect(size, expectedSize);
      expect(position, expectedTitlePosition);
      expect(
        tester.getTopLeft(find.byIcon(header.icon)).dx,
        greaterThan(position.dx),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
