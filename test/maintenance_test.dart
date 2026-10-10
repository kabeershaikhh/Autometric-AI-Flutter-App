import 'dart:typed_data';
import 'package:autometric_ai/maintenance/models.dart';
import 'package:autometric_ai/maintenance/repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

MaintenanceVehicle car({
  int km = 50000,
  DateTime? reading,
  double? weekly = 250,
  int? previous,
  DateTime? previousDate,
}) => MaintenanceVehicle(
  id: 'car',
  manufacturer: 'Toyota',
  model: 'Corolla',
  plate: '',
  fuel: 'Petrol',
  year: 2018,
  odometer: km,
  readingDate: reading ?? DateTime.utc(2026, 10, 1),
  weeklyKm: weekly,
  previousKm: previous,
  previousDate: previousDate,
);
Map<String, dynamic> carFields() => {
  'manufacturer': 'Toyota',
  'model': 'Corolla',
  'year': 2018,
  'plate': '',
  'fuel': 'Petrol',
  'odometer': 50000,
  'readingDate': Timestamp.fromDate(DateTime.utc(2026, 10, 1)),
  'weeklyKm': 250.0,
};
Map<String, dynamic> serviceFields(DateTime date, int km, List<String> types) =>
    {
      'date': Timestamp.fromDate(date),
      'odometer': km,
      'types': types,
      'costPaisa': 850000,
      'notes': '',
      'workshop': '',
      'plannedOnly': false,
      'intervals': {
        for (final type in types) type: {'km': 5000, 'months': 6},
      },
    };

