package com.example.quran

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.Vibrator
import android.animation.ValueAnimator
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import android.widget.RemoteViews

/**
 * Foreground Service that plays the adhan audio file.
 *
 * Key design decisions (inspired by payam_mobile SmsDispatcherService):
 * - Uses MediaPlayer directly (not Flutter's just_audio) because this runs
 *   without the Flutter engine when the app is killed.
 * - Maintains a persistent notification with a "Stop" action.
 * - Holds a WakeLock during playback to prevent CPU sleep.
 * - Automatically stops after playback completes.
 * - Audio files are stored in res/raw/ (not Flutter assets) for native access.
 */
class AdhanForegroundService : Service() {

    companion object {
        private const val TAG = "AdhanForegroundService"
        private const val NOTIFICATION_ID = 2001
        private const val CHANNEL_ID = "adhan_playback_channel_v2"

        const val ACTION_PLAY = "com.example.quran.PLAY_ADHAN"
        const val ACTION_STOP = "com.example.quran.STOP_ADHAN"

        const val EXTRA_PRAYER_NAME = "prayer_name"
        const val EXTRA_MOEZZIN_ASSET = "moezzin_asset"
        const val EXTRA_MOEZZIN_FILE_PATH = "moezzin_file_path"
        const val EXTRA_ALARM_ID = "alarm_id"
        const val EXTRA_VOLUME_LEVEL = "volume_level"
        const val EXTRA_VIBRATE = "vibrate"
        const val EXTRA_PLAY_IN_SILENT_MODE = "play_in_silent_mode"
        const val EXTRA_ASCENDING_VOLUME = "ascending_volume"
        const val EXTRA_WAKE_SCREEN = "wake_screen"

        // Map of moezzin IDs to resource names in res/raw/
        // When you add new adhan audio files, add their mapping here.
        private val MOEZZIN_RESOURCES = mapOf(
            "ghalvash" to "adhan_ghalvash",
            "moazzenzadeh" to "adhan_moazzenzadeh",
            "sobhi" to "adhan_sobhi"
        )

        // Default moezzin if the requested one is not found
        private const val DEFAULT_MOEZZIN = "ghalvash"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var vibrator: Vibrator? = null
    private var volumeAnimator: ValueAnimator? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service onCreate")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        Log.d(TAG, "onStartCommand: action=$action")

        when (action) {
            ACTION_STOP -> {
                Log.i(TAG, "Stop action received. Stopping adhan playback.")
                stopAdhan()
                return START_NOT_STICKY
            }
            ACTION_PLAY -> {
                val prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "اذان"
                val moezzinAsset = intent.getStringExtra(EXTRA_MOEZZIN_ASSET) ?: DEFAULT_MOEZZIN
                val moezzinFilePath = intent.getStringExtra(EXTRA_MOEZZIN_FILE_PATH)
                
                val volumeLevel = intent.getIntExtra(EXTRA_VOLUME_LEVEL, 100)
                val vibrate = intent.getBooleanExtra(EXTRA_VIBRATE, true)
                val playInSilentMode = intent.getBooleanExtra(EXTRA_PLAY_IN_SILENT_MODE, true)
                val ascendingVolume = intent.getBooleanExtra(EXTRA_ASCENDING_VOLUME, false)
                val wakeScreen = intent.getBooleanExtra(EXTRA_WAKE_SCREEN, true)

                Log.i(TAG, "🔊 Starting adhan playback: prayer=$prayerName, moezzin=$moezzinAsset, path=$moezzinFilePath")

                // Check silent mode
                if (!playInSilentMode) {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val ringerMode = audioManager.ringerMode
                    if (ringerMode == AudioManager.RINGER_MODE_SILENT || ringerMode == AudioManager.RINGER_MODE_VIBRATE) {
                        Log.i(TAG, "Silent mode detected and playInSilentMode is false. Skipping adhan.")
                        stopSelf()
                        return START_NOT_STICKY
                    }
                }

                // Start foreground immediately (must be within 5 seconds of startForegroundService)
                startForegroundCompat(prayerName, wakeScreen)

                // Play the adhan audio
                playAdhan(moezzinAsset, moezzinFilePath, prayerName, volumeLevel, ascendingVolume)
                
                if (vibrate) {
                    startVibration()
                }
            }
            else -> {
                // Service restarted by system with null intent
                Log.w(TAG, "Service started with unknown action. Stopping.")
                stopSelf()
                return START_NOT_STICKY
            }
        }

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        Log.d(TAG, "Service onDestroy")
        releaseResources()
        super.onDestroy()
    }

