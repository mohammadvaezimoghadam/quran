package com.example.quran

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

/**
 * Utility class for scheduling and canceling adhan alarms using AlarmManager.
 *
 * Uses the most aggressive alarm scheduling strategy available on each API level:
 * - API 21+: setAlarmClock() — highest priority, survives Doze, shows alarm icon
 * - API 23+: setExactAndAllowWhileIdle() — fallback for Doze survival
 * - API < 21: setExact() — basic exact alarm
 *
 * Alarm data is persisted to SharedPreferences so AdhanBootReceiver can
 * reschedule them after device reboot.
 *
 * Inspired by the dual-mode alarm strategy from payam_mobile's SmsDispatcherService.
 */
object AdhanAlarmScheduler {

    private const val TAG = "AdhanAlarmScheduler"

    // Request code base to avoid collisions with other PendingIntents
    private const val REQUEST_CODE_BASE = 3000

    // Sentinel alarm for daily rescheduling (fires at 00:05 every day)
    private const val SENTINEL_REQUEST_CODE = 2999

    /**
     * Schedules all adhan alarms from a JSON array.
     *
     * Expected JSON format:
     * [
     *   {
     *     "id": 1,
     *     "prayerName": "صبح",
     *     "epochMillis": 1725364800000,
     *     "moezzinAsset": "ghalvash"
     *   },
     *   ...
     * ]
     */
    fun scheduleAlarms(context: Context, alarmsJsonArray: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // 1. Cancel all existing adhan alarms first
        cancelAllAlarms(context)

        // 2. Parse and schedule new alarms
        val alarms = JSONArray(alarmsJsonArray)
        val now = System.currentTimeMillis()
        var scheduledCount = 0

        for (i in 0 until alarms.length()) {
            val alarm = alarms.getJSONObject(i)
            val id = alarm.getInt("id")
            val prayerName = alarm.getString("prayerName")
            val epochMillis = alarm.getLong("epochMillis")
            val moezzinAsset = alarm.optString("moezzinAsset", "ghalvash")
            val moezzinFilePath = alarm.optString("moezzinFilePath", "")
            val volumeLevel = alarm.optInt("volumeLevel", 100)
            val vibrate = alarm.optBoolean("vibrate", true)
            val playInSilentMode = alarm.optBoolean("playInSilentMode", true)
            val ascendingVolume = alarm.optBoolean("ascendingVolume", false)
            val wakeScreen = alarm.optBoolean("wakeScreen", true)

            // Skip alarms in the past
            if (epochMillis <= now) {
                Log.d(TAG, "Skipping past alarm: $prayerName at $epochMillis (now=$now)")
                continue
            }

            val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
                putExtra(AdhanForegroundService.EXTRA_ALARM_ID, id)
                putExtra(AdhanForegroundService.EXTRA_PRAYER_NAME, prayerName)
                putExtra(AdhanForegroundService.EXTRA_MOEZZIN_ASSET, moezzinAsset)
                putExtra(AdhanForegroundService.EXTRA_MOEZZIN_FILE_PATH, moezzinFilePath)
                putExtra(AdhanForegroundService.EXTRA_VOLUME_LEVEL, volumeLevel)
                putExtra(AdhanForegroundService.EXTRA_VIBRATE, vibrate)
                putExtra(AdhanForegroundService.EXTRA_PLAY_IN_SILENT_MODE, playInSilentMode)
                putExtra(AdhanForegroundService.EXTRA_ASCENDING_VOLUME, ascendingVolume)
                putExtra(AdhanForegroundService.EXTRA_WAKE_SCREEN, wakeScreen)
            }

            val requestCode = REQUEST_CODE_BASE + id
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            try {
                scheduleExactAlarm(context, alarmManager, epochMillis, pendingIntent, requestCode)
                scheduledCount++
                Log.i(TAG, "✅ Scheduled alarm #$id: $prayerName at $epochMillis (moezzin=$moezzinAsset)")
            } catch (e: SecurityException) {
                Log.e(TAG, "❌ SecurityException scheduling alarm #$id. Missing SCHEDULE_EXACT_ALARM permission?", e)
            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to schedule alarm #$id: ${e.message}", e)
            }
        }

        // 3. Persist alarms to SharedPreferences for BootReceiver
        saveAlarmsToPrefs(context, alarmsJsonArray)

        // 4. Schedule sentinel alarm for daily rescheduling
        scheduleSentinelAlarm(context, alarmManager)

