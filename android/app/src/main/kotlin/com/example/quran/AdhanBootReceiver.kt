package com.example.quran

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log

/**
 * Listens for BOOT_COMPLETED events to reschedule adhan alarms
 * after device reboot. Without this, all AlarmManager alarms are
 * lost when the device is powered off.
 *
 * On boot, it reads the saved alarm data from SharedPreferences
 * and re-registers all future adhan alarms with AlarmManager.
 */
class AdhanBootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AdhanBootReceiver"
        const val PREFS_NAME = "adhan_alarms_prefs"
        const val KEY_ALARMS_JSON = "scheduled_alarms_json"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != "android.intent.action.QUICKBOOT_POWERON" &&
            intent.action != "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            return
        }

        Log.i(TAG, "📱 Device boot detected. Rescheduling adhan alarms...")

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val alarmsJson = prefs.getString(KEY_ALARMS_JSON, null)

        if (alarmsJson.isNullOrEmpty()) {
            Log.d(TAG, "No saved alarms found. Nothing to reschedule.")
            return
        }

        try {
            AdhanAlarmScheduler.rescheduleFromJson(context, alarmsJson)
            Log.i(TAG, "✅ Adhan alarms rescheduled successfully after boot")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to reschedule alarms after boot: ${e.message}", e)
        }
    }
}
