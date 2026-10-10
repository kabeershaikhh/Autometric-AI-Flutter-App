import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'repository.dart';
import 'platform_notifications.dart' as platform;

/// One account subscription, one garage stream and one preferences stream.
class MaintenanceController extends ChangeNotifier {
  StreamSubscription? _garage, _settings;
  Timer? _clock;
  MaintenanceRepository? repository;
  List<MaintenanceVehicle> vehicles = [];
  ReminderPreferences preferences = const ReminderPreferences();
  String? error, notificationError;
  bool loading = true,
      _disposed = false,
      _hasGarage = false,
      _hasSettings = false;
  String? _fingerprint;
  Future<void> _platformWork = Future.value();
  int _generation = 0;
  String? _uid;
  void start(String? uid) {
    connect(uid);
    // Local arithmetic only: no polling Firestore and no tight background loops.
    _clock = Timer.periodic(const Duration(hours: 1), (_) => refresh());
  }

  void connect(String? uid) {
    if (_generation > 0 && uid == _uid) return;
    _uid = uid;
    repository = null;
    vehicles = [];
    _hasGarage = false;
    _hasSettings = false;
    loading = uid != null;
    _account(uid, ++_generation);
  }

  Future<void> _account(String? uid, int generation) async {
    await _garage?.cancel();
    await _settings?.cancel();
    if (_disposed || generation != _generation) return;
    repository = uid == null ? null : MaintenanceRepository(uid);
    vehicles = [];
    preferences = const ReminderPreferences();
    _hasGarage = false;
    _hasSettings = false;
    _fingerprint = null;
    error = null;
    loading = uid != null;
    if (uid == null) _queue(() => platform.clearNotifications());
    notifyListeners();
    if (uid == null) return;
    final repo = repository!;
    _garage = repo.watchVehicles().listen(
      (data) {
        if (repository != repo) return;
        vehicles = data;
        loading = false;
        error = null;
        _hasGarage = true;
        refresh();
      },
      onError: (Object e) {
        if (repository == repo) {
          loading = false;
          error =
              'Unable to load your garage. Check your connection and Firestore rules.';
          notifyListeners();
        }
      },
    );
    _settings = repo.preferences
        .snapshots(includeMetadataChanges: true)
        .where((doc) => !doc.metadata.hasPendingWrites)
        .listen(
          (doc) {
            if (repository != repo) return;
            preferences = ReminderPreferences.fromMap(doc.data() ?? {});
            _hasSettings = true;
            refresh();
          },
          onError: (Object e) {
            if (repository == repo) {
              notificationError = 'Reminder preferences could not be loaded.';
              notifyListeners();
            }
          },
        );
  }

  List<MaintenanceDue> get reminders {
    final now = DateTime.now().toUtc();
    final result = [
      for (final car in vehicles.where((v) => !v.archived))
        for (final entry in car.schedules.entries)
          calculateDue(
            car,
            entry.key,
            entry.value,
            now,
            leadDays: preferences.leadDays,
          ),
    ];
    result.sort((a, b) {
      final priority = {
        DueStatus.due: 0,
        DueStatus.estimated: 1,
        DueStatus.soon: 2,
        DueStatus.needsReading: 3,
        DueStatus.upcoming: 4,
      };
      return priority[a.status]!.compareTo(priority[b.status]!);
    });
    return result;
  }

  void _queue(Future<void> Function() action) {
    _platformWork = _platformWork.then((_) => action()).catchError((Object e) {
      if (!_disposed) {
        notificationError =
            'Device notifications are unavailable. In-app reminders still work.';
        notifyListeners();
      }
    });
  }

  void refresh() {
    if (_disposed) return;
    notifyListeners();
    if (!_hasGarage || !_hasSettings || repository == null) return;
    final uid = repository!.uid;
    final jobs = <Map<String, dynamic>>[];
    for (final due in reminders) {
      final schedule = due.schedule;
      DateTime? day = schedule.dueDate;
      if (due.forecast != null &&
          (day == null || due.forecast!.isBefore(day))) {
        day = due.forecast;
      }
      if (schedule.dueKm != null && due.vehicle.odometer >= schedule.dueKm!) {
        if (day == null || due.vehicle.readingDate.isBefore(day)) {
          day = due.vehicle.readingDate;
        }
      }
      if (day == null && due.status == DueStatus.soon) {
        day = due.vehicle.readingDate;
      }
      if (due.status == DueStatus.needsReading) {
        day = due.vehicle.readingDate.add(const Duration(days: 30));
      }
      if (day == null) continue;
      var at = pakistanReminder(
        day.subtract(Duration(days: preferences.leadDays)),
        preferences.hour,
      );
      // A fixed cycle anchor lets Android/web suppress repeated overdue alerts.
      if (schedule.snoozedUntil != null && schedule.snoozedUntil!.isAfter(at)) {
        at = schedule.snoozedUntil!;
      }
      jobs.add({
        'id': due.key,
        'vehicleId': due.vehicle.id,
        'at': at.millisecondsSinceEpoch,
        'hour': preferences.hour,
        'body': due.status == DueStatus.needsReading
            ? 'Update your car mileage to improve maintenance estimates.'
            : 'Check ${schedule.type.toLowerCase()} service status. Mileage-based dates are estimates.',
      });
    }
    jobs.sort((a, b) => (a['at'] as int).compareTo(b['at'] as int));
    final bounded = preferences.enabled ? jobs : <Map<String, dynamic>>[];
    final fingerprint = jsonEncode([uid, bounded]);
    // Web reevaluates foreground deadlines; Android avoids redundant alarm writes.
    if (_fingerprint != fingerprint || kIsWeb) {
      _fingerprint = fingerprint;
      _queue(() async {
        if (!_disposed && repository?.uid == uid) {
          await platform.replaceNotifications(uid, bounded);
        }
      });
    }
  }

  Future<bool> enable(bool enabled, {int? hour, int? leadDays}) async {
    final repo = repository;
    if (repo == null) return false;
    if (enabled && !await platform.enableNotifications()) return false;
    if (repository != repo) return false;
    await repo.preferences.set(
      ReminderPreferences(
        enabled: enabled,
        hour: hour ?? preferences.hour,
        leadDays: leadDays ?? preferences.leadDays,
      ).toMap(),
    );
    return true;
  }

  Future<void> savePreferences(int hour, int leadDays) async {
    await repository?.preferences.set(
      ReminderPreferences(
        enabled: preferences.enabled,
        hour: hour,
        leadDays: leadDays,
      ).toMap(),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _garage?.cancel();
    _settings?.cancel();
    _clock?.cancel();
    super.dispose();
  }
}
