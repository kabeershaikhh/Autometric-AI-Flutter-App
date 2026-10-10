import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime dateValue(dynamic value) => value is Timestamp
    ? value.toDate().toUtc()
    : DateTime.parse(value as String).toUtc();
DateTime pakistanDay(DateTime date) {
  final pk = date.toUtc().add(const Duration(hours: 5));
  return DateTime.utc(pk.year, pk.month, pk.day);
}

DateTime pakistanReminder(DateTime day, int hour) => DateTime.utc(
  day.year,
  day.month,
  day.day,
  hour,
).subtract(const Duration(hours: 5));
DateTime addMonths(DateTime date, int months) {
  final first = DateTime.utc(date.year, date.month + months);
  final last = DateTime.utc(first.year, first.month + 1, 0).day;
  return DateTime.utc(first.year, first.month, math.min(date.day, last));
}

String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String numberLabel(num value) => value.round().toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);
int? parsePaisa(String text) {
  if (!RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(text.trim())) return null;
  final parts = text.trim().split('.');
  return int.parse(parts[0]) * 100 +
      (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
}

String costLabel(int paisa) =>
    'PKR ${numberLabel(paisa ~/ 100)}${paisa % 100 == 0 ? '' : '.${(paisa % 100).toString().padLeft(2, '0')}'}';

class MaintenanceSchedule {
  final String type;
  final String cycle;
  final int? dueKm;
  final DateTime? dueDate;
  final DateTime? snoozedUntil;
  final bool read;
  const MaintenanceSchedule({
    required this.type,
    required this.cycle,
    this.dueKm,
    this.dueDate,
    this.snoozedUntil,
    this.read = false,
  });
  factory MaintenanceSchedule.fromMap(Map<String, dynamic> data) =>
      MaintenanceSchedule(
        type: data['type'] as String,
        cycle: data['cycle'] as String,
        dueKm: data['dueKm'] as int?,
        dueDate: data['dueDate'] == null ? null : dateValue(data['dueDate']),
        snoozedUntil: data['snoozedUntil'] == null
            ? null
            : dateValue(data['snoozedUntil']),
        read: data['read'] == true,
      );
  Map<String, dynamic> toMap() => {
    'type': type,
    'cycle': cycle,
    'dueKm': dueKm,
    'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
    'snoozedUntil': snoozedUntil == null
        ? null
        : Timestamp.fromDate(snoozedUntil!),
    'read': read,
  };
}

class MaintenanceVehicle {
  final String id, manufacturer, model, plate, fuel;
  final int year, odometer;
  final DateTime readingDate;
  final int? previousKm;
  final DateTime? previousDate;
  final double? weeklyKm;
  final bool archived;
  final Map<String, MaintenanceSchedule> schedules;
  const MaintenanceVehicle({
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.plate,
    required this.fuel,
    required this.year,
    required this.odometer,
    required this.readingDate,
    this.previousKm,
    this.previousDate,
    this.weeklyKm,
    this.archived = false,
    this.schedules = const {},
  });
  String get name => '$manufacturer $model';
  factory MaintenanceVehicle.fromMap(String id, Map<String, dynamic> data) =>
      MaintenanceVehicle(
        id: id,
        manufacturer: data['manufacturer'] as String,
        model: data['model'] as String,
        plate: data['plate'] as String? ?? '',
        fuel: data['fuel'] as String,
        year: data['year'] as int,
        odometer: data['odometer'] as int,
        readingDate: dateValue(data['readingDate']),
        previousKm: data['previousKm'] as int?,
        previousDate: data['previousDate'] == null
            ? null
            : dateValue(data['previousDate']),
        weeklyKm: (data['weeklyKm'] as num?)?.toDouble(),
        archived: data['archived'] == true,
        schedules: (data['schedules'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(
            key,
            MaintenanceSchedule.fromMap(
              Map<String, dynamic>.from(value as Map),
            ),
          ),
        ),
      );
  double? drivingRate(DateTime now) {
    if (pakistanDay(now).difference(readingDate).inDays > 60) return null;
    if (previousKm != null && previousDate != null) {
      final days = readingDate.difference(previousDate!).inDays;
      if (days >= 7 && odometer >= previousKm!) {
        return (odometer - previousKm!) / days;
      }
    }
    return weeklyKm == null || weeklyKm! <= 0 ? null : weeklyKm! / 7;
  }
}

enum DueStatus { upcoming, soon, due, estimated, needsReading }

class MaintenanceDue {
  final MaintenanceVehicle vehicle;
  final String scheduleId;
  final MaintenanceSchedule schedule;
  final DueStatus status;
  final DateTime? forecast;
  const MaintenanceDue(
    this.vehicle,
    this.scheduleId,
    this.schedule,
    this.status,
    this.forecast,
  );
  String get key => '${vehicle.id}:$scheduleId:${schedule.cycle}';
  bool get actionable => status != DueStatus.upcoming;
  String get label => switch (status) {
    DueStatus.upcoming => 'Upcoming',
    DueStatus.soon => 'Due soon',
    DueStatus.due => 'Due / overdue',
    DueStatus.estimated => 'May be due',
    DueStatus.needsReading => 'Update mileage',
  };
}

MaintenanceDue calculateDue(
  MaintenanceVehicle vehicle,
  String id,
  MaintenanceSchedule schedule,
  DateTime now, {
  int leadDays = 7,
}) {
  final today = pakistanDay(now);
  final rate = vehicle.drivingRate(now);
  final forecast = schedule.dueKm != null && rate != null && rate > 0
      ? vehicle.readingDate.add(
          Duration(
            days: math.max(
              0,
              ((schedule.dueKm! - vehicle.odometer) / rate).ceil(),
            ),
          ),
        )
      : null;
  final confirmedDue =
      (schedule.dueKm != null && vehicle.odometer >= schedule.dueKm!) ||
      (schedule.dueDate != null && !schedule.dueDate!.isAfter(today));
  final estimatedDue = forecast != null && !forecast.isAfter(today);
  final soon =
      (schedule.dueDate != null &&
          schedule.dueDate!.difference(today).inDays <= leadDays) ||
      (forecast != null && forecast.difference(today).inDays <= leadDays) ||
      (schedule.dueKm != null && schedule.dueKm! - vehicle.odometer <= 500);
  final stale = schedule.dueKm != null && forecast == null;
  final status = confirmedDue
      ? DueStatus.due
      : estimatedDue
      ? DueStatus.estimated
      : soon
      ? DueStatus.soon
      : stale
      ? DueStatus.needsReading
      : DueStatus.upcoming;
  return MaintenanceDue(vehicle, id, schedule, status, forecast);
}

class ReminderPreferences {
  final bool enabled;
  final int hour, leadDays;
  const ReminderPreferences({
    this.enabled = false,
    this.hour = 9,
    this.leadDays = 7,
  });
  factory ReminderPreferences.fromMap(Map<String, dynamic> map) =>
      ReminderPreferences(
        enabled: map['enabled'] == true,
        hour: map['hour'] as int? ?? 9,
        leadDays: map['leadDays'] as int? ?? 7,
      );
  Map<String, dynamic> toMap() => {
    'enabled': enabled,
    'hour': hour,
    'leadDays': leadDays,
  };
}
