package com.example.autometric_ai

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.content.Intent

class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent) { super.onNewIntent(intent); setIntent(intent) }
    private var permissionResult: MethodChannel.Result? = null
    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "autometric/maintenance").setMethodCallHandler { call, result ->
            when (call.method) {
                "permission" -> {
                    if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                        if (permissionResult != null) result.success(false)
                        else { permissionResult = result; requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 701) }
                    } else result.success(MaintenanceAlarms.allowed(this))
                }
                "replace" -> {
                    try {
                        MaintenanceAlarms.replace(this, call.argument<String>("uid")!!, call.argument<List<Map<String, Any>>>("reminders") ?: emptyList())
                        result.success(null)
                    } catch (e: Exception) { result.error("schedule", "Unable to schedule maintenance reminders", null) }
                }
                "clear" -> { MaintenanceAlarms.clear(this); result.success(null) }
                "openedVehicle" -> {
                    result.success(intent.getStringExtra("maintenanceVehicle"))
                    intent.removeExtra("maintenanceVehicle")
                }
                else -> result.notImplemented()
            }
        }
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 701) { permissionResult?.success(MaintenanceAlarms.allowed(this)); permissionResult = null }
    }
}
