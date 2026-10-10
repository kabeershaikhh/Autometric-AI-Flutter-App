// Opt-in local render inspection; no live Firebase or user account required.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:autometric_ai/components/web_page_header.dart';
import 'package:autometric_ai/components/web_sidebar.dart';
import 'package:autometric_ai/components/decorated_header.dart';
import 'package:autometric_ai/maintenance/controller.dart';
import 'package:autometric_ai/maintenance/maintenance_page.dart';
import 'package:autometric_ai/maintenance/models.dart';
import 'package:autometric_ai/maintenance/repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final desktop in [false, true]) {
    testWidgets(
      'render maintenance ${desktop ? 'desktop' : 'phone'}',
      (tester) async {
        await tester.runAsync(() async {
          final font = FontLoader('ReviewFont');
          font.addFont(
            Future.value(
              ByteData.sublistView(
                await File('C:/Windows/Fonts/segoeui.ttf').readAsBytes(),
              ),
            ),
          );
          await font.load();
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          await icons.load();
        });
        tester.view.physicalSize = desktop
            ? const Size(1360, 1000)
            : const Size(390, 950);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = MaintenanceRepository(
          'preview',
          firestore: FakeFirebaseFirestore(),
        );
        await repo.user.set({
          'name': 'Abdul kabeer',
          'email': 'preview@example.com',
          'photoBase64': '',
        });
        await repo.saveVehicle({
          'manufacturer': 'Toyota',
          'model': 'Corolla',
          'year': 2018,
          'plate': 'LEA-542',
          'fuel': 'Petrol',
          'odometer': 76258,
          'readingDate': Timestamp.fromDate(
            pakistanDay(DateTime.now()).subtract(const Duration(days: 14)),
          ),
          'weeklyKm': 250.0,
        });
        final controller = MaintenanceController()
          ..repository = repo
          ..loading = false;
        controller.vehicles = await repo.watchVehicles().first;
        addTearDown(controller.dispose);
        final boundary = GlobalKey();
        final page = MaintenancePage(controller: controller);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'ReviewFont',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF7C4DFF),
              ),
            ),
            home: RepaintBoundary(
              key: boundary,
              child: Scaffold(
                body: desktop
                    ? Row(
                        children: [
                          WebSidebar(
                            selectedIndex: 2,
                            onItemTap: (_) {},
                            onLogout: () {},
                            onProfileTap: () {},
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                WebPageHeader(
                                  section: 'Maintenance',
                                  userName: 'Abdul kabeer',
                                  photoBase64: '',
                                  onHome: () {},
                                  onProfile: () {},
                                ),
                                Expanded(child: page),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const DecoratedHeader(
                            title: 'Maintenance',
                            subtitle: 'Care for your vehicle',
                            icon: Icons.build_outlined,
                          ),
                          Expanded(child: page),
                        ],
                      ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> capture(String name) async {
          await tester.runAsync(() async {
            final image =
                await (boundary.currentContext!.findRenderObject()
                        as RenderRepaintBoundary)
                    .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'build/maintenance-review/${desktop ? 'desktop' : 'phone'}-$name.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await capture('garage');
        await tester.ensureVisible(find.text('Toyota Corolla'));
        await tester.tap(find.text('Toyota Corolla'));
        await tester.pumpAndSettle();
        await capture('details');
        await tester.ensureVisible(find.text('Add service / schedule'));
        await tester.tap(find.text('Add service / schedule'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Engine oil change'));
        await tester.pumpAndSettle();
        await capture('service');
        expect(tester.takeException(), isNull);
      },
      skip: Platform.environment['MAINTENANCE_VISUAL_QA'] != '1',
    );
  }
}
