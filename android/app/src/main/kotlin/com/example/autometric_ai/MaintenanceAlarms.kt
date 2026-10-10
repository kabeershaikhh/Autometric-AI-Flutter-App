package com.example.autometric_ai

import android.Manifest
import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar
import java.util.TimeZone

/** Inexact OS alarms: no always-running service, GPS tracking or server billing. */
object MaintenanceAlarms {
    private const val channel = "maintenance"
    private fun prefs(context: Context) = context.getSharedPreferences("maintenance_reminders", Context.MODE_PRIVATE)
    private fun pending(context: Context, index: Int): PendingIntent = PendingIntent.getBroadcast(context, index,
        Intent(context, MaintenanceAlarmReceiver::class.java).putExtra("index", index), PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    fun allowed(context: Context): Boolean =
        (Build.VERSION.SDK_INT < 33 || context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) &&
        (Build.VERSION.SDK_INT < 24 || context.getSystemService(NotificationManager::class.java).areNotificationsEnabled())
    private fun cancel(context: Context) {
        val manager = context.getSystemService(AlarmManager::class.java)
        val indices = JSONArray(prefs(context).getString("scheduled", "[]") ?: "[]")
        for (index in 0 until indices.length()) manager.cancel(pending(context, indices.getInt(index)))
        context.getSystemService(NotificationManager::class.java).cancelAll()
    }
    fun clear(context: Context) { cancel(context); prefs(context).edit().clear().apply() }
    fun replace(context: Context, uid: String, jobs: List<Map<String, Any>>) {
        if (prefs(context).getString("uid", null) != uid) clear(context) else cancel(context)
        val array = JSONArray()
        jobs.take(1000).forEach { array.put(JSONObject(it)) }
        prefs(context).edit().putString("uid", uid).putString("jobs", array.toString()).apply()
        restore(context)
    }
    private fun deliveryKey(job: JSONObject) = "${job.getString("id")}:${job.getLong("at")}"
    fun restore(context: Context) {
        val store = prefs(context)
        if (store.getString("uid", null) == null || !allowed(context)) return
        val jobs = JSONArray(store.getString("jobs", "[]") ?: "[]")
        val delivered = JSONObject(store.getString("delivered", "{}") ?: "{}")
        val scheduled = JSONArray()
        for (index in 0 until jobs.length()) {
            val job = jobs.getJSONObject(index)
            if (delivered.has(deliveryKey(job))) continue
            if (scheduled.length() >= 64) break
            var trigger = job.getLong("at")
            if (trigger < System.currentTimeMillis()) {
                val calendar = Calendar.getInstance(TimeZone.getTimeZone("Asia/Karachi"))
                calendar.set(Calendar.HOUR_OF_DAY, job.optInt("hour", 9)); calendar.set(Calendar.MINUTE, 0); calendar.set(Calendar.SECOND, 0)
                if (calendar.timeInMillis <= System.currentTimeMillis()) calendar.add(Calendar.DAY_OF_YEAR, 1)
                trigger = calendar.timeInMillis
            }
            context.getSystemService(AlarmManager::class.java).setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, trigger, pending(context, index))
            scheduled.put(index)
        }
        store.edit().putString("scheduled", scheduled.toString()).apply()
    }
    fun deliver(context: Context, index: Int) {
        val store = prefs(context)
        if (store.getString("uid", null) == null || !allowed(context)) return
        val jobs = JSONArray(store.getString("jobs", "[]") ?: "[]")
        if (index < 0 || index >= jobs.length()) return
        val job = jobs.getJSONObject(index)
        if (job.getLong("at") > System.currentTimeMillis()) return
        val sent = JSONObject(store.getString("delivered", "{}") ?: "{}")
        val key = deliveryKey(job)
        if (sent.has(key)) return
        val now = Calendar.getInstance(TimeZone.getTimeZone("Asia/Karachi"))
        if (now.get(Calendar.HOUR_OF_DAY) < 8 || now.get(Calendar.HOUR_OF_DAY) > 20) { restore(context); return }
        sent.put(key, System.currentTimeMillis())
        val keys = sent.keys().asSequence().toList()
        val active = (0 until jobs.length()).map { deliveryKey(jobs.getJSONObject(it)) }.toSet()
        for (old in keys) if (!active.contains(old) && sent.getLong(old) < System.currentTimeMillis() - 90L * 86400000) sent.remove(old)
        store.edit().putString("delivered", sent.toString()).apply()
        val manager = context.getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26) manager.createNotificationChannel(NotificationChannel(channel, "Maintenance reminders", NotificationManager.IMPORTANCE_DEFAULT))
        val launch = Intent(context, MainActivity::class.java).putExtra("maintenanceVehicle", job.getString("vehicleId"))
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val click = PendingIntent.getActivity(context, index, launch, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(context, channel) else Notification.Builder(context)
        manager.notify(index, builder.setSmallIcon(R.drawable.ic_maintenance_notification).setContentTitle("AutoMetric • Maintenance")
            .setContentText(job.getString("body")).setStyle(Notification.BigTextStyle().bigText(job.getString("body")))
            .setContentIntent(click).setAutoCancel(true).setVisibility(Notification.VISIBILITY_PRIVATE).build())
        restore(context) // Fill the next slot without creating more than 64 pending alarms.
    }
}
class MaintenanceAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == Intent.ACTION_MY_PACKAGE_REPLACED || intent.action == Intent.ACTION_TIME_CHANGED || intent.action == Intent.ACTION_TIMEZONE_CHANGED) {
            MaintenanceAlarms.restore(context)
        } else MaintenanceAlarms.deliver(context, intent.getIntExtra("index", 0))
    }
}
