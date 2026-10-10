import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

const _channel = MethodChannel('autometric/maintenance');
bool get supported => defaultTargetPlatform == TargetPlatform.android;
Future<bool> enableNotifications() async =>
    supported && (await _channel.invokeMethod<bool>('permission') ?? false);
Future<void> replaceNotifications(
  String uid,
  List<Map<String, dynamic>> reminders,
) async {
  if (supported) {
    await _channel.invokeMethod('replace', {
      'uid': uid,
      'reminders': reminders,
    });
  }
}

Future<void> clearNotifications() async {
  if (supported) await _channel.invokeMethod('clear');
}

Future<String?> notificationVehicle() async =>
    supported ? _channel.invokeMethod<String>('openedVehicle') : null;
