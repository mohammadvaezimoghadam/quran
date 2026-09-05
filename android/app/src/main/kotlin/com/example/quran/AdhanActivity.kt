package com.example.quran

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.graphics.Color
import android.view.Gravity
import android.graphics.Typeface
import android.util.TypedValue
import android.view.View

/**
 * A simple native lock-screen activity that wakes up the device 
 * and shows a "Stop Adhan" button without loading Flutter.
 */
class AdhanActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        turnScreenOnAndKeyguardOff()

        val prayerName = intent.getStringExtra(AdhanForegroundService.EXTRA_PRAYER_NAME) ?: "اذان"

        // Build UI Programmatically
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#121212")) // Dark background
        }

        val title = TextView(this).apply {
            text = "🕌 اذان $prayerName"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 32f)
            setTypeface(null, Typeface.BOLD)
            setPadding(0, 0, 0, 80)
        }
        
        val subtitle = TextView(this).apply {
            text = "در حال پخش اذان..."
            setTextColor(Color.LTGRAY)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
            setPadding(0, 0, 0, 120)
        }

        val stopButton = Button(this).apply {
            text = "قطع اذان"
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#D32F2F")) // Red button
            setPadding(60, 40, 60, 40)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
            setTypeface(null, Typeface.BOLD)
            setOnClickListener {
                val stopIntent = Intent(this@AdhanActivity, AdhanForegroundService::class.java).apply {
                    action = AdhanForegroundService.ACTION_STOP
                }
                startService(stopIntent)
                finish()
            }
        }

        layout.addView(title)
        layout.addView(subtitle)
        layout.addView(stopButton)

        setContentView(layout)
    }

    private fun turnScreenOnAndKeyguardOff() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}
