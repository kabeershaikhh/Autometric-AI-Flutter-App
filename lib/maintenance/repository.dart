import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

Map<String, dynamic> _readingBaseline(
  Map<String, dynamic> old,
  DateTime date, {
  bool correction = false,
}) {
  if (correction) return {'previousKm': null, 'previousDate': null};
  final anchorDate = old['previousDate'];
  final keepAnchor =
      anchorDate != null &&
      old['previousKm'] != null &&
      date.difference(dateValue(anchorDate)).inDays <= 60;
  return {
    'previousKm': keepAnchor ? old['previousKm'] : old['odometer'],
    'previousDate': keepAnchor ? anchorDate : old['readingDate'],
  };
}

/// Account-scoped and deliberately independent from price evaluations.
class MaintenanceRepository {
  final String uid;
  final FirebaseFirestore db;
  MaintenanceRepository(this.uid, {FirebaseFirestore? firestore})
    : db = firestore ?? FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> get user =>
      db.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> get vehicles =>
      user.collection('maintenanceVehicles');
  DocumentReference<Map<String, dynamic>> get preferences =>
      user.collection('maintenanceSettings').doc('reminders');
  Stream<List<MaintenanceVehicle>> watchVehicles() => vehicles
      .orderBy('createdAt')
      .limit(50)
      .snapshots(includeMetadataChanges: true)
      .where((snapshot) => !snapshot.metadata.hasPendingWrites)
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => MaintenanceVehicle.fromMap(doc.id, doc.data()))
            .toList(),
      );

  Future<void> saveVehicle(
    Map<String, dynamic> fields, {
    MaintenanceVehicle? existing,
  }) async {
    final ref = existing == null ? vehicles.doc() : vehicles.doc(existing.id);
    final reading = ref.collection('odometerReadings').doc();
    await db.runTransaction((tx) async {
      final account = await tx.get(user);
      final current = existing == null ? null : await tx.get(ref);
      final count = account.data()?['maintenanceVehicleCount'] as int? ?? 0;
      if (existing == null && count >= 50) {
        throw StateError(
          'Your garage is limited to 50 cars to keep Spark usage predictable.',
        );
      }
      if (existing != null && (current == null || !current.exists)) {
        throw StateError('This vehicle no longer exists.');
      }
      final old = current?.data();
      if (old?['deleting'] == true) {
        throw StateError('This car is being deleted.');
      }
      if (old != null &&
          (fields['odometer'] as int) < (old['odometer'] as int)) {
        throw StateError(
          'Use Update mileage with correction enabled to lower an odometer reading.',
        );
      }
      final changed =
          old == null ||
          old['odometer'] != fields['odometer'] ||
          dateValue(old['readingDate']) != dateValue(fields['readingDate']);
      tx.set(ref, {
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
        if (existing == null) ...{
          'createdAt': FieldValue.serverTimestamp(),
          'archived': false,
          'schedules': <String, dynamic>{},
        },
        if (changed && old != null) ...{
          ..._readingBaseline(old, dateValue(fields['readingDate'])),
        },
      }, SetOptions(merge: true));
      if (existing == null) {
        tx.set(user, {
          'maintenanceVehicleCount': count + 1,
        }, SetOptions(merge: true));
      }
      if (changed) {
        tx.set(reading, {
          'km': fields['odometer'],
          'date': fields['readingDate'],
          'correction': false,
        });
      }
    });
  }

  Future<void> updateMileage(
    String vehicleId,
    int km,
    DateTime date, {
    bool correction = false,
  }) async {
    final ref = vehicles.doc(vehicleId);
    final reading = ref.collection('odometerReadings').doc();
    await db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) throw StateError('Vehicle no longer exists.');
      final data = doc.data()!;
      if (data['deleting'] == true) {
        throw StateError('This car is being deleted.');
      }
      if (date.isBefore(dateValue(data['readingDate']))) {
        throw StateError('The reading date cannot precede the latest reading.');
      }
      if (km < (data['odometer'] as int) && !correction) {
        throw StateError('Enable odometer correction to lower this reading.');
      }
      tx.update(ref, {
        'odometer': km,
        'readingDate': Timestamp.fromDate(date),
        ..._readingBaseline(data, date, correction: correction),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(reading, {
        'km': km,
        'date': Timestamp.fromDate(date),
        'correction': correction,
      });
    });
  }

  Future<void> saveService(
    String vehicleId,
    Map<String, dynamic> fields,
    List<MaintenanceSchedule> schedules, {
    String? serviceId,
    Uint8List? receipt,
    bool removeReceipt = false,
  }) async {
    final ref = vehicles.doc(vehicleId);
    final record = serviceId == null
        ? ref.collection('serviceRecords').doc()
        : ref.collection('serviceRecords').doc(serviceId);
    final receiptRef = ref
        .collection('attachments')
        .doc('receipt_${record.id}');
    await db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final oldRecord = serviceId == null ? null : await tx.get(record);
      if (!doc.exists) throw StateError('Vehicle no longer exists.');
      if (serviceId != null && !oldRecord!.exists) {
        throw StateError('Service no longer exists.');
      }
      final data = doc.data()!;
      if (data['archived'] == true) {
        throw StateError('Restore this car before recording a service.');
      }
      final current = Map<String, dynamic>.from(
        data['schedules'] as Map? ?? {},
      );
      // Remove only schedules sourced from the edited record. Newer services win.
      final blocked = <String>{};
      if (oldRecord != null) {
        for (final type in oldRecord.data()!['types'] as List) {
          final key = Uri.encodeComponent((type as String).toLowerCase());
          if (current[key] != null && current[key]['cycle'] != record.id) {
            blocked.add(key);
          }
        }
        current.removeWhere((_, value) => value['cycle'] == record.id);
      }
      final serviceDate = dateValue(fields['date']);
      if (data['deleting'] == true) {
        throw StateError('This car is being deleted.');
      }
      for (final schedule in schedules) {
        final key = Uri.encodeComponent(schedule.type.toLowerCase());
        if (blocked.contains(key)) continue;
        final previous = current[key];
        if (previous != null &&
            dateValue(previous['serviceDate']).isAfter(serviceDate)) {
          continue;
        }
        if (schedule.dueKm == null && schedule.dueDate == null) {
          current.remove(key);
          continue;
        }
        current[key] = {
          ...MaintenanceSchedule(
            type: schedule.type,
            cycle: record.id,
            dueKm: schedule.dueKm,
            dueDate: schedule.dueDate,
          ).toMap(),
          'serviceDate': fields['date'],
        };
      }
      if (current.length > 20) {
        throw StateError('A car supports up to 20 active service types.');
      }
      final km = fields['odometer'] as int;
      final reading = dateValue(data['readingDate']);
      tx.update(ref, {
        'schedules': current,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!serviceDate.isBefore(reading) &&
            km > (data['odometer'] as int)) ...{
          'odometer': km,
          'readingDate': fields['date'],
          ..._readingBaseline(data, serviceDate),
        },
      });
      if (!serviceDate.isBefore(reading) && km > (data['odometer'] as int)) {
        tx.set(ref.collection('odometerReadings').doc(record.id), {
          'km': km,
          'date': fields['date'],
          'correction': false,
        });
      }
      tx.set(record, {
        ...fields,
        'hasReceipt':
            receipt != null ||
            (!removeReceipt && oldRecord?.data()?['hasReceipt'] == true),
        'updatedAt': FieldValue.serverTimestamp(),
        if (serviceId == null) 'createdAt': FieldValue.serverTimestamp(),
      });
      if (receipt != null) {
        tx.set(receiptRef, {
          'base64': base64Encode(receipt),
          'bytes': receipt.length,
        });
      }
      if (removeReceipt) tx.delete(receiptRef);
    });
  }

  Future<void> changeSchedule(
    MaintenanceDue due, {
    bool? read,
    DateTime? snooze,
  }) async {
    final ref = vehicles.doc(due.vehicle.id);
    await db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final schedules = Map<String, dynamic>.from(
        doc.data()?['schedules'] as Map? ?? {},
      );
      if (schedules[due.scheduleId]?['cycle'] != due.schedule.cycle) return;
      schedules[due.scheduleId] = {
        ...Map<String, dynamic>.from(schedules[due.scheduleId] as Map),
        if (read != null) 'read': read,
        'snoozedUntil': snooze == null ? null : Timestamp.fromDate(snooze),
      };
      tx.update(ref, {'schedules': schedules});
    });
  }

  Future<void> archive(MaintenanceVehicle vehicle) async {
    final ref = vehicles.doc(vehicle.id);
    await db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) throw StateError('Vehicle no longer exists.');
      if (doc.data()!['deleting'] == true) {
        throw StateError(
          'Deletion was started for this car. Retry Delete to finish cleanup.',
        );
      }
      tx.update(ref, {'archived': doc.data()!['archived'] != true});
    });
  }

  Future<void> deleteVehicle(String id) async {
    final ref = vehicles.doc(id);
    // Soft archive first to cancel reminders; retrying deletion is safe.
    await ref.update({'archived': true, 'deleting': true});
    for (final child in ['serviceRecords', 'odometerReadings', 'attachments']) {
      while (true) {
        final page = await ref.collection(child).limit(100).get();
        if (page.docs.isEmpty) break;
        final batch = db.batch();
        for (final doc in page.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
    await db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final account = await tx.get(user);
      if (!doc.exists) return;
      tx.delete(ref);
      tx.set(user, {
        'maintenanceVehicleCount':
            ((account.data()?['maintenanceVehicleCount'] as int? ?? 1) - 1)
                .clamp(0, 50),
      }, SetOptions(merge: true));
    });
  }

  Future<Uint8List?> attachment(String vehicleId, String id) async {
    final data =
        (await vehicles.doc(vehicleId).collection('attachments').doc(id).get())
            .data();
    return data == null ? null : base64Decode(data['base64'] as String);
  }
}
