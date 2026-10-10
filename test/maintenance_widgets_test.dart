import 'package:autometric_ai/maintenance/controller.dart';
import 'package:autometric_ai/maintenance/attachments.dart';
import 'package:autometric_ai/constants/app_colors.dart';
import 'package:autometric_ai/maintenance/maintenance_page.dart';
import 'package:autometric_ai/maintenance/models.dart';
import 'package:autometric_ai/maintenance/repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [const Size(360, 900), const Size(1360, 900)]) {
    testWidgets('garage, car details and service form at ${size.width}px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = FakeFirebaseFirestore();
      final repo = MaintenanceRepository('user', firestore: db);
      await repo.user.set({
        'name': 'User',
        'email': 'u@example.com',
        'photoBase64': '',
      });
      await repo.saveVehicle({
        'manufacturer': 'Toyota',
        'model': 'Corolla',
        'plate': 'LEA-123',
        'fuel': 'Petrol',
        'year': 2018,
        'odometer': 50000,
        'readingDate': Timestamp.fromDate(
          pakistanDay(DateTime.now()).subtract(const Duration(days: 30)),
        ),
        'weeklyKm': 250.0,
      });
      final controller = MaintenanceController()
        ..repository = repo
        ..loading = false;
      controller.vehicles = (await repo.watchVehicles().first);
      addTearDown(controller.dispose);
      final maintenanceKey = GlobalKey<MaintenancePageState>();
      await tester.pumpWidget(
        MaterialApp(
          home: MaintenancePage(key: maintenanceKey, controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Toyota Corolla'), findsOneWidget);
      expect(find.text('50,000 km'), findsOneWidget);
      final summaryBottom = tester.getBottomLeft(find.text('Cars')).dy;
      expect(
        tester.getBottomLeft(find.text('Due / overdue')).dy,
        closeTo(summaryBottom, 0.01),
      );
      expect(
        tester.getBottomLeft(find.text('Due soon')).dy,
        closeTo(summaryBottom, 0.01),
      );
      expect(tester.takeException(), isNull);
      // The title/body of the reminder widget opens it, not only the arrow.
      await tester.tap(find.text('Maintenance reminders'));
      await tester.pumpAndSettle();
      expect(find.text('Stay one service ahead'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
      // AppShell sends Android system-back to the nested maintenance navigator.
      maintenanceKey.currentState!.goBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Toyota Corolla'));
      await tester.pumpAndSettle();
      expect(find.text('Vehicle details'), findsOneWidget);
      expect(tester.widget<AppBar>(find.byType(AppBar)).toolbarHeight, 48);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(AttachmentImage), findsNothing);
      expect(find.text('Update mileage'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.text('Edit car'), findsNothing);
      await tester.tap(find.byTooltip('Car options'));
      await tester.pumpAndSettle();
      expect(find.text('Archive car'), findsOneWidget);
      expect(find.text('Delete car'), findsOneWidget);
      await tester.tap(find.text('Edit car'));
      await tester.pumpAndSettle();
      expect(find.text('Your car, your garage'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      final yearField = find.widgetWithText(TextFormField, 'Model year');
      await tester.ensureVisible(yearField);
      await tester.enterText(yearField, '2019');
      final plateField = find.widgetWithText(
        TextFormField,
        'License plate (optional)',
      );
      await tester.ensureVisible(plateField);
      await tester.enterText(plateField, 'LEA-456');
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final updatedCars = (await repo.vehicles.get()).docs;
      expect(updatedCars.length, 1);
      expect(updatedCars.single.data()['year'], 2019);
      expect(updatedCars.single.data()['plate'], 'LEA-456');
      // This fixture does not subscribe; production's garage stream refreshes it.
      controller.vehicles = await repo.watchVehicles().first;
      controller.notifyListeners();
      await tester.pumpAndSettle();
      expect(find.text('2019'), findsOneWidget);
      expect(find.text('LEA-456'), findsOneWidget);
      await tester.ensureVisible(find.text('Add service / schedule'));
      await tester.tap(find.text('Add service / schedule'));
      await tester.pumpAndSettle();
      final customButton = tester.widget<IconButton>(
        // The mobile service form shares the same compact back bar.
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton && widget.tooltip == 'Add custom type',
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        customButton.style!.backgroundColor!.resolve({}),
        AppColors.primary,
      );
      await tester.tap(find.text('Engine oil change'));
      await tester.pumpAndSettle();
      final distance = find.widgetWithText(TextFormField, 'After distance');
      await tester.ensureVisible(distance);
      await tester.enterText(distance, '5000');
      final months = find.widgetWithText(TextFormField, 'After time');
      await tester.ensureVisible(months);
      await tester.enterText(months, '6');
      final save = find.text('Save');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      final vehicle = (await repo.vehicles.get()).docs.single;
      expect(
        (await vehicle.reference.collection('serviceRecords').get())
            .docs
            .length,
        1,
      );
      expect(
        vehicle.data()['schedules']['engine%20oil%20change']['dueKm'],
        55000,
      );
      expect(find.text('PKR 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
