# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application classes
-keep class com.dhikrapp.qurantracker.** { *; }

# SQLite
-keep class androidx.sqlite.** { *; }
-keep class com.tekartik.sqflite.** { *; }

# Keep notification classes
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# Play Core - ignore missing classes (not needed for basic app)
-dontwarn com.google.android.play.core.**
-ignorewarnings
