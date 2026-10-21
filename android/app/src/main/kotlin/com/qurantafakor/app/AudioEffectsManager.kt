package com.qurantafakor.app

import android.media.audiofx.PresetReverb
import android.media.audiofx.EnvironmentalReverb
import android.media.audiofx.Equalizer
import android.util.Log

/**
 * Manages native Android audio effects (Reverb / Echo & Equalizer) attached to the
 * Quran AudioPlayer's audioSessionId.
 */
class AudioEffectsManager {
    companion object {
        private const val TAG = "AudioEffectsManager"

        // Preset ID constants mapping to Android PresetReverb presets
        const val PRESET_NONE: Short = 0
        const val PRESET_SMALLROOM: Short = 1
        const val PRESET_MEDIUMROOM: Short = 2
        const val PRESET_LARGEROOM: Short = 3
        const val PRESET_MEDIUMHALL: Short = 4
        const val PRESET_LARGEHALL: Short = 5
        const val PRESET_PLATE: Short = 6
    }

    private var presetReverb: PresetReverb? = null
    private var environmentalReverb: EnvironmentalReverb? = null
    private var equalizer: Equalizer? = null
    private var currentSessionId: Int? = null
    private var isEnabled: Boolean = false
    private var isRadioFilterActive: Boolean = false
    private var currentPreset: Short = PRESET_LARGEHALL

    /**
     * Attaches or updates the reverb effect for the given audio session ID.
     */
    fun applyReverb(sessionId: Int, preset: Short, enabled: Boolean): Boolean {
        return try {
            if (sessionId <= 0) {
                Log.w(TAG, "Invalid audioSessionId: $sessionId")
                return false
            }

            // Disable radio equalizer when normal reverb is active
            if (enabled && isRadioFilterActive) {
                equalizer?.enabled = false
                isRadioFilterActive = false
            }

            if (presetReverb == null || currentSessionId != sessionId) {
                release()
                Log.d(TAG, "Creating PresetReverb for sessionId: $sessionId")
                presetReverb = PresetReverb(0, sessionId)
                currentSessionId = sessionId
            }

            currentPreset = preset
            isEnabled = enabled

            presetReverb?.let {
                it.preset = preset
                it.enabled = enabled
                Log.d(TAG, "Reverb applied: preset=$preset, enabled=$enabled, session=$sessionId")
            }
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to apply PresetReverb: ${e.message}", e)
            false
        }
    }

    /**
     * Attaches or updates the Vintage Radio Bandpass Equalizer filter for the given session ID.
     * Cuts low frequencies (< 300Hz), boosts mid presence (~1kHz - 2.5kHz), and cuts treble (> 4.5kHz).
     */
    fun applyRadioFilter(sessionId: Int, enabled: Boolean): Boolean {
        return try {
            if (sessionId <= 0) {
                Log.w(TAG, "Invalid audioSessionId for radio filter: $sessionId")
                return false
            }

            // Disable reverb when radio filter is active (radio has zero hall reflection)
            if (enabled) {
                presetReverb?.enabled = false
                isEnabled = false
            }

            if (equalizer == null || currentSessionId != sessionId) {
                equalizer?.let {
                    it.enabled = false
                    it.release()
                }
                equalizer = Equalizer(0, sessionId)
                currentSessionId = sessionId
            }

            isRadioFilterActive = enabled

            equalizer?.let { eq ->
                eq.enabled = enabled
                if (enabled) {
                    val numBands = eq.numberOfBands
                    val bandRange = eq.bandLevelRange
                    val minLevel = bandRange[0] // Typically -1500 mB (-15 dB)
                    val maxLevel = bandRange[1] // Typically +1500 mB (+15 dB)

                    for (band in 0 until numBands) {
                        val centerFreqHz = eq.getCenterFreq(band.toShort()) / 1000 // Convert mHz to Hz
                        val targetLevel: Short = when {
                            // Sub-bass & Bass (< 300Hz): Heavy cut for telephone/radio small speaker sound
                            centerFreqHz < 300 -> minLevel
                            // Low-mid (300Hz - 600Hz): Moderate cut
                            centerFreqHz in 300..600 -> (minLevel * 0.45f).toInt().toShort()
                            // Mid-range presence (601Hz - 2500Hz): Significant boost for vintage horn/radio presence
                            centerFreqHz in 601..2500 -> (maxLevel * 0.75f).toInt().toShort()
                            // High-mids (2501Hz - 4500Hz): Slight roll off
                            centerFreqHz in 2501..4500 -> (minLevel * 0.25f).toInt().toShort()
                            // High treble (> 4500Hz): Cut completely
                            else -> minLevel
                        }
                        eq.setBandLevel(band.toShort(), targetLevel)
                    }
                    Log.d(TAG, "Vintage radio equalizer applied on session $sessionId with $numBands bands")
                }
            }
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to apply radio equalizer: ${e.message}", e)
            false
        }
    }

    /**
     * Toggles effect on or off for the current session.
     */
    fun setEnabled(enabled: Boolean): Boolean {
        return try {
            isEnabled = enabled
            presetReverb?.enabled = enabled
            Log.d(TAG, "Reverb enabled set to: $enabled")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to toggle reverb: ${e.message}", e)
            false
        }
    }

    /**
     * Releases active audio effects to free hardware DSP resources.
     */
    fun release() {
        try {
            presetReverb?.let {
                it.enabled = false
                it.release()
            }
            presetReverb = null

            environmentalReverb?.let {
                it.enabled = false
                it.release()
            }
            environmentalReverb = null

            equalizer?.let {
                it.enabled = false
                it.release()
            }
            equalizer = null
            isRadioFilterActive = false

            currentSessionId = null
            Log.d(TAG, "Audio effects released")
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing audio effects: ${e.message}", e)
        }
    }
}
