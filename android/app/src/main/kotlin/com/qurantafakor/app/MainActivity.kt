package com.qurantafakor.app

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Main Activity for the Quran app.
 *
 * Extends AudioServiceActivity (required by audio_service package for
 * background Quran audio playback).
 */
class MainActivity : AudioServiceActivity() {
    private val appControlChannelName = "com.qurantafakor.app/app_control"
    private val audioEffectsChannelName = "com.qurantafakor.app/audio_effects"
    private val audioEffectsManager = AudioEffectsManager()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // App Control Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appControlChannelName).setMethodCallHandler { call, result ->
            if (call.method == "restartApp") {
                result.success(true)
                RestartActivity.restartApp(this)
            } else {
                result.notImplemented()
            }
        }

        // Native Audio Effects (Reverb / Echo) Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, audioEffectsChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "applyReverb" -> {
                    val sessionId = call.argument<Int>("sessionId") ?: 0
                    val preset = (call.argument<Int>("preset") ?: 5).toShort()
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val success = audioEffectsManager.applyReverb(sessionId, preset, enabled)
                    result.success(success)
                }
                "applyRadioFilter" -> {
                    val sessionId = call.argument<Int>("sessionId") ?: 0
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val success = audioEffectsManager.applyRadioFilter(sessionId, enabled)
                    result.success(success)
                }
                "setEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val success = audioEffectsManager.setEnabled(enabled)
                    result.success(success)
                }
                "release" -> {
                    audioEffectsManager.release()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        audioEffectsManager.release()
        super.onDestroy()
    }
}
