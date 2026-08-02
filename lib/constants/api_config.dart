import 'package:flutter/foundation.dart';

class ApiConfig {
  /// The base URL for the FastAPI backend.
  /// 
  /// Since you are testing on a PHYSICAL device via USB debugging, 
  /// 10.0.2.2 (Emulator) will NOT work.
  ///
  /// Solution 1 (Recommended): Run `adb reverse tcp:8000 tcp:8000` in your terminal.
  /// This forwards the device's localhost to your PC's localhost over the USB cable.
  /// After running that command, you can just use "http://127.0.0.1:8000".
  ///
  /// Solution 2: Replace the IP below with your computer's Local IPv4 address 
  /// (e.g. "http://192.168.1.5:8000") and ensure both devices are on the same Wi-Fi.
  
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    } else {
      // Set to 127.0.0.1, assuming you run `adb reverse tcp:8000 tcp:8000`
      // Otherwise, change this to your PC's local IP address like "http://192.168.1.100:8000"
      return "http://127.0.0.1:8000";
    }
  }
}
