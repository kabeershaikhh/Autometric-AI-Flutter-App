import 'package:autometric_ai/components/predict_dropdown.dart';
import 'package:autometric_ai/pages/predictPageLayouts/android_predict_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('enabled and disabled dropdowns have a short single-line hint', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              for (final disabled in [false, true])
                Expanded(
                  child: PredictDropdown<String>(
                    label: 'Transmission',
                    items: const ['Automatic'],
                    selectedValue: null,
                    disabled: disabled,
                    onChanged: (_) {},
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    final fields = tester
        .widgetList<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>),
        )
        .toList();
    expect(find.text('Select'), findsNWidgets(2));
    for (final hint in tester.widgetList<Text>(find.text('Select'))) {
      expect(hint.data, 'Select');
      expect(hint.maxLines, 1);
    }
    expect(fields.first.onChanged, isNotNull);
    expect(fields.last.onChanged, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android matches web section grouping at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final mileage = TextEditingController();
    addTearDown(mileage.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: AndroidPredictLayout(
          isLoadingOptions: false,
          options: const {},
          isPredicting: false,
          onPredict: () {},
          mileageController: mileage,
          onBrandChanged: (_) {},
          onModelChanged: (_) {},
          onVariantChanged: (_) {},
          onModelYearChanged: (_) {},
          onEngineCcChanged: (_) {},
          onTransmissionChanged: (_) {},
          onBodyTypeChanged: (_) {},
          onColorChanged: (_) {},
          onAssemblyChanged: (_) {},
          onCityChanged: (_) {},
          filteredYears: const [2020],
          filteredEngines: const [1500],
          filteredTransmissions: const ['Automatic'],
          filteredAssemblies: const ['Local'],
          isBodyTypeLocked: false,
        ),
      ),
    );
    expect(find.text('Vehicle Identity'), findsOneWidget);
    expect(find.text('Technical Specifications'), findsOneWidget);
    expect(find.text('Location & Mileage'), findsOneWidget);
    expect(find.text('Model Year'), findsOneWidget);
    final body = tester.getTopLeft(find.text('Body Type')).dy;
    final color = tester.getTopLeft(find.text('Color')).dy;
    final location = tester.getTopLeft(find.text('Location & Mileage')).dy;
    expect(body, lessThan(location));
    expect(color, lessThan(location));
    expect(find.text('Performance & Specifications'), findsNothing);
    expect(find.text('Body & Location'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
