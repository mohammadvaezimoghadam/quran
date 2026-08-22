# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Just Audio, Audio Service & Audio Session
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.audio_session.** { *; }

# Google ExoPlayer & AndroidX Media3 (Crucial for audio playback in Release mode!)
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn com.google.android.exoplayer2.**
-dontwarn androidx.media3.**

# Android Native Media & Audio Focus
-keep class android.media.** { *; }
-keep class android.support.v4.media.** { *; }
-keep class androidx.media.** { *; }

# Preserve reflectively accessed methods in ExoPlayer audio decoders
-keepclassmembers class * extends com.google.android.exoplayer2.audio.AudioDecoder {
    public <init>(...);
}
-keepclassmembers class * extends androidx.media3.decoder.CryptoConfig {
    public <init>(...);
}
