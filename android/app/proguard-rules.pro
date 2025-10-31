# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# video_player: Prevent stripping
-keep class io.flutter.plugins.videoplayer.** { *; }
-keep class com.pichillilorenzo.** { *; }

# ExoPlayer (used by video_player)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# === FIX FOR R8 MISSING CLASSES ===
# Keep Play Core & Deferred Components (Flutter uses them even if not enabled)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**