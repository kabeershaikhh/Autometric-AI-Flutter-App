import 'dart:js_interop';
import 'dart:convert';

@JS('maintenanceNotifications.supported')
external bool get supported;
@JS('maintenanceNotifications.enable')
external JSPromise<JSBoolean> _enable();
@JS('maintenanceNotifications.reconcile')
external void _reconcile(JSString uid, JSString json);
@JS('maintenanceNotifications.clear')
external void _clear();
@JS('maintenanceNotifications.openedVehicle')
external JSString? _openedVehicle();

Future<bool> enableNotifications() async =>
    supported && (await _enable().toDart).toDart;
Future<void> replaceNotifications(
  String uid,
  List<Map<String, dynamic>> reminders,
) async {
  // JSON passed by the coordinator through a small web-only helper.
  _reconcile(uid.toJS, jsonEncode(reminders).toJS);
}

Future<void> clearNotifications() async => _clear();
Future<String?> notificationVehicle() async => _openedVehicle()?.toDart;
