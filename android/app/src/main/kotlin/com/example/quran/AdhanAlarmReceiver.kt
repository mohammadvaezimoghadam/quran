package com.example.quran

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log

/**
 * Receives exact alarm broadcasts at the precise moment of each adhan.
 * Immediately acquires a WakeLock to prevent the CPU from sleeping,
 * then starts AdhanForegroundService to play the adhan audio.
 *
 * This runs in native Android without any Flutter engine overhead,
 * ensuring 100% reliability even in deep Doze mode at Fajr time.
 */
class AdhanAlarmReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AdhanAlarmReceiver"
        private const val WAKELOCK_TAG = "Quran::AdhanAlarmWakeLock"
        private const val WAKELOCK_TIMEOUT_MS = 60_000L // 1 minute max

        // Static WakeLock so the service can release it after starting foreground
        @Volatile
        var wakeLock: PowerManager.WakeLock? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        val prayerName = intent.getStringExtra(AdhanForegroundService.EXTRA_PRAYER_NAME) ?: "unknown"
        val moezzinAsset = intent.getStringExtra(AdhanForegroundService.EXTRA_MOEZZIN_ASSET) ?: ""
        val moezzinFilePath = intent.getStringExtra(AdhanForegroundService.EXTRA_MOEZZIN_FILE_PATH)
        val alarmId = intent.getIntExtra(AdhanForegroundService.EXTRA_ALARM_ID, -1)

        val volumeLevel = intent.getIntExtra(AdhanForegroundService.EXTRA_VOLUME_LEVEL, 100)
        val vibrate = intent.getBooleanExtra(AdhanForegroundService.EXTRA_VIBRATE, true)
        val playInSilentMode = intent.getBooleanExtra(AdhanForegroundService.EXTRA_PLAY_IN_SILENT_MODE, true)
        val ascendingVolume = intent.getBooleanExtra(AdhanForegroundService.EXTRA_ASCENDING_VOLUME, false)
        val wakeScreen = intent.getBooleanExtra(AdhanForegroundService.EXTRA_WAKE_SCREEN, true)

        Log.i(TAG, "⏰ Adhan alarm received! Prayer: $prayerName, Moezzin: $moezzinAsset, Path: $moezzinFilePath, AlarmId: $alarmId")

        // 1. Acquire WakeLock immediately to prevent CPU from sleeping
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wl = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            WAKELOCK_TAG
        ).apply {
            setReferenceCounted(false)
            acquire(WAKELOCK_TIMEOUT_MS)
        }
        wakeLock = wl
        Log.d(TAG, "WakeLock acquired")

        // 2. Start AdhanForegroundService
        val serviceIntent = Intent(context, AdhanForegroundService::class.java).apply {
            action = AdhanForegroundService.ACTION_PLAY
            putExtra(AdhanForegroundService.EXTRA_PRAYER_NAME, prayerName)
            putExtra(AdhanForegroundService.EXTRA_MOEZZIN_ASSET, moezzinAsset)
            putExtra(AdhanForegroundService.EXTRA_MOEZZIN_FILE_PATH, moezzinFilePath)
            putExtra(AdhanForegroundService.EXTRA_ALARM_ID, alarmId)
            putExtra(AdhanForegroundService.EXTRA_VOLUME_LEVEL, volumeLevel)
            putExtra(AdhanForegroundService.EXTRA_VIBRATE, vibrate)
            putExtra(AdhanForegroundService.EXTRA_PLAY_IN_SILENT_MODE, playInSilentMode)
            putExtra(AdhanForegroundService.EXTRA_ASCENDING_VOLUME, ascendingVolume)
            putExtra(AdhanForegroundService.EXTRA_WAKE_SCREEN, wakeScreen)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            Log.i(TAG, "AdhanForegroundService start command sent successfully")
        } catch (e: Exception) {
            Log.e(TAG, "CRITICAL: Failed to start AdhanForegroundService: ${e.message}", e)
            // Release WakeLock if service failed to start
            if (wl.isHeld) wl.release()
            wakeLock = null
        }
    }
}
