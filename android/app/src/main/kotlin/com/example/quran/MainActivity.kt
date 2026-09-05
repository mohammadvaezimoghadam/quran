package com.example.quran

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Main Activity for the Quran app.
 *
 * Extends AudioServiceActivity (required by audio_service package for
 * background Quran audio playback) and adds a MethodChannel for
 * adhan-related native operations.
 *
 * MethodChannel Methods:
 * - scheduleAdhanAlarms(String alarmsJson): Schedule exact alarms
 * - cancelAllAdhanAlarms(): Cancel all scheduled alarms
 * - openAutoStartSettings(): Open Xiaomi/Huawei auto-start settings
 * - requestIgnoreBatteryOptimizations(): Request battery exemption
 * - isIgnoringBatteryOptimizations(): Check battery exemption status
 * - canScheduleExactAlarms(): Check if exact alarms are allowed
 * - requestExactAlarmPermission(): Open exact alarm settings (Android 12+)
 */
class MainActivity : AudioServiceActivity() {

    companion object {
        private const val TAG = "MainActivity"
        private const val ADHAN_METHOD_CHANNEL = "com.example.quran/adhan"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ADHAN_METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            Log.d(TAG, "MethodChannel call: ${call.method}")

            when (call.method) {
                // ──────────── Alarm Scheduling ────────────
                "scheduleAdhanAlarms" -> {
                    val alarmsJson = call.argument<String>("alarmsJson")
                    if (alarmsJson.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "alarmsJson is required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        AdhanAlarmScheduler.scheduleAlarms(this, alarmsJson)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to schedule alarms: ${e.message}", e)
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }

                "cancelAllAdhanAlarms" -> {
                    try {
                        AdhanAlarmScheduler.cancelAllAlarms(this)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to cancel alarms: ${e.message}", e)
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }

                // ──────────── Battery Optimization ────────────
                "requestIgnoreBatteryOptimizations" -> {
                    requestIgnoreBatteryOptimizations()
                    result.success(true)
                }

                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }

                // ──────────── Exact Alarm Permission (Android 12+) ────────────
                "canScheduleExactAlarms" -> {
                    result.success(canScheduleExactAlarms())
                }

                "requestExactAlarmPermission" -> {
                    requestExactAlarmPermission()
                    result.success(true)
                }

                // ──────────── Overlay / Display Over Apps Permission ────────────
                "canDrawOverlays" -> {
                    result.success(canDrawOverlays())
                }

                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }

                // ──────────── Instant Test Adhan ────────────
                "triggerTestAdhanNow" -> {
                    try {
                        val volumeLevel = call.argument<Int>("volumeLevel") ?: 100
                        val vibrate = call.argument<Boolean>("vibrate") ?: true
                        val playInSilentMode = call.argument<Boolean>("playInSilentMode") ?: true
                        val ascendingVolume = call.argument<Boolean>("ascendingVolume") ?: false
                        val moezzinId = call.argument<String>("moezzinId") ?: "ghalvash"
                        val moezzinFilePath = call.argument<String>("moezzinFilePath")

                        val intent = Intent(this, AdhanForegroundService::class.java).apply {
                            action = AdhanForegroundService.ACTION_PLAY
                            putExtra(AdhanForegroundService.EXTRA_PRAYER_NAME, "اذان (تست فوری)")
                            putExtra(AdhanForegroundService.EXTRA_MOEZZIN_ASSET, moezzinId)
                            putExtra(AdhanForegroundService.EXTRA_MOEZZIN_FILE_PATH, moezzinFilePath)
                            putExtra(AdhanForegroundService.EXTRA_VOLUME_LEVEL, volumeLevel)
                            putExtra(AdhanForegroundService.EXTRA_VIBRATE, vibrate)
                            putExtra(AdhanForegroundService.EXTRA_PLAY_IN_SILENT_MODE, playInSilentMode)
                            putExtra(AdhanForegroundService.EXTRA_ASCENDING_VOLUME, ascendingVolume)
                            putExtra(AdhanForegroundService.EXTRA_WAKE_SCREEN, true)
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to start test adhan service: ${e.message}", e)
                        result.error("TEST_ERROR", e.message, null)
                    }
                }

                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success(true)
                }

                // ──────────── Auto-Start Settings (Xiaomi/Huawei/Oppo) ────────────
                "openAutoStartSettings" -> {
                    openAutoStartSettings()
                    result.success(true)
                }

                // ──────────── General App Settings ────────────
                "openAppSettings" -> {
                    openAppSettings()
                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openNotificationSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                }
                startActivity(intent)
            } catch (e: Exception) {
                openAppSettings()
            }
        } else {
            openAppSettings()
        }
    }

    // ─────────────────────────────── Battery Optimization ───────────────────────────────

    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            return powerManager.isIgnoringBatteryOptimizations(packageName)
        }
        return true // Not applicable on older devices
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                }
                startActivity(intent)
                Log.i(TAG, "Opened battery optimization settings")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to open battery settings: ${e.message}", e)
                // Fallback to general battery settings
                try {
                    startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                } catch (e2: Exception) {
                    Log.e(TAG, "Fallback also failed: ${e2.message}", e2)
                }
            }
        }
    }

    // ─────────────────────────────── Exact Alarm Permission ───────────────────────────────

    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            return alarmManager.canScheduleExactAlarms()
        }
        return true // Not restricted on older devices
    }

    private fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    data = Uri.parse("package:$packageName")
                }
                startActivity(intent)
                Log.i(TAG, "Opened exact alarm permission settings")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to open exact alarm settings: ${e.message}", e)
                openAppSettings()
            }
        }
    }

    // ─────────────────────────────── Overlay / Display Over Apps ───────────────────────────────

    private fun canDrawOverlays(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Settings.canDrawOverlays(this)) {
                return true
            }

            // MIUI / HyperOS AppOps Fallback for Xiaomi/Redmi/Poco
            val isXiaomi = Build.MANUFACTURER.contains("xiaomi", ignoreCase = true) ||
                           Build.MANUFACTURER.contains("redmi", ignoreCase = true) ||
                           Build.MANUFACTURER.contains("poco", ignoreCase = true)
            if (isXiaomi) {
                try {
                    val appOps = getSystemService(Context.APP_OPS_SERVICE) as android.app.AppOpsManager
                    val modeStr = appOps.checkOpNoThrow(
                        "android:system_alert_window",
                        android.os.Process.myUid(),
                        packageName
                    )
                    if (modeStr == android.app.AppOpsManager.MODE_ALLOWED) {
                        return true
                    }

                    val checkOpMethod = appOps.javaClass.getMethod(
                        "checkOpNoThrow",
                        Int::class.javaPrimitiveType,
                        Int::class.javaPrimitiveType,
                        String::class.java
                    )
                    val op24Mode = checkOpMethod.invoke(appOps, 24, android.os.Process.myUid(), packageName) as Int
                    if (op24Mode == android.app.AppOpsManager.MODE_ALLOWED) {
                        return true
                    }

                    val op10021Mode = checkOpMethod.invoke(appOps, 10021, android.os.Process.myUid(), packageName) as Int
                    if (op10021Mode == android.app.AppOpsManager.MODE_ALLOWED) {
                        return true
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "MIUI AppOps overlay check failed: ${e.message}")
                }
            }

            return false
        }
        return true
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val isXiaomi = Build.MANUFACTURER.contains("xiaomi", ignoreCase = true) ||
                           Build.MANUFACTURER.contains("redmi", ignoreCase = true) ||
                           Build.MANUFACTURER.contains("poco", ignoreCase = true)

            if (isXiaomi) {
                // Prioritize Xiaomi MIUI specific "Other Permissions" (سایر مجوزها) Activity
                try {
                    val intent = Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                        setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
                        putExtra("extra_pkgname", packageName)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    Log.i(TAG, "Opened MIUI permissions editor for overlay (Xiaomi)")
                    return
                } catch (e: Exception) {
                    Log.w(TAG, "MIUI overlay intent failed: ${e.message}")
                }
            }

            // Standard package-specific overlay intent
            try {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                ).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                Log.i(TAG, "Opened overlay permission settings (package uri)")
                return
            } catch (e: Exception) {
                Log.w(TAG, "Attempt failed for overlay intent: ${e.message}")
            }

            // Fallback: MIUI Permissions Editor Activity
            try {
                val intent = Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                    setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
                    putExtra("extra_pkgname", packageName)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                Log.i(TAG, "Opened MIUI permissions editor fallback")
                return
            } catch (e: Exception) {
                Log.w(TAG, "MIUI overlay fallback failed: ${e.message}")
            }

            // General App Settings fallback
            openAppSettings()
        }
    }

    // ─────────────────────────────── Auto-Start (OEM-Specific) ───────────────────────────────

    /**
     * Attempts to open the auto-start management page for various OEMs.
     * This is critical for Xiaomi (MIUI/HyperOS), Huawei (EMUI), Oppo (ColorOS),
     * Vivo (FuntouchOS), etc. Without auto-start enabled, these OEMs will
     * kill the app's background processes and prevent alarms from firing.
     *
     * Ported directly from payam_mobile's working implementation.
     */
    private fun openAutoStartSettings() {
        val autoStartIntents = listOf(
            // Xiaomi MIUI / HyperOS
            Intent().setClassName(
                "com.miui.securitycenter",
                "com.miui.permcenter.autostart.AutoStartManagementActivity"
            ),
            // Xiaomi fallback
            Intent("miui.intent.action.OP_AUTO_START").addCategory(Intent.CATEGORY_DEFAULT),
            // Huawei EMUI
            Intent().setClassName(
                "com.huawei.systemmanager",
                "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
            ),
            // Huawei fallback
            Intent().setClassName(
                "com.huawei.systemmanager",
                "com.huawei.systemmanager.optimize.process.ProtectActivity"
            ),
            // Oppo ColorOS
            Intent().setClassName(
                "com.coloros.safecenter",
                "com.coloros.safecenter.startupapp.StartupAppListActivity"
            ),
            // Oppo fallback
            Intent().setClassName(
                "com.oppo.safe",
                "com.oppo.safe.permission.startup.StartupAppListActivity"
            ),
            // Vivo FuntouchOS
            Intent().setClassName(
                "com.vivo.permissionmanager",
                "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
            ),
            // Samsung (One UI auto-start management)
            Intent().setClassName(
                "com.samsung.android.lool",
                "com.samsung.android.sm.battery.ui.BatteryActivity"
            ),
            // Asus ZenUI
            Intent().setClassName(
                "com.asus.mobilemanager",
                "com.asus.mobilemanager.MainActivity"
            ),
            // Letv / LeEco
            Intent().setClassName(
                "com.letv.android.letvsafe",
                "com.letv.android.letvsafe.AutobootManageActivity"
            )
        )

        for (intent in autoStartIntents) {
            try {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                Log.i(TAG, "Opened auto-start settings: ${intent.component?.className}")
                return
            } catch (e: Exception) {
                // Try next OEM intent
                Log.d(TAG, "Auto-start intent failed: ${intent.component?.className}")
            }
        }

        // Final fallback: open general app settings
        Log.w(TAG, "No OEM auto-start activity found. Opening general app settings.")
        openAppSettings()
    }

    // ─────────────────────────────── General App Settings ───────────────────────────────

    private fun openAppSettings() {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open app settings: ${e.message}", e)
        }
    }
}