void main() {
  test('PKR amounts use integer paisa, not floating point', () {
    expect(parsePaisa('8500.10'), 850010);
    expect(costLabel(850010), 'PKR 8,500.10');
    expect(parsePaisa('-1'), null);
    expect(parsePaisa('1.111'), null);
    expect(parsePaisa('NaN'), null);
  });
  test('calendar intervals clamp month-end and Pakistan reminder timezone', () {
    expect(addMonths(DateTime.utc(2024, 1, 31), 1), DateTime.utc(2024, 2, 29));
    expect(addMonths(DateTime.utc(2026, 8, 31), 6), DateTime.utc(2027, 2, 28));
    expect(
      pakistanReminder(DateTime.utc(2026, 10, 1), 9),
      DateTime.utc(2026, 10, 1, 4),
    );
    expect(
      pakistanDay(DateTime.utc(2026, 9, 30, 20)),
      DateTime.utc(2026, 10, 1),
    );
  });
  test('whichever confirmed threshold comes first wins', () {
    final now = DateTime.utc(2026, 10, 8);
    final schedule = MaintenanceSchedule(
      type: 'Oil',
      cycle: '1',
      dueKm: 55000,
      dueDate: DateTime.utc(2026, 10, 7),
    );
    expect(calculateDue(car(), 'oil', schedule, now).status, DueStatus.due);
    expect(
      calculateDue(
        car(km: 55000),
        'oil',
        MaintenanceSchedule(
          type: 'Oil',
          cycle: '1',
          dueKm: 55000,
          dueDate: DateTime.utc(2027),
        ),
        now,
      ).status,
      DueStatus.due,
    );
  });
  test('estimated mileage is distinct, never changes confirmed odometer', () {
    final vehicle = car(weekly: 700);
    final result = calculateDue(
      vehicle,
      'oil',
      const MaintenanceSchedule(type: 'Oil', cycle: '1', dueKm: 50500),
      DateTime.utc(2026, 10, 8),
    );
    expect(result.status, DueStatus.estimated);
    expect(vehicle.odometer, 50000);
    expect(result.forecast, DateTime.utc(2026, 10, 6));
  });
  test('missing and stale readings never invent an estimated date', () {
    const schedule = MaintenanceSchedule(type: 'Oil', cycle: '1', dueKm: 60000);
    expect(
      calculateDue(
        car(weekly: null),
        'oil',
        schedule,
        DateTime.utc(2026, 10, 8),
      ).forecast,
      null,
    );
    expect(
      calculateDue(car(), 'oil', schedule, DateTime.utc(2027, 1, 1)).status,
      DueStatus.needsReading,
    );
  });
  test('measured driving rate uses readings at least seven days apart', () {
    final vehicle = car(
      previous: 49300,
      previousDate: DateTime.utc(2026, 9, 24),
      weekly: 10,
    );
    expect(vehicle.drivingRate(DateTime.utc(2026, 10, 8)), 100);
  });

  group('account-scoped repository', () {
    late FakeFirebaseFirestore db;
    late MaintenanceRepository repo;
    late String id;
    setUp(() async {
      db = FakeFirebaseFirestore();
      repo = MaintenanceRepository('alice', firestore: db);
      await repo.user.set({
        'name': 'Alice',
        'email': 'a@example.com',
        'photoBase64': '',
      });
      await repo.saveVehicle(carFields());
      id = (await repo.vehicles.get()).docs.single.id;
    });
    test(
      'daily mileage updates preserve a useful seven-day baseline',
      () async {
        for (var day = 2; day <= 8; day++) {
          await repo.updateMileage(
            id,
            50000 + (day - 1) * 100,
            DateTime.utc(2026, 10, day),
          );
        }
        final vehicle = MaintenanceVehicle.fromMap(
          id,
          (await repo.vehicles.doc(id).get()).data()!,
        );
        expect(vehicle.drivingRate(DateTime.utc(2026, 10, 8)), 100);
        expect(vehicle.previousKm, 50000);
      },
    );
    test('maintenance does not create or read prediction records', () async {
      expect((await repo.user.collection('evaluations').get()).docs, isEmpty);
      expect(
        (await MaintenanceRepository('bob', firestore: db).vehicles.get()).docs,
        isEmpty,
      );
      expect(
        (await repo.vehicles.get()).docs.single.data().containsKey('base64'),
        false,
      );
      expect(
        (await repo.vehicles.doc(id).collection('attachments').get()).docs,
        isEmpty,
      );
    });
    test('mileages cannot decrease without an explicit correction', () async {
      await expectLater(
        repo.updateMileage(id, 100, DateTime.utc(2026, 10, 8)),
        throwsStateError,
      );
      await repo.updateMileage(
        id,
        100,
        DateTime.utc(2026, 10, 8),
        correction: true,
      );
      final data = (await repo.vehicles.doc(id).get()).data()!;
      expect(data['odometer'], 100);
      expect(data['previousKm'], null);
    });
    test('separate schedules survive a later unrelated service', () async {
      await repo.saveService(
        id,
        serviceFields(DateTime.utc(2026, 10, 2), 50100, ['Oil', 'Air filter']),
        [
          MaintenanceSchedule(type: 'Oil', cycle: '', dueKm: 55100),
          MaintenanceSchedule(type: 'Air filter', cycle: '', dueKm: 60100),
        ],
      );
      await repo.saveService(
        id,
        serviceFields(DateTime.utc(2026, 10, 3), 50200, ['Oil']),
        [MaintenanceSchedule(type: 'Oil', cycle: '', dueKm: 55200)],
      );
      final data = (await repo.vehicles.doc(id).get()).data()!;
      expect(data['schedules']['air%20filter']['dueKm'], 60100);
      expect(data['schedules']['oil']['dueKm'], 55200);
    });
    test(
      'historical service does not roll back current mileage or newer schedule',
      () async {
        await repo.saveService(
          id,
          serviceFields(DateTime.utc(2026, 10, 3), 50200, ['Oil']),
          [MaintenanceSchedule(type: 'Oil', cycle: '', dueKm: 55200)],
        );
        await repo.saveService(
          id,
          serviceFields(DateTime.utc(2026, 9, 1), 48000, ['Oil']),
          [MaintenanceSchedule(type: 'Oil', cycle: '', dueKm: 53000)],
        );
        final data = (await repo.vehicles.doc(id).get()).data()!;
        expect(data['odometer'], 50200);
        expect(data['schedules']['oil']['dueKm'], 55200);
      },
    );
    test(
      'editing older service cannot overwrite the newer service schedule',
      () async {
        await repo.saveService(
          id,
          serviceFields(DateTime.utc(2026, 10, 2), 50100, ['Oil']),
          [MaintenanceSchedule(type: 'Oil', cycle: '', dueKm: 55100)],
        );
        final old =
            (await repo.vehicles.doc(id).collection('serviceRecords').get())
                .docs
                .single;
        await repo.saveService(
          id,
          serviceFields(DateTime.utc(2026, 10, 3), 50200, ['Oil']),
          [MaintenanceSchedule(type: 'Oil', cycle: '', dueKm: 55200)],
        );
        await repo.saveService(
          id,
          serviceFields(DateTime.utc(2026, 10, 2), 50100, ['Oil']),
          [MaintenanceSchedule(type: 'Oil', cycle: '', dueKm: 58100)],
          serviceId: old.id,
        );
        expect(
          (await repo.vehicles.doc(id).get())
              .data()!['schedules']['oil']['dueKm'],
          55200,
        );
      },
    );
    test('vehicle deletion clears all children and account count', () async {
      await repo.saveService(
        id,
        serviceFields(DateTime.utc(2026, 10, 2), 50100, ['Oil']),
        [MaintenanceSchedule(type: 'Oil', cycle: '', dueKm: 55100)],
        receipt: Uint8List.fromList([4, 5]),
      );
      await repo.deleteVehicle(id);
      expect((await repo.vehicles.get()).docs, isEmpty);
      for (final child in [
        'attachments',
        'serviceRecords',
        'odometerReadings',
      ]) {
        expect(
          (await repo.vehicles.doc(id).collection(child).get()).docs,
          isEmpty,
        );
      }
      expect((await repo.user.get()).data()!['maintenanceVehicleCount'], 0);
    });
  });
}