    // ─────────────────────────────── Audio Playback ───────────────────────────────

    private fun playAdhan(moezzinId: String, moezzinFilePath: String?, prayerName: String, volumeLevel: Int, ascendingVolume: Boolean) {
        // Release any previous player
        mediaPlayer?.release()
        mediaPlayer = null

        // Acquire WakeLock for the duration of playback
        acquireWakeLock()

        try {
            mediaPlayer = MediaPlayer().apply {
                // Set audio attributes for alarm/adhan (plays over silent mode on some devices)
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )

                // Try to load from absolute file path first
                var loaded = false
                var targetFilePath = moezzinFilePath
                if (targetFilePath.isNullOrEmpty()) {
                    val appDocsFile = java.io.File(applicationContext.filesDir.parent, "app_flutter/adhans/adhan_$moezzinId.mp3")
                    val appFilesFile = java.io.File(applicationContext.filesDir, "adhans/adhan_$moezzinId.mp3")
                    if (appDocsFile.exists()) {
                        targetFilePath = appDocsFile.absolutePath
                    } else if (appFilesFile.exists()) {
                        targetFilePath = appFilesFile.absolutePath
                    }
                }

                if (!targetFilePath.isNullOrEmpty()) {
                    val file = java.io.File(targetFilePath)
                    if (file.exists()) {
                        Log.i(TAG, "Loading adhan from local file: $targetFilePath")
                        setDataSource(targetFilePath)
                        loaded = true
                    } else {
                        Log.w(TAG, "Local file not found: $targetFilePath. Falling back to built-in.")
                    }
                }

                // Fallback to built-in raw resource or System Alarm Ringtone
                if (!loaded) {
                    val resourceName = MOEZZIN_RESOURCES[moezzinId] ?: MOEZZIN_RESOURCES[DEFAULT_MOEZZIN]!!
                    val resId = resources.getIdentifier(resourceName, "raw", packageName)
                    if (resId != 0) {
                        Log.i(TAG, "Loading adhan from built-in resource: $resourceName")
                        val afd = resources.openRawResourceFd(resId)
                        setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                        afd.close()
                        loaded = true
                    } else {
                        Log.w(TAG, "Built-in resource $resourceName not found. Falling back to System Alarm Ringtone.")
                        val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                        if (alarmUri != null) {
                            setDataSource(applicationContext, alarmUri)
                            loaded = true
                        } else {
                            Log.e(TAG, "❌ Audio resource not found and no system alarm available. Stopping service.")
                            stopAdhan()
                            return
                        }
                    }
                }


                val targetVolume = volumeLevel / 100f
                if (ascendingVolume) {
                    setVolume(0f, 0f)
                    volumeAnimator = ValueAnimator.ofFloat(0f, targetVolume).apply {
                        duration = 30000 // 30 seconds
                        addUpdateListener { animator ->
                            val vol = animator.animatedValue as Float
                            mediaPlayer?.setVolume(vol, vol)
                        }
                        start()
                    }
                } else {
                    setVolume(targetVolume, targetVolume)
                }

                // If using fallback system ringtone, loop it so it behaves like an alarm rather than a 1-second beep
                if (!loaded || moezzinFilePath.isNullOrEmpty()) {
                    isLooping = true
                }

                setOnPreparedListener { player ->
                    Log.i(TAG, "🎵 MediaPlayer prepared. Starting playback...")
                    player.start()
                }

                setOnCompletionListener {
                    Log.i(TAG, "✅ Adhan playback completed for: $prayerName")
                    // Stop vibration and audio, but KEEP the notification visible on screen!
                    vibrator?.cancel()
                    vibrator = null
                    volumeAnimator?.cancel()
                    volumeAnimator = null
                    mediaPlayer?.release()
                    mediaPlayer = null
                    
                    // Auto dismiss notification after 5 minutes of idle time
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        stopAdhan()
                    }, 5 * 60 * 1000L)
                }

                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "❌ MediaPlayer error: what=$what, extra=$extra")
                    stopAdhan()
                    true
                }

                prepareAsync()
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to initialize MediaPlayer: ${e.message}", e)
            stopAdhan()
        }
    }

    private fun startVibration() {
        vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        val pattern = longArrayOf(0, 1000, 1000)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(android.os.VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 0)
        }
    }

    private fun stopAdhan() {
        Log.d(TAG, "Stopping adhan...")

        vibrator?.cancel()
        vibrator = null
        volumeAnimator?.cancel()
        volumeAnimator = null
        
        mediaPlayer?.let {
            try {
                if (it.isPlaying) it.stop()
                it.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing MediaPlayer: ${e.message}")
            }
        }
        mediaPlayer = null

        releaseResources()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    // ─────────────────────────────── WakeLock ───────────────────────────────

    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "Quran::AdhanPlaybackWakeLock"
        ).apply {
            setReferenceCounted(false)
            acquire(10 * 60 * 1000L) // 10 minutes max (adhan is ~5 min)
        }
        Log.d(TAG, "Playback WakeLock acquired")
    }

    private fun releaseResources() {
        // Release our own WakeLock
        wakeLock?.let {
            if (it.isHeld) it.release()
        }
        wakeLock = null

        // Release the AlarmReceiver's WakeLock
        AdhanAlarmReceiver.wakeLock?.let {
            if (it.isHeld) it.release()
        }
        AdhanAlarmReceiver.wakeLock = null

        Log.d(TAG, "All WakeLocks released")
    }

    // ─────────────────────────────── Notification ───────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "پخش اذان",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "نمایش وضعیت پخش اذان"
                setSound(null, null) // Sound is explicitly managed by MediaPlayer inside the service
                enableVibration(false) // Vibration is explicitly managed by Vibrator inside the service
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
            Log.d(TAG, "Notification channel created: $CHANNEL_ID")
        }
    }

    private fun startForegroundCompat(prayerName: String, wakeScreen: Boolean) {
        val notification = buildNotification(prayerName, wakeScreen)

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                // Android 14+ requires explicit foreground service type
                ServiceCompat.startForeground(
                    this,
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            // Explicitly notify SystemUI to guarantee immediate rendering on MIUI / HyperOS
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(NOTIFICATION_ID, notification)

            Log.d(TAG, "Foreground service started with notification")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start foreground with type. Retrying basic...", e)
            try {
                startForeground(NOTIFICATION_ID, notification)
                val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                manager.notify(NOTIFICATION_ID, notification)
            } catch (e2: Exception) {
                Log.e(TAG, "CRITICAL: Could not start foreground at all", e2)
            }
        }
    }

    private fun buildNotification(prayerName: String, wakeScreen: Boolean): Notification {
        // "Stop Adhan" action button
        val stopIntent = Intent(this, AdhanForegroundService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Tap notification → open the app
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openAppPendingIntent = PendingIntent.getActivity(
            this, 0, openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Collapsed view (heads-up & default)
        val collapsedLayout = RemoteViews(packageName, R.layout.custom_adhan_notification).apply {
            setTextViewText(R.id.notification_title, "اذان $prayerName")
            setTextViewText(R.id.notification_subtitle, "به افق تهران")
            setImageViewResource(R.id.btn_stop_adhan, R.drawable.ic_volume_off)
            setImageViewResource(R.id.icon_mosque, R.drawable.ic_mosque_gold)
            setOnClickPendingIntent(R.id.btn_stop_adhan, stopPendingIntent)
        }

        // Expanded view (when user pulls down notification)
        val expandedLayout = RemoteViews(packageName, R.layout.custom_adhan_notification_big).apply {
            setTextViewText(R.id.notification_title_big, "اذان $prayerName")
            setTextViewText(R.id.notification_subtitle_big, "به افق تهران")
            setImageViewResource(R.id.btn_stop_adhan_big, R.drawable.ic_volume_off)
            setImageViewResource(R.id.icon_mosque_big, R.drawable.ic_mosque_gold)
            setOnClickPendingIntent(R.id.btn_stop_adhan_big, stopPendingIntent)
        }

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("اذان $prayerName")
            .setContentText("به افق تهران")
            .setCustomContentView(collapsedLayout)
            .setCustomBigContentView(expandedLayout)
            .setCustomHeadsUpContentView(collapsedLayout)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setContentIntent(openAppPendingIntent)
            
        if (wakeScreen) {
            var canUseFullScreen = true
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                canUseFullScreen = notificationManager.canUseFullScreenIntent()
            }

            if (canUseFullScreen) {
                val fullScreenIntent = Intent(this, AdhanActivity::class.java).apply {
                    putExtra(EXTRA_PRAYER_NAME, prayerName)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                }
                val fullScreenPendingIntent = PendingIntent.getActivity(
                    this, 0, fullScreenIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                builder.setFullScreenIntent(fullScreenPendingIntent, true)
            }
        }
        
        return builder.build()
    }
}