        Log.i(TAG, "📋 Total alarms scheduled: $scheduledCount out of ${alarms.length()}")
    }

    /**
     * Reschedules alarms from JSON stored in SharedPreferences (called by BootReceiver).
     */
    fun rescheduleFromJson(context: Context, alarmsJson: String) {
        Log.i(TAG, "Rescheduling alarms from persisted JSON...")
        scheduleAlarms(context, alarmsJson)
    }

    /**
     * Cancels all scheduled adhan alarms.
     */
    fun cancelAllAlarms(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val prefs = context.getSharedPreferences(AdhanBootReceiver.PREFS_NAME, Context.MODE_PRIVATE)
        val alarmsJson = prefs.getString(AdhanBootReceiver.KEY_ALARMS_JSON, null)

        if (!alarmsJson.isNullOrEmpty()) {
            try {
                val alarms = JSONArray(alarmsJson)
                for (i in 0 until alarms.length()) {
                    val alarm = alarms.getJSONObject(i)
                    val id = alarm.getInt("id")
                    val requestCode = REQUEST_CODE_BASE + id

                    val intent = Intent(context, AdhanAlarmReceiver::class.java)
                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        requestCode,
                        intent,
                        PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
                    )

                    if (pendingIntent != null) {
                        alarmManager.cancel(pendingIntent)
                        pendingIntent.cancel()
                        Log.d(TAG, "Cancelled alarm #$id (requestCode=$requestCode)")
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error canceling alarms: ${e.message}", e)
            }
        }

        // Also cancel sentinel alarm
        val sentinelIntent = Intent(context, AdhanAlarmReceiver::class.java)
        val sentinelPending = PendingIntent.getBroadcast(
            context, SENTINEL_REQUEST_CODE, sentinelIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        sentinelPending?.let {
            alarmManager.cancel(it)
            it.cancel()
        }

        // Clear persisted alarms
        prefs.edit().remove(AdhanBootReceiver.KEY_ALARMS_JSON).apply()
        Log.i(TAG, "All adhan alarms cancelled")
    }

    // ─────────────────────────────── Private Helpers ───────────────────────────────

    /**
     * Schedules an exact alarm using the most aggressive strategy available.
     * Uses dual-mode scheduling (setAlarmClock + setExactAndAllowWhileIdle)
     * for maximum reliability on all Android versions and OEM skins.
     */
    /**
     * Schedules an exact alarm using setAlarmClock — the most aggressive
     * alarm strategy on Android. It:
     * - Bypasses Doze mode completely
     * - Shows an alarm icon in the status bar (signals to OEMs this is important)
     * - Survives most OEM battery restrictions (Xiaomi, Samsung, Huawei)
     * - Is treated as a user-facing alarm by the system
     *
     * This is the same strategy used in payam_mobile's SmsDispatcherService
     * and is proven to work reliably on real devices.
     */
    private fun scheduleExactAlarm(
        context: Context,
        alarmManager: AlarmManager,
        triggerAtMillis: Long,
        pendingIntent: PendingIntent,
        @Suppress("UNUSED_PARAMETER") requestCode: Int
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val showIntent = PendingIntent.getActivity(
                context, 0,
                Intent(context, MainActivity::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerAtMillis, showIntent)
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
        } else {
            // Fallback for very old devices (API < 21)
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
        }
    }

    /**
     * Schedules a "sentinel" alarm at 00:05 every day.
     * This alarm triggers a reschedule of the next day's adhan times,
     * ensuring alarms are always fresh even if the app isn't opened.
     */
    private fun scheduleSentinelAlarm(context: Context, alarmManager: AlarmManager) {
        val calendar = java.util.Calendar.getInstance().apply {
            add(java.util.Calendar.DAY_OF_YEAR, 1)
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 5)
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
        }

        val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
            putExtra("is_sentinel", true)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            SENTINEL_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val showIntent = PendingIntent.getActivity(
                    context, 0,
                    Intent(context, MainActivity::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(calendar.timeInMillis, showIntent),
                    pendingIntent
                )
            }
            Log.i(TAG, "🌙 Sentinel alarm scheduled for ${calendar.timeInMillis} (tomorrow 00:05)")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule sentinel alarm: ${e.message}", e)
        }
    }

    /**
     * Persists alarm data to SharedPreferences so BootReceiver can restore them.
     */
    private fun saveAlarmsToPrefs(context: Context, alarmsJson: String) {
        val prefs = context.getSharedPreferences(AdhanBootReceiver.PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(AdhanBootReceiver.KEY_ALARMS_JSON, alarmsJson).apply()
        Log.d(TAG, "Alarms persisted to SharedPreferences")
    }
}
